import 'dart:async';

import 'package:dart_oxide_core/src/types/option/option.dart';
import 'package:dart_oxide_core/src/types/single_element_iterator.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// [Result] is a type that represents either success ([Ok]) or failure ([Err]).
// TODO:: overview
@Freezed(copyWith: false)
sealed class Result<R, E> with _$Result<R, E> {
  const Result._();

  /// Creates a [Result] that contains a value.
  const factory Result.ok(R value) = Ok<R, E>;

  /// Creates a [Result] that contains an error.
  const factory Result.err(E error) = Err<R, E>;

  /// Executes the given [fn] and returns [Ok] if no exception is thrown,
  /// otherwise returns [Err] with the thrown exception mapped to [E] by [onError].
  /// Both [fn] and [onError] must be synchronous.
  static Result<R, E> guard<R, E, X extends Object>(
    R Function() fn, {
    required E Function(X) onError,
  }) {
    try {
      return Result.ok(fn());
    } on X catch (error) {
      return Result.err(onError(error));
    }
  }

  /// Executes the given [fn] and returns [Ok] if no exception is thrown,
  /// otherwise returns [Err] with the thrown exception mapped to [E] by [onError].
  /// Any of [fn] and [onError] may be asynchronous.
  static Future<Result<R, E>> guardAsync<R, E, X extends Object>(
    FutureOr<R> Function() fn, {
    required FutureOr<E> Function(X) onError,
  }) async {
    try {
      return Result<R, E>.ok(await fn());
    } on X catch (error) {
      return Result.err(await onError(error));
    }
  }

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

  /// Returns the contained [Err] value.
  ///
  /// # Throws
  ///
  /// Throws a [StateError] with the provided [message] if the result is [Ok].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(2);
  /// ok.expectErr('is an error'); // throws StateError('is an error')
  ///
  /// final err = Result<int, String>.err('error');
  /// assert(err.expectErr('error') == 'error');
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  E expectErr(String message) => switch (this) {
        Ok() => throw StateError(message),
        Err(:final error) => error,
      };

  /// Returns the contained [Ok] value.
  ///
  /// Because this function may throw, its use is generally discouraged.
  /// Instead, prefer to use pattern matching and handle the [Err] case explicitly,
  /// or call [unwrapOr] or [unwrapOrElse]. Some primitive types also
  /// provide an [unwrapOrDefault] extension method to provide a default value.
  ///
  /// # Throws
  ///
  /// Throws a [StateError] if the result is [Err].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(2);
  /// assert(ok.unwrap() == 2);
  ///
  /// final err = Result<int, String>.err('error');
  /// err.unwrap(); // throws StateError('Result is Err(error)')
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  R unwrap() => switch (this) {
        Ok(:final value) => value,
        Err(:final error) => throw StateError('Result is Err($error)'),
      };

