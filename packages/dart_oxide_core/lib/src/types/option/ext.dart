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

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Stream<T> takeWhileSome() =>
      takeWhile((element) => element.isSome).whereSome();

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Stream<Option<T>> skipWhileNone() => skipWhile((element) => element.isNone);
}
