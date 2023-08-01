import 'dart:collection';

import 'package:dart_oxide_core/src/types/option/option.dart';

class SingleElementIter<T> with IterableMixin<T> {
  final Option<T> _option;

  SingleElementIter(this._option);

  @override
  Iterator<T> get iterator => SingleElementIterator(_option);

  @override
  int get length => _option.isSome ? 1 : 0;

  @override
  bool get isEmpty => _option.isNone;

  @override
  bool get isNotEmpty => !isEmpty;

  @override
  T get first => _option.unwrap();

  @override
  T get last => _option.unwrap();

  @override
  T get single => _option.unwrap();

  @override
  T elementAt(int index) {
    if (index == 0) {
      return _option.unwrap();
    } else {
      throw RangeError.index(index, this);
    }
  }
}

class SingleElementIterator<T> implements Iterator<T> {
  bool _checked = false;
  final Option<T> _value;

  SingleElementIterator(this._value);

  @override
  bool moveNext() {
    final ret = _value.isSome && !_checked;
    _checked = true;
    return ret;
  }

  @override
  T get current => _value.unwrap();
}
