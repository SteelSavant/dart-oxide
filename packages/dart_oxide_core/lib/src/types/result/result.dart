import 'dart:async';

import 'package:dart_oxide_core/src/types/option/option.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@Freezed(map: FreezedMapOptions(map: false, mapOrNull: false, maybeMap: false))
class Result<R, E> with _$Result<R, E> {
  const Result._();

  /// Creates a [Result] that contains a value.
  const factory Result.ok(R value) = _Ok<R, E>;

  /// Creates a [Result] that contains an error.
  const factory Result.err(E error) = _Err<R, E>;

  @useResult
  static Result<R, E> guard<R, E>(
    R Function() fn, {
    required E Function(Object) onErr,
  }) {
    try {
      return Result<R, E>.ok(fn());
    } catch (e) {
      return Result<R, E>.err(onErr(e));
    }
  }

  @useResult
  static Result<R, Exception> guardExc<R>(R Function() fn) {
    try {
      return Result<R, Exception>.ok(fn());
    } on Exception catch (e) {
      return Result<R, Exception>.err(e);
    }
  }

  @useResult
  static Result<R, Object> guardAll<R>(R Function() fn) {
    try {
      return Result<R, Exception>.ok(fn());
    } catch (e) {
      return Result<R, Object>.err(e);
    }
  }

  @useResult
  static Future<Result<R, E>> guardAsync<R, E>(
    Future<R> Function() fn, {
    required FutureOr<E> Function(Object) onErr,
  }) async {
    try {
      return Result<R, E>.ok(await fn());
    } catch (e) {
      final err = onErr(e);
      return err is Future
          ? Result<R, E>.err(await err)
          : Result<R, E>.err(err);
    }
  }

  @useResult
  static Future<Result<R, Exception>> guardExcAsync<R>(
      Future<R> Function() fn) async {
    try {
      return Result<R, Exception>.ok(await fn());
    } on Exception catch (e) {
      return Result<R, Exception>.err(e);
    }
  }

  @useResult
  static Future<Result<R, Object>> guardAllAsync<R>(
      Future<R> Function() fn) async {
    try {
      return Result<R, Exception>.ok(await fn());
    } catch (e) {
      return Result<R, Object>.err(e);
    }
  }

  /// Checks if the [Result] contains a value.
  bool get isOk => this is _Ok<R, E>;
  bool get isErr => this is _Err<R, E>;

  /// Checks if the [Result] contains a value that satisfies the given [predicate].
  bool isOkAnd(bool Function(R) predicate) => when(
        ok: predicate,
        err: (_) => false,
      );

  /// Checks if the [Result] contains an error that satisfies the given [predicate].
  bool isErrAnd(bool Function(E) predicate) => when(
        ok: (_) => false,
        err: predicate,
      );

  Option<R> ok() => when(
        ok: Option.some,
        err: (_) => const Option.none(),
      );

  Option<E> err() => when(
        ok: (_) => const Option.none(),
        err: Option.some,
      );

  /// Maps the value in the [Result] if it is [isOk], otherwise returns [Result.err].
  Result<R2, E> map<R2>(R2 Function(R) fn) => when(
        ok: (ok) => Result.ok(fn(ok)),
        err: Result.err,
      );

  /// Maps the value in the [Result] if it is [isOk], otherwise returns [or].
  Result<R2, E> mapOr<R2>(R2 Function(R) fn, Result<R2, E> or) => when(
        ok: (ok) => Result.ok(fn(ok)),
        err: (_) => or,
      );

  /// Maps the value in the [Result] if it is [isOk], otherwise returns the value returned by the provided [orElse] function.
  Result<R2, E> mapOrElse<R2>(
          R2 Function(R) fn, Result<R2, E> Function(E) orElse) =>
      when(
        ok: (ok) => Result.ok(fn(ok)),
        err: orElse,
      );

  /// Maps the error in the [Result] if it is [isErr], otherwise returns [Result.ok].
  Result<R, E2> mapErr<E2>(E2 Function(E) fn) => when(
        ok: Result.ok,
        err: (err) => Result.err(fn(err)),
      );

  Result<R, E> inspect(void Function(R) fn) => when(
        ok: (ok) {
          fn(ok);
          return this;
        },
        err: Result<R, E>.err,
      );

  Result<R, E> inspectErr(void Function(E) fn) => when(
      ok: Result<R, E>.ok,
      err: (err) {
        fn(err);
        return this;
      });

  Iterable<R> iter() => when(
        ok: (ok) => [ok],
        err: (_) => [],
      );

  /// Returns the value in the [Result] if it is [isOk], otherwise throws a [StateError] with the provided message.
  R expect(String message) => when(
        ok: (ok) => ok,
        err: (_) => throw StateError(message),
      );

  /// Returns the value in the [Result] if it is [isOk], otherwise throws a [StateError].
  R unwrap() {
    return when(
      ok: (ok) => ok,
      err: (err) => throw StateError('Result is Err($err)'),
    );
  }

