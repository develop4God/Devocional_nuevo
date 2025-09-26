// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prayers_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PrayersRiverpodState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Prayer> prayers, String? errorMessage)
        loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Prayer> prayers, String? errorMessage)? loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Prayer> prayers, String? errorMessage)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PrayersStateInitial value) initial,
    required TResult Function(PrayersStateLoading value) loading,
    required TResult Function(PrayersStateLoaded value) loaded,
    required TResult Function(PrayersStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PrayersStateInitial value)? initial,
    TResult? Function(PrayersStateLoading value)? loading,
    TResult? Function(PrayersStateLoaded value)? loaded,
    TResult? Function(PrayersStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PrayersStateInitial value)? initial,
    TResult Function(PrayersStateLoading value)? loading,
    TResult Function(PrayersStateLoaded value)? loaded,
    TResult Function(PrayersStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrayersRiverpodStateCopyWith<$Res> {
  factory $PrayersRiverpodStateCopyWith(PrayersRiverpodState value,
          $Res Function(PrayersRiverpodState) then) =
      _$PrayersRiverpodStateCopyWithImpl<$Res, PrayersRiverpodState>;
}

/// @nodoc
class _$PrayersRiverpodStateCopyWithImpl<$Res,
        $Val extends PrayersRiverpodState>
    implements $PrayersRiverpodStateCopyWith<$Res> {
  _$PrayersRiverpodStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrayersRiverpodState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$PrayersStateInitialImplCopyWith<$Res> {
  factory _$$PrayersStateInitialImplCopyWith(_$PrayersStateInitialImpl value,
          $Res Function(_$PrayersStateInitialImpl) then) =
      __$$PrayersStateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PrayersStateInitialImplCopyWithImpl<$Res>
    extends _$PrayersRiverpodStateCopyWithImpl<$Res, _$PrayersStateInitialImpl>
    implements _$$PrayersStateInitialImplCopyWith<$Res> {
  __$$PrayersStateInitialImplCopyWithImpl(_$PrayersStateInitialImpl _value,
      $Res Function(_$PrayersStateInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of PrayersRiverpodState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PrayersStateInitialImpl implements PrayersStateInitial {
  const _$PrayersStateInitialImpl();

  @override
  String toString() {
    return 'PrayersRiverpodState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrayersStateInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Prayer> prayers, String? errorMessage)
        loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Prayer> prayers, String? errorMessage)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Prayer> prayers, String? errorMessage)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PrayersStateInitial value) initial,
    required TResult Function(PrayersStateLoading value) loading,
    required TResult Function(PrayersStateLoaded value) loaded,
    required TResult Function(PrayersStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PrayersStateInitial value)? initial,
    TResult? Function(PrayersStateLoading value)? loading,
    TResult? Function(PrayersStateLoaded value)? loaded,
    TResult? Function(PrayersStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PrayersStateInitial value)? initial,
    TResult Function(PrayersStateLoading value)? loading,
    TResult Function(PrayersStateLoaded value)? loaded,
    TResult Function(PrayersStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class PrayersStateInitial implements PrayersRiverpodState {
  const factory PrayersStateInitial() = _$PrayersStateInitialImpl;
}

/// @nodoc
abstract class _$$PrayersStateLoadingImplCopyWith<$Res> {
  factory _$$PrayersStateLoadingImplCopyWith(_$PrayersStateLoadingImpl value,
          $Res Function(_$PrayersStateLoadingImpl) then) =
      __$$PrayersStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PrayersStateLoadingImplCopyWithImpl<$Res>
    extends _$PrayersRiverpodStateCopyWithImpl<$Res, _$PrayersStateLoadingImpl>
    implements _$$PrayersStateLoadingImplCopyWith<$Res> {
  __$$PrayersStateLoadingImplCopyWithImpl(_$PrayersStateLoadingImpl _value,
      $Res Function(_$PrayersStateLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of PrayersRiverpodState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PrayersStateLoadingImpl implements PrayersStateLoading {
  const _$PrayersStateLoadingImpl();

  @override
  String toString() {
    return 'PrayersRiverpodState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrayersStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Prayer> prayers, String? errorMessage)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Prayer> prayers, String? errorMessage)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Prayer> prayers, String? errorMessage)? loaded,
    TResult Function(String message)? error,
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
    required TResult Function(PrayersStateInitial value) initial,
    required TResult Function(PrayersStateLoading value) loading,
    required TResult Function(PrayersStateLoaded value) loaded,
    required TResult Function(PrayersStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PrayersStateInitial value)? initial,
    TResult? Function(PrayersStateLoading value)? loading,
    TResult? Function(PrayersStateLoaded value)? loaded,
    TResult? Function(PrayersStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PrayersStateInitial value)? initial,
    TResult Function(PrayersStateLoading value)? loading,
    TResult Function(PrayersStateLoaded value)? loaded,
    TResult Function(PrayersStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class PrayersStateLoading implements PrayersRiverpodState {
  const factory PrayersStateLoading() = _$PrayersStateLoadingImpl;
}

/// @nodoc
abstract class _$$PrayersStateLoadedImplCopyWith<$Res> {
  factory _$$PrayersStateLoadedImplCopyWith(_$PrayersStateLoadedImpl value,
          $Res Function(_$PrayersStateLoadedImpl) then) =
      __$$PrayersStateLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Prayer> prayers, String? errorMessage});
}

/// @nodoc
class __$$PrayersStateLoadedImplCopyWithImpl<$Res>
    extends _$PrayersRiverpodStateCopyWithImpl<$Res, _$PrayersStateLoadedImpl>
    implements _$$PrayersStateLoadedImplCopyWith<$Res> {
  __$$PrayersStateLoadedImplCopyWithImpl(_$PrayersStateLoadedImpl _value,
      $Res Function(_$PrayersStateLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of PrayersRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prayers = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$PrayersStateLoadedImpl(
      prayers: null == prayers
          ? _value._prayers
          : prayers // ignore: cast_nullable_to_non_nullable
              as List<Prayer>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PrayersStateLoadedImpl implements PrayersStateLoaded {
  const _$PrayersStateLoadedImpl(
      {required final List<Prayer> prayers, this.errorMessage})
      : _prayers = prayers;

  final List<Prayer> _prayers;
  @override
  List<Prayer> get prayers {
    if (_prayers is EqualUnmodifiableListView) return _prayers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_prayers);
  }

  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PrayersRiverpodState.loaded(prayers: $prayers, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrayersStateLoadedImpl &&
            const DeepCollectionEquality().equals(other._prayers, _prayers) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_prayers), errorMessage);

  /// Create a copy of PrayersRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrayersStateLoadedImplCopyWith<_$PrayersStateLoadedImpl> get copyWith =>
      __$$PrayersStateLoadedImplCopyWithImpl<_$PrayersStateLoadedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Prayer> prayers, String? errorMessage)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(prayers, errorMessage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Prayer> prayers, String? errorMessage)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(prayers, errorMessage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Prayer> prayers, String? errorMessage)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(prayers, errorMessage);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PrayersStateInitial value) initial,
    required TResult Function(PrayersStateLoading value) loading,
    required TResult Function(PrayersStateLoaded value) loaded,
    required TResult Function(PrayersStateError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PrayersStateInitial value)? initial,
    TResult? Function(PrayersStateLoading value)? loading,
    TResult? Function(PrayersStateLoaded value)? loaded,
    TResult? Function(PrayersStateError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PrayersStateInitial value)? initial,
    TResult Function(PrayersStateLoading value)? loading,
    TResult Function(PrayersStateLoaded value)? loaded,
    TResult Function(PrayersStateError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class PrayersStateLoaded implements PrayersRiverpodState {
  const factory PrayersStateLoaded(
      {required final List<Prayer> prayers,
      final String? errorMessage}) = _$PrayersStateLoadedImpl;

  List<Prayer> get prayers;
  String? get errorMessage;

  /// Create a copy of PrayersRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrayersStateLoadedImplCopyWith<_$PrayersStateLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PrayersStateErrorImplCopyWith<$Res> {
  factory _$$PrayersStateErrorImplCopyWith(_$PrayersStateErrorImpl value,
          $Res Function(_$PrayersStateErrorImpl) then) =
      __$$PrayersStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$PrayersStateErrorImplCopyWithImpl<$Res>
    extends _$PrayersRiverpodStateCopyWithImpl<$Res, _$PrayersStateErrorImpl>
    implements _$$PrayersStateErrorImplCopyWith<$Res> {
  __$$PrayersStateErrorImplCopyWithImpl(_$PrayersStateErrorImpl _value,
      $Res Function(_$PrayersStateErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of PrayersRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$PrayersStateErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$PrayersStateErrorImpl implements PrayersStateError {
  const _$PrayersStateErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'PrayersRiverpodState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrayersStateErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of PrayersRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrayersStateErrorImplCopyWith<_$PrayersStateErrorImpl> get copyWith =>
      __$$PrayersStateErrorImplCopyWithImpl<_$PrayersStateErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Prayer> prayers, String? errorMessage)
        loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Prayer> prayers, String? errorMessage)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Prayer> prayers, String? errorMessage)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PrayersStateInitial value) initial,
    required TResult Function(PrayersStateLoading value) loading,
    required TResult Function(PrayersStateLoaded value) loaded,
    required TResult Function(PrayersStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PrayersStateInitial value)? initial,
    TResult? Function(PrayersStateLoading value)? loading,
    TResult? Function(PrayersStateLoaded value)? loaded,
    TResult? Function(PrayersStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PrayersStateInitial value)? initial,
    TResult Function(PrayersStateLoading value)? loading,
    TResult Function(PrayersStateLoaded value)? loaded,
    TResult Function(PrayersStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class PrayersStateError implements PrayersRiverpodState {
  const factory PrayersStateError({required final String message}) =
      _$PrayersStateErrorImpl;

  String get message;

  /// Create a copy of PrayersRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrayersStateErrorImplCopyWith<_$PrayersStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
