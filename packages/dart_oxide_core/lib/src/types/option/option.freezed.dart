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
mixin _$Option<T> {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T value) some,
    required TResult Function() none,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T value)? some,
    TResult? Function()? none,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T value)? some,
    TResult Function()? none,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OptionCopyWith<T, $Res> {
  factory $OptionCopyWith(Option<T> value, $Res Function(Option<T>) then) =
      _$OptionCopyWithImpl<T, $Res, Option<T>>;
}

/// @nodoc
class _$OptionCopyWithImpl<T, $Res, $Val extends Option<T>>
    implements $OptionCopyWith<T, $Res> {
  _$OptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$_SomeCopyWith<T, $Res> {
  factory _$$_SomeCopyWith(_$_Some<T> value, $Res Function(_$_Some<T>) then) =
      __$$_SomeCopyWithImpl<T, $Res>;
  @useResult
  $Res call({T value});
}

/// @nodoc
class __$$_SomeCopyWithImpl<T, $Res>
    extends _$OptionCopyWithImpl<T, $Res, _$_Some<T>>
    implements _$$_SomeCopyWith<T, $Res> {
  __$$_SomeCopyWithImpl(_$_Some<T> _value, $Res Function(_$_Some<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = freezed,
  }) {
    return _then(_$_Some<T>(
      freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc

class _$_Some<T> extends _Some<T> {
  const _$_Some(this.value) : super._();

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
            other is _$_Some<T> &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(value));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SomeCopyWith<T, _$_Some<T>> get copyWith =>
      __$$_SomeCopyWithImpl<T, _$_Some<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T value) some,
    required TResult Function() none,
  }) {
    return some(value);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T value)? some,
    TResult? Function()? none,
  }) {
    return some?.call(value);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T value)? some,
    TResult Function()? none,
    required TResult orElse(),
  }) {
    if (some != null) {
      return some(value);
    }
    return orElse();
  }
}

abstract class _Some<T> extends Option<T> {
  const factory _Some(final T value) = _$_Some<T>;
  const _Some._() : super._();

  T get value;
  @JsonKey(ignore: true)
  _$$_SomeCopyWith<T, _$_Some<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_NoneCopyWith<T, $Res> {
  factory _$$_NoneCopyWith(_$_None<T> value, $Res Function(_$_None<T>) then) =
      __$$_NoneCopyWithImpl<T, $Res>;
}

/// @nodoc
class __$$_NoneCopyWithImpl<T, $Res>
    extends _$OptionCopyWithImpl<T, $Res, _$_None<T>>
    implements _$$_NoneCopyWith<T, $Res> {
  __$$_NoneCopyWithImpl(_$_None<T> _value, $Res Function(_$_None<T>) _then)
      : super(_value, _then);
}

/// @nodoc

class _$_None<T> extends _None<T> {
  const _$_None() : super._();

  @override
  String toString() {
    return 'Option<$T>.none()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$_None<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T value) some,
    required TResult Function() none,
  }) {
    return none();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T value)? some,
    TResult? Function()? none,
  }) {
    return none?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T value)? some,
    TResult Function()? none,
    required TResult orElse(),
  }) {
    if (none != null) {
      return none();
    }
    return orElse();
  }
}

abstract class _None<T> extends Option<T> {
  const factory _None() = _$_None<T>;
  const _None._() : super._();
}
