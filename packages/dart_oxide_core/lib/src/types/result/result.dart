import 'dart:async';

import 'package:dart_oxide_core/src/types/option/option.dart';
import 'package:dart_oxide_core/src/types/single_element_iterator.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// [Result] is a type that represents either success ([Ok]) or failure ([Err]).
@Freezed(copyWith: false)
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

  /// Returns [true] if the result is [Ok]
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(1);
  /// assert(ok.isOk == true);
  ///
  /// final err = Result<int, String>.err('error');
  /// assert(err.isOk == false);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool get isOk => this is Ok<R, E>;

  /// Returns [true] if the result is [Err]
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(1);
  /// assert(ok.isErr == false);
  ///
  /// final err = Result<int, String>.err('error');
  /// assert(err.isErr == true);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool get isErr => this is Err<R, E>;

  /// Returns [true] if the result is [Ok] and the value inside matches the given [predicate].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final okPass = Result<int, String>.ok(2);
  /// assert(ok.isOkAnd((value) => value > 1) == true);
  ///
  /// final okFail = Result<int, String>.ok(1);
  /// assert(ok.isOkAnd((value) => value > 1) == false);
  ///
  /// final err = Result<int, String>.err('error');
  /// assert(err.isOkAnd((value) => value > 1) == false);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool isOkAnd(bool Function(R) predicate) => switch (this) {
        Ok(:final value) => predicate(value),
        Err() => false,
      };

  /// Returns [true] if the result is [Err] and the error inside matches the given [predicate].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(1);
  /// assert(ok.isErrAnd((error) => error == 'error') == false);
  ///
  /// final errPass = Result<int, String>.err('error');
  /// assert(errPass.isErrAnd((error) => error == 'error') == true);
  ///
  /// final errFail = Result<int, String>.err('error2');
  /// assert(errFail.isErrAnd((error) => error == 'error') == false);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool isErrAnd(bool Function(E) predicate) => switch (this) {
        Ok() => false,
        Err(:final error) => predicate(error),
      };

  /// Converts from [Result<R, E>] to [Option<R>].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(2);
  /// assert(ok.ok() == Some(2));
  ///
  /// final err = Result<int, String>.err('error');
  /// assert(err.ok() == None());
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<R> ok() => switch (this) {
        Ok(:final value) => Option.some(value),
        Err() => Option<R>.none(),
      };

  /// Converts from [Result<R, E>] to [Option<E>].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(2);
  /// assert(ok.err() == None());
  ///
  /// final err = Result<int, String>.err('error');
  /// assert(err.err() == Some('error'));
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<E> err() => switch (this) {
        Ok() => Option<E>.none(),
        Err(:final error) => Option.some(error),
      };

  /// Maps a [Result<R, E>] to [Result<R2, E>] by applying a function to a
  /// contained [Ok] value, leaving an [Err] value untouched.
  ///
  /// This function can be used to compose the results of two functions.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(2);
  /// assert(ok.map((value) => value + 1) == Result<int, String>.ok(3));
  ///
  /// final err = Result<int, String>.err('error');
  /// assert(err.map((value) => value + 1) == Result<int, String>.err('error'));
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<R2, E> map<R2>(R2 Function(R) fn) => switch (this) {
        Ok(:final value) => Result.ok(fn(value)),
        Err(:final error) => Result.err(error),
      };

  /// Returns the provided default [or] (if [Err]), or applies a function to the
  /// contained value (if [Ok]),
  ///
  /// Arguments passed to `mapOr` are eagerly evaluated; if you are passing the
  /// result of a function call, it is recommended to use [mapOrElse], which is
  /// lazily evaluated.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(1);
  /// assert(ok.mapOr(or: 5, map: (value) => value + 1) == 2);
  ///
  /// final err = Result<int, String>.err('error');
  /// assert(err.mapOr(or: 5, map: (value) => value + 1) == 5);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  R2 mapOr<R2>({required R2 Function(R) map, required R2 or}) => switch (this) {
        Ok(:final value) => map(value),
        Err() => or,
      };

  /// Maps a [Result<R, E>] to [R2] by applying a fallback function [orElse] to
  /// a contained [Err] value, or a function [map] to a contained [Ok] value.
  ///
  /// This function can be used to unpack a successful result while
  /// handling an error.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(2);
  /// assert(ok.mapOrElse(map: (value) => value + 1, orElse: (error) => 0) == 3);
  ///
  /// final err = Result<int, String>.err('error');
  /// assert(err.mapOrElse(map: (value) => value + 1, orElse: (error) => 0) == 0);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  R2 mapOrElse<R2>({
    required R2 Function(R) map,
    required R2 Function(E) orElse,
  }) =>
      switch (this) {
        Ok(:final value) => map(value),
        Err(:final error) => orElse(error),
      };

  /// Maps a [Result<R, E>] to [Result<R, E2>] by applying a function to a
  /// contained [Err] value, leaving an [Ok] value untouched.
  ///
  /// This function can be used to pass through a successful result while
  /// handling an error.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(2);
  /// assert(ok.mapErr((error) => 'error') == Result<int, String>.ok(2));
  ///
  /// final err = Result<int, String>.err('error');
  /// assert(err.mapErr((error) => 'error2') == Result<int, String>.err('error2'));
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<R, E2> mapErr<E2>(E2 Function(E) fn) => switch (this) {
        Ok(:final value) => Result.ok(value),
        Err(:final error) => Result.err(fn(error)),
      };

  /// Calls [fn] on the contained value if the result is [Ok], and returns [this]
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(2);
  /// ok.inspect((value) => print(value)); // prints 2
  ///
  /// final err = Result<int, String>.err('error');
  /// err.inspect((value) => print(value)); // does nothing
  /// ```
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

  /// Calls [fn] on the contained error if the result is [Err], and returns [this].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(2);
  /// ok.inspectErr((error) => print(error)); // does nothing
  ///
  /// final err = Result<int, String>.err('error');
  /// err.inspectErr((error) => print(error)); // prints 'error'
  /// ```
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

  /// Returns an iterator over the possibly contained value.
  ///
  /// # Examples
  ///
  /// ```
  /// final xiter = Resutl<int, String>.ok(4).iter;
  /// assert(iter.moveNext() == true);
  /// assert(iter.current == 4);
  ///
  /// final yiter = Result<int, String>.err('error').iter;
  /// assert(iter.moveNext() == false);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Iterable<R> get iter => SingleElementIter(ok());

  /// Returns the contained [Ok] value.
  ///
  /// Because this function may throw, its use is generally discouraged.
  /// Instead, prefer to use pattern matching and handle the [Err] case explicitly,
  /// or call [unwrapOr] or [unwrapOrElse]. Some primitive types
  /// also provide an [unwrapOrDefault] extension method to provide a default value.
  ///
  /// # Throws
  ///
  /// Throws a [StateError] with the provided [message] if the result is [Err].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(2);
  /// assert(ok.unwrap('error') == 2);
  ///
  /// final err = Result<int, String>.err('error');
  /// err.unwrap('is an error'); // throws StateError('is an error')
  /// ```
  ///
  /// We recommend that [expect] messages are used to describe the reason
  /// you _expect_ the [Result] should be [Ok].
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
  bool contains(R element) => switch (this) {
        Ok(:final value) => value == element,
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

extension ResultResult<R, E> on Result<Result<R, E>, E> {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<R, E> flatten() => switch (this) {
        Ok(:final value) => value,
        Err(:final error) => Result.err(error),
      };
}

// unwrapOrDefault not currently possible generically; static extensions are used instead for known types

extension ResultBool<E> on Result<bool, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `false`.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<bool, Exception>.ok(true);
  /// final err = Result<bool, Exception>.err(Exception());
  ///
  /// assert(ok.unwrapOrDefault() == true);
  /// assert(err.unwrapOrDefault() == false);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool unwrapOrDefault() => unwrapOr(false);
}

