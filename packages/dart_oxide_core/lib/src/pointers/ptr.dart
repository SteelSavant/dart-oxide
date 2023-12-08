import 'dart:async';

import 'package:dart_oxide_core/types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:synchronized/synchronized.dart';

part 'ptr.freezed.dart';

() _unitFn(final void _) => ();

class AlreadyLockedError extends StateError {
  AlreadyLockedError() : super('lock is already held');
}

class AlreadyDisposedError extends StateError {
  AlreadyDisposedError([final String? msg])
      : super(msg ?? 'object is already disposed');
}

/// An interface for defining a class that can be disposed, (possibly) asynchronously.
///
/// # Undefined Behavior
///
/// Accessing an [IDisposable] after calling [dispose], including calling [dispose]
/// again, is undefined behavior.
abstract interface class IFutureDisposable<U extends FutureOr<()>> {
  /// Disposes the object, preventing further use.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  U dispose();
}

/// An interface for defining a class that can be disposed synchronously.
///
/// # Undefined Behavior
///
/// Accessing an [IDisposable] after calling [this.dispose], including calling [this.dispose]
/// again, is undefined behavior.
typedef IDisposable = IFutureDisposable<()>;

@Freezed(copyWith: false)
class _BoxFinalizable<T> with _$_BoxFinalizable<T> {
  const factory _BoxFinalizable({
    required final T value,
    required final void Function(T) onFinalize,
  }) = _BoxFinalizableImpl;
  const _BoxFinalizable._();

  void finalize() => onFinalize(value);
}

