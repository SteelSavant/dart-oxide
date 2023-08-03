import 'package:dart_oxide_core/types.dart';
import 'package:spec/spec.dart';

void main() {
  group('NewType', () {
    test('Test NewType hashcode', () {
      const x = NewType<int, String>(1);

      const y = NewType<int, String>(1);

      expect(x.hashCode).toEqual(y.hashCode);
    });

    test('Test Newtype equality', () {
      const x = NewType<int, String>(1);

      const y = NewType<int, String>(1);

      expect(x).toEqual(y);
    });

    test('Test Newtype inequality', () {
      const dynamic x = NewType<int, String>(1);

      const dynamic y = NewType<int, int>(1);

      expect(x).not.toEqual(y);
    });
  });

  group('Option', () {
    test('Test toOption on null', () {
      const int? x = null;

      expect(x.toOption()).toEqual(const Option<int>.none());
    });

    test('Test toOption on non-null', () {
      const x = 1;

      expect(x.toOption()).toEqual(const Option.some(1));
    });

    test('Test toNullable on Some', () {
      const x = Option.some(1);

      expect(x.toNullable()).toEqual(1);
    });

    test('Test toNullable on None', () {
      const x = Option<int>.none();

      expect(x.toNullable()).toEqual(null);
    });

    test('Test Option equality', () {
      const x = Option.some(1);

      const y = Option.some(1);

      expect(x).toEqual(y);
    });

    test('Test Option inequality', () {
      const x = Option.some(1);

      const y = Option.some(2);

      expect(x).not.toEqual(y);
    });

    test('Test Option innequality with None', () {
      const x = Option.some(1);

      const y = Option<int>.none();

      expect(x).not.toEqual(y);
    });

    test('Test Option equality with None', () {
      const x = Option<int>.none();

      const y = Option<int>.none();

      expect(x).toEqual(y);
    });

    test('Test isSome on Some', () {
      const x = Option.some(1);

      expect(x.isSome).toEqual(true);
    });

    test('Test isSome on None', () {
      const x = Option<int>.none();

      expect(x.isSome).toEqual(false);
    });

    test('Test isNone on Some', () {
      const x = Option.some(1);

      expect(x.isNone).toEqual(false);
    });

    test('Test isNone on None', () {
      const x = Option<int>.none();

      expect(x.isNone).toEqual(true);
    });

    test('Test isSomeAnd on Some', () {
      const x = Option.some(1);

      expect(x.isSomeAnd((_) => true)).toEqual(true);
    });

    test('Test isSomeAnd on None', () {
      const x = Option<int>.none();

      expect(x.isSomeAnd((_) => true)).toEqual(false);
    });

    test('Test isSomeAnd on Some with false predicate', () {
      const x = Option.some(1);

      expect(x.isSomeAnd((_) => false)).toEqual(false);
    });

    test('Test expect on Some', () {
      const x = Option.some(1);

      expect(x.expect('Error')).toEqual(1);
    });

    test('Test expect on None', () {
      const x = Option<int>.none();

      expect(() => x.expect('Error')).throws.isStateError();
    });

    test('Test unwrap on Some', () {
      const x = Option.some(1);

      expect(x.unwrap()).toEqual(1);
    });

    test('Test unwrap on None', () {
      const x = Option<int>.none();

      expect(x.unwrap).throws.isStateError();
    });

    test('Test unwrapOr on Some', () {
      const x = Option.some(1);

      expect(x.unwrapOr(2)).toEqual(1);
    });

    test('Test unwrapOr on None', () {
      const x = Option<int>.none();

      expect(x.unwrapOr(2)).toEqual(2);
    });

    test('Test unwrapOrElse on Some', () {
      const x = Option.some(1);

      expect(x.unwrapOrElse(() => 2)).toEqual(1);
    });

    test('Test unwrapOrElse on None', () {
      const x = Option<int>.none();

      expect(x.unwrapOrElse(() => 2)).toEqual(2);
    });

    test('Test map on Some', () {
      const x = Option.some(1);

      expect(x.map((x) => x + 1)).toEqual(const Option.some(2));
    });

    test('Test map on None', () {
      const x = Option<int>.none();

      expect(x.map((x) => x + 1)).toEqual(const Option.none());
    });

    test('Test inspect on Some', () {
      const x = Option.some(1);
      var y = 0;

      expect(
        x.inspect((x) {
          y = x;
        }),
      ).toEqual(x);
      expect(y).toEqual(1);
    });

    test('Test inspect on None', () {
      const x = Option<int>.none();
      var y = 0;

      expect(
        x.inspect((x) {
          y = x;
        }),
      ).toEqual(x);
      expect(y).toEqual(0);
    });

    test('Test mapOr on Some', () {
      const x = Option.some(1);

      expect(x.mapOr(map: (x) => x + 1, or: 5)).toEqual(2);
    });

    test('Test mapOr on None', () {
      const x = Option<int>.none();

      expect(x.mapOr(map: (x) => x + 1, or: 5)).toEqual(5);
    });

    test('Test mapOrElse on Some', () {
      const x = Option.some(1);

      expect(x.mapOrElse(map: (x) => x + 1, orElse: () => 5)).toEqual(2);
    });

    test('Test mapOrElse on None', () {
      const x = Option<int>.none();

      expect(x.mapOrElse(map: (x) => x + 1, orElse: () => 5)).toEqual(5);
    });

    test('Test okOr on Some', () {
      const x = Option.some(1);

      expect(x.okOr(5)).toEqual(const Ok(1));
    });

    test('Test okOr on None', () {
      const x = Option<int>.none();

      expect(x.okOr(5)).toEqual(const Err(5));
    });

    test('Test okOrElse on Some', () {
      const x = Option.some(1);

      expect(x.okOrElse(() => 5)).toEqual(const Ok(1));
    });

    test('Test okOrElse on None', () {
      const x = Option<int>.none();

      expect(x.okOrElse(() => 5)).toEqual(const Err(5));
    });

    test('Test iter on Some', () {
      const x = Option.some(1);

      expect(x.iter.toList()).toEqual(const [1]);
    });

    test('Test iter on None', () {
      const x = Option<int>.none();

      expect(x.iter.toList()).toEqual(const []);
    });

    test('Test and on Some', () {
      const x = Option.some(1);

      expect(x.and(const Option.some(2))).toEqual(const Option.some(2));
    });

    test('Test and on None', () {
      const x = Option<int>.none();

      expect(x.and(const Option.some(2))).toEqual(const Option.none());
    });

    test('Test andThen on Some', () {
      const x = Option.some(1);

      expect(x.andThen((x) => Option.some(x + 1)))
          .toEqual(const Option.some(2));
    });

    test('Test andThen on None', () {
      const x = Option<int>.none();

      expect(x.andThen((x) => Option.some(x + 1))).toEqual(const Option.none());
    });

    test('Test where on Some', () {
      const x = Option.some(1);

      expect(x.where((x) => x == 1)).toEqual(const Option.some(1));
    });

    test('Test where on Some that fails filter', () {
      const x = Option.some(1);
      final v = x.where((x) => x == 2);

      expect(v).toEqual(const Option.none());
    });

    test('Test where on None', () {
      const x = Option<int>.none();

      expect(x.where((x) => x == 1)).toEqual(const Option.none());
    });

    test('Test or on Some', () {
      const x = Option.some(1);

      expect(x.or(const Option.some(2))).toEqual(const Option.some(1));
    });

    test('Test or on None', () {
      const x = Option<int>.none();

      expect(x.or(const Option.some(2))).toEqual(const Option.some(2));
    });

    test('Test orElse on Some', () {
      const x = Option.some(1);

      expect(x.orElse(() => const Option.some(2)))
          .toEqual(const Option.some(1));
    });

    test('Test orElse on None', () {
      const x = Option<int>.none();

      expect(x.orElse(() => const Option.some(2)))
          .toEqual(const Option.some(2));
    });

    test('Test xor Some on Some', () {
      const x = Option.some(1);

      expect(x.xor(const Option.some(2))).toEqual(const Option.none());
    });

    test('Test xor Some on None', () {
      const x = Option<int>.none();

      expect(x.xor(const Option.some(2))).toEqual(const Option.some(2));
    });

    test('Test xor None on Some', () {
      const x = Option.some(1);

      expect(x.xor(const Option<int>.none())).toEqual(const Option.some(1));
    });

    test('Test xor None on None', () {
      const x = Option<int>.none();

      expect(x.xor(const Option.none())).toEqual(const Option.none());
    });

    test('Test zip on Some', () {
      const x = Option.some(1);

      expect(x.zip(const Option.some(2))).toEqual(const Option.some((1, 2)));
    });

    test('Test zip on None', () {
      const x = Option<int>.none();

      expect(x.zip(const Option.some(2))).toEqual(const Option.none());
    });

    test('Test zip on Some with None', () {
      const x = Option.some(1);

      expect(x.zip(const Option<int>.none())).toEqual(const Option.none());
    });

    test('Test zip on None with None', () {
      const x = Option<int>.none();

      expect(x.zip(const Option<int>.none())).toEqual(const Option.none());
    });

    test('Test zipWith on Some', () {
      const x = Option.some(1);

      expect(x.zipWith(const Option.some(2), (x, y) => x + y))
          .toEqual(const Option.some(3));
    });

    test('Test zipWith on None', () {
      const x = Option<int>.none();

      expect(x.zipWith(const Option.some(2), (x, y) => x + y))
          .toEqual(const Option.none());
    });

    test('Test zipWith on Some with None', () {
      const x = Option.some(1);

      expect(x.zipWith(const Option<int>.none(), (x, y) => x + y))
          .toEqual(const Option.none());
    });

    test('Test zipWith on None with None', () {
      const x = Option<int>.none();

      expect(x.zipWith(const Option<int>.none(), (x, y) => x + y))
          .toEqual(const Option.none());
    });

    test('Test unzip on Some', () {
      const x = Option.some((1, 2));

      expect(x.unzip()).toEqual((const Option.some(1), const Option.some(2)));
    });

    test('Test unzip on None', () {
      const x = Option<(int, int)>.none();

      expect(x.unzip()).toEqual((const Option.none(), const Option.none()));
    });

    test('Test future on Some', () async {
      final x = Option.some(Future.value(1));

      await expect(x.wait).completion.toEqual(const Option.some(1));
    });

    test('Test future on None', () async {
      const x = Option<Future<int>>.none();

      await expect(x.wait).completion.toEqual(const Option.none());
    });

    test('Test transpose on Some Ok', () {
      const x = Option.some(Ok<int, String>(1));

      expect(x.transpose()).toEqual(const Ok(Option.some(1)));
    });

    test('Test transpose on Some Err', () {
      const x = Option.some(Err<int, String>('Error'));

      expect(x.transpose()).toEqual(const Err('Error'));
    });

    test('Test transpose on None', () {
      const x = Option<Result<int, String>>.none();

      expect(x.transpose()).toEqual(const Ok(Option<int>.none()));
    });

    test('Test Option flatten on Some', () {
      const x = Option.some(Option.some(1));

      expect(x.flatten()).toEqual(const Option.some(1));
    });

    test('Test Option flatten on None', () {
      const x = Option<Option<int>>.none();

      expect(x.flatten()).toEqual(const Option.none());
    });

    test('Test Option flatten on Some of None', () {
      const x = Option.some(Option<int>.none());

      expect(x.flatten()).toEqual(const Option.none());
    });

    test('Test bool unwrapOrDefault on Some', () {
      const x = Option.some(true);

      expect(x.unwrapOrDefault()).toEqual(true);
    });

    test('Test bool unwrapOrDefault on None', () {
      const x = Option<bool>.none();

      expect(x.unwrapOrDefault()).toEqual(false);
    });

    test('Test int unwrapOrDefault on Some', () {
      const x = Option.some(1);

      expect(x.unwrapOrDefault()).toEqual(1);
    });

    test('Test int unwrapOrDefault on None', () {
      const x = Option<int>.none();

      expect(x.unwrapOrDefault()).toEqual(0);
    });

    test('Test double unwrapOrDefault on Some', () {
      const x = Option.some(1.0);

      expect(x.unwrapOrDefault()).toEqual(1.0);
    });

    test('Test double unwrapOrDefault on None', () {
      const x = Option<double>.none();

      expect(x.unwrapOrDefault()).toEqual(0.0);
    });

    test('Test num unwrapOrDefault on Some', () {
      const x = Option.some(1);

      expect(x.unwrapOrDefault()).toEqual(1);
    });

    test('Test num unwrapOrDefault on None', () {
      const x = Option<num>.none();

      expect(x.unwrapOrDefault()).toEqual(0);
    });

    test('Test String unwrapOrDefault on Some', () {
      const x = Option.some('1');

      expect(x.unwrapOrDefault()).toEqual('1');
    });

    test('Test String unwrapOrDefault on None', () {
      const x = Option<String>.none();

      expect(x.unwrapOrDefault()).toEqual('');
    });

    test('Test List unwrapOrDefault on Some', () {
      const x = Option.some([1]);

      expect(x.unwrapOrDefault()).toEqual([1]);
    });

    test('Test List unwrapOrDefault on None', () {
      const x = Option<List<int>>.none();

      expect(x.unwrapOrDefault()).toEqual([]);
    });

    test('Test Map unwrapOrDefault on Some', () {
      const x = Option.some({'1': 1});

      expect(x.unwrapOrDefault()).toEqual({'1': 1});
    });

    test('Test Map unwrapOrDefault on None', () {
      const x = Option<Map<String, int>>.none();

      expect(x.unwrapOrDefault()).toEqual({});
    });

    test('Test Set unwrapOrDefault on Some', () {
      const x = Option.some({1});

      expect(x.unwrapOrDefault()).toEqual({1});
    });

    test('Test Set unwrapOrDefault on None', () {
      const x = Option<Set<int>>.none();

      expect(x.unwrapOrDefault()).toEqual({});
    });

    test('Test Iterable unwrapOrDefault on Some', () {
      final x = Option.some(Iterable.generate(1, (i) => i));

      expect(x.unwrapOrDefault()).toEqual([0]);
    });

    test('Test Iterable unwrapOrDefault on None', () {
      const x = Option<Iterable<int>>.none();

      expect(x.unwrapOrDefault()).toEqual([]);
    });

    test('Test Stream unwrapOrDefault on Some', () async {
      final x = Option.some(Stream.fromIterable([1]));

      await expect(x.unwrapOrDefault().first).completion.toEqual(1);
    });

    test('Test Stream unwrapOrDefault on None', () async {
      const x = Option<Stream<int>>.none();

      await expect(x.unwrapOrDefault().first).throws.isStateError();
    });

    test('Test Duration unwrapOrDefault on Some', () {
      const x = Option.some(Duration(seconds: 1));

      expect(x.unwrapOrDefault()).toEqual(const Duration(seconds: 1));
    });

    test('Test Duration unwrapOrDefault on None', () {
      const x = Option<Duration>.none();

      expect(x.unwrapOrDefault()).toEqual(Duration.zero);
    });

    test('Test Iterable<Option<T>> whereSome', () {
      final x = [
        const Option.some(1),
        const Option<int>.none(),
        const Option.some(2)
      ];

      expect(x.whereSome()).toEqual([1, 2]);
    });

    test('Test Iterable<Option<T>> whereSomeAnd', () {
      final x = [
        const Option.some(1),
        const Option<int>.none(),
        const Option.some(2)
      ];

      expect(x.whereSomeAnd((x) => x == 1)).toEqual([1]);
    });

    test('Test Iterable<Option<T>> mapWhereSome', () {
      final x = [
        const Option.some(1),
        const Option<int>.none(),
        const Option.some(2)
      ];

      expect(x.mapWhereSome((x) => x + 1)).toEqual([2, 3]);
    });

    test('Test Stream<Option<T>> whereSome', () async {
      final x = Stream.fromIterable(
        [const Option.some(1), const Option<int>.none(), const Option.some(2)],
      );

      await expect(x.whereSome().toList()).completion.toEqual([1, 2]);
    });

    test('Test Stream<Option<T>> whereSomeAnd', () async {
      final x = Stream.fromIterable(
        [const Option.some(1), const Option<int>.none(), const Option.some(2)],
      );

      await expect(x.whereSomeAnd((x) => x == 1).toList())
          .completion
          .toEqual([1]);
    });

    test('Test Stream<Option<T>> mapWhereSome', () async {
      final x = Stream.fromIterable(
        [const Option.some(1), const Option<int>.none(), const Option.some(2)],
      );

      await expect(x.mapWhereSome((x) => x + 1).toList())
          .completion
          .toEqual([2, 3]);
    });

    test('Test Stream<Option<T>> takeWhileSome', () async {
      final x = Stream.fromIterable(
        [const Option.some(1), const Option<int>.none(), const Option.some(2)],
      );

      await expect(x.takeWhileSome().toList()).completion.toEqual([1]);
    });

    test('Test Stream<Option<T>> skipWhileNone start Some', () async {
      final x = Stream.fromIterable(
        [const Option.some(1), const Option<int>.none(), const Option.some(2)],
      );

      await expect(x.skipWhileNone().toList()).completion.toEqual(
        [const Option.some(1), const Option.none(), const Option.some(2)],
      );
    });

    test('Test Stream<Option<T>> skipWhileNone start None', () async {
      final x = Stream.fromIterable(
        [
          const Option<int>.none(),
          const Option<int>.none(),
          const Option.some(1),
          const Option.some(2)
        ],
      );

      await expect(x.skipWhileNone().toList())
          .completion
          .toEqual([const Option.some(1), const Option.some(2)]);
    });
  });

  group('Result tests', () {
    test('Test Result equality', () {
      const x = Result<int, String>.ok(1);

      const y = Result<int, String>.ok(1);

      expect(x).toEqual(y);
    });

    test('Test Result inequality', () {
      const x = Result<int, String>.ok(1);

      const y = Result<int, String>.ok(2);

      expect(x).not.toEqual(y);
    });

    test('Test Result equality with Err', () {
      const x = Result<int, String>.ok(1);

      const y = Result<int, String>.err('Error');

      expect(x).not.toEqual(y);
    });

    test('Test Result equality with Err', () {
      const x = Result<int, String>.err('Error');

      const y = Result<int, String>.err('Error');

      expect(x).toEqual(y);
    });

    test('Test Result isOk on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.isOk).toEqual(true);
    });

    test('Test Result isOk on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.isOk).toEqual(false);
    });

    test('Test Result isErr on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.isErr).toEqual(false);
    });

    test('Test Result isErr on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.isErr).toEqual(true);
    });

    test('Test Result isOkAnd on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.isOkAnd((_) => true)).toEqual(true);
    });

    test('Test Result isOkAnd on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.isOkAnd((_) => true)).toEqual(false);
    });

    test('Test Result isOkAnd on Ok with false predicate', () {
      const x = Result<int, String>.ok(1);

      expect(x.isOkAnd((_) => false)).toEqual(false);
    });

    test('Test Result isErrAnd on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.isErrAnd((_) => true)).toEqual(false);
    });

    test('Test Result isErrAnd on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.isErrAnd((_) => true)).toEqual(true);
    });

    test('Test Result isErrAnd on Err with false predicate', () {
      const x = Result<int, String>.err('Error');

      expect(x.isErrAnd((_) => false)).toEqual(false);
    });

    test('Test ok on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.ok()).toEqual(const Option.some(1));
    });

    test('Test ok on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.ok()).toEqual(const Option.none());
    });

    test('Test err on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.err()).toEqual(const Option.none());
    });

    test('Test err on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.err()).toEqual(const Option.some('Error'));
    });

    test('Test map on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.map((x) => x + 1)).toEqual(const Result.ok(2));
    });

    test('Test map on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.map((x) => x + 1)).toEqual(const Result.err('Error'));
    });

    test('Test mapOr on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.mapOr((x) => x + 1, 5)).toEqual(2);
    });

    test('Test mapOr on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.mapOr((x) => x + 1, 5)).toEqual(5);
    });

    test('Test mapOrElse on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.mapOrElse((x) => x + 1, (_) => 5)).toEqual(2);
    });

    test('Test mapOrElse on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.mapOrElse((x) => x + 1, (_) => 5)).toEqual(5);
    });

    test('Test mapErr on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.mapErr((x) => '${x}1')).toEqual(const Result.ok(1));
    });

    test('Test mapErr on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.mapErr((x) => '${x}1')).toEqual(const Result.err('Error1'));
    });

    test('Test inspect on Ok', () {
      const x = Result<int, String>.ok(1);
      var y = 0;

      expect(
        x.inspect((x) {
          y = x;
        }),
      ).toEqual(x);
      expect(y).toEqual(1);
    });

    test('Test inspect on Err', () {
      const x = Result<int, String>.err('Error');
      var y = 0;

      expect(
        x.inspect((x) {
          y = x;
        }),
      ).toEqual(x);
      expect(y).toEqual(0);
    });

    test('Test inspectErr on Ok', () {
      const x = Result<int, String>.ok(1);
      var y = '';

      expect(
        x.inspectErr((x) {
          y = x;
        }),
      ).toEqual(x);
      expect(y).toEqual('');
    });

    test('Test inspectErr on Err', () {
      const x = Result<int, String>.err('Error');
      var y = '';

      expect(
        x.inspectErr((x) {
          y = x;
        }),
      ).toEqual(x);
      expect(y).toEqual('Error');
    });

    test('Test iter on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.iter.toList()).toEqual(const [1]);
    });

    test('Test iter on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.iter.toList()).toEqual(const []);
    });

    test('Test expect on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.expect('Error')).toEqual(1);
    });

    test('Test expect on Err', () {
      const x = Result<int, String>.err('Error');

      expect(() => x.expect('Error')).throws.isStateError();
    });

    test('Test expectErr on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(() => x.expectErr('Error')).throws.isStateError();
    });

    test('Test expectErr on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.expectErr('Error')).toEqual('Error');
    });

    test('Test unwrap on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.unwrap()).toEqual(1);
    });

    test('Test unwrap on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.unwrap).throws.isStateError();
    });

    test('Test unwrapOr on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.unwrapOr(2)).toEqual(1);
    });

    test('Test unwrapOr on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.unwrapOr(2)).toEqual(2);
    });

    test('Test unwrapOrElse on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.unwrapOrElse((_) => 2)).toEqual(1);
    });

    test('Test unwrapOrElse on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.unwrapOrElse((_) => 2)).toEqual(2);
    });

    test('Test unwrapErr on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.unwrapErr).throws.isStateError();
    });

    test('Test unwrapErr on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.unwrapErr()).toEqual('Error');
    });

    test('Test and on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.and(const Result.ok(2))).toEqual(const Result.ok(2));
    });

    test('Test and on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.and(const Result.ok(2))).toEqual(const Result.err('Error'));
    });

    test('Test andThen on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.andThen((x) => Result.ok(x + 1))).toEqual(const Result.ok(2));
    });

    test('Test andThen on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.andThen((x) => Result.ok(x + 1)))
          .toEqual(const Result.err('Error'));
    });

    test('Test or on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.or(const Result<int, String>.ok(2))).toEqual(const Result.ok(1));
    });

    test('Test or on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.or(const Result<int, String>.ok(2))).toEqual(const Result.ok(2));
    });

    test('Test orElse on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.orElse((_) => const Result<int, String>.ok(2)))
          .toEqual(const Result.ok(1));
    });

    test('Test orElse on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.orElse((_) => const Result<int, String>.ok(2)))
          .toEqual(const Result.ok(2));
    });

    test('Test contains on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.contains(1)).toEqual(true);
    });

    test('Test contains on Ok that fails', () {
      const x = Result<int, String>.ok(1);

      expect(x.contains(2)).toEqual(false);
    });

    test('Test contains on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.contains(1)).toEqual(false);
    });

    test('Test containsErr on Ok', () {
      const x = Result<int, String>.ok(1);

      expect(x.containsErr('Error')).toEqual(false);
    });

    test('Test containsErr on Err', () {
      const x = Result<int, String>.err('Error');

      expect(x.containsErr('Error')).toEqual(true);
    });

    test('Test containsErr on Err that fails', () {
      const x = Result<int, String>.err('Error');

      expect(x.containsErr('Error2')).toEqual(false);
    });

    test('Test value on Result<R, Never>', () {
      const x = Result<int, Never>.ok(1);

      expect(x.value).toEqual(1);
    });

    test('Test error on Result<Never, E>', () {
      const x = Result<Never, String>.err('Error');

      expect(x.error).toEqual('Error');
    });

    test('Test transpose on Ok Some', () {
      const x = Result<Option<int>, String>.ok(Option.some(1));

      expect(x.transpose()).toEqual(const Option.some(Result.ok(1)));
    });

    test('Test transpose on Ok None', () {
      const x = Result<Option<int>, String>.ok(Option<int>.none());

      expect(x.transpose()).toEqual(const Option.none());
    });

    test('Test transpose on Err', () {
      const x = Result<Option<int>, String>.err('Error');

      expect(x.transpose()).toEqual(const Option.some(Result.err('Error')));
    });

    test('Test future Ok Err on Ok', () async {
      final x = Result<Future<int>, Future<String>>.ok(Future.value(1));

      await expect(x.future).completion.toEqual(const Result.ok(1));
    });

    test('Test future Ok Err on Err', () async {
      final x = Result<Future<int>, Future<String>>.err(Future.value('Error'));

      await expect(x.future).completion.toEqual(const Result.err('Error'));
    });

    test('Test future Ok on Ok', () async {
      final x = Result<Future<int>, String>.ok(Future.value(1));

      await expect(x.future).completion.toEqual(const Result.ok(1));
    });

    test('Test future Ok on Err', () async {
      const x = Result<Future<int>, String>.err('Error');

      await expect(x.future).completion.toEqual(const Result.err('Error'));
    });

    test('Test future Err', () async {
      final x = Result<int, Future<String>>.err(Future.value('Error'));

      await expect(x.future).completion.toEqual(const Result.err('Error'));
    });

    test('Test flatten on Ok Ok', () {
      const x = Result<Result<int, String>, String>.ok(Result.ok(1));

      expect(x.flatten()).toEqual(const Result.ok(1));
    });

    test('Test flatten on Ok Err', () {
      const x = Result<Result<int, String>, String>.ok(Result.err('Error'));

      expect(x.flatten()).toEqual(const Result.err('Error'));
    });

    test('Test flatten on Err', () {
      const x = Result<Result<int, String>, String>.err('Error');

      expect(x.flatten()).toEqual(const Result.err('Error'));
    });

    test('Test unwrapOrDefault on bool success', () {
      const x = Result<bool, String>.ok(true);

      expect(x.unwrapOrDefault()).toEqual(true);
    });

    test('Test unwrapOrDefault on bool failure', () {
      const x = Result<bool, String>.err('Error');

      expect(x.unwrapOrDefault()).toEqual(false);
    });

    test('Test unwrapOrDefault on int success', () {
      const x = Result<int, String>.ok(1);

      expect(x.unwrapOrDefault()).toEqual(1);
    });

    test('Test unwrapOrDefault on int failure', () {
      const x = Result<int, String>.err('Error');

      expect(x.unwrapOrDefault()).toEqual(0);
    });

    test('Test unwrapOrDefault on double success', () {
      const x = Result<double, String>.ok(1.0);

      expect(x.unwrapOrDefault()).toEqual(1.0);
    });

    test('Test unwrapOrDefault on double failure', () {
      const x = Result<double, String>.err('Error');

      expect(x.unwrapOrDefault()).toEqual(0.0);
    });

    test('Test unwrapOrDefault on num success', () {
      const x = Result<num, String>.ok(1);

      expect(x.unwrapOrDefault()).toEqual(1);
    });

    test('Test unwrapOrDefault on num failure', () {
      const x = Result<num, String>.err('Error');

      expect(x.unwrapOrDefault()).toEqual(0);
    });

    test('Test unwrapOrDefault on String success', () {
      const x = Result<String, String>.ok('1');

      expect(x.unwrapOrDefault()).toEqual('1');
    });

    test('Test unwrapOrDefault on String failure', () {
      const x = Result<String, String>.err('Error');

      expect(x.unwrapOrDefault()).toEqual('');
    });

    test('Test unwrapOrDefault on DateTime success', () {
      final x = Result<DateTime, String>.ok(DateTime(2020));

      expect(x.unwrapOrDefault()).toEqual(DateTime(2020));
    });

    test('Test unwrapOrDefault on DateTime failure', () {
      const x = Result<DateTime, String>.err('Error');

      expect(x.unwrapOrDefault()).toEqual(DateTime(0));
    });

    test('Test unwrapOrDefault on List success', () {
      const x = Result<List<int>, String>.ok([1]);

      expect(x.unwrapOrDefault()).toEqual([1]);
    });

    test('Test unwrapOrDefault on List failure', () {
      const x = Result<List<int>, String>.err('Error');

      expect(x.unwrapOrDefault()).toEqual([]);
    });

    test('Test unwrapOrDefault on Map success', () {
      const x = Result<Map<String, int>, String>.ok({'1': 1});

      expect(x.unwrapOrDefault()).toEqual({'1': 1});
    });

    test('Test unwrapOrDefault on Map failure', () {
      const x = Result<Map<String, int>, String>.err('Error');

      expect(x.unwrapOrDefault()).toEqual({});
    });

    test('Test unwrapOrDefault on Set success', () {
      const x = Result<Set<int>, String>.ok({1});

      expect(x.unwrapOrDefault()).toEqual({1});
    });

    test('Test unwrapOrDefault on Set failure', () {
      const x = Result<Set<int>, String>.err('Error');

      expect(x.unwrapOrDefault()).toEqual({});
    });

    test('Test unwrapOrDefault on Iterable success', () {
      final x =
          Result<Iterable<int>, String>.ok(Iterable.generate(1, (i) => i));

      expect(x.unwrapOrDefault()).toEqual([0]);
    });

    test('Test unwrapOrDefault on Iterable failure', () {
      const x = Result<Iterable<int>, String>.err('Error');

      expect(x.unwrapOrDefault()).toEqual([]);
    });

    test('Test unwrapOrDefault on Stream success', () async {
      final x = Result<Stream<int>, String>.ok(Stream.fromIterable([1]));

      await expect(x.unwrapOrDefault().first).completion.toEqual(1);
    });

    test('Test unwrapOrDefault on Stream failure', () async {
      const x = Result<Stream<int>, String>.err('Error');

      await expect(x.unwrapOrDefault().first).throws.isStateError();
    });

    test('Test unwrapOrDefault on Duration success', () {
      const x = Result<Duration, String>.ok(Duration(seconds: 1));

      expect(x.unwrapOrDefault()).toEqual(const Duration(seconds: 1));
    });

    test('Test unwrapOrDefault on Duration failure', () {
      const x = Result<Duration, String>.err('Error');

      expect(x.unwrapOrDefault()).toEqual(Duration.zero);
    });

    test('Test Iterable<Result<T, E>> whereOk', () {
      final x = [
        const Result<int, String>.ok(1),
        const Result<int, String>.err('Error')
      ];

      expect(x.whereOk()).toEqual([1]);
    });

    test('Test Iterable<Result<T, E>> whereOkAnd', () {
      final x = [
        const Result<int, String>.ok(1),
        const Result<int, String>.err('Error')
      ];

      expect(x.whereOkAnd((x) => x == 1)).toEqual([1]);
    });

    test('Test Iterable<Result<T, E>> collectResult no errors', () {
      final x = [
        const Result<int, String>.ok(1),
        const Result<int, String>.ok(2)
      ];

      expect(x.collectResult()).toEqual(const Result.ok([1, 2]));
    });

    test('Test Iterable<Result<T, E>> collectResult with errors', () {
      final x = [
        const Result<int, String>.ok(1),
        const Result<int, String>.err('Error')
      ];

      expect(x.collectResult()).toEqual(const Result.err('Error'));
    });

    test('Test Stream<Result<T, E>> whereOk', () async {
      final x = Stream.fromIterable(
        [
          const Result<int, String>.ok(1),
          const Result<int, String>.err('Error')
        ],
      );

      await expect(x.whereOk().toList()).completion.toEqual([1]);
    });

    test('Test Stream<Result<T, E>> whereOkAnd', () async {
      final x = Stream.fromIterable(
        [
          const Result<int, String>.ok(1),
          const Result<int, String>.err('Error')
        ],
      );

      await expect(x.whereOkAnd((x) => x == 1).toList())
          .completion
          .toEqual([1]);
    });

    test('Test Stream<Result<T, E>> whereOkAnd fails', () async {
      final x = Stream.fromIterable(
        [
          const Result<int, String>.ok(1),
          const Result<int, String>.ok(2),
          const Result<int, String>.err('Error')
        ],
      );

      await expect(x.whereOkAnd((x) => x == 2).toList())
          .completion
          .toEqual([2]);
    });

    test('Test Stream<Result<T, E>> takeWhileOk', () async {
      final x = Stream.fromIterable(
        [
          const Result<int, String>.ok(1),
          const Result<int, String>.err('Error'),
          const Result<int, String>.ok(2)
        ],
      );

      await expect(x.takeWhileOk().toList()).completion.toEqual([1]);
    });

    test('Test Stream<Result<T, E>> skipWhileErr', () async {
      final x = Stream.fromIterable(
        [
          const Result<int, String>.err('Error'),
          const Result<int, String>.ok(1),
          const Result<int, String>.err('Error2'),
          const Result<int, String>.ok(2)
        ],
      );

      await expect(x.skipWhileErr().toList()).completion.toEqual(
        [const Result.ok(1), const Result.err('Error2'), const Result.ok(2)],
      );
    });

    test('Test Stream<Result<T, E>> collectResult no errors', () async {
      final x = Stream.fromIterable(
        [const Result<int, String>.ok(1), const Result<int, String>.ok(2)],
      );

      await expect(x.collectResult())
          .completion
          .toEqual(const Result.ok([1, 2]));
    });

    test('Test Stream<Result<T, E>> collectResult with errors', () async {
      final x = Stream.fromIterable(
        [
          const Result<int, String>.ok(1),
          const Result<int, String>.err('Error'),
          const Result<int, String>.ok(2)
        ],
      );

      await expect(x.collectResult())
          .completion
          .toEqual(const Result.err('Error'));
    });
  });

  group('Test UnitExt', () {
    test('Test void toUnit', () {
      const x = 5;

      expect(x.toUnit()).toEqual(());
    });

    test('Test Future toUnit', () async {
      final x = Future<void>.value();
      await expect(x.toUnit()).completion.toBe(());
    });
  });
}
