import 'dart:async';

import 'package:dart_oxide_core/types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stack_trace/stack_trace.dart';

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

/// Protects a value that needs to be disposed, and tracks whether or not it has been disposed.
/// [()] is used instead of [void] to prevent collections from unifying to [void] instead of [FutureOr<void>].
final class Box<T, U extends FutureOr<()>> implements IAsyncDisposable {
  // TODO::figure out how to make this work with a Finalizer (or if that would even be beneficial)

  T? _value;
  final U Function(T) _drop;

  late Trace _disposedTrace;
  late DateTime _disposedTime;

  Box(
    T value, {
    required U Function(T) onDispose,
  })  : _value = value,
        _drop = onDispose;

  static Box<T, ()> value<T>(T value) => Box(
        value,
        onDispose: _unitFn,
      );

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Box<T, FutureOr<()>> fromAsyncDisposable<T extends IAsyncDisposable>(
    T value,
  ) =>
      Box<T, FutureOr<()>>(
        value,
        onDispose: (v) async => await v.dispose(),
      );

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Box<T, ()> fromDisposable<T extends IDisposable>(
    T value,
  ) =>
      Box<T, ()>(
        value,
        onDispose: (v) => v.dispose(),
      );

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

final class BoxMut<T, U extends FutureOr<()>> extends Box<T, U> {
  BoxMut(super.value, {required super.onDispose});

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static BoxMut<T, ()> value<T>(T value) => BoxMut(
        value,
        onDispose: _unitFn,
      );

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static BoxMut<T, FutureOr<()>>
      fromAsyncDisposable<T extends IAsyncDisposable>(
    T value,
  ) =>
          BoxMut<T, FutureOr<()>>(
            value,
            onDispose: (v) async => await v.dispose(),
          );

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static BoxMut<T, ()> fromDisposable<T extends IDisposable>(
    T value,
  ) =>
      BoxMut<T, ()>(
        value,
        onDispose: (v) => v.dispose(),
      );

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Result<(), StateError> mutate(T value) => _value == null
      ? Result.err(StateError(_errorMsg))
      : Result<T, StateError>.ok(_value = value).map((p0) => ());
}

final class Rc<T, U extends FutureOr<()>> extends Box<T, U> {
  Ptr<int> _count = Ptr(1);

  Rc(super.value, {required super.onDispose});

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Rc<T, FutureOr<()>> fromAsyncDisposable<T extends IAsyncDisposable>(
    T value,
  ) =>
      Rc<T, FutureOr<()>>(
        value,
        onDispose: (v) async => await v.dispose(),
      );

  Rc._cloned(super.value, Ptr<int> count, {required super.onDispose})
      : _count = count;

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Rc<T, ()> fromDisposable<T extends IDisposable>(
    T value,
  ) =>
      Rc<T, ()>(
        value,
        onDispose: (v) => v.dispose(),
      );

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Rc<T, ()> value<T>(T value) => Rc(
        value,
        onDispose: _unitFn,
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
  BoxMut<T, ()> toBoxMut() => BoxMut.value(value);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Box<T, ()> toBox() => Box.value(value);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Rc<T, ()> toRc() => Rc.value(value);
}
