// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Option<T> {}

/// @nodoc

class _$Some<T> extends Some<T> {
  const _$Some(this.value) : super._();

  @override
  final T value;

  @override
  String toString() {
    return 'Option<$T>.some(value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Some<T> &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(value));
}

abstract class Some<T> extends Option<T> {
  const factory Some(final T value) = _$Some<T>;
  const Some._() : super._();

  T get value;
}

/// @nodoc

class _$None<T> extends None<T> {
  _$None() : super._();

  @override
  String toString() {
    return 'Option<$T>.none()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$None<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

abstract class None<T> extends Option<T> {
  factory None() = _$None<T>;
  None._() : super._();
}