@unfreezed
class _CountedBoxFinalizable<T>
    with _$_CountedBoxFinalizable<T>
    implements _BoxFinalizable<T> {
  factory _CountedBoxFinalizable({
    required final T value,
    required final void Function(T) onFinalize,
    required final Ptr<int> count,
    // ignore: prefer_final_parameters
    required bool isFinalized,
  }) = _CountedBoxFinalizableImpl;
  const _CountedBoxFinalizable._();

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

/// Base implementation for (relatively) smart pointers. Provides a common
/// interface for accessing the protected object, and disposing the object,
/// as well as a common implementation for attaching a finalizer.
///
/// [()] is used instead of [void] to prevent collections from unifying to [void] instead of [FutureOr<void>].
@internal
abstract final class BaseBox<T extends Object, U extends FutureOr<()>>
    implements IFutureDisposable<U> {
  static final Finalizer<_BoxFinalizable<dynamic>> _finalizer =
      Finalizer((final value) => value.finalize());
  T? _value;
  final U Function(T) _drop;

  late Trace _disposedTrace;
  late DateTime _disposedTime;

  _BoxFinalizable<T> _createFinalizable();

  BaseBox(
    final T value, {
    required final U Function(T) onDispose,

    /// Attach this box to a finalizer, which will call [onDispose]
    /// on the stored [value] when the the box becomes unreachable and
    /// the finalizer is run.
    final bool finalize = true,
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
  T _unwrap() => _value ??= throw AlreadyDisposedError(_errorMsg);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  T _dispose() {
    final value = _unwrap();
    _finalizer.detach(this);
    _value = null;
    _disposedTime = DateTime.now();
    _disposedTrace = Trace.current();
    return value;
  }

  /// Disposes this box the protected object, preventing further use.
  ///
  /// # Throws
  ///
  /// Throws a [AlreadyDisposedError] if the object has already been disposed.
  ///
  /// # Examples
  ///
  /// ```
  /// final box = Box(1);
  /// box.dispose();
  /// box.unwrap(); // throws AlreadyDisposedError
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @override
  U dispose() => _drop(_dispose());
}

@internal
base mixin BaseBoxValueMixin<T extends Object, U extends FutureOr<()>>
    on BaseBox<T, U> {
  /// Returns a [Result] containing the protected object, or a [AlreadyDisposedError] if the object is disposed.
  ///
  /// # Examples
  ///
  /// ```
  /// final box = Box(1);
  /// final result = box.tryValue();
  /// assert(result.isOk);
  ///
  /// box.dispose();
  /// final result2 = box.tryValue();
  /// assert(result2.isErr);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  @doNotStore
  Result<T, StateError> tryValue() {
    final value = this._value;
    return value != null
        ? Result.ok(value)
        : Result.err(AlreadyDisposedError(_errorMsg));
  }

  /// Returns the protected object, or throws a [AlreadyDisposedError] if the object is disposed.
  ///
  /// # Throws
  ///
  /// Throws a [AlreadyDisposedError] if the object is disposed.
  ///
  /// # Examples
  ///
  /// ```
  /// final box = Box(1);
  /// assert(box.unwrap() == 1);
  ///
  /// box.dispose();
  /// box.unwrap(); // throws AlreadyDisposedError
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  @doNotStore
  T unwrap() => _unwrap();

  /// Returns the protected object, or throws a [AlreadyDisposedError] with the provided
  /// [msg]. If [includeTrace] is true, the stack trace of the first call to
  /// [dispose] will be included in the error message. If [includeDisposeTime]
  /// is true, the time of the first call to [dispose] will be included in
  /// the error message.
  ///
  /// # Throws
  ///
  /// Throws a [AlreadyDisposedError] if the object has already been disposed.
  ///
  /// # Examples
  ///
  /// ```
  /// final box = Box(1);
  /// assert(box.expect('box is not disposed') == 1);
  /// box.dispose();
  /// box.expect('box is not disposed'); // throws AlreadyDisposedError
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  @doNotStore
  T expect(
    final String msg, {
    final bool includeTrace = false,
    final bool includeDisposeTime = false,
  }) =>
      _value ??= switch ((includeTrace, includeDisposeTime)) {
        (true, true) => throw AlreadyDisposedError(
            '$msg: $_errorMsg',
          ),
        (true, false) => throw AlreadyDisposedError(
            '$msg: $T first disposed from $_disposedTrace',
          ),
        (false, true) => throw AlreadyDisposedError(
            '$msg: $T first disposed at $_disposedTime',
          ),
        (false, false) => throw AlreadyDisposedError(msg),
      };
}

/// Protects a value that needs to be disposed, and tracks whether or not it has been disposed.
final class Box<T extends Object, U extends FutureOr<()>> extends BaseBox<T, U>
    with BaseBoxValueMixin<T, U> {
  /// Creates a new [Box] that points to the provided value. When this box is disposed,
  /// [super.onDispose] will be called on [tryValue]. If [super.finalize] is true, this [Box]
  /// will be attached to a finalizer, which will dispose this [Box] when it becomes unreachable.
  ///
  /// Due to the nature of [Finalizer], [super.onDispose] is not guaranteed to be invoked.
  Box(super.value, {required super.onDispose, super.finalize}) : super();

  /// Creates a new [Box] that points to the provided value. The value will
  /// not be disposed when this [Box] is disposed. Primarily useful
  /// for storing a value in a collection of [Box]s, or for tracking the
  /// lifetime/usage of a value at runtime.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Box<T, ()> fromValue<T extends Object>(final T value) => Box(
        value,
        onDispose: _unitFn,
        finalize: false,
      );

  /// Creates a new [Box] that points to the provided value. The [IDisposable]
  /// will be disposed when this [Box] is disposed. If [finalize] is true,
  /// this [Box] will be attached to a finalizer, which will dispose [value]
  /// when this [Box] becomes unreachable.
  ///
  /// Due to the nature of [Finalizer], [value.dispose()] is not guaranteed to be invoked.
  ///
  /// # Undefined Behavior
  ///
  /// Disposing [value] from outside of this [Box] is undefined behavior, and
  /// may result in a double free, or cause arbitrary methods to throw.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Box<T, ()> fromDisposable<T extends IDisposable>(
    final T value, {
    final bool finalize = true,
  }) =>
      Box(
        value,
        onDispose: (final T v) => v.dispose(),
        finalize: finalize,
      );

  /// Creates a new [Box] that points to the provided value. The [IFutureDisposable]
  /// will be disposed when this [Box] is disposed. If [finalize] is true,
  /// this [Box] will be attached to a finalizer, which will dispose [value]
  /// when this [Box] becomes unreachable.
  ///
  /// Due to the nature of [Finalizer], [IFutureDisposable.dispose] is not guaranteed to be invoked.
  ///
  /// # Undefined Behavior
  ///
  /// Disposing [value] from outside of this [Box] is undefined behavior, and
  /// may result in a double free, or cause arbitrary methods to throw.
  static Box<T, U> fromAsyncDisposable<T extends IFutureDisposable<U>,
          U extends FutureOr<()>>(
    final T value, {
    final bool finalize = true,
  }) =>
      Box(
        value,
        onDispose: (final T v) => v.dispose(),
        finalize: finalize,
      );

  @override
  _BoxFinalizable<T> _createFinalizable() => _BoxFinalizable(
        value: unwrap(),
        onFinalize: _drop,
      );
}

/// A reference counted pointer. When the last reference is dropped, the
/// underlying value is disposed. [()] is used instead of [void] to prevent
/// the return type from unifying to [void] instead of [FutureOr<void>].
final class Rc<T extends Object, U extends FutureOr<()>> extends BaseBox<T, U>
    with BaseBoxValueMixin<T, U> {
  Ptr<int> _count = Ptr(1);
  final bool _finalize;

  /// Creates a new [Rc] that points to the provided value. When all references
  /// to the value are dropped, [super.onDispose] will be called on [tryValue]. If [super.finalize]
  /// is true, this [Rc] will be attached to a finalizer, which will dispose
  /// this [Rc] when it becomes unreachable.
  ///
  /// Due to the nature of [Finalizer], [super.onDispose] is not guaranteed to be invoked.
  Rc(super.value, {required super.onDispose, super.finalize})
      : _finalize = finalize,
        super();

  /// Creates a new [Rc] that points to the provided value. The [IDisposable]
  /// will be disposed when the last reference is disposed. If [finalize] is
  /// true, this [Rc] will be attached to a finalizer, which will dispose
  /// this [Rc] when it becomes unreachable.
  ///
  /// Due to the nature of [Finalizer], [IDisposable.dispose()] is not guaranteed to be invoked.
  ///
  /// # Undefined Behavior
  ///
  /// Disposing [value] from outside of this [Rc] is undefined behavior, and
  /// may result in a double free, or cause arbitrary methods to throw.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Rc<T, ()> fromDisposable<T extends IDisposable>(
    final T value, {
    final bool finalize = true,
  }) =>
      Rc<T, ()>(
        value,
        onDispose: (final v) => v.dispose(),
        finalize: finalize,
      );

  /// Creates a new [Rc] that points to the provided value. The [IFutureDisposable]
  /// will be disposed when the last reference is disposed. If [finalize] is
  /// true, this [Rc] will be attached to a finalizer, which will dispose
  /// this [Rc] when it becomes unreachable.
  ///
  /// Due to the nature of [Finalizer], [IFutureDisposable.dispose] is not guaranteed to be invoked.
  ///
  /// # Undefined Behavior
  ///
  /// Disposing [value] from outside of this [Rc] is undefined behavior, and
  /// may result in a double free, or cause arbitrary methods to throw.
  static Rc<T, U> fromAsyncDisposable<T extends IFutureDisposable<U>,
          U extends FutureOr<()>>(
    final T value, {
    final bool finalize = true,
  }) =>
      Rc<T, U>(
        value,
        onDispose: (final v) => v.dispose(),
        finalize: finalize,
      );

  /// Creates a new [Rc] that points to the provided value. The value will
  /// not be disposed when the last reference is dropped. Primarily useful
  /// for storing a value in a collection of [Rc]s, or for tracking the
  /// lifetime/usage of a value at runtime.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Rc<T, ()> fromValue<T extends Object>(final T value) => Rc(
        value,
        onDispose: _unitFn,
        finalize: false,
      );

  Rc._cloned(
    super.value,
    final Ptr<int> count, {
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

  /// Returns a new [Rc] that points to the same value as this, and increments
  /// the reference count.
  ///
  /// # Throws
  ///
  /// Throws a [AlreadyDisposedError] if this is already disposed.
  ///
  /// # Examples
  ///
  /// ```
  /// final rc = Rc(1);
  /// final rc2 = rc.clone();
  ///
  /// assert(rc.unwrap() == rc2.unwrap());
  /// ```
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

  /// Disposes this [Rc] and decrements the reference count. If this is the last reference to [tryValue], [tryValue] is also disposed.
  ///
  /// # Throws
  ///
  /// Throws a [AlreadyDisposedError] if this is already disposed.
  ///
  /// # Examples
  ///
  /// ```
  /// final IDisposable x = ...; // some disposable object
  /// final rc = Rc(x);
  /// rc.dispose();
  /// rc.unwrap(); // throws AlreadyDisposedError
  /// x.unwrap(); // throws AlreadyDisposedError
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @override
  U dispose() {
    final value = _dispose();

    _count.value--;

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

/// Like a [LockBox], but additionally allows attempting to access the protected value without
/// acquiring the lock. If the lock is held, the access will fail.
final class LooseLockBox<T extends Object, U extends FutureOr<()>>
    extends BaseBox<T, U>
    with BaseBoxValueMixin<T, U>
    implements LockBox<T, U> {
  final Lock _lock;

  /// Returns true if the lock is currently locked.
  @override
  bool get locked => _lock.locked;

  /// For reentrant, test whether we are currently in the synchronized section.
  /// For non reentrant, it returns the [locked] status.
  @override
  bool get inLock => _lock.inLock;

  /// Creates a new [LooseLockBox] that points to the provided value. When this box is disposed,
  /// [super.onDispose] will be called on [tryValue]. If [super.finalize] is true, this [LooseLockBox]
  /// will be attached to a finalizer, which will dispose this [LooseLockBox] when it becomes unreachable.
  ///
  /// Due to the nature of [Finalizer], [super.onDispose] is not guaranteed to be invoked.
  LooseLockBox(
    super.value, {
    required super.onDispose,
    super.finalize,
    final bool reentrant = false,
  })  : _lock = Lock(reentrant: reentrant),
        super();

  /// Creates a new [LooseLockBox] that points to the provided value. The value will
  /// not be disposed when this [LooseLockBox] is disposed. Primarily useful
  /// for storing a value in a collection of [LooseLockBox]s, or for tracking the
  /// lifetime/usage of a value at runtime.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static LooseLockBox<T, ()> fromValue<T extends Object>(
    final T value, {
    final bool reentrant = false,
  }) =>
      LooseLockBox(
        value,
        onDispose: _unitFn,
        finalize: false,
        reentrant: reentrant,
      );

  /// Creates a new [LooseLockBox] that points to the provided value. The [IDisposable]
  /// will be disposed when this [LooseLockBox] is disposed. If [finalize] is true,
  /// this [LooseLockBox] will be attached to a finalizer, which will dispose [value]
  /// when this [LooseLockBox] becomes unreachable.
  ///
  /// Due to the nature of [Finalizer], [value.dispose()] is not guaranteed to be invoked.
  ///
  /// # Undefined Behavior
  ///
  /// Disposing [value] from outside of this [LooseLockBox] is undefined behavior, and
  /// may result in a double free, or cause arbitrary methods to throw.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static LooseLockBox<T, ()> fromDisposable<T extends IDisposable>(
    final T value, {
    final bool finalize = true,
    final bool reentrant = false,
  }) =>
      LooseLockBox(
        value,
        onDispose: (final T v) => v.dispose(),
        finalize: finalize,
        reentrant: reentrant,
      );

  /// Creates a new [LooseLockBox] that points to the provided value. The [IFutureDisposable]
  /// will be disposed when this [LooseLockBox] is disposed. If [finalize] is true,
  /// this [LooseLockBox] will be attached to a finalizer, which will dispose [value]
  /// when this [LooseLockBox] becomes unreachable.
  ///
  /// Due to the nature of [Finalizer], [IFutureDisposable.dispose] is not guaranteed to be invoked.
  ///
  /// # Undefined Behavior
  ///
  /// Disposing [value] from outside of this [LooseLockBox] is undefined behavior, and
  /// may result in a double free, or cause arbitrary methods to throw.
  static LooseLockBox<T, U> fromAsyncDisposable<T extends IFutureDisposable<U>,
          U extends FutureOr<()>>(
    final T value, {
    final bool finalize = true,
    final bool reentrant = false,
  }) =>
      LooseLockBox(
        value,
        onDispose: (final T v) => v.dispose(),
        finalize: finalize,
        reentrant: reentrant,
      );

  /// Returns a [Result] containing the protected object, or an
  /// [AlreadyDisposedError] if the object is disposed, or an
  /// [AlreadyLockedError] if the [LooseLockBox] is locked.
  ///
  /// # Examples
  ///
  /// ```
  /// final box = Box(1);
  /// final result = box.value;
  /// assert(result.isOk);
  ///
  /// box.dispose();
  /// final result2 = box.value;
  /// assert(result2.isErr);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  @doNotStore
  @override
  Result<T, StateError> tryValue() {
    if (_lock.locked && !_lock.inLock) {
      return Result.err(AlreadyLockedError());
    }

    return super.tryValue();
  }

  /// Returns the protected object, or throws an
  /// [AlreadyDisposedError] if the object is disposed, or an
  /// [AlreadyLockedError] if the [LooseLockBox] is locked.
  ///
  /// # Throws
  ///
  /// Throws a [AlreadyDisposedError] if the object is disposed.
  /// Throws a [AlreadyLockedError] if the [LooseLockBox] is locked.
  ///
  /// # Examples
  ///
  /// ```
  /// final box = Box(1);
  /// assert(box.unwrap() == 1);
  ///
  /// box.dispose();
  /// box.unwrap(); // throws AlreadyDisposedError
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  @doNotStore
  @override
  T unwrapLock() => _lock.locked && !_lock.inLock
      ? throw AlreadyLockedError()
      : super.unwrap();

  /// Returns the protected object, or throws a [AlreadyDisposedError] or [AlreadyLockedError] with the provided
  /// [msg]. If [includeTrace] is true, the stack trace of the first call to
  /// [dispose] will be included in the error message. If [includeDisposeTime]
  /// is true, the time of the first call to [dispose] will be included in
  /// the error message.
  ///
  /// # Throws
  ///
  /// Throws a [AlreadyDisposedError] if the object has already been disposed.
  /// Throws a [AlreadyLockedError] if the [LooseLockBox] is locked.
  ///
  /// # Examples
  ///
  /// ```
  /// final box = Box(1);
  /// assert(box.expect('box is not disposed') == 1);
  /// box.dispose();
  /// box.expect('box is not disposed'); // throws AlreadyDisposedError
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  @doNotStore
  @override
  T expect(
    final String msg, {
    final bool includeTrace = false,
    final bool includeDisposeTime = false,
  }) =>
      super.expect(
        msg,
        includeTrace: includeTrace,
        includeDisposeTime: includeDisposeTime,
      );

  /// Runs [fn] with a lock on the protected object once the lock can be acquired.
  /// Returns a [Result] containing the result of [fn], or a [AlreadyDisposedError] if the object is disposed.
  @override
  Future<Result<R, AlreadyDisposedError>> lock<R>(
    final FutureOr<R> Function(T) fn,
  ) =>
      _lock.synchronized(
        () async => _value == null
            ? Result.ok(await fn(_value!))
            : Result.err(AlreadyDisposedError(_errorMsg)),
      );

  /// If the lock is not currently held, runs [fn] with a lock on the protected object.
  /// Returns a [Result] containing the result of [fn], or a [AlreadyDisposedError] if the object is disposed.
  @override
  Future<Result<R, StateError>> tryLock<R>(final FutureOr<R> Function(T) fn) {
    if (_lock.locked && !_lock.inLock) {
      return Future.value(
        Result.err(AlreadyLockedError()),
      );
    } else {
      return _lock.synchronized(
        () async => _value == null
            ? Result.ok(await fn(_value!))
            : Result.err(AlreadyDisposedError(_errorMsg)),
      );
    }
  }

  LockBox<T, U> get tightened => this;

  @override
  _BoxFinalizable<T> _createFinalizable() => _BoxFinalizable(
        value: unwrap(),
        onFinalize: _drop,
      );

  @override
  LooseLockBox<T, U> get loosened => this;
}

abstract final class LockBox<T extends Object, U extends FutureOr<()>>
    implements BaseBox<T, U> {
  bool get locked;
  bool get inLock;
  Future<Result<R, StateError>> lock<R>(final FutureOr<R> Function(T) fn);
  Future<Result<R, StateError>> tryLock<R>(final FutureOr<R> Function(T) fn);
  T unwrapLock();

  /// Creates a new [LockBox] that points to the provided value. When this box is disposed,
  /// [super.onDispose] will be called on [value]. If [super.finalize] is true, this [LockBox]
  /// will be attached to a finalizer, which will dispose this [LockBox] when it becomes unreachable.
  ///
  /// Due to the nature of [Finalizer], [super.onDispose] is not guaranteed to be invoked.
  factory LockBox(
    final T value, {
    required final U Function(T) onDispose,
    final bool finalize = true,
    final bool reentrant = false,
  }) =>
      LooseLockBox(
        value,
        onDispose: onDispose,
        finalize: finalize,
        reentrant: reentrant,
      );

  /// Creates a new [LockBox] that points to the provided value. The value will
  /// not be disposed when this [LockBox] is disposed. Primarily useful
  /// for storing a value in a collection of [LockBox]s, or for tracking the
  /// lifetime/usage of a value at runtime.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static LockBox<T, ()> fromValue<T extends Object>(
    final T value, {
    final bool reentrant = false,
  }) =>
      LooseLockBox(
        value,
        onDispose: _unitFn,
        finalize: false,
        reentrant: reentrant,
      );

  /// Creates a new [LockBox] that points to the provided value. The [IDisposable]
  /// will be disposed when this [LockBox] is disposed. If [finalize] is true,
  /// this [LockBox] will be attached to a finalizer, which will dispose [value]
  /// when this [LockBox] becomes unreachable.
  ///
  /// Due to the nature of [Finalizer], [value.dispose()] is not guaranteed to be invoked.
  ///
  /// # Undefined Behavior
  ///
  /// Disposing [value] from outside of this [LockBox] is undefined behavior, and
  /// may result in a double free, or cause arbitrary methods to throw.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static LockBox<T, ()> fromDisposable<T extends IDisposable>(
    final T value, {
    final bool finalize = true,
    final bool reentrant = false,
  }) =>
      LooseLockBox(
        value,
        onDispose: (final T v) => v.dispose(),
        finalize: finalize,
        reentrant: reentrant,
      );

  /// Creates a new [LockBox] that points to the provided value. The [IFutureDisposable]
  /// will be disposed when this [LockBox] is disposed. If [finalize] is true,
  /// this [LockBox] will be attached to a finalizer, which will dispose [value]
  /// when this [LockBox] becomes unreachable.
  ///
  /// Due to the nature of [Finalizer], [IFutureDisposable.dispose] is not guaranteed to be invoked.
  ///
  /// # Undefined Behavior
  ///
  /// Disposing [value] from outside of this [LockBox] is undefined behavior, and
  /// may result in a double free, or cause arbitrary methods to throw.
  static LockBox<T, U> fromAsyncDisposable<T extends IFutureDisposable<U>,
          U extends FutureOr<()>>(
    final T value, {
    final bool finalize = true,
    final bool reentrant = false,
  }) =>
      LooseLockBox(
        value,
        onDispose: (final T v) => v.dispose(),
        finalize: finalize,
        reentrant: reentrant,
      );

  LooseLockBox<T, U> get loosened => this as LooseLockBox<T, U>;
}

/// A pointer to a value. A mutable wrapper around a value to allow the internal
/// value to be changed without changing the pointer itself. Most useful for
/// modifying external values in closures/functions.
///
/// Mutating state (especially at a distance, as is possible through [Ptr])
/// is generally discouraged, as it can lead to difficult to debug code.
/// Use with caution.
///
/// # Examples
///
/// ```
/// void increment(Ptr<int> ptr) {
///   ptr.value +=1 ;
/// }
///
/// final x = Ptr(1);
/// increment(x);
///
/// assert(x.value == 2);
/// ```
class Ptr<T> {
  T value;

  Ptr(this.value);
}
