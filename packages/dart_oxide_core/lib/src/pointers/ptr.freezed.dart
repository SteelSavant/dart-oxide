// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ptr.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$_BoxFinalizable<T> {
  T get value => throw _privateConstructorUsedError;
  void Function(T) get onFinalize => throw _privateConstructorUsedError;
}

/// @nodoc

class _$_BoxFinalizableImpl<T> extends _BoxFinalizableImpl<T> {
  const _$_BoxFinalizableImpl({required this.value, required this.onFinalize})
      : super._();

  @override
  final T value;
  @override
  final void Function(T) onFinalize;

  @override
  String toString() {
    return '_BoxFinalizable<$T>(value: $value, onFinalize: $onFinalize)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BoxFinalizableImpl<T> &&
            const DeepCollectionEquality().equals(other.value, value) &&
            (identical(other.onFinalize, onFinalize) ||
                other.onFinalize == onFinalize));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(value), onFinalize);
}

abstract class _BoxFinalizableImpl<T> extends _BoxFinalizable<T> {
  const factory _BoxFinalizableImpl(
      {required final T value,
      required final void Function(T) onFinalize}) = _$_BoxFinalizableImpl<T>;
  const _BoxFinalizableImpl._() : super._();

  @override
  T get value;
  @override
  void Function(T) get onFinalize;
}

/// @nodoc
mixin _$_CountedBoxFinalizable<T> {
  @freezed
  T get value => throw _privateConstructorUsedError;
  @freezed
  set value(T value) => throw _privateConstructorUsedError;
  @freezed
  void Function(T) get onFinalize => throw _privateConstructorUsedError;
  @freezed
  Ptr<int> get count => throw _privateConstructorUsedError;
  bool get isFinalized => throw _privateConstructorUsedError;
  set isFinalized(bool value) => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  _$CountedBoxFinalizableCopyWith<T, _CountedBoxFinalizable<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$CountedBoxFinalizableCopyWith<T, $Res> {
  factory _$CountedBoxFinalizableCopyWith(_CountedBoxFinalizable<T> value,
          $Res Function(_CountedBoxFinalizable<T>) then) =
      __$CountedBoxFinalizableCopyWithImpl<T, $Res, _CountedBoxFinalizable<T>>;
  @useResult
  $Res call(
      {@freezed T value,
      @freezed void Function(T) onFinalize,
      @freezed Ptr<int> count,
      bool isFinalized});
}

/// @nodoc
class __$CountedBoxFinalizableCopyWithImpl<T, $Res,
        $Val extends _CountedBoxFinalizable<T>>
    implements _$CountedBoxFinalizableCopyWith<T, $Res> {
  __$CountedBoxFinalizableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = freezed,
    Object? onFinalize = null,
    Object? count = null,
    Object? isFinalized = null,
  }) {
    return _then(_value.copyWith(
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as T,
      onFinalize: null == onFinalize
          ? _value.onFinalize
          : onFinalize // ignore: cast_nullable_to_non_nullable
              as void Function(T),
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as Ptr<int>,
      isFinalized: null == isFinalized
          ? _value.isFinalized
          : isFinalized // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CountedBoxFinalizableImplCopyWith<T, $Res>
    implements _$CountedBoxFinalizableCopyWith<T, $Res> {
  factory _$$_CountedBoxFinalizableImplCopyWith(
          _$_CountedBoxFinalizableImpl<T> value,
          $Res Function(_$_CountedBoxFinalizableImpl<T>) then) =
      __$$_CountedBoxFinalizableImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call(
      {@freezed T value,
      @freezed void Function(T) onFinalize,
      @freezed Ptr<int> count,
      bool isFinalized});
}

/// @nodoc
class __$$_CountedBoxFinalizableImplCopyWithImpl<T, $Res>
    extends __$CountedBoxFinalizableCopyWithImpl<T, $Res,
        _$_CountedBoxFinalizableImpl<T>>
    implements _$$_CountedBoxFinalizableImplCopyWith<T, $Res> {
  __$$_CountedBoxFinalizableImplCopyWithImpl(
      _$_CountedBoxFinalizableImpl<T> _value,
      $Res Function(_$_CountedBoxFinalizableImpl<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = freezed,
    Object? onFinalize = null,
    Object? count = null,
    Object? isFinalized = null,
  }) {
    return _then(_$_CountedBoxFinalizableImpl<T>(
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as T,
      onFinalize: null == onFinalize
          ? _value.onFinalize
          : onFinalize // ignore: cast_nullable_to_non_nullable
              as void Function(T),
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as Ptr<int>,
      isFinalized: null == isFinalized
          ? _value.isFinalized
          : isFinalized // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_CountedBoxFinalizableImpl<T> extends _CountedBoxFinalizableImpl<T> {
  _$_CountedBoxFinalizableImpl(
      {@freezed required this.value,
      @freezed required this.onFinalize,
      @freezed required this.count,
      required this.isFinalized})
      : super._();

  @override
  @freezed
  T value;
  @override
  @freezed
  final void Function(T) onFinalize;
  @override
  @freezed
  final Ptr<int> count;
  @override
  bool isFinalized;

  @override
  String toString() {
    return '_CountedBoxFinalizable<$T>(value: $value, onFinalize: $onFinalize, count: $count, isFinalized: $isFinalized)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CountedBoxFinalizableImplCopyWith<T, _$_CountedBoxFinalizableImpl<T>>
      get copyWith => __$$_CountedBoxFinalizableImplCopyWithImpl<T,
          _$_CountedBoxFinalizableImpl<T>>(this, _$identity);
}

abstract class _CountedBoxFinalizableImpl<T> extends _CountedBoxFinalizable<T> {
  factory _CountedBoxFinalizableImpl(
      {@freezed required T value,
      @freezed required final void Function(T) onFinalize,
      @freezed required final Ptr<int> count,
      required bool isFinalized}) = _$_CountedBoxFinalizableImpl<T>;
  _CountedBoxFinalizableImpl._() : super._();

  @override
  @freezed
  T get value;
  @freezed
  set value(T value);
  @override
  @freezed
  void Function(T) get onFinalize;
  @override
  @freezed
  Ptr<int> get count;
  @override
  bool get isFinalized;
  set isFinalized(bool value);
  @override
  @JsonKey(ignore: true)
  _$$_CountedBoxFinalizableImplCopyWith<T, _$_CountedBoxFinalizableImpl<T>>
      get copyWith => throw _privateConstructorUsedError;
}
