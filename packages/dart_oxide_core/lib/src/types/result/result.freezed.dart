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
mixin _$Result<R, E> {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(R value) ok,
    required TResult Function(E error) err,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(R value)? ok,
    TResult? Function(E error)? err,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(R value)? ok,
    TResult Function(E error)? err,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultCopyWith<R, E, $Res> {
  factory $ResultCopyWith(
          Result<R, E> value, $Res Function(Result<R, E>) then) =
      _$ResultCopyWithImpl<R, E, $Res, Result<R, E>>;
}

/// @nodoc
class _$ResultCopyWithImpl<R, E, $Res, $Val extends Result<R, E>>
    implements $ResultCopyWith<R, E, $Res> {
  _$ResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$_OkCopyWith<R, E, $Res> {
  factory _$$_OkCopyWith(_$_Ok<R, E> value, $Res Function(_$_Ok<R, E>) then) =
      __$$_OkCopyWithImpl<R, E, $Res>;
  @useResult
  $Res call({R value});
}

/// @nodoc
class __$$_OkCopyWithImpl<R, E, $Res>
    extends _$ResultCopyWithImpl<R, E, $Res, _$_Ok<R, E>>
    implements _$$_OkCopyWith<R, E, $Res> {
  __$$_OkCopyWithImpl(_$_Ok<R, E> _value, $Res Function(_$_Ok<R, E>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = freezed,
  }) {
    return _then(_$_Ok<R, E>(
      freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as R,
    ));
  }
}

/// @nodoc

class _$_Ok<R, E> extends _Ok<R, E> {
  const _$_Ok(this.value) : super._();

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
            other is _$_Ok<R, E> &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(value));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_OkCopyWith<R, E, _$_Ok<R, E>> get copyWith =>
      __$$_OkCopyWithImpl<R, E, _$_Ok<R, E>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(R value) ok,
    required TResult Function(E error) err,
  }) {
    return ok(value);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(R value)? ok,
    TResult? Function(E error)? err,
  }) {
    return ok?.call(value);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(R value)? ok,
    TResult Function(E error)? err,
    required TResult orElse(),
  }) {
    if (ok != null) {
      return ok(value);
    }
    return orElse();
  }
}

abstract class _Ok<R, E> extends Result<R, E> {
  const factory _Ok(final R value) = _$_Ok<R, E>;
  const _Ok._() : super._();

  R get value;
  @JsonKey(ignore: true)
  _$$_OkCopyWith<R, E, _$_Ok<R, E>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_ErrCopyWith<R, E, $Res> {
  factory _$$_ErrCopyWith(
          _$_Err<R, E> value, $Res Function(_$_Err<R, E>) then) =
      __$$_ErrCopyWithImpl<R, E, $Res>;
  @useResult
  $Res call({E error});
}

/// @nodoc
class __$$_ErrCopyWithImpl<R, E, $Res>
    extends _$ResultCopyWithImpl<R, E, $Res, _$_Err<R, E>>
    implements _$$_ErrCopyWith<R, E, $Res> {
  __$$_ErrCopyWithImpl(_$_Err<R, E> _value, $Res Function(_$_Err<R, E>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = freezed,
  }) {
    return _then(_$_Err<R, E>(
      freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as E,
    ));
  }
}

/// @nodoc

class _$_Err<R, E> extends _Err<R, E> {
  const _$_Err(this.error) : super._();

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
            other is _$_Err<R, E> &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(error));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ErrCopyWith<R, E, _$_Err<R, E>> get copyWith =>
      __$$_ErrCopyWithImpl<R, E, _$_Err<R, E>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(R value) ok,
    required TResult Function(E error) err,
  }) {
    return err(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(R value)? ok,
    TResult? Function(E error)? err,
  }) {
    return err?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(R value)? ok,
    TResult Function(E error)? err,
    required TResult orElse(),
  }) {
    if (err != null) {
      return err(error);
    }
    return orElse();
  }
}

abstract class _Err<R, E> extends Result<R, E> {
  const factory _Err(final E error) = _$_Err<R, E>;
  const _Err._() : super._();

  E get error;
  @JsonKey(ignore: true)
  _$$_ErrCopyWith<R, E, _$_Err<R, E>> get copyWith =>
      throw _privateConstructorUsedError;
}
