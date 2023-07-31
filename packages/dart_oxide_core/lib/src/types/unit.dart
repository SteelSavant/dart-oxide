// /// Extensions to allow easier usage with the unit type.
// /// Due to issues with type inferece using generics, most extensions require explicit typing to work properly.
// library unit;

/// alias for the unit type [()]; useful for comparing as a [Type] to avoid ambiguity between () as a type and () as a value.
typedef Unit = ();

extension VoidExt on void {
  () toUnit() => ();
}

extension FutureVoidExt on Future<void> {
  Future<()> toUnit() async {
    await this;
    return ();
  }
}

// extension UnitFnExt on void Function() {
//   () Function() toUnitFn() => () {
//         this();
//         return ();
//       };
// }

// extension UnitFn1Ext<T1> on void Function(T1) {
//   () Function(T1) toUnitFn() => (T1 value) {
//         this(value);
//         return ();
//       };
// }

// extension UnitFn2Ext<T1, T2> on void Function(T1, T2) {
//   () Function(T1, T2) toUnitFn() => (T1 value1, T2 value2) {
//         this(value1, value2);
//         return ();
//       };
// }

// extension UnitFn3Ext<T1, T2, T3> on void Function(T1, T2, T3) {
//   () Function(T1, T2, T3) toUnitFn() => (T1 value1, T2 value2, T3 value3) {
//         this(value1, value2, value3);
//         return ();
//       };
// }

// extension UnitFn4Ext<T1, T2, T3, T4> on void Function(T1, T2, T3, T4) {
//   () Function(T1, T2, T3, T4) toUnitFn() =>
//       (T1 value1, T2 value2, T3 value3, T4 value4) {
//         this(value1, value2, value3, value4);
//         return ();
//       };
// }

// extension UnitFn5Ext<T1, T2, T3, T4, T5> on void Function(T1, T2, T3, T4, T5) {
//   () Function(T1, T2, T3, T4, T5) toUnitFn() =>
//       (T1 value1, T2 value2, T3 value3, T4 value4, T5 value5) {
//         this(value1, value2, value3, value4, value5);
//         return ();
//       };
// }

// extension UnitFn6Ext<T1, T2, T3, T4, T5, T6> on void Function(
//   T1,
//   T2,
//   T3,
//   T4,
//   T5,
//   T6,
// ) {
//   () Function(T1, T2, T3, T4, T5, T6) toUnitFn() =>
//       (T1 value1, T2 value2, T3 value3, T4 value4, T5 value5, T6 value6) {
//         this(value1, value2, value3, value4, value5, value6);
//         return ();
//       };
// }

// extension UnitFn7Ext<T1, T2, T3, T4, T5, T6, T7> on void Function(
//   T1,
//   T2,
//   T3,
//   T4,
//   T5,
//   T6,
//   T7,
// ) {
//   () Function(T1, T2, T3, T4, T5, T6, T7) toUnitFn() => (
//         T1 value1,
//         T2 value2,
//         T3 value3,
//         T4 value4,
//         T5 value5,
//         T6 value6,
//         T7 value7,
//       ) {
//         this(value1, value2, value3, value4, value5, value6, value7);
//         return ();
//       };
// }

// extension UnitFn8Ext<T1, T2, T3, T4, T5, T6, T7, T8> on void Function(
//   T1,
//   T2,
//   T3,
//   T4,
//   T5,
//   T6,
//   T7,
//   T8,
// ) {
//   () Function(T1, T2, T3, T4, T5, T6, T7, T8) toUnitFn() => (
//         T1 value1,
//         T2 value2,
//         T3 value3,
//         T4 value4,
//         T5 value5,
//         T6 value6,
//         T7 value7,
//         T8 value8,
//       ) {
//         this(value1, value2, value3, value4, value5, value6, value7, value8);
//         return ();
//       };
// }

// extension UnitFn9Ext<T1, T2, T3, T4, T5, T6, T7, T8, T9> on void Function(
//   T1,
//   T2,
//   T3,
//   T4,
//   T5,
//   T6,
//   T7,
//   T8,
//   T9,
// ) {
//   () Function(T1, T2, T3, T4, T5, T6, T7, T8, T9) toUnitFn() => (
//         T1 value1,
//         T2 value2,
//         T3 value3,
//         T4 value4,
//         T5 value5,
//         T6 value6,
//         T7 value7,
//         T8 value8,
//         T9 value9,
//       ) {
//         this(
//           value1,
//           value2,
//           value3,
//           value4,
//           value5,
//           value6,
//           value7,
//           value8,
//           value9,
//         );
//         return ();
//       };
// }

// extension UnitFn10Ext<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10> on void Function(
//   T1,
//   T2,
//   T3,
//   T4,
//   T5,
//   T6,
//   T7,
//   T8,
//   T9,
//   T10,
// ) {
//   () Function(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) toUnitFn() => (
//         T1 value1,
//         T2 value2,
//         T3 value3,
//         T4 value4,
//         T5 value5,
//         T6 value6,
//         T7 value7,
//         T8 value8,
//         T9 value9,
//         T10 value10,
//       ) {
//         this(
//           value1,
//           value2,
//           value3,
//           value4,
//           value5,
//           value6,
//           value7,
//           value8,
//           value9,
//           value10,
//         );
//         return ();
//       };
// }

