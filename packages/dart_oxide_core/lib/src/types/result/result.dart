import 'dart:async';

import 'package:dart_oxide_core/src/types/option/option.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
sealed class Result<R, E> with _$Result<R, E> {
  const Result._();

  /// Creates a [Result] that contains a value.
  const factory Result.ok(R value) = Ok<R, E>;

  /// Creates a [Result] that contains an error.
  const factory Result.err(E error) = Err<R, E>;

  // TODO::figure out good ergonomics for guard clauses
  // @useResult
  // static Result<R, E> guard<R, E, X>(
  //   R Function() fn, {
  //   required E Function(X) onErr, // type inference seems to fail here if X is same type as E
  // }) {
  //   try {
  //     return Result<R, E>.ok(fn());
  //   } on X catch (e) {
  //     return Result<R, E>.err(onErr(e));
  //   }
  // }

  // @useResult
  // static Result<R, Exception> guardException<R>(R Function() fn) {
  //   try {
  //     return Result<R, Exception>.ok(fn());
  //   } on Exception catch (e) {
  //     return Result<R, Exception>.err(e);
  //   }
  // }

  // @useResult
  // static Result<R, Object> guardAny<R>(R Function() fn) {
  //   try {
  //     return Result<R, Exception>.ok(fn());
  //   } catch (e) {
  //     return Result<R, Object>.err(e);
  //   }
  // }

  // @useResult
  // static Future<Result<R, E>> guardAsync<R, E, X extends Object>(
  //   Future<R> Function() fn, {
  //   required FutureOr<E> Function(X) onErr,
  // }) async {
  //   try {
  //     return Result<R, E>.ok(await fn());
  //   } on X catch (e) {
  //     final err = onErr(e);
  //     return err is Future
  //         ? Result<R, E>.err(await err)
  //         : Result<R, E>.err(err);
  //   }
  // }

  // @useResult
  // static Future<Result<R, Exception>> guardExceptionAsync<R>(
  //   Future<R> Function() fn,
  // ) async {
  //   try {
  //     return Result<R, Exception>.ok(await fn());
  //   } on Exception catch (e) {
  //     return Result<R, Exception>.err(e);
  //   }
  // }

  // @useResult
  // static Future<Result<R, Object>> guardAnyAsync<R>(
  //   Future<R> Function() fn,
  // ) async {
  //   try {
  //     return Result<R, Exception>.ok(await fn());
  //   } catch (e) {
  //     return Result<R, Object>.err(e);
  //   }
  // }

  /// Checks if the [Result] contains a value.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool get isOk => this is Ok<R, E>;

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool get isErr => this is Err<R, E>;

