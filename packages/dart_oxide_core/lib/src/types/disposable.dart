import 'dart:async';

import 'package:dart_oxide_core/src/types/result/result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stack_trace/stack_trace.dart';

/// Interface for objects that can be disposed. As Dart does not have a built-in `Drop` trait, this is the closest equivalent.
/// It is recommended to use [DisposableMixin] instead of implementing this interface directly.
/// Type parameter `T` is should refer to the type of [this], the type of the object being disposed.
abstract class IDisposable<T extends Object> {
  Result<T, StateError> get checked;

  /// Disposes of the object.
  @mustBeOverridden
  FutureOr<void> dispose();
}

/// An interface to constrain the return type of an [IDisposable] or [DisposableMixin] `dispose` method to [void]
/// Type parameter `T` is should refer to the type of [this], the type of the object being disposed.
// ignore: missing_override_of_must_be_overridden
abstract class ISyncDisposable<T extends Object> implements IDisposable<T> {
  @override
  @mustBeOverridden
  void dispose();
}

/// An interface to constrain the return type of an [IDisposable] or [DisposableMixin] `dispose` method to [Future\<void\>]
/// Type parameter `T` is should refer to the type of [this], the type of the object being disposed.
// ignore: missing_override_of_must_be_overridden
abstract class IAsyncDisposable<T extends Object> implements IDisposable<T> {
  @override
  @mustBeOverridden
  Future<void> dispose();
}

/// A mixin that implements `[IDisposable\<T\>]` and provides a default implementation of its methods.
/// Type parameter `T` is should refer to the type of `[this]`, the type of the object being disposed.

// /// Also provides a finalizer to ensure that the `[dispose]` method is invoked when the object is no longer in scope and has not already been disposed.

// ignore: mixin_super_class_constraint_non_interface
mixin DisposableMixin<T extends Object> on T implements IDisposable<T> {
  // // TODO::verify the finalizer works as expected
  // static final Finalizer<IDisposable> _finalizer =
  //     Finalizer((disposable) => disposable.dispose());

  bool _disposed = false;

  late Trace _disposedTrace;
  late DateTime _disposedTime;

  StateError get _error {
    assert(_disposed);
    return StateError(
        'cannot use object after being disposed;\nobject first disposed at $_disposedTime\nfrom $_disposedTrace');
  }

  // /// Attaches the object to the finalizer, so that it will be disposed when it is no longer in scope.
  // /// Must be called within the constructor of the object.
  // @protected
  // void attach() {
  //   _finalizer.attach(this, this, detach: this);
  // }

  /// Returns a result containing the return value of the provided function if the object, or a [StateError] if the object is disposed.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @override
  @nonVirtual
  @useResult
  Result<T, StateError> get checked =>
      _disposed ? Result.err(_error) : Result.ok(this as T);

  @override
  FutureOr<void> dispose() {
    if (_disposed) {
      throw _error;
    }
    _disposed = true;
    _disposedTime = DateTime.now();
    _disposedTrace = Trace.current();
    // _finalizer.detach(this);
  }
}
