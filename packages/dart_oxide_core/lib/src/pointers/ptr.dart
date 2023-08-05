import 'dart:async';

import 'package:dart_oxide_core/types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stack_trace/stack_trace.dart';

part 'ptr.freezed.dart';

() _unitFn(void _) => ();

/// An interface for defining a class that can be disposed. Accessing an [IDisposable] after calling [dispose], including calling [dispose] again, is undefined behavior.
abstract interface class IAsyncDisposable<U extends FutureOr<()>> {
  /// Disposes the object, preventing further use.
  /// Return type is FutureOr<()> to allow unification with [IDisposable]; always treat it as a future.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  U dispose();
}

typedef IDisposable = IAsyncDisposable<()>;

@Freezed(copyWith: false)
class _BoxFinalizable<T> with _$_BoxFinalizable<T> {
  const _BoxFinalizable._();

  const factory _BoxFinalizable({
    required T value,
    required void Function(T) onFinalize,
  }) = _BoxFinalizableImpl;

  void finalize() => onFinalize(value);
}

@unfreezed
class _CountedBoxFinalizable<T>
    with _$_CountedBoxFinalizable<T>
    implements _BoxFinalizable<T> {
  const _CountedBoxFinalizable._();

  factory _CountedBoxFinalizable({
    @freezed required T value,
    @freezed required final void Function(T) onFinalize,
    @freezed required final Ptr<int> count,
    required bool isFinalized,
  }) = _CountedBoxFinalizableImpl;

  @override
  void finalize() {
    if (!isFinalized) {
      isFinalized = true;
      count.value--;
      if (count.value == 0) {
        onFinalize(value);
      }
    }
  }
}

/// Protects a value that needs to be disposed, and tracks whether or not it has been disposed.
/// [()] is used instead of [void] to prevent collections from unifying to [void] instead of [FutureOr<void>].
@internal
abstract final class BaseBox<T, U extends FutureOr<()>>
    implements IAsyncDisposable<U> {
  static final Finalizer<_BoxFinalizable<dynamic>> _finalizer =
      Finalizer((value) => value.finalize());
  T? _value;
  final U Function(T) _drop;

  late Trace _disposedTrace;
  late DateTime _disposedTime;

  _BoxFinalizable<T> _createFinalizable();

  BaseBox(
    T value, {
    required U Function(T) onDispose,

    /// Attach this box to a finalizer, which will call [onDispose]
    /// on the stored [value] when the the box becomes unreachable and
    /// the finalizer is run.
    bool finalize = true,
  })  : _value = value,
        _drop = onDispose {
    if (finalize) {
      _finalizer.attach(
        this,
        _createFinalizable(),
        detach: this,
      );
    }
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String get _errorMsg =>
      'cannot use object after being disposed: $T first disposed at $_disposedTime from $_disposedTrace';

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  @doNotStore
  T unwrap() => _value ??= throw StateError(_errorMsg);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  @doNotStore
  T expect(
    String error, {
    bool includeTrace = false,
    bool includeDisposeTime = false,
  }) =>
      _value ??= switch ((includeTrace, includeDisposeTime)) {
        (true, true) => throw StateError(
            '$error: $_errorMsg',
          ),
        (true, false) => throw StateError(
            '$error: $T first disposed from $_disposedTrace',
          ),
        (false, true) => throw StateError(
            '$error: $T first disposed at $_disposedTime',
          ),
        (false, false) => throw StateError(error),
      };

  /// Returns a result containing the return value of the provided function if the object, or a [StateError] if the object is disposed.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  @doNotStore
  Result<T, StateError> get wrapped {
    final value = this._value;
    return value != null ? Result.ok(value) : Result.err(StateError(_errorMsg));
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  T _dispose() {
    final value = unwrap();
    _finalizer.detach(this);
    _value = null;
    _disposedTime = DateTime.now();
    _disposedTrace = Trace.current();
    return value;
  }

  /// Disposes the protected object, preventing further use.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @override
  U dispose() => _drop(_dispose());
}

final class Box<T, U extends FutureOr<()>> extends BaseBox<T, U> {
  Box(super.value, {required super.onDispose, super.finalize}) : super();

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Box<T, ()> value<T>(T value) => Box(
        value,
        onDispose: _unitFn,
        finalize: false,
      );

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Box<T, ()> fromDisposable<T extends IDisposable>(
    T value, {
    bool finalize = true,
  }) =>
      Box(
        value,
        onDispose: (T v) => v.dispose(),
        finalize: finalize,
      );

  static Box<T, U> fromAsyncDisposable<T extends IAsyncDisposable<U>,
          U extends FutureOr<()>>(
    T value, {
    bool finalize = true,
  }) =>
      Box(
        value,
        onDispose: (T v) => v.dispose(),
        finalize: finalize,
      );

  @override
  _BoxFinalizable<T> _createFinalizable() => _BoxFinalizable(
        value: unwrap(),
        onFinalize: _drop,
      );
}

final class Rc<T, U extends FutureOr<()>> extends BaseBox<T, U>
    implements IAsyncDisposable<U> {
  Ptr<int> _count = Ptr(1);
  final bool _finalize;

  Rc(super.value, {required super.onDispose, super.finalize})
      : _finalize = finalize,
        super();

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Rc<T, ()> fromDisposable<T extends IDisposable>(
    T value, {
    bool finalize = true,
  }) =>
      Rc<T, ()>(
        value,
        onDispose: (v) => v.dispose(),
        finalize: finalize,
      );

  static Rc<T, U> fromAsyncDisposable<T extends IAsyncDisposable<U>,
          U extends FutureOr<()>>(
    T value, {
    bool finalize = true,
  }) =>
      Rc<T, U>(
        value,
        onDispose: (v) => v.dispose(),
        finalize: finalize,
      );

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Rc<T, ()> value<T>(T value) => Rc(
        value,
        onDispose: _unitFn,
        finalize: false,
      );

  Rc._cloned(
    super.value,
    Ptr<int> count, {
    required super.onDispose,
    required super.finalize,
  })  : _count = count,
        _finalize = finalize;

  @override
  _BoxFinalizable<T> _createFinalizable() => _CountedBoxFinalizable(
        value: unwrap(),
        onFinalize: _drop,
        count: _count,
        isFinalized: false,
      );

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Rc<T, U> clone() {
    final value = unwrap();
    _count.value++;

    return Rc._cloned(
      value,
      _count,
      onDispose: _drop,
      finalize: _finalize,
    );
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @override
  U dispose() {
    _count.value--;

    final value = _dispose();

    if (_count.value == 0) {
      return _drop(value);
    } else {
      // this is a bit sketchy, but it appears to work
      if (U == Unit) {
        return () as U;
      } else {
        return Future.value(()) as U;
      }
    }
  }
}

class Ptr<T> {
  T value;

  Ptr(this.value);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Box<T, ()> toBox() => Box.value(value);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Rc<T, ()> toRc() => Rc.value(value);
}