  /// Returns the value in the [Result] if it is [isOk], otherwise returns the provided [or] value.
  R unwrapOr(R or) => when(
        ok: (ok) => ok,
        err: (_) => or,
      );

  /// Returns the value in the [Result] if it is [isOk], otherwise returns the value returned by the provided [orElse] function.
  R unwrapOrElse(R Function(E) orElse) => when(
        ok: (ok) => ok,
        err: orElse,
      );

  /// Returns the error in the [Result] if it is [isErr], otherwise throws a [StateError] with the provided message.
  E expectErr(String message) => when(
        ok: (_) => throw StateError(message),
        err: (err) => err,
      );

  /// Returns the error in the [Result] if it is [isErr], otherwise throws a [StateError].
  E unwrapErr() {
    return when(
      ok: (ok) => throw StateError('Result is Ok($ok)'),
      err: (err) => err,
    );
  }

  /// Returns the value in the [Result] if it is [isOk], otherwise returns the [err] value.
  Result<U, E> and<U>(Result<U, E> err) => when(
        ok: (_) => err,
        err: Result.err,
      );

  Result<U, E> andThen<U>(Result<U, E> Function(R) fn) => when(
        ok: fn,
        err: Result.err,
      );

  Result<R, F> or<F>(Result<R, F> err) => when(
        ok: Result.ok,
        err: (_) => err,
      );

  Result<R, F> orElse<F>(Result<R, F> Function(E) fn) => when(
        ok: Result.ok,
        err: fn,
      );

  bool contains(R other) => when(
        ok: (ok) => ok == other,
        err: (_) => false,
      );

  bool containsErr(E other) => when(
        ok: (_) => false,
        err: (err) => err == other,
      );
}

extension InfallibleResult<R> on Result<R, Never> {
  /// Returns the value in the result. Since the result is infallible, this method never throws.
  R get ok => unwrap();
}

extension InfallibleErrResult<E> on Result<Never, E> {
  /// Returns the error in the result. Since the err is infallible, this method never throws.
  E get error => unwrapErr();
}

extension ResultOption<R, E> on Result<Option<R>, E> {
  Option<Result<R, E>> transpose() => when(
        ok: (ok) => ok.map(Result.ok),
        err: (_) => const Option.none(),
      );
}

extension ResultFuture<R, E> on Result<Future<R>, Future<E>> {
  Future<Result<R, E>> get future => when(
        ok: (ok) => ok.then(Result.ok),
        err: (err) => err.then(Result.err),
      );
}

extension ResultFutureOk<R, E> on Result<Future<R>, E> {
  Future<Result<R, E>> get future => when(
        ok: (ok) => ok.then(Result.ok),
        err: (err) => Future.value(Result.err(err)),
      );
}

extension ResultFutureErr<R, E> on Result<R, Future<E>> {
  Future<Result<R, E>> get future => when(
        ok: (ok) => Future.value(Result.ok(ok)),
        err: (err) => err.then(Result.err),
      );
}

// unwrapOrDefault not currently possible generically; static extensions are used instead for known types

extension ResultResult<R, E> on Result<Result<R, E>, E> {
  Result<R, E> flatten() => when(
        ok: (ok) => ok,
        err: Result.err,
      );
}

extension ResultBool<E> on Result<bool, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `false`.
  bool unwrapOrDefault() => unwrapOr(false);
}

extension ResultInt<E> on Result<int, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `0`.
  int unwrapOrDefault() => unwrapOr(0);
}

extension ResultDouble<E> on Result<double, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `0.0`.
  double unwrapOrDefault() => unwrapOr(0.0);
}

extension ResultNum<E> on Result<num, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `0`.
  num unwrapOrDefault() => unwrapOr(0);
}

extension ResultString<E> on Result<String, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `''`.
  String unwrapOrDefault() => unwrapOr('');
}

extension ResultDateTime<E> on Result<DateTime, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `DateTime(0)`.
  DateTime unwrapOrDefault() => unwrapOr(DateTime(0));
}

extension ResultList<T, E> on Result<List<T>, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `[]`.
  List<T> unwrapOrDefault() => unwrapOr([]);
}

extension ResultMap<K, V, E> on Result<Map<K, V>, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `{}`.
  Map<K, V> unwrapOrDefault() => unwrapOr({});
}

extension ResultSet<T, E> on Result<Set<T>, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `{}`.
  Set<T> unwrapOrDefault() => unwrapOr({});
}

extension ResultIterable<T, E> on Result<Iterable<T>, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `[]`.
  Iterable<T> unwrapOrDefault() => unwrapOr([]);
}

extension ResultStream<T, E> on Result<Stream<T>, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `Stream.empty()`.
  Stream<T> unwrapOrDefault() => unwrapOr(Stream<T>.empty());
}

extension ResultDuration<E> on Result<Duration, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `Duration.zero`.
  Duration unwrapOrDefault() => unwrapOr(Duration.zero);
}
