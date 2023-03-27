import 'package:dart_oxide_core/types.dart';

extension IterableResult<R, E> on Iterable<Result<R, E>> {
  Iterable<R> whereOk() sync* {
    for (final option in this) {
      if (option.isOk) {
        yield option.unwrap();
      }
    }
  }

  Iterable<T> mapWhere<T>(Option<T> Function(R) predicate) sync* {
    for (final option in this) {
      if (option.isOk) {
        final value = predicate(option.unwrap());
        if (value.isSome) {
          yield value.unwrap();
        }
      }
    }
  }

  Result<List<R>, E> toResult() => fold<Result<List<R>, E>>(
        const Result.ok([]),
        (acc, next) =>
            acc.andThen((list) => next.map((value) => list..add(value))),
      );
}

extension StreamResult<R, E> on Stream<Result<R, E>> {
  Stream<R> whereOk() =>
      where((result) => result.isOk).map((result) => result.unwrap());

  Stream<T> mapWhere<T>(Option<T> Function(R) predicate) =>
      where((result) => result.isOk)
          .map((result) => predicate(result.unwrap()))
          .whereSome();

  Stream<R> takeWhileOk() => takeWhile((element) => element.isOk).whereOk();
}
