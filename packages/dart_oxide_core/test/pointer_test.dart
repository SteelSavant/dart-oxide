import 'dart:async';

import 'package:dart_oxide_core/pointers.dart';
import 'package:dart_oxide_core/types.dart';
import 'package:spec/spec.dart';

class _SyncDisposable implements IDisposable {
  int x = 1;

  _SyncDisposable();

  @override
  () dispose() => (x = 5).toUnit();
}

class _AsyncDisposable implements IAsyncDisposable {
  int x = 1;

  _AsyncDisposable();

  @override
  Future<()> dispose() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    x = 5;
    return ();
  }
}

void main() {
  group('Disposable tests', () {
    test('Test unwrap DisposableDisposableBox on sync disposable', () {
      final disposable = _SyncDisposable().toBox();

      expect(disposable.unwrap().x).toEqual(1);
      disposable.dispose();
      expect(disposable.unwrap).throws.isStateError();
    });

    test('Test unwrap DisposableDisposableBox on async disposable', () async {
      final disposable = _AsyncDisposable().toBox();

      expect(disposable.unwrap().x).toEqual(1);
      await disposable.dispose();
      expect(disposable.unwrap).throws.isStateError();
    });

    test('Test sync dispose function actually invoked', () {
      final internal = _SyncDisposable();
      final disposable = Box.fromDisposable(
        internal,
      );

      expect(disposable.unwrap().x).toEqual(1);
      disposable.dispose();
      expect(internal.x).toEqual(5);
    });

    test('Test async dispose function actually invoked', () async {
      final internal = _AsyncDisposable();
      final disposable = Box.fromAsyncDisposable(
        internal,
      );

      expect(disposable.unwrap().x).toEqual(1);
      await disposable.dispose();
      expect(internal.x).toEqual(5);
    });

    test('Test standard constructor dispose function actually invoked', () {
      var x = 1;
      final disposable = Box(
        x,
        onDispose: (int d) {
          x += d;
          return ();
        },
      );

      expect(disposable.unwrap()).toEqual(1);
      disposable.dispose();
      expect(x).toEqual(2);
    });

    test(
        'Test mixed DisposableDisposableBox types in collection unify correctly across FutureOr types',
        () {
      final disposables = [
        Box.fromDisposable(_SyncDisposable()),
        Box.fromAsyncDisposable(_SyncDisposable()),
      ];

      expect(disposables).isA<List<Box<_SyncDisposable, FutureOr<()>>>>();
    });
  });
}
