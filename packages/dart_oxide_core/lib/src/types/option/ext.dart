import 'package:dart_oxide_core/types.dart';

/// Extensions on [T?] to convert to [Option<T>].
extension NullableToOptionExt<T> on T? {
  /// Converts [this] to [Option<T>].
  /// If [this] is `null`, returns [None], otherwise returns [Some(this)].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final some = 1.toOption();
  /// final none = null.toOption();
  ///
  /// assert(some == Some(1));
  /// assert(none.isNone);
  /// ```
  Option<T> toOption() => Option.fromNullable(this);
}

/// Extensions on [Iterable<Option\<T\>>].
/// Provides additional methods for mapping and filtering based on the [Option] variant.
extension IterableOption<T> on Iterable<Option<T>> {
  /// Filters the [Iterable] to only [Some] values, returns an [Iterable] containing
  /// the unwrapped values.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final list = [Some(1), None(), Some(2), None(), Some(3)];
  /// final some = list.whereSome();
  ///
  /// assert(some == [1, 2, 3]);
  /// ```
  Iterable<T> whereSome() sync* {
    for (final option in this) {
      switch (option) {
        case Some(:final value):
          yield value;

        case None():
          break;
      }
    }
  }

  /// Filters the [Iterable] to only [Some] values that match the predicate,
  /// returns an [Iterable] containing the matching unwrapped values.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final list = [Some(1), None(), Some(2), None(), Some(3)];
  /// final some = list.whereSomeAnd((value) => value.isEven);
  ///
  /// assert(some == [2]);
  /// ```
  Iterable<T> whereSomeAnd(bool Function(T) predicate) sync* {
    for (final option in this) {
      switch (option) {
        case Some(:final value) when predicate(value):
          yield value;

        default:
          break;
      }
    }
  }

  /// Maps the [Iterable] to a new [Iterable] by applying a function to all [Some] values.
  /// Returns an [Iterable] containing the mapped values.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final list = [Some(1), None(), Some(2), None(), Some(3)];
  /// final some = list.mapWhereSome((value) => value * 2);
  ///
  /// assert(some == [2, 4, 6]);
  /// ```
  Iterable<R> mapWhereSome<R>(R Function(T) mapper) sync* {
    for (final option in this) {
      switch (option) {
        case Some(:final value):
          yield mapper(value);

        case None():
          break;
      }
    }
  }

  /// Collects the [Iterable] into an [Option\<List\<T\>\>].
  /// If any of the values are [None], returns [None], otherwise returns [Some(List\<T\>)].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final listSome = [Some(1), Some(2), Some(3)];
  /// final some = listSome.collectOption();
  /// assert(some = Option.some([1, 2, 3]));
  ///
  /// final listNone = [Some(1), None(), Some(2), None(), Some(3)];
  /// final none = listNone.collectOption();
  /// assert(none = Option.none());
  /// ```
  Option<List<T>> collectOption() {
    final list = <T>[];

    for (final option in this) {
      switch (option) {
        case Some(:final value):
          list.add(value);

        case None():
          return None<List<T>>();
      }
    }

    return Some(list);
  }
}

extension StreamOption<T> on Stream<Option<T>> {
  /// Filters the [Stream] to only [Some] values, returns a [Stream] containing
  /// the unwrapped values.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final stream = Stream.fromIterable([Some(1), None(), Some(2), None(), Some(3)]);
  ///
  /// await for (final value in stream.whereSome()) {
  ///   print(value); // prints 1, 2, 3
  /// }
  /// ```
  Stream<T> whereSome() async* {
    await for (final option in this) {
      switch (option) {
        case Some(:final value):
          yield value;

        case None():
          break;
      }
    }
  }

  /// Filters the [Stream] to only [Some] values that match the predicate,
  /// returns a [Stream] containing the matching unwrapped values.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final stream = Stream.fromIterable([Some(1), None(), Some(2), None(), Some(3)]);
  ///
  /// await for (final value in stream.whereSomeAnd((value) => value.isEven)) {
  ///   print(value); // prints 2
  /// }
  Stream<T> whereSomeAnd(bool Function(T) predicate) async* {
    await for (final option in this) {
      switch (option) {
        case Some(:final value) when predicate(value):
          yield value;

        default:
          break;
      }
    }
  }

  /// Maps the [Stream] to a new [Stream] by applying a function to all [Some] values.
  /// Returns a [Stream] containing the mapped values.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final stream = Stream.fromIterable([Some(1), None(), Some(2), None(), Some(3)]);
  ///
  /// await for (final value in stream.mapWhereSome((value) => value * 2)) {
  ///   print(value); // prints 2, 4, 6
  /// }
  /// ```
  Stream<R> mapWhereSome<R>(R Function(T) mapper) async* {
    await for (final option in this) {
      switch (option) {
        case Some(:final value):
          yield mapper(value);

        case None():
          break;
      }
    }
  }

  /// Collects the [Stream] into an [Option\<List\<T\>\>]. If any of the values are [None],
  /// returns [None], otherwise returns [Some(List\<T\>)].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final streamSome = Stream.fromIterable([Some(1), Some(2), Some(3)]);
  /// final some = await streamSome.collectOption();
  /// assert(some = Option.some([1, 2, 3]));
  ///
  /// final streamNone = Stream.fromIterable([Some(1), None(), Some(2), None(), Some(3)]);
  /// final none = await streamNone.collectOption();
  /// assert(none = Option.none());
  /// ```
  Future<Option<List<T>>> collectOption() async {
    final list = <T>[];

    await for (final option in this) {
      switch (option) {
        case Some(:final value):
          list.add(value);

        case None():
          return None<List<T>>();
      }
    }

    return Some(list);
  }

  /// Forwards data events while data is [Some].
  ///
  /// Returns a stream that provides the same events as this stream until data
  /// is [None]. The returned stream is done when either this stream is done,
  /// or when this stream first emits a data event that is [None].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final stream = Stream.fromIterable([Some(1), Some(2), None(), Some(3)]);
  ///
  /// await for (final value in stream.takeWhileSome()) {
  ///   print(value); // prints 1, 2
  /// }
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Stream<T> takeWhileSome() =>
      takeWhile((element) => element.isSome).whereSome();

  /// Skip data events from this stream while they are [None].

  /// Returns a stream that emits the same events as this stream, except that data
  /// events are not emitted until a data event is [Some].
  /// If the call throws, the error is emitted as an error event on the returned
  /// stream instead of the data event.

  /// Error and done events are provided by the returned stream unmodified.

  /// The returned stream is a broadcast stream if this stream is.
  /// For a broadcast stream, the events are only tested from the time the
  /// returned stream is listened to.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final stream = Stream.fromIterable([None(), None(), Some(1), Some(2), None(), Some(3)]);
  ///
  /// await for (final value in stream.skipWhileNone()) {
  ///   print(value); // prints Some(1), Some(2), None(), Some(3)
  /// }
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Stream<Option<T>> skipWhileNone() => skipWhile((element) => element.isNone);
}
