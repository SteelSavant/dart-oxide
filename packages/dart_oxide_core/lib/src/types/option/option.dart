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
/// While const constructors can mitigate this issue in some circumstances, it is not always possible to use them,
/// especiallly in generic code.
/// While this is not a problem for most use cases, it can be a problem in performance-critical code.
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
  const factory Option.none() = None<T>;

  // Potential implementation to allow None<T> == None<Never> to get around const weirdness without inference checks.
  // @override
  // bool operator ==(dynamic other) =>
  //     identical(this, other) ||
  //     (other is Option &&
  //         switch ((this, other)) {
  //           (Some<T>(:final value), Some<T>(value: final otherValue)) =>
  //             value == otherValue,
  //           (None<T>(), None<Never>()) => true,
  //           (None<Never>(), None<T>()) => true,
  //           (None<T>(), None<T>()) => true,
  //           _ => false,
  //         });

  // @override
  // int get hashCode => switch (this) {
  //       Some(:final value) => Object.hash(runtimeType, value),
  //       None() => Object.hash(runtimeType, 157890234),
  //     };

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

  /// Returns the value in the [Option] if it is [isSome], otherwise throws a [StateError].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  T unwrap() => switch (this) {
        Some(:final value) => value,
        None() =>
          throw StateError('called `Option.unwrap()` on a `None` value'),
      };

  /// Returns the value in the [Option] if it is [isSome], otherwise returns the provided [or] value.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  T unwrapOr(T defaultValue) => switch (this) {
        Some(:final value) => value,
        None() => defaultValue,
      };

  /// Returns the value in the [Option] if it is [isSome], otherwise returns the value returned by the provided [orElse] function.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  T unwrapOrElse(T Function() fn) => switch (this) {
        Some(:final value) => value,
        None() => fn(),
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

  /// Returns an iterator over the possibly contained value.
  ///
  /// # Examples
  ///
  /// ```
  /// final x = Some(4);
  /// assert(x.iter.moveNext() == true);
  /// assert(x.iter.current == 4);
  ///
  /// final y = None<int>();
  /// assert(y.iter.moveNext() == false);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Iterable<T> get iter => SingleElementIter(this);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<R> and<R>(Option<R> other) => switch (this) {
        Some() => other,
        None() => Option<R>.none(),
      };

  /// Returns [None] if the option is [None], otherwise calls `fn` with the
  /// wrapped value and returns the result.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<R> andThen<R>(Option<R> Function(T) fn) => switch (this) {
        Some(:final value) => fn(value),
        None() => Option<R>.none(),
      };

  /// Returns [None] if the option is [None], otherwise calls [predicate]
  /// with the wrapped value and returns:
  ///
  /// - [Some(t)] if [predicate] returns `true` (where `t` is the wrapped value), and
  /// - [None] if [predicate] returns `false`.
  ///
  /// This function works similar to [Iterable.where]. You can imagine the [Option<T>] being an iterator over one or zero elements.
  /// [where] lets you decide which element to keep.
  ///
  /// # Examples
  ///
  /// ```
  /// bool isEven(int n) => n % 2 == 0;
  ///
  /// assert(None().where(isEven) == None();
  /// assert(Some(3).where(isEven) == None());
  /// assert(Some(4).where(isEven) == Some(4));
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<T> where(bool Function(T) predicate) => switch (this) {
        Some(:final value) when predicate(value) => this,
        _ => Option<T>.none(),
      };

  /// Returns the option if it contains a value, otherwise returns [other].
  ///
  /// Arguments passed to `or` are eagerly evaluated; if you are passing the
  /// result of a function call, it is recommended to use [orElse], which is
  /// lazily evaluated.
  ///
  /// # Examples
  ///
  /// ```
  /// final x = Some(2);
  /// final y = None<int>();
  /// assert(x.or(y) == Some(2));
  ///
  /// final z = None<int>();
  /// final w = Some(100);
  /// assert(z.or(w) == Some(100));
  ///
  /// final a = Some(2);
  /// final b = Some(100);
  /// assert(a.or(b) == Some(2));
  ///
  /// final c = None<int>();
  /// final d = None<int>();
  /// assert(c.or(d) == None<int>());
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<T> or(Option<T> other) => switch (this) {
        Some() => this,
        None() => other,
      };

  /// Returns the option if it contains a value, otherwise calls [fn] and
  /// returns the result.
  ///
  /// # Examples
  ///
  /// ```
  /// Option<String> nobody() => None<String>();
  /// Option<String> vikings() => Some('vikings');
  ///
  /// assert(Some('barbarians').orElse(vikings) == Some('barbarians'));
  /// assert(None<String>().orElse(vikings) == Some('vikings'));
  /// assert(None<String>().orElse(nobody) == None<String>());
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<T> orElse(Option<T> Function() fn) => switch (this) {
        Some() => this,
        None() => fn(),
      };

  /// Returns [Some] if exactly one of [this], [other] is [Some], otherwise returns [None].
  ///
  /// # Examples
  ///
  /// ```
  /// final x = Some(2);
  /// final y = None<int>();
  /// assert(x.xor(y) == Some(2));
  ///
  /// final z = None<int>();
  /// final w = Some(2);
  /// assert(z.xor(w) == Some(2));
  ///
  /// final a = Some(2);
  /// final b = Some(3);
  /// assert(a.xor(b) == None<int>());
  ///
  /// final c = None<int>();
  /// final d = None<int>();
  /// assert(c.xor(d) == None<int>());
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<T> xor(Option<T> other) => switch ((this, other)) {
        (Some(), None()) => this,
        (None(), Some()) => other,
        _ => Option<T>.none(),
      };

  /// Zips [this] with another [Option].
  ///
  /// If [this] is [Some(s)] and [other] is [Some(o)], returns [Some((s, o))].
  /// Otherwise, returns [None].
  ///
  /// # Examples
  ///
  /// ```
  /// final x = Some(1);
  /// final y = Some('hi');
  /// final z = None<int>();
  ///
  /// assert(x.zip(y) == Some((1, 'hi')));
  /// assert(x.zip(z) == None());
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<(T, R)> zip<R>(Option<R> other) => switch (this) {
        Some(:final value) => other.map((other) => (value, other)),
        // ignore: prefer_const_constructors, fails to compile if const
        None() => Option<(T, R)>.none(),
      };

  /// Zips [this] and another [Option] with function [fn].
  ///
  /// If [this] is [Some(s)] and [other] is [Some(o)], returns [Some(fn(s, o))].
  /// Otherwise, returns [None].
  ///
  /// # Examples
  ///
  /// ```
  /// class Point {
  ///   final int x;
  ///  final int y;
  ///  Point(this.x, this.y) {}
  /// }
  ///
  /// final x = Some(17.5);
  /// final y = Some(42.7);
  ///
  /// assert(x.zipWith(y, (a, b) => Point(a, b)) == Some(Point(17.5, 42.7)));
  /// assert(x.zipWith(None(), (a, b) => Point(a, b)) == None<Point>());
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<R> zipWith<U, R>(Option<U> other, R Function(T, U) fn) =>
      switch ((this, other)) {
        (Some(:final value), Some(value: final other)) =>
          Option.some(fn(value, other)),
        _ => Option<R>.none(),
      };
}

