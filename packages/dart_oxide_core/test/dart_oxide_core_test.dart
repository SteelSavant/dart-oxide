import 'package:dart_oxide_core/pointers.dart';
import 'package:dart_oxide_core/src/types/disposable.dart';
import 'package:dart_oxide_core/types.dart';
import 'package:spec/spec.dart';

void main() {
  group('RC tests', () {
    test('RC', () async {
      int disposeCount = 0;
      final rc = Rc(SyncDisposable(0, onDispose: (_) {
        disposeCount += 1;
      }));

      final rc2 = rc.clone();
      expect(disposeCount).toBe(0);

      final rc3 = rc.clone();
      expect(disposeCount).toBe(0);

      await rc.dispose();
      expect(disposeCount).toBe(0);

      await rc2.dispose();
      expect(disposeCount).toBe(0);

      await rc3.dispose();

      expect(disposeCount).toBe(1);
    });
  });

  group('Ref tests', () {
    test('Ref', () {
      final ref = Ref(0);

      expect(ref.value).toBe(0);

      ref.value = 5;

      expect(ref.value).toBe(5);
    });
  });

  group('Option tests', () {
    test('Some value', () {
      const some = Option.some(0);

      expect(some.isSome).toBe(true);
      expect(some.isNone).toBe(false);
      expect(some.unwrap()).toBe(0);
    });

    test('None value', () {
      const none = Option<int>.none();

      expect(none.isSome).toBe(false);
      expect(none.isNone).toBe(true);
      expect(() => none.unwrap()).throws.isStateError();
    });

    test('Some isSomeAnd', () {
      const some = Option.some(0);

      expect(some.isSomeAnd((value) => value == 0)).toBe(true);
      expect(some.isSomeAnd((value) => value == 1)).toBe(false);
    });

    test('None isSomeAnd', () {
      const none = Option<int>.none();

      expect(none.isSomeAnd((value) => value == 0)).toBe(false);
    });
  });

  group('Result tests', () {
    test('Ok value', () {
      const ok = Result<int, String>.ok(0);

      expect(ok.isOk).toBe(true);
      expect(ok.isErr).toBe(false);
      expect(ok.unwrap()).toBe(0);
    });

    test('Err value', () {
      const err = Result<int, String>.err('error');

      expect(err.isOk).toBe(false);
      expect(err.isErr).toBe(true);
      expect(() => err.unwrap()).throws.isStateError();
    });

    test('Ok isOkAnd', () {
      const ok = Result<int, String>.ok(0);

      expect(ok.isOkAnd((value) => value == 0)).toBe(true);
      expect(ok.isOkAnd((value) => value == 1)).toBe(false);
    });

    test('Err isOkAnd', () {
      const err = Result<int, String>.err('error');

      expect(err.isOkAnd((value) => value == 0)).toBe(false);
    });
  });

  group('Newtype tests', () {
    test('Newtype', () {
      const accountId = NewType<int, _AccountIdBrand>(0);
      const userId = NewType<int, _UserIdBrand>(0);

      // ignore: unrelated_type_equality_checks
      expect(accountId == userId).toBe(false);
    });
  });

  group('Disposable tests', () {
    test('SyncDisposable', () {
      int disposeCount = 0;
      final disposable = SyncDisposable(0, onDispose: (_) {
        disposeCount += 1;
      });

      expect(disposeCount).toBe(0);

      disposable.dispose();

      expect(disposeCount).toBe(1);
    });

    test('AsyncDisposable', () async {
      int disposeCount = 0;
      final disposable = AsyncDisposable(0, onDispose: (_) async {
        disposeCount += 1;
      });

      expect(disposeCount).toBe(0);

      await disposable.dispose();

      expect(disposeCount).toBe(1);
    });
  });
}

abstract class _AccountIdBrand {}

abstract class _UserIdBrand {}
