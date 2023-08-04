import 'dart:async';

import 'package:dart_oxide_core/types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stack_trace/stack_trace.dart';

part 'ptr.freezed.dart';

/// An interface for defining a class that can be disposed asynchronously. Accessing an [IDisposable] after calling [dispose], including calling [dispose] again, is undefined behavior.
abstract interface class IAsyncDisposable {
  /// Disposes the object, preventing further use.
  /// Return type is FutureOr<()> to allow unification with [IDisposable]; always treat it as a future.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  FutureOr<()> dispose();
}

/// An interface for defining a class that can be disposed synchronously. Accessing an [ISyncDisposable] after calling [dispose], including calling [dispose] again, is undefined behavior.
abstract interface class IDisposable implements IAsyncDisposable {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @override
  () dispose();
}

() _unitFn(void _) => ();

@freezed
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
    if (count.value <= 0 && !isFinalized) {
      isFinalized = true;
      onFinalize(value);
    }
  }
}

/// Protects a value that needs to be disposed, and tracks whether or not it has been disposed.
/// [()] is used instead of [void] to prevent collections from unifying to [void] instead of [FutureOr<void>].
abstract final class BaseBox<T, U extends FutureOr<()>>
    implements IAsyncDisposable {
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

final class AsyncBox<T, U extends FutureOr<()>> extends BaseBox<T, U> {
  AsyncBox._(super.value, {required super.onDispose, super.finalize});

  @override
  _BoxFinalizable<T> _createFinalizable() => _BoxFinalizable(
        value: unwrap(),
        onFinalize: _drop,
      );
}

final class Box<T> extends AsyncBox<T, ()> implements IDisposable {
  Box(super.value, {required super.onDispose, super.finalize}) : super._();

  static AsyncBox<T, U> async<T, U extends FutureOr<()>>(
    T value, {
    required U Function(T) onDispose,
    bool finalize = true,
  }) =>
      AsyncBox._(value, onDispose: onDispose, finalize: finalize);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Box<T> value<T>(T value) => Box(
        value,
        onDispose: _unitFn,
        finalize: false,
      );

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static AsyncBox<T, FutureOr<()>>
      fromAsyncDisposable<T extends IAsyncDisposable>(
    T value, {
    bool finalize = true,
  }) =>
          AsyncBox<T, FutureOr<()>>._(
            value,
            onDispose: (v) async => await v.dispose(),
            finalize: finalize,
          );

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Box<T> fromDisposable<T extends IDisposable>(
    T value, {
    bool finalize = true,
  }) =>
      Box<T>(
        value,
        onDispose: (T v) => v.dispose(),
        finalize: finalize,
      );
}

final class AsyncRc<T, U extends FutureOr<()>> extends BaseBox<T, U> {
  Ptr<int> _count = Ptr(1);
  final bool _finalize;

  AsyncRc._(super.value, {required super.onDispose, super.finalize})
      : _finalize = finalize;

  AsyncRc._cloned(
    super.value,
    Ptr<int> count, {
    required super.onDispose,
    super.finalize,
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
  AsyncRc<T, U> clone() {
    final value = unwrap();
    _count.value++;

    return AsyncRc._cloned(
      value,
      _count,
      onDispose: _drop,
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

final class Rc<T> extends AsyncRc<T, ()> implements IDisposable {
  Rc(super.value, {required super.onDispose, super.finalize}) : super._();

  static AsyncRc<T, U> async<T, U extends FutureOr<()>>(
    T value, {
    required U Function(T) onDispose,
    bool finalize = true,
  }) =>
      AsyncRc._(
        value,
        onDispose: onDispose,
        finalize: finalize,
      );

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static AsyncRc<T, FutureOr<()>>
      fromAsyncDisposable<T extends IAsyncDisposable>(
    T value, {
    bool finalize = true,
  }) =>
          AsyncRc<T, FutureOr<()>>._(
            value,
            onDispose: (v) async => await v.dispose(),
            finalize: finalize,
          );

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Rc<T> fromDisposable<T extends IDisposable>(
    T value, {
    bool finalize = true,
  }) =>
      Rc<T>(
        value,
        onDispose: (v) => v.dispose(),
        finalize: finalize,
      );

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Rc<T> value<T>(T value) => Rc(
        value,
        onDispose: _unitFn,
        finalize: false,
      );

  Rc._cloned(
    super.value,
    super.count, {
    required super.onDispose,
    super.finalize,
  }) : super._cloned();

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @override
  @useResult
  Rc<T> clone() {
    final value = unwrap();
    _count.value++;

    return Rc._cloned(
      value,
      _count,
      onDispose: _drop,
      finalize: _finalize,
    );
  }
}

class Ptr<T> {
  T value;

  Ptr(this.value);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Box<T> toBox() => Box.value(value);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Rc<T> toRc() => Rc.value(value);
}
