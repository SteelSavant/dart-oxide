import 'package:dart_oxide_core/src/types/result/result.dart';
import 'package:dart_oxide_core/src/types/single_element_iterator.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'option.freezed.dart';

/// An optional value.
///
/// Type [Option] represents an optional value; every [Option] is either [Some] and contains a value, or [None], and does not.
///
/// [Option]s are commonly paired with pattern matching to query the presence
/// of a value and take action, always accounting for the [`None`] case.
///
/// ```
/// Option<double> divide(double numerator, double denominator) {
///     if denominator == 0.0 {
///         Option.none()
///     } else {
///         Option.some(numerator / denominator)
///     }
/// }
///
/// // The return value of the function is an option
/// final result = divide(2.0, 3.0);
///
/// // Pattern match to retrieve the value
/// switch(result) {
///     // The division was valid
///     Some(:final value) => print("Result: $value"),
///     // The division was invalid
///     None() => print("Cannot divide by 0"),
/// }
/// ```
///
/// # Comparison to [T?]
///
/// [Option] is very similar to [T?], but with a few key differences:
///
/// * [Option] is composable, nullable types are not. For example, Option\<Option\<T\>\> is a valid type, but T?? is not.
/// * The [None] value of different types do not are not equivalent, whereas any null value will be equivalent, regardless of the type [T]. For example, Option\<int\>.none() is not the same as Option\<String\>.none().
/// * Extensions on [Object?] apply to non-nullable objects as well, whereas extensions on [Option<T>] only apply to [Option]s. This prevents polluting the global namespace with extensions that only apply to nullable types.

/// ## Performance considerations compared to [T?]
///
/// Due to the nature of Dart's type system, both the [Some] and [None] variants of [Option] allocate an object.
/// Additionally, the [None] variant is not `const` to avoid issues with `const Option.none()` creating a [None<Never>], which can cause runtime type issues.
/// While this is not a problem for most use cases, it can be a problem in performance-critical code.
///
/// [Option]
///
/// # Method overview
///
/// In addition to working with pattern matching, [Option] provides a wide
/// variety of different methods.
///
/// ## Querying the variant
///
/// The [isSome] and [isNone] methods return [true] if the [Option]
/// is [Some] or [None], respectively.
///
///  ## Extracting the contained value
///
/// These methods extract the contained value in an [Option<T>] when it
/// is the [Some] variant. If the [Option] is [None]:
///
/// * [expect] throws a StateError with a provided custom message
/// * [unwrap] throws a StateError with a generic message
/// * [unwrapOr] returns the provided default value
/// * [unwrapOrElse] returns the result of evaluating the provided function
/// * [unwrapOrDefault] is implemented as an extension on many primitive types. It returns a practical default value if the [Option] is [None].
//

@freezed
sealed class Option<T> with _$Option<T> {
  const Option._();

  /// Creates an [Option] that contains a value.
  const factory Option.some(T value) = Some<T>;

  /// Creates an [Option] that does not contain a value.
  /// Not const because of issues with const Option.none() being typed as Option\<Never\>.
  factory Option.none() = None<T>;

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
      value == null ? Option.none() : Option<T>.some(value);

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
  @override
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

  // Iterator and related overrides

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  SingleElementIter<T> asIter() => SingleElementIter(this);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<R> cast<R>() => switch (this) {
        Some(:final value) => Option.some(value as R),
        None() => Option<R>.none(),
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool contains(T element) => switch (this) {
        Some(:final value) => value == element,
        None() => false,
      };

  /// Returns the [Option] if it is [isSome] and matches [predicate], otherwise returns [Option.none]. Analagous to [Option.filter] in Rust.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<T> where(bool Function(T) predicate) => switch (this) {
        Some(:final value) => predicate(value) ? this : Option<T>.none(),
        None() => Option<T>.none(),
      };

  // zip and unzip

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
