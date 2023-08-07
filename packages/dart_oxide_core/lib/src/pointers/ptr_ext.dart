import 'dart:async';

import 'package:dart_oxide_core/src/pointers/ptr.dart';
import 'package:dart_oxide_core/types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// TODO::annotation to force users to box/cell constructed disposable types

/// Runs the given [action] with the given [resource] and then disposes it.
/// The [action] must be synchronous. The [resource] will be disposed even if
/// the [action] throws.
///
/// # Throws
///
/// Throws if the [action] throws.
///
/// # Examples
///
/// ```dart
/// final x = 1;
/// final y = using(
///   Box.fromValue(2),
///   (box) => x + box.value,
/// );
/// assert(y == 3);
/// ```
R using<T extends IDisposable, R>(
  T resource,
  R Function(T) action,
) {
  try {
    return action(resource);
  } finally {
    resource.dispose();
  }
}

/// Runs the given [action] with the given [resource] and then disposes it.
/// Any of the [action] or the [resource] may be asynchronous. The [resource]
/// will be disposed even if the [action] throws.
///
/// # Throws
///
/// Throws if the [action] throws.
///
/// # Examples
///
/// ```dart
/// final x = 1;
/// final y = await usingAsync(
///   Box.fromValue(2),
///   (box) async => x + box.value,
/// );
/// assert(y == 3);
/// ```
Future<R> usingAsync<T extends IFutureDisposable<U>, U extends FutureOr<()>, R>(
  T resource,
  FutureOr<R> Function(T) action,
) async {
  try {
    return await action(resource);
  } finally {
    // ignore: unnecessary_cast, cast is necessary to satisfy the type checker
    await (resource as IFutureDisposable<FutureOr<()>>).dispose();
  }
}

extension IDisposableExt<T extends IDisposable> on T {
  /// Returns a [Box] that wraps this [IDisposable].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Box<T, ()> toBox() => Box.fromDisposable<T>(this);

  /// Returns a [Rc] that wraps this [IDisposable].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Rc<T, ()> toRc() => Rc.fromDisposable<T>(this);
}

extension IDisposableAsyncExt<T extends IFutureDisposable<U>,
    U extends FutureOr<()>> on T {
  /// Returns a [Box] that wraps this [IFutureDisposable].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Box<T, U> toBox() => Box.fromAsyncDisposable<T, U>(this);

  /// Returns a [Rc] that wraps this [IFutureDisposable].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Rc<T, U> toRc() => Rc.fromAsyncDisposable<T, U>(this);
}

extension OptionPtrExt<T> on Ptr<Option<T>> {
  /// Takes the value out of the [Ptr], leaving a [None] in its place.
  ///
  /// # Examples
  ///
  /// ```
  /// final x = Ptr(Option<int>.some(2));
  /// final y = x.take();
  /// assert(x.value == Option<int>.none());
  /// assert(y == Option<int>.some(2));
  ///
  /// final z = Ptr(Option<int>.none());
  /// final w = z.take();
  /// assert(z.value == Option<int>.none());
  /// assert(w == Option<int>.none());
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Option<T> take() {
    final option = value;
    value = Option<T>.none();
    return option;
  }

  /// Replaces the actual value in the [Ptr] by the value given in parameter,
  /// returning the old value if present,
  /// leaving a [Some] in its place.
  ///
  /// # Examples
  ///
  /// ```
  /// final x = Ptr(Option<int>.some(2));
  /// final xOld = x.replace(5);
  /// assert(x.value == Option<int>.some(5));
  /// assert(xOld == Option<int>.some(2));
  ///
  /// final y = Ptr(Option<int>.none());
  /// final yOld = y.replace(3);
  /// assert(y.value == Option<int>.some(3));
  /// assert(yOld == Option<int>.none());
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  Option<T> replace(T value) {
    final old = this.value;
    this.value = Option.some(value);
    return old;
  }
}

extension NullPtrExt<T> on Ptr<T?> {
  /// Takes the value out of the [Ptr], leaving a `null` in its place.
  ///
  /// # Examples
  ///
  /// ```
  /// final x = Ptr(2);
  /// final y = x.take();
  /// assert(x.value == null);
  /// assert(y == 2);
  ///
  /// final z = Ptr<int?>(null);
  /// final w = z.take();
  /// assert(z.value == null);
  /// assert(w == null);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  T? take() {
    final value = this.value;
    this.value = null;
    return value;
  }
}

extension PtrExt<T> on Ptr<T> {
  /// Replaces the actual value in the Ptr by the value given in parameter,
  /// returning the old value.
  ///
  /// # Examples
  ///
  /// ```
  /// final x = Ptr(2);
  /// final xOld = x.replace(5);
  /// assert(x.value == 5);
  /// assert(xOld == 2);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @useResult
  T replace(T value) {
    final old = this.value;
    this.value = value;
    return old;
  }
}
