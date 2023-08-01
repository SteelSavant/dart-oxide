import 'dart:async';

import 'package:dart_oxide_core/types.dart';

extension IterableResult<R, E> on Iterable<Result<R, E>> {
  Iterable<R> whereOk() sync* {
    for (final option in this) {
      switch (option) {
        case Ok(:final value):
          yield value;

        default:
          break;
      }
    }
  }

  Iterable<R> whereOkAnd(bool Function(R) predicate) sync* {
    for (final option in this) {
      switch (option) {
        case Ok(:final value) when predicate(value):
          yield value;

        default:
          break;
      }
    }
  }

  Result<List<R>, E> collectResult() => fold<Result<List<R>, E>>(
        Result<List<R>, E>.ok([]),
        (acc, next) =>
            acc.andThen((list) => next.map((value) => list..add(value))),
      );
}

extension StreamResult<R, E> on Stream<Result<R, E>> {
  Stream<R> whereOk() async* {
    await for (final option in this) {
      switch (option) {
        case Ok(:final value):
          yield value;

        default:
          break;
      }
    }
  }

  Stream<R> whereOkAnd(bool Function(R) predicate) async* {
    await for (final option in this) {
      switch (option) {
        case Ok(:final value) when predicate(value):
          yield value;

        default:
          break;
      }
    }
  }

  Stream<R> takeWhileOk() => takeWhile((element) => element.isOk).whereOk();

  Stream<Result<R, E>> skipWhileErr() => skipWhile((element) => element.isErr);

  Future<Result<List<R>, E>> collectResult() async {
    final list = <R>[];

    return transform(
      StreamTransformer.fromHandlers(
        handleData: (data, EventSink<Result<List<R>, E>> sink) {
          if (data.isOk) {
            list.add(data.unwrap());
          } else {
            sink
              ..add(Result<List<R>, E>.err(data.unwrapErr()))
              ..close();
          }
        },
        handleDone: (sink) {
          sink
            ..add(Result<List<R>, E>.ok(list))
            ..close();
        },
      ),
    ).last;
  }
}