extension OptionRecordExt<T, R> on Option<(T, R)> {
  /// Unzips an [Option] containing a tuple of two options.
  ///
  /// If `this` is `Some((a, b))` this method returns `(Some(a), Some(b))`.
  /// Otherwise, `(None, None)` is returned.
  ///
  /// # Examples
  ///
  /// ```
  /// final x = Some((1, 'hi'));
  /// final y = None<(int, String)>();
  ///
  /// assert(x.unzip() == (Some(1), Some('hi')));
  /// assert(y.unzip() == (None<int>(), None<String>()));
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  (Option<T>, Option<R>) unzip() => switch (this) {
        Some(:final value) => (Option.some(value.$1), Option.some(value.$2)),
        None() => (Option<T>.none(), Option<R>.none()),
      };
}

extension OptionFutureExt<T> on Option<Future<T>> {
  /// Waits for the [Future] in the [Option] to complete, and returns an [Option] of the result.
  ///
  /// Examples:
  ///
  /// ```
  /// final x = Some(Future.value(5));
  ///
  /// assert(await x.wait == Some(5));
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Future<Option<T>> get wait => switch (this) {
        Some(:final value) => value.then(Option.some),
        None() => Future.value(Option<T>.none()),
      };
}

extension OptionResult<R, E> on Option<Result<R, E>> {
  /// Transposes an [Option] of a [Result] into a [Result] of an [Option].
  ///
  /// [`None`] will be mapped to <code>[Ok]\([None])</code>.
  /// <code>[Some]\([Ok]\(\_))</code> and <code>[Some]\([Err]\(\_))</code> will be mapped to
  /// <code>[Ok]\([Some]\(\_))</code> and <code>[Err]\(\_)</code>.
  ///
  /// # Examples
  ///
  /// ```
  /// final x = Ok(Some(5));
  /// final y = Some(Ok(5));
  ///
  /// assert(x == y.transpose());
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<Option<R>, E> transpose() => switch (this) {
        Some(value: Ok(:final value)) => Ok(Some(value)),
        Some(value: Err(:final error)) => Err(error),
        None() => Ok(None<R>()),
      };
}

// unwrapOrDefault not currently possible generically; static extensions are used instead for known types

extension OptionOptionExt<T> on Option<Option<T>> {
  /// Converts from [Option<Option<T>] to [Option<T>].
  ///
  /// # Example
  /// ```
  /// final x = Some(Some(1));
  /// final y = None<Option<int>>();
  /// final z = Some(None<int>());
  ///
  /// assert(x.flatten() == Some(1));
  /// assert(y.flatten() == None<int>());
  /// assert(z.flatten() == None<int>());
  /// ```
  ///
  /// Flattening only removes one level of nesting at a time.
  ///
  /// ```
  /// final x = Some(Some(Some(1)));
  ///
  /// assert(x.flatten() == Some(Some(1)));
  /// assert(x.flatten().flatten() == Some(1));
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<T> flatten() => unwrapOr(Option<T>.none());
}

