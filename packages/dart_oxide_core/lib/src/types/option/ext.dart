import 'package:dart_oxide_core/types.dart';

extension NullableExt<T> on T? {
  Option<T> toOption() => Option.fromNullable(this);
}

extension IterableOption<T> on Iterable<Option<T>> {
  Iterable<T> whereSome() sync* {
    for (final option in this) {
      if (option.isSome) {
        yield option.unwrap();
      }
    }
  }

  Iterable<T> whereSomeAnd(bool Function(T) predicate) sync* {
    for (final option in this) {
      if (option.isSomeAnd(predicate)) {
        yield option.unwrap();
      }
    }
  }

  Iterable<R> mapWhereSome<R>(R Function(T) mapper) sync* {
    for (final option in this) {
      switch (option) {
        case Some(:final value):
          yield mapper(value);

        case None():
          break;
      }
    }
  }
}

extension StreamOption<T> on Stream<Option<T>> {
  Stream<T> whereSome() =>
      where((option) => option.isSome).map((option) => option.unwrap());

  Stream<T> whereSomeAnd(bool Function(T) predicate) async* {
    await for (final option in this) {
      if (option.isSomeAnd(predicate)) {
        yield option.unwrap();
      }
    }
  }

  Stream<R> mapWhereSome<R>(R Function(T) mapper) async* {
    await for (final option in this) {
      switch (option) {
        case Some(:final value):
          yield mapper(value);

        case None():
          break;
      }
    }
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Stream<T> takeWhileSome() =>
      takeWhile((element) => element.isSome).whereSome();

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  Stream<T> skipWhileNone() =>
      skipWhile((element) => element.isNone).whereSome();
}