extension ResultInt<E> on Result<int, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `0`.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, Exception>.ok(1);
  /// final err = Result<int, Exception>.err(Exception());
  ///
  /// assert(ok.unwrapOrDefault() == 1);
  /// assert(err.unwrapOrDefault() == 0);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int unwrapOrDefault() => unwrapOr(0);
}

extension ResultDouble<E> on Result<double, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `0.0`.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<double, Exception>.ok(1.0);
  /// final err = Result<double, Exception>.err(Exception());
  ///
  /// assert(ok.unwrapOrDefault() == 1.0);
  /// assert(err.unwrapOrDefault() == 0.0);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  double unwrapOrDefault() => unwrapOr(0.0);
}

extension ResultNum<E> on Result<num, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `0`.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<num, Exception>.ok(1);
  /// final err = Result<num, Exception>.err(Exception());
  ///
  /// assert(ok.unwrapOrDefault() == 1);
  /// assert(err.unwrapOrDefault() == 0);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  num unwrapOrDefault() => unwrapOr(0);
}

extension ResultString<E> on Result<String, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `''`.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<String, Exception>.ok('hello');
  /// final err = Result<String, Exception>.err(Exception());
  ///
  /// assert(ok.unwrapOrDefault(); == 'hello');
  /// assert(err.unwrapOrDefault == '');
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String unwrapOrDefault() => unwrapOr('');
}

