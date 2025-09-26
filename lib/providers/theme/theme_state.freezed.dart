// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'theme_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ThemeState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
            String themeFamily, Brightness brightness, ThemeData themeData)
        loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(
            String themeFamily, Brightness brightness, ThemeData themeData)?
        loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(
            String themeFamily, Brightness brightness, ThemeData themeData)?
        loaded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ThemeStateLoading value) loading,
    required TResult Function(ThemeStateLoaded value) loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ThemeStateLoading value)? loading,
    TResult? Function(ThemeStateLoaded value)? loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ThemeStateLoading value)? loading,
    TResult Function(ThemeStateLoaded value)? loaded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThemeStateCopyWith<$Res> {
  factory $ThemeStateCopyWith(
          ThemeState value, $Res Function(ThemeState) then) =
      _$ThemeStateCopyWithImpl<$Res, ThemeState>;
}

/// @nodoc
class _$ThemeStateCopyWithImpl<$Res, $Val extends ThemeState>
    implements $ThemeStateCopyWith<$Res> {
  _$ThemeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ThemeState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ThemeStateLoadingImplCopyWith<$Res> {
  factory _$$ThemeStateLoadingImplCopyWith(_$ThemeStateLoadingImpl value,
          $Res Function(_$ThemeStateLoadingImpl) then) =
      __$$ThemeStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ThemeStateLoadingImplCopyWithImpl<$Res>
    extends _$ThemeStateCopyWithImpl<$Res, _$ThemeStateLoadingImpl>
    implements _$$ThemeStateLoadingImplCopyWith<$Res> {
  __$$ThemeStateLoadingImplCopyWithImpl(_$ThemeStateLoadingImpl _value,
      $Res Function(_$ThemeStateLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ThemeState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ThemeStateLoadingImpl implements ThemeStateLoading {
  const _$ThemeStateLoadingImpl();

  @override
  String toString() {
    return 'ThemeState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ThemeStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
            String themeFamily, Brightness brightness, ThemeData themeData)
        loaded,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(
            String themeFamily, Brightness brightness, ThemeData themeData)?
        loaded,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(
            String themeFamily, Brightness brightness, ThemeData themeData)?
        loaded,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ThemeStateLoading value) loading,
    required TResult Function(ThemeStateLoaded value) loaded,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ThemeStateLoading value)? loading,
    TResult? Function(ThemeStateLoaded value)? loaded,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ThemeStateLoading value)? loading,
    TResult Function(ThemeStateLoaded value)? loaded,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class ThemeStateLoading implements ThemeState {
  const factory ThemeStateLoading() = _$ThemeStateLoadingImpl;
}

/// @nodoc
abstract class _$$ThemeStateLoadedImplCopyWith<$Res> {
  factory _$$ThemeStateLoadedImplCopyWith(_$ThemeStateLoadedImpl value,
          $Res Function(_$ThemeStateLoadedImpl) then) =
      __$$ThemeStateLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String themeFamily, Brightness brightness, ThemeData themeData});
}

/// @nodoc
class __$$ThemeStateLoadedImplCopyWithImpl<$Res>
    extends _$ThemeStateCopyWithImpl<$Res, _$ThemeStateLoadedImpl>
    implements _$$ThemeStateLoadedImplCopyWith<$Res> {
  __$$ThemeStateLoadedImplCopyWithImpl(_$ThemeStateLoadedImpl _value,
      $Res Function(_$ThemeStateLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of ThemeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeFamily = null,
    Object? brightness = null,
    Object? themeData = null,
  }) {
    return _then(_$ThemeStateLoadedImpl(
      themeFamily: null == themeFamily
          ? _value.themeFamily
          : themeFamily // ignore: cast_nullable_to_non_nullable
              as String,
      brightness: null == brightness
          ? _value.brightness
          : brightness // ignore: cast_nullable_to_non_nullable
              as Brightness,
      themeData: null == themeData
          ? _value.themeData
          : themeData // ignore: cast_nullable_to_non_nullable
              as ThemeData,
    ));
  }
}

/// @nodoc

class _$ThemeStateLoadedImpl implements ThemeStateLoaded {
  const _$ThemeStateLoadedImpl(
      {required this.themeFamily,
      required this.brightness,
      required this.themeData});

  @override
  final String themeFamily;
  @override
  final Brightness brightness;
  @override
  final ThemeData themeData;

  @override
  String toString() {
    return 'ThemeState.loaded(themeFamily: $themeFamily, brightness: $brightness, themeData: $themeData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThemeStateLoadedImpl &&
            (identical(other.themeFamily, themeFamily) ||
                other.themeFamily == themeFamily) &&
            (identical(other.brightness, brightness) ||
                other.brightness == brightness) &&
            (identical(other.themeData, themeData) ||
                other.themeData == themeData));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, themeFamily, brightness, themeData);

  /// Create a copy of ThemeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ThemeStateLoadedImplCopyWith<_$ThemeStateLoadedImpl> get copyWith =>
      __$$ThemeStateLoadedImplCopyWithImpl<_$ThemeStateLoadedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
            String themeFamily, Brightness brightness, ThemeData themeData)
        loaded,
  }) {
    return loaded(themeFamily, brightness, themeData);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(
            String themeFamily, Brightness brightness, ThemeData themeData)?
        loaded,
  }) {
    return loaded?.call(themeFamily, brightness, themeData);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(
            String themeFamily, Brightness brightness, ThemeData themeData)?
        loaded,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(themeFamily, brightness, themeData);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ThemeStateLoading value) loading,
    required TResult Function(ThemeStateLoaded value) loaded,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ThemeStateLoading value)? loading,
    TResult? Function(ThemeStateLoaded value)? loaded,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ThemeStateLoading value)? loading,
    TResult Function(ThemeStateLoaded value)? loaded,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class ThemeStateLoaded implements ThemeState {
  const factory ThemeStateLoaded(
      {required final String themeFamily,
      required final Brightness brightness,
      required final ThemeData themeData}) = _$ThemeStateLoadedImpl;

  String get themeFamily;
  Brightness get brightness;
  ThemeData get themeData;

  /// Create a copy of ThemeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ThemeStateLoadedImplCopyWith<_$ThemeStateLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