  /// Checks if the [Result] contains a value that satisfies the given [predicate].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool isOkAnd(bool Function(R) predicate) => switch (this) {
        Ok(:final value) => predicate(value),
        Err() => false,
      };

  /// Checks if the [Result] contains an error that satisfies the given [predicate].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool isErrAnd(bool Function(E) predicate) => switch (this) {
        Ok() => false,
        Err(:final error) => predicate(error),
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<R> ok() => switch (this) {
        Ok(:final value) => Option.some(value),
        Err() => Option<R>.none(),
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<E> err() => switch (this) {
        Ok() => Option<E>.none(),
        Err(:final error) => Option.some(error),
      };

  /// Maps the value in the [Result] if it is [isOk], otherwise returns [Result.err].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<R2, E> map<R2>(R2 Function(R) fn) => switch (this) {
        Ok(:final value) => Result.ok(fn(value)),
        Err(:final error) => Result.err(error),
      };

  /// Maps the value in the [Result] if it is [isOk], otherwise returns [or].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  R2 mapOr<R2>(R2 Function(R) fn, R2 or) => switch (this) {
        Ok(:final value) => fn(value),
        Err() => or,
      };

  /// Maps the value in the [Result] if it is [isOk], otherwise returns the value returned by the provided [orElse] function.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  R2 mapOrElse<R2>(
    R2 Function(R) fn,
    R2 Function(E) orElse,
  ) =>
      switch (this) {
        Ok(:final value) => fn(value),
        Err(:final error) => orElse(error),
      };

  /// Maps the error in the [Result] if it is [isErr], otherwise returns [Result.ok].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<R, E2> mapErr<E2>(E2 Function(E) fn) => switch (this) {
        Ok(:final value) => Result.ok(value),
        Err(:final error) => Result.err(fn(error)),
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<R, E> inspect(void Function(R) fn) {
    switch (this) {
      case Ok(:final value):
        fn(value);
        return this;

      case Err():
        return this;
    }
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<R, E> inspectErr(void Function(E) fn) {
    switch (this) {
      case Ok():
        return this;
      case Err(:final error):
        fn(error);
        return this;
    }
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Iterable<R> iter() => switch (this) {
        Ok(:final value) => [value],
        Err() => [],
      };

  /// Returns the value in the [Result] if it is [isOk], otherwise throws a [StateError] with the provided message.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  R expect(String message) => switch (this) {
        Ok(:final value) => value,
        Err() => throw StateError(message),
      };

  /// Returns the error in the [Result] if it is [isErr], otherwise throws a [StateError] with the provided message.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  E expectErr(String message) => switch (this) {
        Ok() => throw StateError(message),
        Err(:final error) => error,
      };

  /// Returns the value in the [Result] if it is [isOk], otherwise throws a [StateError].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  R unwrap() => switch (this) {
        Ok(:final value) => value,
        Err(:final error) => throw StateError('Result is Err($error)'),
      };

  /// Returns the value in the [Result] if it is [isOk], otherwise returns the provided [or] value.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  R unwrapOr(R or) => switch (this) {
        Ok(:final value) => value,
        Err() => or,
      };

  /// Returns the value in the [Result] if it is [isOk], otherwise returns the value returned by the provided [orElse] function.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  R unwrapOrElse(R Function(E) orElse) => switch (this) {
        Ok(:final value) => value,
        Err(:final error) => orElse(error),
      };

  /// Returns the error in the [Result] if it is [isErr], otherwise throws a [StateError].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  E unwrapErr() => switch (this) {
        Ok(:final value) => throw StateError('Result is Ok($value)'),
        Err(:final error) => error,
      };

  /// Returns [res] if the result is [isOk], otherwise returns the [Err] value of [this].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<U, E> and<U>(Result<U, E> res) => switch (this) {
        Ok() => res,
        Err(:final error) => Result.err(error),
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<U, E> andThen<U>(Result<U, E> Function(R) fn) => switch (this) {
        Ok(:final value) => fn(value),
        Err(:final error) => Result.err(error)
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<R, F> or<F>(Result<R, F> err) => switch (this) {
        Ok(:final value) => Result.ok(value),
        Err() => err,
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<R, F> orElse<F>(Result<R, F> Function(E) fn) => switch (this) {
        Ok(:final value) => Result.ok(value),
        Err(:final error) => fn(error),
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool contains(R other) => switch (this) {
        Ok(:final value) => value == other,
        Err() => false,
      };

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool containsErr(E other) => switch (this) {
        Ok() => false,
        Err(:final error) => error == other,
      };
}

extension InfallibleResult<R> on Result<R, Never> {
  /// Returns the value in the result. Since the result is infallible, this method never throws.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  R get value => unwrap();
}

extension InfallibleErrResult<E> on Result<Never, E> {
  /// Returns the error in the result. Since the err is infallible, this method never throws.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  E get error => unwrapErr();
}

extension ResultOption<R, E> on Result<Option<R>, E> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<Result<R, E>> transpose() => switch (this) {
        Ok(:final value) => value.map(Result.ok),
        Err(:final error) => Some(Result.err(error)),
      };
}

extension ResultFuture<R, E> on Result<Future<R>, Future<E>> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Future<Result<R, E>> get future => switch (this) {
        Ok(:final value) => value.then(Result.ok),
        Err(:final error) => error.then(Result.err),
      };
}

extension ResultFutureOk<R, E> on Result<Future<R>, E> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Future<Result<R, E>> get future => switch (this) {
        Ok(:final value) => value.then(Result.ok),
        Err(:final error) => Future.value(Result.err(error)),
      };
}

extension ResultFutureErr<R, E> on Result<R, Future<E>> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Future<Result<R, E>> get future => switch (this) {
        Ok(:final value) => Future.value(Result.ok(value)),
        Err(:final error) => error.then(Result.err),
      };
}

// unwrapOrDefault not currently possible generically; static extensions are used instead for known types

extension ResultResult<R, E> on Result<Result<R, E>, E> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<R, E> flatten() => switch (this) {
        Ok(:final value) => value,
        Err(:final error) => Result.err(error),
      };
}

extension ResultBool<E> on Result<bool, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `false`.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool unwrapOrDefault() => unwrapOr(false);
}

extension ResultInt<E> on Result<int, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `0`.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int unwrapOrDefault() => unwrapOr(0);
}

extension ResultDouble<E> on Result<double, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `0.0`.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  double unwrapOrDefault() => unwrapOr(0.0);
}

extension ResultNum<E> on Result<num, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `0`.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  num unwrapOrDefault() => unwrapOr(0);
}

extension ResultString<E> on Result<String, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `''`.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String unwrapOrDefault() => unwrapOr('');
}

extension ResultDateTime<E> on Result<DateTime, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `DateTime(0)`.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  DateTime unwrapOrDefault() => unwrapOr(DateTime(0));
}

extension ResultList<T, E> on Result<List<T>, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `[]`.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  List<T> unwrapOrDefault() => unwrapOr([]);
}

extension ResultMap<K, V, E> on Result<Map<K, V>, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `{}`.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Map<K, V> unwrapOrDefault() => unwrapOr({});
}

extension ResultSet<T, E> on Result<Set<T>, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `{}`.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Set<T> unwrapOrDefault() => unwrapOr({});
}

extension ResultIterable<T, E> on Result<Iterable<T>, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `[]`.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Iterable<T> unwrapOrDefault() => unwrapOr([]);
}

extension ResultStream<T, E> on Result<Stream<T>, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `Stream.empty()`.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Stream<T> unwrapOrDefault() => unwrapOr(Stream<T>.empty());
}

extension ResultDuration<E> on Result<Duration, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `Duration.zero`.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Duration unwrapOrDefault() => unwrapOr(Duration.zero);
}
