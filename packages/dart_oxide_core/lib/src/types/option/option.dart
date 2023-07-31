import 'package:dart_oxide_core/src/types/result/result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'option.freezed.dart';

@freezed
sealed class Option<T> with _$Option<T> {
  const Option._();

  /// Creates an [Option] that contains a value.
  const factory Option.some(T value) = Some<T>;

  /// Creates an [Option] that does not contain a value.
  const factory Option.none() = None<T>;

  /// Returns T if the [Option] is [isSome], otherwise returns null.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  T? toNullable() => switch (this) {
        Some(:final value) => value,
        None() => null,
      };

  ///Creates an option that is Some if the value is not null, otherwise None.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  factory Option.fromNullable(T? value) =>
      value == null ? Option<T>.none() : Option<T>.some(value);

  /// Checks if the [Option] contains a value.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool get isSome => this is Some<T>;

  /// Checks if the [Option] does not contain a value.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool get isNone => this is None<T>;

  /// Checks if the [Option] contains a value that satisfies the given [predicate].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool isSomeAnd(bool Function(T) predicate) => switch (this) {
        Some(:final value) => predicate(value),
        None() => false,
      };

  /// Returns the value in the [Option] if it is [isSome], otherwise throws a [StateError] with the provided message.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  T expect(String message) => switch (this) {
        Some(:final value) => value,
        None() => throw StateError(message),
      };

  /// Convenience getter for [unwrap].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  T get unwrapped => unwrap();

  /// Returns the value in the [Option] if it is [isSome], otherwise throws a [StateError].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  T unwrap() => switch (this) {
        Some(:final value) => value,
        None() => throw StateError('Option is None'),
      };

  /// Returns the value in the [Option] if it is [isSome], otherwise returns the provided [or] value.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  T unwrapOr(T or) => switch (this) {
        Some(:final value) => value,
        None() => or,
      };

  /// Returns the value in the [Option] if it is [isSome], otherwise returns the value returned by the provided [orElse] function.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  T unwrapOrElse(T Function() orElse) => switch (this) {
        Some(:final value) => value,
        None() => orElse(),
      };

  /// Maps the value in the [Option] if it is [isSome], otherwise returns [Option.none].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<R> map<R>(R Function(T) fn) => switch (this) {
        Some(:final value) => Option.some(fn(value)),
        None() => Option<R>.none(),
      };

  /// Calls the provided [fn] if the [Option] is [isSome], and returns the [Option] itself.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<T> inspect(void Function(T) fn) {
    switch (this) {
      case Some(:final value):
        fn(value);
      default:
        break;
    }

    return this;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<R> mapOr<R>(R Function(T) fn, R or) => switch (this) {
        Some(:final value) => Option.some(fn(value)),
        None() => Option.some(or),
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<R> mapOrElse<R>(R Function(T) fn, R Function() orElse) =>
      switch (this) {
        Some(:final value) => Option.some(fn(value)),
        None() => Option.some(orElse()),
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<T, E> okOr<E>(E error) => switch (this) {
        Some(:final value) => Result.ok(value),
        None() => Result.err(error),
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<T, E> okOrElse<E>(E Function() orElse) => switch (this) {
        Some(:final value) => Result.ok(value),
        None() => Result.err(orElse()),
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Iterable<T> iter() => switch (this) {
        Some(:final value) => [value],
        None() => [],
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<R> and<R>(Option<R> other) => switch (this) {
        Some() => other,
        None() => Option<R>.none(),
      };

  /// Returns [`None`] if the option is [`None`], otherwise calls `fn` with the
  /// wrapped value and returns the result.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<R> andThen<R>(Option<R> Function(T) fn) => switch (this) {
        Some(:final value) => fn(value),
        None() => Option<R>.none(),
      };

  /// Returns the [Option] if it is [isSome] and matches [predicate], otherwise returns [Option.none]. Analagous to [Option.filter] in Rust.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<T> where(bool Function(T) predicate) => switch (this) {
        Some(:final value) => predicate(value) ? this : Option<T>.none(),
        None() => Option<T>.none(),
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<T> or(Option<T> other) => switch (this) {
        Some() => this,
        None() => other,
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<T> orElse(Option<T> Function() orElse) => switch (this) {
        Some() => this,
        None() => orElse(),
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<T> xor(Option<T> other) => this.isSome && other.isNone
      ? this
      : this.isNone && other.isSome
          ? other
          : Option<T>.none();

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool contains(T other) => switch (this) {
        Some(:final value) => value == other,
        None() => false,
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<(T, R)> zip<R>(Option<R> other) => switch (this) {
        Some(:final value) => other.map((other) => (value, other)),
        // ignore: prefer_const_constructors, fails to compile if const
        None() => Option<(T, R)>.none(),
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<R> zipWith<U, R>(Option<U> other, R Function(T, U) fn) =>
      switch ((this, other)) {
        (Some(:final value), Some(value: final other)) =>
          Option.some(fn(value, other)),
        _ => Option<R>.none(),
      };

  // TODO::consider reimplementing such that `take` and `replace` are possible
}

extension OptionRecord<T, R> on Option<(T, R)> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  (Option<T>, Option<R>) unzip() => switch (this) {
        Some(:final value) => (Option.some(value.$1), Option.some(value.$2)),
        None() => (Option<T>.none(), Option<R>.none()),
      };
}

extension OptionFuture<T> on Option<Future<T>> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Future<Option<T>> get future => switch (this) {
        Some(:final value) => value.then(Option.some),
        None() => Future.value(Option<T>.none()),
      };
}

extension OptionResult<R, E> on Option<Result<R, E>> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<Option<R>, E> transpose() => switch (this) {
        Some(:final value) => value.map(Option.some),
        None() => Result.ok(Option<R>.none()),
      };
}

// unwrapOrDefault not currently possible generically; static extensions are used instead for known types

extension OptionOption<T> on Option<Option<T>> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<T> unwrapOrDefault() => unwrapOr(Option<T>.none());

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<T> flatten() => unwrapOrDefault();
}

extension OptionBool on Option<bool> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool unwrapOrDefault() => unwrapOr(false);
}

extension OptionInt on Option<int> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int unwrapOrDefault() => unwrapOr(0);
}

extension OptionDouble on Option<double> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  double unwrapOrDefault() => unwrapOr(0.0);
}

extension OptionNum on Option<num> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  num unwrapOrDefault() => unwrapOr(0);
}

extension OptionString on Option<String> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String unwrapOrDefault() => unwrapOr('');
}

extension OptionDateTime on Option<DateTime> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  DateTime unwrapOrDefault() => unwrapOr(DateTime(0));
}

extension OptionList<T> on Option<List<T>> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  List<T> unwrapOrDefault() => unwrapOr([]);
}

extension OptionMap<K, V> on Option<Map<K, V>> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Map<K, V> unwrapOrDefault() => unwrapOr({});
}

extension OptionSet<T> on Option<Set<T>> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Set<T> unwrapOrDefault() => unwrapOr({});
}

extension OptionIterable<T> on Option<Iterable<T>> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Iterable<T> unwrapOrDefault() => unwrapOr([]);
}

extension OptionStream<T> on Option<Stream<T>> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Stream<T> unwrapOrDefault() => unwrapOr(Stream<T>.empty());
}

extension OptionDuration on Option<Duration> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Duration unwrapOrDefault() => unwrapOr(Duration.zero);
}
