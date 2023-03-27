import 'package:dart_oxide_core/types.dart';

extension IterableOption<T> on Iterable<Option<T>> {
  Iterable<T> whereSome() sync* {
    for (final option in this) {
      if (option.isSome) {
        yield option.unwrap();
      }
    }
  }

  Iterable<T> mapWhere(bool Function(T) predicate) sync* {
    for (final option in this) {
      if (option.isNone) {
        yield option.unwrap();
      }
    }
  }
}

extension StreamOption<T> on Stream<Option<T>> {
  Stream<T> whereSome() =>
      where((option) => option.isSome).map((option) => option.unwrap());

  Stream<T> mapWhere(bool Function(T) predicate) =>
      where((option) => option.isSome)
          .map((option) => option.unwrap())
          .where(predicate);

  Stream<T> takeWhileSome() =>
      takeWhile((element) => element.isSome).whereSome();
}
