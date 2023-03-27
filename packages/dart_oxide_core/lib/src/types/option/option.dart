import 'package:dart_oxide_core/types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'option.freezed.dart';

@Freezed(map: FreezedMapOptions(map: false, mapOrNull: false, maybeMap: false))
class Option<T> with _$Option<T> {
  const Option._();

  /// Creates an [Option] that contains a value.
  const factory Option.some(T value) = _Some<T>;

  /// Creates an [Option] that does not contain a value.
  const factory Option.none() = _None<T>;

  /// Checks if the [Option] contains a value.
  bool get isSome => this is _Some<T>;
  bool get isNone => this is _None<T>;

  /// Checks if the [Option] contains a value that satisfies the given [predicate].
  bool isSomeAnd(bool Function(T) predicate) => when(
        some: predicate,
        none: () => false,
      );

  /// Returns the value in the [Option] if it is [isSome], otherwise throws a [StateError] with the provided message.
  T expect(String message) => when(
        some: (some) => some,
        none: () => throw StateError(message),
      );

  /// Returns the value in the [Option] if it is [isSome], otherwise throws a [StateError].
  T unwrap() {
    return when(
      some: (some) => some,
      none: () => throw StateError('Option is None'),
    );
  }

  /// Returns the value in the [Option] if it is [isSome], otherwise returns the provided [or] value.
  T unwrapOr(T or) => when(
        some: (some) => some,
        none: () => or,
      );

  /// Returns the value in the [Option] if it is [isSome], otherwise returns the value returned by the provided [orElse] function.
  T unwrapOrElse(T Function() orElse) => when(
        some: (some) => some,
        none: orElse,
      );

  /// Maps the value in the [Option] if it is [isSome], otherwise returns [Option.none].
  Option<R> map<R>(R Function(T) fn) => when(
        some: (some) => Option.some(fn(some)),
        none: Option.none,
      );

  /// Calls the provided [fn] if the [Option] is [isSome], and returns the [Option] itself.
  Option<T> inspect(void Function(T) fn) {
    when(
      some: fn,
      none: () {},
    );
    return this;
  }

  Option<R> mapOr<R>(R Function(T) fn, R or) => when(
        some: (some) => Option.some(fn(some)),
        none: () => Option.some(or),
      );

  Option<R> mapOrElse<R>(R Function(T) fn, R Function() orElse) => when(
        some: (some) => Option.some(fn(some)),
        none: () => Option.some(orElse()),
      );

  Result<T, E> okOr<E>(E error) => when(
        some: Result.ok,
        none: () => Result.err(error),
      );

  Result<T, E> okOrElse<E>(E Function() orElse) => when(
        some: Result.ok,
        none: () => Result.err(orElse()),
      );

  Iterable<T> iter() => when(
        some: (some) => [some],
        none: () => [],
      );

  Option<R> and<R>(Option<R> other) => when(
        some: (_) => other,
        none: Option.none,
      );

  /// Returns [`None`] if the option is [`None`], otherwise calls `fn` with the
  /// wrapped value and returns the result.
  Option<R> andThen<R>(Option<R> Function(T) fn) => when(
        some: fn,
        none: Option.none,
      );

  /// Returns the [Option] if it is [isSome] and matches [predicate], otherwise returns [Option.none]. Analagous to [Option.filter] in Rust.
  Option<T> where(bool Function(T) predicate) => when(
        some: (some) =>
            predicate(some) ? Option.some(some) : const Option.none(),
        none: Option<T>.none,
      );

  Option<T> or(Option<T> other) => when(
        some: (_) => this,
        none: () => other,
      );

  Option<T> orElse(Option<T> Function() orElse) => when(
        some: (_) => this,
        none: orElse,
      );

  Option<T> xor(Option<T> other) => this.isSome && other.isNone
      ? this
      : this.isNone && other.isSome
          ? other
          : const Option.none();

  bool contains(T other) => when(
        some: (some) => some == other,
        none: () => false,
      );

  Option<Tuple2<T, R>> zip<R>(Option<R> other) => when(
        some: (some) => other.map((other) => Tuple2(some, other)),
        none: Option.none,
      );

  Option<Tuple2<T, S>> zipWith<R, S>(Option<R> other, S Function(T, R) fn) =>
      when(
        some: (some) => other
            .map((other) => Tuple2(some, other))
            .map((t) => Tuple2(t.item1, fn(t.item1, t.item2))),
        none: Option.none,
      );

  // TODO::consider reimplementing such that `take` and `replace` are possible
}

extension OptionTuple2<T, R> on Option<Tuple2<T, R>> {
  Tuple2<Option<T>, Option<R>> unzip() => when(
        some: (some) =>
            Tuple2(Option.some(some.item1), Option.some(some.item2)),
        none: () => const Tuple2(Option.none(), Option.none()),
      );
}

extension OptionFuture<T> on Option<Future<T>> {
  Future<Option<T>> get future => when(
        some: (some) => some.then(Option.some),
        none: () => Future.value(const Option.none()),
      );
}

// TODO::this
// extension OptionResult<R, E> on Option<Result<R, E>> {
//   Result<Option<R>, E> transpose() => when(
//         some: (some) => some.map(Option.some),
//         none: () => const Result.ok(Option.none()),
//       );
// }

// unwrapOrDefault not currently possible generically; static extensions are used instead for known types

extension OptionOption<T> on Option<Option<T>> {
  Option<T> unwrapOrDefault() => unwrapOr(const Option.none());
  Option<T> flatten() => unwrapOrDefault();
}

extension OptionBool on Option<bool> {
  bool unwrapOrDefault() => unwrapOr(false);
}

extension OptionInt on Option<int> {
  int unwrapOrDefault() => unwrapOr(0);
}

extension OptionDouble on Option<double> {
  double unwrapOrDefault() => unwrapOr(0.0);
}

extension OptionNum on Option<num> {
  num unwrapOrDefault() => unwrapOr(0);
}

extension OptionString on Option<String> {
  String unwrapOrDefault() => unwrapOr('');
}

extension OptionDateTime on Option<DateTime> {
  DateTime unwrapOrDefault() => unwrapOr(DateTime(0));
}

extension OptionList<T> on Option<List<T>> {
  List<T> unwrapOrDefault() => unwrapOr([]);
}

extension OptionMap<K, V> on Option<Map<K, V>> {
  Map<K, V> unwrapOrDefault() => unwrapOr({});
}

extension OptionSet<T> on Option<Set<T>> {
  Set<T> unwrapOrDefault() => unwrapOr({});
}

extension OptionIterable<T> on Option<Iterable<T>> {
  Iterable<T> unwrapOrDefault() => unwrapOr([]);
}

extension OptionStream<T> on Option<Stream<T>> {
  Stream<T> unwrapOrDefault() => unwrapOr(Stream<T>.empty());
}

extension OptionDuration on Option<Duration> {
  Duration unwrapOrDefault() => unwrapOr(Duration.zero);
}