extension OptionBoolExt on Option<bool> {
  /// Returns the contained [Some] value or a default of [false].
  ///
  /// # Example
  /// ```
  /// final x = Some(true);
  /// final y = None<bool>();
  ///
  /// assert(x.unwrapOrDefault() == true);
  /// assert(y.unwrapOrDefault() == false);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool unwrapOrDefault() => unwrapOr(false);
}

extension OptionIntExt on Option<int> {
  /// Returns the contained [Some] value or a default of [int.zero].
  ///
  /// # Example
  /// ```
  /// final x = Some(1);
  /// final y = None<int>();
  ///
  /// assert(x.unwrapOrDefault() == 1);
  /// assert(y.unwrapOrDefault() == 0);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int unwrapOrDefault() => unwrapOr(0);
}

extension OptionDoubleExt on Option<double> {
  /// Returns the contained [Some] value or a default of [double.zero].
  ///
  /// # Example
  /// ```
  /// final x = Some(1.0);
  /// final y = None<double>();
  ///
  /// assert(x.unwrapOrDefault() == 1.0);
  /// assert(y.unwrapOrDefault() == 0.0);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  double unwrapOrDefault() => unwrapOr(0.0);
}

extension OptionNumExt on Option<num> {
  /// Returns the contained [Some] value or a default of [num.zero].
  ///
  /// # Example
  /// ```
  /// final x = Some(1);
  /// final y = None<num>();
  ///
  /// assert(x.unwrapOrDefault() == 1);
  /// assert(y.unwrapOrDefault() == 0);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  num unwrapOrDefault() => unwrapOr(0);
}

extension OptionStringExt on Option<String> {
  /// Returns the contained [Some] value or a default of [String.empty].
  ///
  /// # Example
  /// ```
  /// final x = Some('Hello, world!');
  /// final y = None<String>();
  ///
  /// assert(x.unwrapOrDefault() == 'Hello, world!');
  /// assert(y.unwrapOrDefault() == '');
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String unwrapOrDefault() => unwrapOr('');
}

extension OptionListExt<T> on Option<List<T>> {
  /// Returns the contained [Some] value or a default of [List.empty].
  ///
  /// # Example
  /// ```
  /// final x = Some([1, 2, 3]);
  /// final y = None<List<int>>();
  ///
  /// assert(x.unwrapOrDefault() == [1, 2, 3]);
  /// assert(y.unwrapOrDefault() == []);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  List<T> unwrapOrDefault() => unwrapOr([]);
}

extension OptionMapExt<K, V> on Option<Map<K, V>> {
  /// Returns the contained [Some] value or a default of [Map.empty].
  ///
  /// # Example
  /// ```
  /// final x = Some({'a': 1, 'b': 2, 'c': 3});
  /// final y = None<Map<String, int>>();
  ///
  /// assert(x.unwrapOrDefault() == {'a': 1, 'b': 2, 'c': 3});
  /// assert(y.unwrapOrDefault() == {});
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Map<K, V> unwrapOrDefault() => unwrapOr({});
}

extension OptionSetExt<T> on Option<Set<T>> {
  /// Returns the contained [Some] value or a default of [Set.empty].
  ///
  /// # Example
  /// ```
  /// final x = Some({'a', 'b', 'c'});
  /// final y = None<Set<String>>();
  ///
  /// assert(x.unwrapOrDefault() == {'a', 'b', 'c'});
  /// assert(y.unwrapOrDefault() == {});
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Set<T> unwrapOrDefault() => unwrapOr({});
}

extension OptionIterableExt<T> on Option<Iterable<T>> {
  /// Returns the contained [Some] value or a default of [Iterable.empty].
  ///
  /// # Example
  /// ```
  /// final x = Some(Iterable.generate(3, (i) => i));
  /// final y = None<Iterable<int>>();
  ///
  /// assert(x.unwrapOrDefault().toList() == [0, 1, 2]);
  /// assert(y.unwrapOrDefault().toList() == []);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Iterable<T> unwrapOrDefault() => unwrapOr(Iterable<T>.empty());
}

extension OptionStreamExt<T> on Option<Stream<T>> {
  /// Returns the contained [Some] value or a default of [Stream.empty].
  ///
  /// # Example
  /// ```
  /// final x = Some(Stream.fromIterable([1, 2, 3]));
  /// final y = None<Stream<int>>();
  ///
  /// assert(await x.unwrapOrDefault().toList() == [1, 2, 3]);
  /// assert(await y.unwrapOrDefault().toList() == []);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Stream<T> unwrapOrDefault() => unwrapOr(Stream<T>.empty());
}

extension OptionDurationExt on Option<Duration> {
  /// Returns the contained [Some] value or a default of [Duration.zero].
  ///
  /// # Example
  /// ```
  /// final x = Some(Duration(seconds: 1));
  /// final y = None<Duration>();
  ///
  /// assert(x.unwrapOrDefault() == Duration(seconds: 1));
  /// assert(y.unwrapOrDefault() == Duration.zero);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Duration unwrapOrDefault() => unwrapOr(Duration.zero);
}
