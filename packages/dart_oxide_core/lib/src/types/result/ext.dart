import 'dart:async';

import 'package:dart_oxide_core/types.dart';

extension IterableResultExt<R, E> on Iterable<Result<R, E>> {
  /// Filters the [Iterable] to only [Ok] values, returns an [Iterable] containing
  /// the unwrapped values.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final list = [Ok(1), Err(2), Ok(3), Err(4), Ok(5)];
  /// final ok = list.whereOk();
  ///
  /// assert(ok == [1, 3, 5]);
  /// ```
  Iterable<R> whereOk() sync* {
    for (final option in this) {
      switch (option) {
        case Ok(:final value):
          yield value;

        default:
          break;
      }
    }
  }

  /// Filters the [Iterable] to only [Ok] values that match the predicate,
  /// returns an [Iterable] containing the matching unwrapped values.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final list = [Ok(1), Ok(2), Ok(3), Err(4), Ok(5)];
  /// final ok = list.whereOkAnd((value) => value.isEven);
  ///
  /// assert(ok == [2]);
  /// ```
  Iterable<R> whereOkAnd(final bool Function(R) predicate) sync* {
    for (final option in this) {
      switch (option) {
        case Ok(:final value) when predicate(value):
          yield value;

        default:
          break;
      }
    }
  }

  /// Maps the [Iterable] to a new [Iterable] by applying a function to all [Ok] values.
  /// Returns an [Iterable] containing the mapped values.
  ///
  /// # Examples
  /// ```
  /// final list = [Ok(1), Ok(2), Ok(3), Err(4), Ok(5)];
  /// final ok = list.mapWhereOk((value) => value * 2);
  ///
  /// assert(ok == [2, 4, 6, 10]);
  /// ```
  Iterable<T> mapWhereOk<T>(final T Function(R) mapper) sync* {
    for (final option in this) {
      switch (option) {
        case Ok(:final value):
          yield mapper(value);

        default:
          break;
      }
    }
  }

  /// Collects the [Iterable] into a [Result] containing a [List] of all [Ok] values.
  /// If any [Err] values are encountered, the first [Err] value is returned.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final list = [Ok(1), Ok(2), Ok(3), Ok(4), Ok(5)];
  /// final ok = list.collectResult();
  /// assert(ok == Ok([1, 2, 3, 4, 5]));
  ///
  /// final errList = [Ok(1), Err(2), Ok(3), Err(4), Ok(5)];
  /// final err = errList.collectResult();
  /// assert(err == Err(2));
  /// ```
  Result<List<R>, E> collectResult() {
    final list = <R>[];

    for (final result in this) {
      switch (result) {
        case Ok(:final value):
          list.add(value);

        case Err(:final error):
          return Result.err(error);
      }
    }

    return Ok(list);
  }
}

extension StreamResultExt<R, E> on Stream<Result<R, E>> {
  /// Filters the [Stream] to only [Ok] values, returns a [Stream] containing
  /// the unwrapped values.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final stream = Stream.fromIterable([Ok(1), Err(2), Ok(3), Err(4), Ok(5)]);
  ///
  /// await for (final value in stream.whereOk()) {
  ///    print(value); // prints 1, 3, 5
  /// }
  /// ```
  Stream<R> whereOk() async* {
    await for (final option in this) {
      switch (option) {
        case Ok(:final value):
          yield value;

        default:
          break;
      }
    }
  }

  /// Filters the [Stream] to only [Ok] values that match the predicate,
  /// returns a [Stream] containing the matching unwrapped values.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final stream = Stream.fromIterable([Ok(1), Ok(2), Ok(3), Err(4), Ok(5)]);
  ///
  /// await for (final value in stream.whereOkAnd((value) => value.isEven)) {
  ///    print(value); // prints 2
  /// }
  /// ```
  Stream<R> whereOkAnd(final bool Function(R) predicate) async* {
    await for (final option in this) {
      switch (option) {
        case Ok(:final value) when predicate(value):
          yield value;

        default:
          break;
      }
    }
  }

  /// Maps the [Stream] to a new [Stream] by applying a function to all [Ok] values.
  /// Returns a [Stream] containing the mapped values.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final stream = Stream.fromIterable([Ok(1), Ok(2), Ok(3), Err(4), Ok(5)]);
  ///
  /// await for (final value in stream.mapWhereOk((value) => value * 2)) {
  ///   print(value); // prints 2, 4, 6, 10
  /// }
  Stream<T> mapWhereSome<T>(final T Function(R) mapper) async* {
    await for (final option in this) {
      switch (option) {
        case Ok(:final value):
          yield mapper(value);

        case Err():
          break;
      }
    }
  }

  /// Forwards data events while data is [Ok].
  ///
  /// Returns a stream that provides the same events as this stream until data
  /// is [Err]. The returned stream is done when either this stream is done,
  /// or when the first error event occurs
  ///
  /// # Examples
  ///
  /// ```dart
  /// final stream = Stream.fromIterable([Ok(1), Ok(2), Err(3), Ok(4), Err(5)]);
  ///
  /// await for (final value in stream.takeWhileOk()) {
  ///    print(value); // prints 1, 2
  /// }
  /// ```
  Stream<R> takeWhileOk() =>
      takeWhile((final element) => element.isOk).whereOk();

  /// Skips data events from this stream while they are [Err].
  ///
  /// Returns a stream that emits the same events as this stream, except that
  /// data events are not emitted until a data event is [Ok].

  /// Error and done events
  ///
  /// The returned stream is a broadcast stream if this stream is.
  /// For a broadcast stream, the events are only tested from the time the
  /// returned stream is listened to.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final stream = Stream.fromIterable([Err(1), Err(2), Ok(3), Err(4), Ok(5)]);
  ///
  /// await for (final value in stream.skipWhileErr()) {
  ///    print(value); // prints Ok(3), Err(4), Ok(5)
  /// }
  Stream<Result<R, E>> skipWhileErr() =>
      skipWhile((final element) => element.isErr);

  /// Collects the [Stream] into a [Result] containing a [List] of all [Ok] values.
  /// If any [Err] values are encountered, the first [Err] value is returned.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final stream = Stream.fromIterable([Ok(1), Ok(2), Ok(3), Ok(4), Ok(5)]);
  /// final ok = await stream.collectResult();
  /// assert(ok == Ok([1, 2, 3, 4, 5]));
  ///
  /// final errStream = Stream.fromIterable([Ok(1), Err(2), Ok(3), Err(4), Ok(5)]);
  /// final err = await errStream.collectResult();
  /// assert(err == Err(2));
  /// ```
  Future<Result<List<R>, E>> collectResult() async {
    final list = <R>[];

    await for (final result in this) {
      switch (result) {
        case Ok(:final value):
          list.add(value);

        case Err(:final error):
          return Result<List<R>, E>.err(error);
      }
    }

    return Ok(list);
  }
}
