import 'dart:async';

import 'package:dart_oxide_core/types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stack_trace/stack_trace.dart';

part 'ptr.freezed.dart';

() _unitFn(void _) => ();

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
/// Accessing an [IDisposable] after calling [dispose], including calling [dispose]
/// again, is undefined behavior.
typedef IDisposable = IFutureDisposable<()>;

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

/// Base implementation for (relatively) smart pointers. Provides a common
/// interface for accessing the protected object, and disposing the object,
/// as well as a common implementation for attaching a finalizer.
///
/// [()] is used instead of [void] to prevent collections from unifying to [void] instead of [FutureOr<void>].
@internal
abstract final class BaseBox<T extends Object, U extends FutureOr<()>>
    implements IFutureDisposable<U> {
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

  /// Returns a [Result] containing the protected object, or a [StateError] if the object is disposed.
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
  Result<T, StateError> get value {
    final value = this._value;
    return value != null ? Result.ok(value) : Result.err(StateError(_errorMsg));
  }

  /// Returns the protected object, or throws a [StateError] if the object is disposed.
  ///
  /// # Throws
  ///
  /// Throws a [StateError] if the object is disposed.
  ///
  /// # Examples
  ///
  /// ```
  /// final box = Box(1);
  /// assert(box.unwrap() == 1);
  ///
  /// box.dispose();
  /// box.unwrap(); // throws StateError
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  @doNotStore
  T unwrap() => _value ??= throw StateError(_errorMsg);

  /// Returns the protected object, or throws a [StateError] with the provided
  /// [msg]. If [includeTrace] is [true], the stack trace of the first call to
  /// [dispose] will be included in the error message. If [includeDisposeTime]
  /// is [true], the time of the first call to [dispose] will be included in
  /// the error message.
  ///
  /// # Throws
  ///
  /// Throws a [StateError] if the object has already been disposed.
  ///
  /// # Examples
  ///
  /// ```
  /// final box = Box(1);
  /// assert(box.expect('box is not disposed') == 1);
  /// box.dispose();
  /// box.expect('box is not disposed'); // throws StateError
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  @doNotStore
  T expect(
    String msg, {
    bool includeTrace = false,
    bool includeDisposeTime = false,
  }) =>
      _value ??= switch ((includeTrace, includeDisposeTime)) {
        (true, true) => throw StateError(
            '$msg: $_errorMsg',
          ),
        (true, false) => throw StateError(
            '$msg: $T first disposed from $_disposedTrace',
          ),
        (false, true) => throw StateError(
            '$msg: $T first disposed at $_disposedTime',
          ),
        (false, false) => throw StateError(msg),
      };

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

  /// Disposes this box the protected object, preventing further use.
  ///
  /// # Throws
  ///
  /// Throws a [StateError] if the object has already been disposed.
  ///
  /// # Examples
  ///
  /// ```
  /// final box = Box(1);
  /// box.dispose();
  /// box.unwrap(); // throws StateError
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @override
  U dispose() => _drop(_dispose());
}

/// Protects a value that needs to be disposed, and tracks whether or not it has been disposed.
final class Box<T extends Object, U extends FutureOr<()>>
    extends BaseBox<T, U> {
  /// Creates a new [Box] that points to the provided value. When this box is disposed,
  /// [onDispose] will be called on [value]. If [finalize]is [true], this [Box]
  /// will be attached to a finalizer, which will dispose this [Box] when it becomes unreachable.
  ///
  /// Due to the nature of [Finalizer], [onDispose] is not guaranteed to be invoked.
  Box(super.value, {required super.onDispose, super.finalize}) : super();

  /// Creates a new [Box] that points to the provided value. The value will
  /// not be disposed when this [Box] is disposed. Primarily useful
  /// for storing a value in a collection of [Box]s, or for tracking the
  /// lifetime/usage of a value at runtime.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Box<T, ()> fromValue<T extends Object>(T value) => Box(
        value,
        onDispose: _unitFn,
        finalize: false,
      );

  /// Creates a new [Box] that points to the provided value. The [IDisposable]
  /// will be disposed when this [Box] is disposed. If [finalize] is [true],
  /// this [Box] will be attached to a finalizer, which will dispose [value]
  /// when this [Box] becomes unreachable.
  ///
  /// Due to the nature of [Finalizer], [IDisposable.dispose] is not guaranteed to be invoked.
  ///
  /// # Undefined Behavior
  ///
  /// Disposing [value] from outside of this [Box] is undefined behavior, and
  /// may result in a double free, or cause arbitrary methods to throw.
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

  /// Creates a new [Box] that points to the provided value. The [IFutureDisposable]
  /// will be disposed when this [Box] is disposed. If [finalize] is [true],
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

/// A reference counted pointer. When the last reference is dropped, the
/// underlying value is disposed. [()] is used instead of [void] to prevent
/// the return type from unifying to [void] instead of [FutureOr<void>].
final class Rc<T extends Object, U extends FutureOr<()>> extends BaseBox<T, U>
    implements IFutureDisposable<U> {
  Ptr<int> _count = Ptr(1);
  final bool _finalize;

  /// Creates a new [Rc] that points to the provided value. When all references
  /// to the value are dropped, [onDispose] will be called on [value]. If [finalize]
  /// is [true], this [Rc] will be attached to a finalizer, which will dispose
  /// this [Rc] when it becomes unreachable.
  ///
  /// Due to the nature of [Finalizer], [onDispose] is not guaranteed to be invoked.
  Rc(super.value, {required super.onDispose, super.finalize})
      : _finalize = finalize,
        super();

  /// Creates a new [Rc] that points to the provided value. The [IDisposable]
  /// will be disposed when the last reference is disposed. If [finalize] is
  /// [true], this [Rc] will be attached to a finalizer, which will dispose
  /// this [Rc] when it becomes unreachable.
  ///
  /// Due to the nature of [Finalizer], [IDisposable.dispose] is not guaranteed to be invoked.
  ///
  /// # Undefined Behavior
  ///
  /// Disposing [value] from outside of this [Rc] is undefined behavior, and
  /// may result in a double free, or cause arbitrary methods to throw.
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

  /// Creates a new [Rc] that points to the provided value. The [IFutureDisposable]
  /// will be disposed when the last reference is disposed. If [finalize] is
  /// [true], this [Rc] will be attached to a finalizer, which will dispose
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
    T value, {
    bool finalize = true,
  }) =>
      Rc<T, U>(
        value,
        onDispose: (v) => v.dispose(),
        finalize: finalize,
      );

  /// Creates a new [Rc] that points to the provided value. The value will
  /// not be disposed when the last reference is dropped. Primarily useful
  /// for storing a value in a collection of [Rc]s, or for tracking the
  /// lifetime/usage of a value at runtime.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  static Rc<T, ()> fromValue<T extends Object>(T value) => Rc(
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

  /// Returns a new [Rc] that points to the same value as [this], and increments
  /// the reference count.
  ///
  /// # Throws
  ///
  /// Throws a [StateError] if [this] is already disposed.
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

  /// Disposes this [Rc] and decrements the reference count. If this is the last reference to [value], [value] is also disposed.
  ///
  /// # Throws
  ///
  /// Throws a [StateError] if [this] is already disposed.
  ///
  /// # Examples
  ///
  /// ```
  /// final IDisposable x = ...; // some disposable object
  /// final rc = Rc(x);
  /// rc.dispose();
  /// rc.unwrap(); // throws StateError
  /// x.unwrap(); // throws StateError
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