extension ResultDateTime<E> on Result<DateTime, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `DateTime(0)`.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<DateTime, Exception>.ok(DateTime(1));
  /// final err = Result<DateTime, Exception>.err(Exception());
  ///
  /// assert(ok.unwrapOrDefault() == DateTime(1));
  /// assert(err.unwrapOrDefault() == DateTime(0));
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  DateTime unwrapOrDefault() => unwrapOr(DateTime(0));
}

extension ResultList<T, E> on Result<List<T>, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `<T>[]`.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<List<int>, Exception>.ok([1, 2, 3]);
  /// final err = Result<List<int>, Exception>.err(Exception());
  ///
  /// assert(ok.unwrapOrDefault() == [1, 2, 3]);
  /// assert(err.unwrapOrDefault() == []);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  List<T> unwrapOrDefault() => unwrapOr([]);
}

extension ResultMap<K, V, E> on Result<Map<K, V>, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `<K,V>{}`.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<Map<int, int>, Exception>.ok({1: 1, 2: 2, 3: 3});
  /// final err = Result<Map<int, int>, Exception>.err(Exception());
  ///
  /// assert(ok.unwrapOrDefault() == {1: 1, 2: 2, 3: 3});
  /// assert(err.unwrapOrDefault() == {});
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Map<K, V> unwrapOrDefault() => unwrapOr({});
}

extension ResultSet<T, E> on Result<Set<T>, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `<T>{}`.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<Set<int>, Exception>.ok({1, 2, 3});
  /// final err = Result<Set<int>, Exception>.err(Exception());
  ///
  /// assert(ok.unwrapOrDefault() == {1, 2, 3});
  /// assert(err.unwrapOrDefault() == {});
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Set<T> unwrapOrDefault() => unwrapOr({});
}

extension ResultIterable<T, E> on Result<Iterable<T>, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `[]`.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<Iterable<int>, Exception>.ok([1, 2, 3]);
  /// final err = Result<Iterable<int>, Exception>.err(Exception());
  ///
  /// assert(ok.unwrapOrDefault().toList() == [1, 2, 3]);
  /// assert(err.unwrapOrDefault().toList() == []);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Iterable<T> unwrapOrDefault() => unwrapOr([]);
}

extension ResultStream<T, E> on Result<Stream<T>, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `Stream.empty()`.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<Stream<int>, Exception>.ok(Stream.fromIterable([1, 2, 3]));
  /// final err = Result<Stream<int>, Exception>.err(Exception());
  ///
  /// assert(await ok.unwrapOrDefault().toList() == [1, 2, 3]);
  /// assert(await err.unwrapOrDefault().toList() == []);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Stream<T> unwrapOrDefault() => unwrapOr(Stream<T>.empty());
}

extension ResultDuration<E> on Result<Duration, E> {
  /// Returns the value in the [Result] if it is [isOk], otherwise returns `Duration.zero`.
  ///
  /// # Examples
  ///
  /// ```
  /// final ok = Result<Duration, Exception>.ok(const Duration(seconds: 1));
  /// final err = Result<Duration, Exception>.err(Exception());
  ///
  /// assert(ok.unwrapOrDefault() == const Duration(seconds: 1));
  /// assert(err.unwrapOrDefault() == Duration.zero);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Duration unwrapOrDefault() => unwrapOr(Duration.zero);
}
