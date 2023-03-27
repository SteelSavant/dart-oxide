import 'dart:async';

import 'package:dart_oxide_core/src/types/disposable.dart';

/// Acts as an automatic reference counter for a disposable _value of type [T],
/// to allow shared access while assuring
/// that the object is not disposed of while still in scope.
/// The dispose method on the owned object should NOT be called
/// while the reference is held; disposing is handled by this object once
/// the reference count returns to zero.
///
/// While this is generally less useful in Dart due to garbage collection,
/// it can be useful in cases where the object may have multiple owners,
/// and where depending on the garbage-collector for disposal of resources is not desirable (for performance reasons, etc.).

class Rc<R extends IDisposable<R>>
    with DisposableMixin<Rc<R>>
    implements IAsyncDisposable<Rc<R>> {
  static final _counts = <Type, Map<int, int>>{};
  final R _value;

  R get value => _value.checked.unwrap();

  Map<int, int> get _typedCounts => checked.map((_) {
        _counts[R] ??= {};
        return _counts[R]!;
      }).unwrap();

  Rc(this._value) {
    _typedCounts[_value.hashCode] = (_typedCounts[_value.hashCode] ?? 0) + 1;
  }

  Rc<R> clone() => checked.map((value) => Rc<R>(value._value)).unwrap();

  @override
  Future<void> dispose() async {
    await super.dispose();
    _typedCounts[_value.hashCode] = _typedCounts[_value.hashCode]! - 1;

    if (_typedCounts[_value.hashCode] == 0) {
      _typedCounts.remove(_value.hashCode);
      return _value.dispose();
    }
  }
}