// extension UnitFn11Ext<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11> on void
//     Function(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11) {
//   () Function(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11) toUnitFn() => (
//         T1 value1,
//         T2 value2,
//         T3 value3,
//         T4 value4,
//         T5 value5,
//         T6 value6,
//         T7 value7,
//         T8 value8,
//         T9 value9,
//         T10 value10,
//         T11 value11,
//       ) {
//         this(
//           value1,
//           value2,
//           value3,
//           value4,
//           value5,
//           value6,
//           value7,
//           value8,
//           value9,
//           value10,
//           value11,
//         );
//         return ();
//       };
// }

// extension UnitFn12Ext<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12> on void
//     Function(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12) {
//   () Function(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12) toUnitFn() => (
//         T1 value1,
//         T2 value2,
//         T3 value3,
//         T4 value4,
//         T5 value5,
//         T6 value6,
//         T7 value7,
//         T8 value8,
//         T9 value9,
//         T10 value10,
//         T11 value11,
//         T12 value12,
//       ) {
//         this(
//           value1,
//           value2,
//           value3,
//           value4,
//           value5,
//           value6,
//           value7,
//           value8,
//           value9,
//           value10,
//           value11,
//           value12,
//         );
//         return ();
//       };
// }

// extension UnitFn13Ext<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13>
//     on void Function(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13) {
//   () Function(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13)
//       toUnitFn() => (
//             T1 value1,
//             T2 value2,
//             T3 value3,
//             T4 value4,
//             T5 value5,
//             T6 value6,
//             T7 value7,
//             T8 value8,
//             T9 value9,
//             T10 value10,
//             T11 value11,
//             T12 value12,
//             T13 value13,
//           ) {
//             this(
//               value1,
//               value2,
//               value3,
//               value4,
//               value5,
//               value6,
//               value7,
//               value8,
//               value9,
//               value10,
//               value11,
//               value12,
//               value13,
//             );
//             return ();
//           };
// }

// extension UnitFn14Ext<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13,
//     T14> on void Function(
//   T1,
//   T2,
//   T3,
//   T4,
//   T5,
//   T6,
//   T7,
//   T8,
//   T9,
//   T10,
//   T11,
//   T12,
//   T13,
//   T14,
// ) {
//   () Function(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14)
//       toUnitFn() => (
//             T1 value1,
//             T2 value2,
//             T3 value3,
//             T4 value4,
//             T5 value5,
//             T6 value6,
//             T7 value7,
//             T8 value8,
//             T9 value9,
//             T10 value10,
//             T11 value11,
//             T12 value12,
//             T13 value13,
//             T14 value14,
//           ) {
//             this(
//               value1,
//               value2,
//               value3,
//               value4,
//               value5,
//               value6,
//               value7,
//               value8,
//               value9,
//               value10,
//               value11,
//               value12,
//               value13,
//               value14,
//             );
//             return ();
//           };
// }

// extension UnitFn15Ext<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13,
//     T14, T15> on void Function(
//   T1,
//   T2,
//   T3,
//   T4,
//   T5,
//   T6,
//   T7,
//   T8,
//   T9,
//   T10,
//   T11,
//   T12,
//   T13,
//   T14,
//   T15,
// ) {
//   () Function(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15)
//       toUnitFn() => (
//             T1 value1,
//             T2 value2,
//             T3 value3,
//             T4 value4,
//             T5 value5,
//             T6 value6,
//             T7 value7,
//             T8 value8,
//             T9 value9,
//             T10 value10,
//             T11 value11,
//             T12 value12,
//             T13 value13,
//             T14 value14,
//             T15 value15,
//           ) {
//             this(
//               value1,
//               value2,
//               value3,
//               value4,
//               value5,
//               value6,
//               value7,
//               value8,
//               value9,
//               value10,
//               value11,
//               value12,
//               value13,
//               value14,
//               value15,
//             );
//             return ();
//           };
// }

// extension UnitFn16Ext<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13,
//     T14, T15, T16> on void Function(
//   T1,
//   T2,
//   T3,
//   T4,
//   T5,
//   T6,
//   T7,
//   T8,
//   T9,
//   T10,
//   T11,
//   T12,
//   T13,
//   T14,
//   T15,
//   T16,
// ) {
//   () Function(
//     T1,
//     T2,
//     T3,
//     T4,
//     T5,
//     T6,
//     T7,
//     T8,
//     T9,
//     T10,
//     T11,
//     T12,
//     T13,
//     T14,
//     T15,
//     T16,
//   ) toUnitFn() => (
//         T1 value1,
//         T2 value2,
//         T3 value3,
//         T4 value4,
//         T5 value5,
//         T6 value6,
//         T7 value7,
//         T8 value8,
//         T9 value9,
//         T10 value10,
//         T11 value11,
//         T12 value12,
//         T13 value13,
//         T14 value14,
//         T15 value15,
//         T16 value16,
//       ) {
//         this(
//           value1,
//           value2,
//           value3,
//           value4,
//           value5,
//           value6,
//           value7,
//           value8,
//           value9,
//           value10,
//           value11,
//           value12,
//           value13,
//           value14,
//           value15,
//           value16,
//         );
//         return ();
//       };
// }

// extension AsyncUnitFnExt on Future<void> Function() {
//   Future<()> Function() toUnitFn() => () async {
//         await this();
//         return ();
//       };
// }