  /// Returns the contained [Ok] value or a provided default.
  ///
  /// Arguments passed to `unwrapOr` are eagerly evaluated; if you are passing the
  /// result of a function call, it is recommended to use [unwrapOrElse], which is
  /// lazily evaluated.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(2);
  /// assert(ok.unwrapOr(3) == 2);
  ///
  /// final err = Result<int, String>.err('error');
  /// assert(err.unwrapOr(3) == 3);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  R unwrapOr(R or) => switch (this) {
        Ok(:final value) => value,
        Err() => or,
      };

  /// Returns the contained [Ok] value or computes it from a closure.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(2);
  /// assert(ok.unwrapOrElse((error) => 3) == 2);
  ///
  /// final err = Result<int, String>.err('error');
  /// assert(err.unwrapOrElse((error) => 3) == 3);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  R unwrapOrElse(R Function(E) orElse) => switch (this) {
        Ok(:final value) => value,
        Err(:final error) => orElse(error),
      };

  /// Returns the contained [Err] value.
  ///
  /// # Throws
  ///
  /// Throws a [StateError] if the result is [Ok].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(2);
  /// ok.unwrapErr(); // throws StateError('Result is Ok(2)')
  ///
  /// final err = Result<int, String>.err('error');
  /// assert(err.unwrapErr() == 'error');
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  E unwrapErr() => switch (this) {
        Ok(:final value) => throw StateError('Result is Ok($value)'),
        Err(:final error) => error,
      };

  /// Returns [res] if the result is [Ok], otherwise returns the [Err] value of [this].
  ///
  /// Arguments passed to `and` are eagerly evaluated; if you are passing the
  /// result of a function call, it is recommended to use [andThen], which is
  /// lazily evaluated.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(2);
  /// final late = Result<int, String>.err('late error');
  /// final early = Result<int, String>.err('early error');
  /// final differentOk = Result<String, String>.ok('different ok');
  ///
  /// assert(ok.and(late) == Result<int, String>.err('late error'));
  /// assert(early.and(ok) == Result<int, String>.err('early error'));
  /// assert(early.and(late) == Result<int, String>.err('early error'));
  /// assert(ok.and(differentOk) == Result<String, String>.ok('different ok'));
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<U, E> and<U>(Result<U, E> res) => switch (this) {
        Ok() => res,
        Err(:final error) => Result.err(error),
      };

  /// Calls [fn] if the result is [Ok], otherwise returns the [Err] value of [this].
  ///
  /// This function can be used for control flow based on [Result] values.
  /// Often used to chain fallible operations that may return [Err].
  ///
  /// # Examples
  ///
  /// ```
  /// final sq = (x) => Result<int, String>.ok((x * x).toString());
  ///
  /// assert(Result<int, String>.ok(2).andThen(sq) == Result<int, String>.ok('4'));
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<U, E> andThen<U>(Result<U, E> Function(R) fn) => switch (this) {
        Ok(:final value) => fn(value),
        Err(:final error) => Result.err(error)
      };

  /// Returns [res] if the result is [Err], otherwise returns the [Ok] value of [this].
  ///
  /// Arguments passed to `or` are eagerly evaluated; if you are passing the
  /// result of a function call, it is recommended to use [orElse], which is
  /// lazily evaluated.
  ///
  /// # Examples
  ///
  /// ```dart
  /// final ok = Result<int, String>.ok(2);
  /// final otherOk = Result<int, String>.ok(100);
  /// final late = Result<int, String>.err('late error');
  /// final early = Result<int, String>.err('early error');
  ///
  /// assert(ok.or(late) == Result<int, String>.ok(2));
  /// assert(early.or(ok) == Result<int, String>.ok(2));
  /// assert(early.or(late) == Result<int, String>.err('late error'));
  /// assert(ok.or(otherOk) == Result<int, String>.ok(2));
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<R, F> or<F>(Result<R, F> err) => switch (this) {
        Ok(:final value) => Result.ok(value),
        Err() => err,
      };

  /// Calls [fn] if the result is [Err], otherwise returns the [Ok] value of [this].
  ///
  /// This function can be used for control flow based on [Result] values.
  ///
  /// # Examples
  ///
  /// ```
  /// final sq = (x) => Result<int, int>.ok(x * x);
  /// final err = (x) => Result<int, int>.err(x);
  ///
  /// assert(Result<int, int>.ok(2).orElse(sq).orElse(sq) == Result<int, int>.ok(2));
  /// assert(Result<int, int>.ok(2).orElse(err).orElse(sq) == Result<int, int>.ok(2));
  /// assert(Result<int, int>.err(3).orElse(sq).orElse(err) == Result<int, int>.ok(9));
  /// assert(Result<int, int>.err(3).orElse(err).orElse(err) == Result<int, int>.err(3));
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<R, F> orElse<F>(Result<R, F> Function(E) fn) => switch (this) {
        Ok(:final value) => Result.ok(value),
        Err(:final error) => fn(error),
      };
}

