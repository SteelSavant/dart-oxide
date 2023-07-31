// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Result<R, E> {}

/// @nodoc

class _$Ok<R, E> extends Ok<R, E> {
  const _$Ok(this.value) : super._();

  @override
  final R value;

  @override
  String toString() {
    return 'Result<$R, $E>.ok(value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Ok<R, E> &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(value));
}

abstract class Ok<R, E> extends Result<R, E> {
  const factory Ok(final R value) = _$Ok<R, E>;
  const Ok._() : super._();

  R get value;
}

/// @nodoc

class _$Err<R, E> extends Err<R, E> {
  const _$Err(this.error) : super._();

  @override
  final E error;

  @override
  String toString() {
    return 'Result<$R, $E>.err(error: $error)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Err<R, E> &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(error));
}

abstract class Err<R, E> extends Result<R, E> {
  const factory Err(final E error) = _$Err<R, E>;
  const Err._() : super._();

  E get error;
}
