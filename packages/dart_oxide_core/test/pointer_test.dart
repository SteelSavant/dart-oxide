// TODO:: create pointer tests to test finalizer that run in vm_service (https://stackoverflow.com/questions/63730179/can-we-force-the-dart-garbage-collector)

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
  group('Box tests', () {
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

    test('Test wrapped value is correct', () {
      final disposable = Box.value(5);

      expect(disposable.wrapped).toEqual(const Result.ok(5));
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

      expect(disposables).isA<List<AsyncBox<_SyncDisposable, FutureOr<()>>>>();
    });

    test('Test expect to not throw if not disposed', () {
      final disposable = Box.fromDisposable(_SyncDisposable());

      expect(disposable.expect('Error').x).toEqual(1);
    });

    test('Test expect to throw with correct msg', () {
      final disposable = Box.fromDisposable(_SyncDisposable())..dispose();

      for (final (msg, includeDisposeTime, includeTrace) in [
        ('Default', false, false),
        ('With time', true, false),
        ('With Trace', false, true),
        ('With Time and Trace', true, true),
      ]) {
        try {
          final _ = disposable.expect(
            msg,
            includeDisposeTime: includeDisposeTime,
            includeTrace: includeTrace,
          );
        } on StateError catch (e) {
          expect(e.message).toContain(msg);
          if (includeDisposeTime) {
            expect(e.message).toContain(' at ');
          } else {
            expect(e.message).not.toContain(' at ');
          }
          if (includeTrace) {
            expect(e.message).toContain(' from ');
          } else {
            expect(e.message).not.toContain(' from ');
          }
        }
      }
    });
  });

  group('Rc tests', () {
    test('Test clone', () {
      final rc = Rc.fromDisposable(_SyncDisposable());
      final rc2 = rc.clone();

      expect(rc.unwrap().x).toEqual(1);
      expect(rc2.unwrap().x).toEqual(1);
    });

    test('Test clone after dispose fails', () async {
      final rc = Rc.fromAsyncDisposable(_AsyncDisposable());
      await rc.dispose();

      expect(rc.clone).throws.isStateError();
    });

    test('Test Rc does not dispose value if cloned is live', () {
      var x = 0;
      final rc = Rc(1, onDispose: (v) => (x += v).toUnit());
      final rc2 = rc.clone();
      rc.dispose();
      expect(rc.unwrap).throws.isStateError();
      expect(rc2.unwrap()).toEqual(1);
      expect(x).toEqual(0);
    });

    test('Test Rc does not dispose value if original is live', () {
      var x = 0;
      final rc = Rc(1, onDispose: (v) => (x += v).toUnit());
      final rc2 = rc.clone()..dispose();
      expect(rc.unwrap()).toEqual(1);
      expect(rc2.unwrap).throws.isStateError();
      expect(x).toEqual(0);
    });

    test('Test Rc disposes value if all Rcs are disposed', () {
      var x = 0;
      final rc = Rc(1, onDispose: (v) => (x += v).toUnit());
      final rc2 = rc.clone();
      rc.dispose();
      rc2.dispose();
      expect(rc.unwrap).throws.isStateError();
      expect(rc2.unwrap).throws.isStateError();
      expect(x).toEqual(1);
    });
  });

  group('Ptr tests', () {
    test('Test Ptr toBox', () {
      final box = Ptr(1).toBox();

      expect(box).isA<Box<int>>();
      expect(box.unwrap()).toEqual(1);
    });

    test('Test Ptr toRc', () {
      final rc = Ptr(1).toRc();

      expect(rc).isA<Rc<int>>();
      expect(rc.unwrap()).toEqual(1);
    });

    test('Test OptionPtr take from Some', () {
      final ptr = Ptr(const Option.some(1));
      final option = ptr.take();

      expect(option).isA<Option<int>>();
      expect(option.unwrap()).toEqual(1);
      expect(ptr.value).isA<Option<int>>();
      expect(ptr.value).toEqual(const Option.none());
    });

    test('Test OptionPtr take from None', () {
      final ptr = Ptr(const Option<int>.none());
      final option = ptr.take();

      expect(option).isA<Option<int>>();
      expect(option).toEqual(const Option.none());
      expect(ptr.value).isA<Option<int>>();
      expect(ptr.value).toEqual(const Option.none());
    });

    test('Test OptionPtr replace from Some', () {
      final ptr = Ptr(const Option.some(1));
      final option = ptr.replace(2);

      expect(option).isA<Option<int>>();
      expect(option.unwrap()).toEqual(1);
      expect(ptr.value).isA<Option<int>>();
      expect(ptr.value).toEqual(const Option.some(2));
    });

    test('Test OptionPtr replace from None', () {
      final ptr = Ptr(const Option<int>.none());
      final option = ptr.replace(2);

      expect(option).isA<Option<int>>();
      expect(option).toEqual(const Option.none());
      expect(ptr.value).isA<Option<int>>();
      expect(ptr.value).toEqual(const Option.some(2));
    });

    test('Test NullPtr take from NonNull', () {
      final ptr = Ptr<int?>(1);
      final value = ptr.take();

      expect(value).toEqual(1);
      expect(ptr.value).toEqual(null);
    });

    test('Test NullPtr take from Null', () {
      final ptr = Ptr<int?>(null);
      final value = ptr.take();

      expect(value).toEqual(null);
      expect(ptr.value).toEqual(null);
    });

    test('Test Ptr replace from NonNull', () {
      final ptr = Ptr(1);
      final value = ptr.replace(2);

      expect(value).toEqual(1);
      expect(ptr.value).toEqual(2);
    });

    test('Test Ptr replace from Null to NonNull', () {
      final ptr = Ptr<int?>(null);
      final value = ptr.replace(2);

      expect(value).toEqual(null);
      expect(ptr.value).toEqual(2);
    });

    test('Test Ptr replace from NonNull to Null', () {
      final ptr = Ptr<int?>(1);
      final value = ptr.replace(null);

      expect(value).toEqual(1);
      expect(ptr.value).toEqual(null);
    });
  });

  group('Test using statements', () {
    test('Test using', () {
      final box = Box.value(Ptr(1));
      using(box, (box) {
        box.unwrap().value = 2;
      });
    });
  });
}