extension InfallibleResult<R> on Result<R, Never> {
  /// Returns the contained [Ok] value, but never panics.
  ///
  /// Unlike [unwrap], this method doesn't throw and is only callable
  /// on [Result]s that are infallible. Therefore, it can be used instead of
  /// [unwrap] as a maintainability safeguard that will fail to compile if the
  /// error type of the [Result] is later changed to an error that can actually
  /// occur.
  ///
  /// # Examples
  ///
  /// ```dart
  /// fn foo() => Result<int, Never>.ok(1);
  ///
  /// assert(foo().value == 1);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  R get value => unwrap();
}

extension InfallibleErrResult<E> on Result<Never, E> {
  /// Returns the contained [Err] value, but never panics.
  ///
  /// Unlike [unwrapErr], this method doesn't throw and is only callable
  /// on [Result]s that always fail. Therefore, it can be used instead of
  /// [unwrapErr] as a maintainability safeguard that will fail to compile if the
  /// ok type of the [Result] is later changed to a type that can actually
  /// occur.
  ///
  /// # Examples
  ///
  /// ```dart
  /// fn foo() => Result<Never, String>.err('error');
  ///
  /// assert(foo().err == 'error');
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  E get error => unwrapErr();
}

extension ResultOption<R, E> on Result<Option<R>, E> {
  /// Transposes a [Result] of an [Option] into an [Option] of a [Result].
  ///
  /// [Ok(None)] will be mapped to [None].
  /// [Ok(Some(_))] and [Err(_)] will be mapped to [Some(Ok(_))] and [Some(Err(_))].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final x = Result<Option<int>, String>.ok(Some(5));
  /// final y = Option<Result<int, String>>.some(Result.ok(5));
  /// assert(x.transposed == y);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Option<Result<R, E>> get transposed => switch (this) {
        Ok(:final value) => value.map(Result.ok),
        Err(:final error) => Some(Result.err(error)),
      };
}

extension ResultFuture<R, E> on Result<Future<R>, Future<E>> {
  /// Converts a [Result] of a [Future] into a [Future] of a [Result].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final x = Result<Future<int>, Future<String>>.ok(Future.value(5));
  /// final y = Future<Result<int, String>>.value(Result.ok(5));
  /// assert(x.wait == y);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Future<Result<R, E>> get wait => switch (this) {
        Ok(:final value) => value.then(Result.ok),
        Err(:final error) => error.then(Result.err),
      };
}

extension ResultFutureOk<R, E> on Result<Future<R>, E> {
  /// Converts a [Result] of a [Future] into a [Future] of a [Result].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final x = Result<Future<int>, String>.ok(Future.value(5));
  /// final y = Future<Result<int, String>>.value(Result.ok(5));
  /// assert(x.wait == y);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Future<Result<R, E>> get wait => switch (this) {
        Ok(:final value) => value.then(Result.ok),
        Err(:final error) => Future.value(Result.err(error)),
      };
}

extension ResultFutureErr<R, E> on Result<R, Future<E>> {
  /// Converts a [Result] of a [Future] into a [Future] of a [Result].
  ///
  /// # Examples
  ///
  /// ```dart
  /// final x = Result<int, Future<String>>.err(Future.value('error'));
  /// final y = Future<Result<int, String>>.value(Result.err('error'));
  /// assert(x.wait == y);
  /// ```
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Future<Result<R, E>> get wait => switch (this) {
        Ok(:final value) => Future.value(Result.ok(value)),
        Err(:final error) => error.then(Result.err),
      };
}

extension ResultResult<R, E> on Result<Result<R, E>, E> {
  /// Converts from [Result<Result\<R, E\>, E>] to [Result<R, E>].
  ///
  /// # Examples
  ///
  /// ```
  /// final ok = Result<Result<int, String>, String>.ok(Result.ok(1));
  /// assert(ok.flattened == Result.ok(1));
  ///
  /// final err = Result<Result<int, String>, String>.err('error');
  /// assert(err.flattened == Result.err('error'));
  /// ```
  ///
  /// Flattening only removes one level of nesting at a time.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Result<R, E> get flattened => switch (this) {
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
