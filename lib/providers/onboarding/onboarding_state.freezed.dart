// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OnboardingRiverpodState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)
        stepActive,
    required TResult Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)
        configuring,
    required TResult Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)
        completed,
    required TResult Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)?
        stepActive,
    TResult? Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)?
        configuring,
    TResult? Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)?
        completed,
    TResult? Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)?
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)?
        stepActive,
    TResult Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)?
        configuring,
    TResult Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)?
        completed,
    TResult Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)?
        error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnboardingInitialState value) initial,
    required TResult Function(OnboardingLoadingState value) loading,
    required TResult Function(OnboardingStepActiveState value) stepActive,
    required TResult Function(OnboardingConfiguringState value) configuring,
    required TResult Function(OnboardingCompletedState value) completed,
    required TResult Function(OnboardingErrorState value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OnboardingInitialState value)? initial,
    TResult? Function(OnboardingLoadingState value)? loading,
    TResult? Function(OnboardingStepActiveState value)? stepActive,
    TResult? Function(OnboardingConfiguringState value)? configuring,
    TResult? Function(OnboardingCompletedState value)? completed,
    TResult? Function(OnboardingErrorState value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnboardingInitialState value)? initial,
    TResult Function(OnboardingLoadingState value)? loading,
    TResult Function(OnboardingStepActiveState value)? stepActive,
    TResult Function(OnboardingConfiguringState value)? configuring,
    TResult Function(OnboardingCompletedState value)? completed,
    TResult Function(OnboardingErrorState value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingRiverpodStateCopyWith<$Res> {
  factory $OnboardingRiverpodStateCopyWith(OnboardingRiverpodState value,
          $Res Function(OnboardingRiverpodState) then) =
      _$OnboardingRiverpodStateCopyWithImpl<$Res, OnboardingRiverpodState>;
}

/// @nodoc
class _$OnboardingRiverpodStateCopyWithImpl<$Res,
        $Val extends OnboardingRiverpodState>
    implements $OnboardingRiverpodStateCopyWith<$Res> {
  _$OnboardingRiverpodStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnboardingRiverpodState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$OnboardingInitialStateImplCopyWith<$Res> {
  factory _$$OnboardingInitialStateImplCopyWith(
          _$OnboardingInitialStateImpl value,
          $Res Function(_$OnboardingInitialStateImpl) then) =
      __$$OnboardingInitialStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$OnboardingInitialStateImplCopyWithImpl<$Res>
    extends _$OnboardingRiverpodStateCopyWithImpl<$Res,
        _$OnboardingInitialStateImpl>
    implements _$$OnboardingInitialStateImplCopyWith<$Res> {
  __$$OnboardingInitialStateImplCopyWithImpl(
      _$OnboardingInitialStateImpl _value,
      $Res Function(_$OnboardingInitialStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of OnboardingRiverpodState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$OnboardingInitialStateImpl implements OnboardingInitialState {
  const _$OnboardingInitialStateImpl();

  @override
  String toString() {
    return 'OnboardingRiverpodState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingInitialStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)
        stepActive,
    required TResult Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)
        configuring,
    required TResult Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)
        completed,
    required TResult Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)
        error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)?
        stepActive,
    TResult? Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)?
        configuring,
    TResult? Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)?
        completed,
    TResult? Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)?
        error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)?
        stepActive,
    TResult Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)?
        configuring,
    TResult Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)?
        completed,
    TResult Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)?
        error,
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
    required TResult Function(OnboardingInitialState value) initial,
    required TResult Function(OnboardingLoadingState value) loading,
    required TResult Function(OnboardingStepActiveState value) stepActive,
    required TResult Function(OnboardingConfiguringState value) configuring,
    required TResult Function(OnboardingCompletedState value) completed,
    required TResult Function(OnboardingErrorState value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OnboardingInitialState value)? initial,
    TResult? Function(OnboardingLoadingState value)? loading,
    TResult? Function(OnboardingStepActiveState value)? stepActive,
    TResult? Function(OnboardingConfiguringState value)? configuring,
    TResult? Function(OnboardingCompletedState value)? completed,
    TResult? Function(OnboardingErrorState value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnboardingInitialState value)? initial,
    TResult Function(OnboardingLoadingState value)? loading,
    TResult Function(OnboardingStepActiveState value)? stepActive,
    TResult Function(OnboardingConfiguringState value)? configuring,
    TResult Function(OnboardingCompletedState value)? completed,
    TResult Function(OnboardingErrorState value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class OnboardingInitialState implements OnboardingRiverpodState {
  const factory OnboardingInitialState() = _$OnboardingInitialStateImpl;
}

/// @nodoc
abstract class _$$OnboardingLoadingStateImplCopyWith<$Res> {
  factory _$$OnboardingLoadingStateImplCopyWith(
          _$OnboardingLoadingStateImpl value,
          $Res Function(_$OnboardingLoadingStateImpl) then) =
      __$$OnboardingLoadingStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$OnboardingLoadingStateImplCopyWithImpl<$Res>
    extends _$OnboardingRiverpodStateCopyWithImpl<$Res,
        _$OnboardingLoadingStateImpl>
    implements _$$OnboardingLoadingStateImplCopyWith<$Res> {
  __$$OnboardingLoadingStateImplCopyWithImpl(
      _$OnboardingLoadingStateImpl _value,
      $Res Function(_$OnboardingLoadingStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of OnboardingRiverpodState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$OnboardingLoadingStateImpl implements OnboardingLoadingState {
  const _$OnboardingLoadingStateImpl();

  @override
  String toString() {
    return 'OnboardingRiverpodState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingLoadingStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)
        stepActive,
    required TResult Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)
        configuring,
    required TResult Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)
        completed,
    required TResult Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)
        error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)?
        stepActive,
    TResult? Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)?
        configuring,
    TResult? Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)?
        completed,
    TResult? Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)?
        error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)?
        stepActive,
    TResult Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)?
        configuring,
    TResult Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)?
        completed,
    TResult Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)?
        error,
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
    required TResult Function(OnboardingInitialState value) initial,
    required TResult Function(OnboardingLoadingState value) loading,
    required TResult Function(OnboardingStepActiveState value) stepActive,
    required TResult Function(OnboardingConfiguringState value) configuring,
    required TResult Function(OnboardingCompletedState value) completed,
    required TResult Function(OnboardingErrorState value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OnboardingInitialState value)? initial,
    TResult? Function(OnboardingLoadingState value)? loading,
    TResult? Function(OnboardingStepActiveState value)? stepActive,
    TResult? Function(OnboardingConfiguringState value)? configuring,
    TResult? Function(OnboardingCompletedState value)? completed,
    TResult? Function(OnboardingErrorState value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnboardingInitialState value)? initial,
    TResult Function(OnboardingLoadingState value)? loading,
    TResult Function(OnboardingStepActiveState value)? stepActive,
    TResult Function(OnboardingConfiguringState value)? configuring,
    TResult Function(OnboardingCompletedState value)? completed,
    TResult Function(OnboardingErrorState value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class OnboardingLoadingState implements OnboardingRiverpodState {
  const factory OnboardingLoadingState() = _$OnboardingLoadingStateImpl;
}

/// @nodoc
abstract class _$$OnboardingStepActiveStateImplCopyWith<$Res> {
  factory _$$OnboardingStepActiveStateImplCopyWith(
          _$OnboardingStepActiveStateImpl value,
          $Res Function(_$OnboardingStepActiveStateImpl) then) =
      __$$OnboardingStepActiveStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {int currentStepIndex,
      OnboardingStepInfo currentStep,
      Map<String, dynamic> userSelections,
      Map<String, dynamic> stepConfiguration,
      bool canProgress,
      bool canGoBack,
      OnboardingProgress progress});
}

/// @nodoc
class __$$OnboardingStepActiveStateImplCopyWithImpl<$Res>
    extends _$OnboardingRiverpodStateCopyWithImpl<$Res,
        _$OnboardingStepActiveStateImpl>
    implements _$$OnboardingStepActiveStateImplCopyWith<$Res> {
  __$$OnboardingStepActiveStateImplCopyWithImpl(
      _$OnboardingStepActiveStateImpl _value,
      $Res Function(_$OnboardingStepActiveStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of OnboardingRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStepIndex = null,
    Object? currentStep = null,
    Object? userSelections = null,
    Object? stepConfiguration = null,
    Object? canProgress = null,
    Object? canGoBack = null,
    Object? progress = null,
  }) {
    return _then(_$OnboardingStepActiveStateImpl(
      currentStepIndex: null == currentStepIndex
          ? _value.currentStepIndex
          : currentStepIndex // ignore: cast_nullable_to_non_nullable
              as int,
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as OnboardingStepInfo,
      userSelections: null == userSelections
          ? _value._userSelections
          : userSelections // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      stepConfiguration: null == stepConfiguration
          ? _value._stepConfiguration
          : stepConfiguration // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      canProgress: null == canProgress
          ? _value.canProgress
          : canProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      canGoBack: null == canGoBack
          ? _value.canGoBack
          : canGoBack // ignore: cast_nullable_to_non_nullable
              as bool,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as OnboardingProgress,
    ));
  }
}

/// @nodoc

class _$OnboardingStepActiveStateImpl implements OnboardingStepActiveState {
  const _$OnboardingStepActiveStateImpl(
      {required this.currentStepIndex,
      required this.currentStep,
      required final Map<String, dynamic> userSelections,
      required final Map<String, dynamic> stepConfiguration,
      required this.canProgress,
      required this.canGoBack,
      required this.progress})
      : _userSelections = userSelections,
        _stepConfiguration = stepConfiguration;

  @override
  final int currentStepIndex;
  @override
  final OnboardingStepInfo currentStep;
  final Map<String, dynamic> _userSelections;
  @override
  Map<String, dynamic> get userSelections {
    if (_userSelections is EqualUnmodifiableMapView) return _userSelections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_userSelections);
  }

  final Map<String, dynamic> _stepConfiguration;
  @override
  Map<String, dynamic> get stepConfiguration {
    if (_stepConfiguration is EqualUnmodifiableMapView)
      return _stepConfiguration;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_stepConfiguration);
  }

  @override
  final bool canProgress;
  @override
  final bool canGoBack;
  @override
  final OnboardingProgress progress;

  @override
  String toString() {
    return 'OnboardingRiverpodState.stepActive(currentStepIndex: $currentStepIndex, currentStep: $currentStep, userSelections: $userSelections, stepConfiguration: $stepConfiguration, canProgress: $canProgress, canGoBack: $canGoBack, progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingStepActiveStateImpl &&
            (identical(other.currentStepIndex, currentStepIndex) ||
                other.currentStepIndex == currentStepIndex) &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            const DeepCollectionEquality()
                .equals(other._userSelections, _userSelections) &&
            const DeepCollectionEquality()
                .equals(other._stepConfiguration, _stepConfiguration) &&
            (identical(other.canProgress, canProgress) ||
                other.canProgress == canProgress) &&
            (identical(other.canGoBack, canGoBack) ||
                other.canGoBack == canGoBack) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentStepIndex,
      currentStep,
      const DeepCollectionEquality().hash(_userSelections),
      const DeepCollectionEquality().hash(_stepConfiguration),
      canProgress,
      canGoBack,
      progress);

  /// Create a copy of OnboardingRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingStepActiveStateImplCopyWith<_$OnboardingStepActiveStateImpl>
      get copyWith => __$$OnboardingStepActiveStateImplCopyWithImpl<
          _$OnboardingStepActiveStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)
        stepActive,
    required TResult Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)
        configuring,
    required TResult Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)
        completed,
    required TResult Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)
        error,
  }) {
    return stepActive(currentStepIndex, currentStep, userSelections,
        stepConfiguration, canProgress, canGoBack, progress);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)?
        stepActive,
    TResult? Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)?
        configuring,
    TResult? Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)?
        completed,
    TResult? Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)?
        error,
  }) {
    return stepActive?.call(currentStepIndex, currentStep, userSelections,
        stepConfiguration, canProgress, canGoBack, progress);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)?
        stepActive,
    TResult Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)?
        configuring,
    TResult Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)?
        completed,
    TResult Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)?
        error,
    required TResult orElse(),
  }) {
    if (stepActive != null) {
      return stepActive(currentStepIndex, currentStep, userSelections,
          stepConfiguration, canProgress, canGoBack, progress);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnboardingInitialState value) initial,
    required TResult Function(OnboardingLoadingState value) loading,
    required TResult Function(OnboardingStepActiveState value) stepActive,
    required TResult Function(OnboardingConfiguringState value) configuring,
    required TResult Function(OnboardingCompletedState value) completed,
    required TResult Function(OnboardingErrorState value) error,
  }) {
    return stepActive(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OnboardingInitialState value)? initial,
    TResult? Function(OnboardingLoadingState value)? loading,
    TResult? Function(OnboardingStepActiveState value)? stepActive,
    TResult? Function(OnboardingConfiguringState value)? configuring,
    TResult? Function(OnboardingCompletedState value)? completed,
    TResult? Function(OnboardingErrorState value)? error,
  }) {
    return stepActive?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnboardingInitialState value)? initial,
    TResult Function(OnboardingLoadingState value)? loading,
    TResult Function(OnboardingStepActiveState value)? stepActive,
    TResult Function(OnboardingConfiguringState value)? configuring,
    TResult Function(OnboardingCompletedState value)? completed,
    TResult Function(OnboardingErrorState value)? error,
    required TResult orElse(),
  }) {
    if (stepActive != null) {
      return stepActive(this);
    }
    return orElse();
  }
}

abstract class OnboardingStepActiveState implements OnboardingRiverpodState {
  const factory OnboardingStepActiveState(
          {required final int currentStepIndex,
          required final OnboardingStepInfo currentStep,
          required final Map<String, dynamic> userSelections,
          required final Map<String, dynamic> stepConfiguration,
          required final bool canProgress,
          required final bool canGoBack,
          required final OnboardingProgress progress}) =
      _$OnboardingStepActiveStateImpl;

  int get currentStepIndex;
  OnboardingStepInfo get currentStep;
  Map<String, dynamic> get userSelections;
  Map<String, dynamic> get stepConfiguration;
  bool get canProgress;
  bool get canGoBack;
  OnboardingProgress get progress;

  /// Create a copy of OnboardingRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingStepActiveStateImplCopyWith<_$OnboardingStepActiveStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$OnboardingConfiguringStateImplCopyWith<$Res> {
  factory _$$OnboardingConfiguringStateImplCopyWith(
          _$OnboardingConfiguringStateImpl value,
          $Res Function(_$OnboardingConfiguringStateImpl) then) =
      __$$OnboardingConfiguringStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {OnboardingConfigurationType configurationType,
      Map<String, dynamic> configurationData});
}

/// @nodoc
class __$$OnboardingConfiguringStateImplCopyWithImpl<$Res>
    extends _$OnboardingRiverpodStateCopyWithImpl<$Res,
        _$OnboardingConfiguringStateImpl>
    implements _$$OnboardingConfiguringStateImplCopyWith<$Res> {
  __$$OnboardingConfiguringStateImplCopyWithImpl(
      _$OnboardingConfiguringStateImpl _value,
      $Res Function(_$OnboardingConfiguringStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of OnboardingRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? configurationType = null,
    Object? configurationData = null,
  }) {
    return _then(_$OnboardingConfiguringStateImpl(
      configurationType: null == configurationType
          ? _value.configurationType
          : configurationType // ignore: cast_nullable_to_non_nullable
              as OnboardingConfigurationType,
      configurationData: null == configurationData
          ? _value._configurationData
          : configurationData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$OnboardingConfiguringStateImpl implements OnboardingConfiguringState {
  const _$OnboardingConfiguringStateImpl(
      {required this.configurationType,
      required final Map<String, dynamic> configurationData})
      : _configurationData = configurationData;

  @override
  final OnboardingConfigurationType configurationType;
  final Map<String, dynamic> _configurationData;
  @override
  Map<String, dynamic> get configurationData {
    if (_configurationData is EqualUnmodifiableMapView)
      return _configurationData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_configurationData);
  }

  @override
  String toString() {
    return 'OnboardingRiverpodState.configuring(configurationType: $configurationType, configurationData: $configurationData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingConfiguringStateImpl &&
            (identical(other.configurationType, configurationType) ||
                other.configurationType == configurationType) &&
            const DeepCollectionEquality()
                .equals(other._configurationData, _configurationData));
  }

  @override
  int get hashCode => Object.hash(runtimeType, configurationType,
      const DeepCollectionEquality().hash(_configurationData));

  /// Create a copy of OnboardingRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingConfiguringStateImplCopyWith<_$OnboardingConfiguringStateImpl>
      get copyWith => __$$OnboardingConfiguringStateImplCopyWithImpl<
          _$OnboardingConfiguringStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)
        stepActive,
    required TResult Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)
        configuring,
    required TResult Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)
        completed,
    required TResult Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)
        error,
  }) {
    return configuring(configurationType, configurationData);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)?
        stepActive,
    TResult? Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)?
        configuring,
    TResult? Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)?
        completed,
    TResult? Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)?
        error,
  }) {
    return configuring?.call(configurationType, configurationData);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)?
        stepActive,
    TResult Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)?
        configuring,
    TResult Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)?
        completed,
    TResult Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)?
        error,
    required TResult orElse(),
  }) {
    if (configuring != null) {
      return configuring(configurationType, configurationData);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnboardingInitialState value) initial,
    required TResult Function(OnboardingLoadingState value) loading,
    required TResult Function(OnboardingStepActiveState value) stepActive,
    required TResult Function(OnboardingConfiguringState value) configuring,
    required TResult Function(OnboardingCompletedState value) completed,
    required TResult Function(OnboardingErrorState value) error,
  }) {
    return configuring(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OnboardingInitialState value)? initial,
    TResult? Function(OnboardingLoadingState value)? loading,
    TResult? Function(OnboardingStepActiveState value)? stepActive,
    TResult? Function(OnboardingConfiguringState value)? configuring,
    TResult? Function(OnboardingCompletedState value)? completed,
    TResult? Function(OnboardingErrorState value)? error,
  }) {
    return configuring?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnboardingInitialState value)? initial,
    TResult Function(OnboardingLoadingState value)? loading,
    TResult Function(OnboardingStepActiveState value)? stepActive,
    TResult Function(OnboardingConfiguringState value)? configuring,
    TResult Function(OnboardingCompletedState value)? completed,
    TResult Function(OnboardingErrorState value)? error,
    required TResult orElse(),
  }) {
    if (configuring != null) {
      return configuring(this);
    }
    return orElse();
  }
}

abstract class OnboardingConfiguringState implements OnboardingRiverpodState {
  const factory OnboardingConfiguringState(
          {required final OnboardingConfigurationType configurationType,
          required final Map<String, dynamic> configurationData}) =
      _$OnboardingConfiguringStateImpl;

  OnboardingConfigurationType get configurationType;
  Map<String, dynamic> get configurationData;

  /// Create a copy of OnboardingRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingConfiguringStateImplCopyWith<_$OnboardingConfiguringStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$OnboardingCompletedStateImplCopyWith<$Res> {
  factory _$$OnboardingCompletedStateImplCopyWith(
          _$OnboardingCompletedStateImpl value,
          $Res Function(_$OnboardingCompletedStateImpl) then) =
      __$$OnboardingCompletedStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {Map<String, dynamic> appliedConfigurations,
      DateTime completionTimestamp});
}

/// @nodoc
class __$$OnboardingCompletedStateImplCopyWithImpl<$Res>
    extends _$OnboardingRiverpodStateCopyWithImpl<$Res,
        _$OnboardingCompletedStateImpl>
    implements _$$OnboardingCompletedStateImplCopyWith<$Res> {
  __$$OnboardingCompletedStateImplCopyWithImpl(
      _$OnboardingCompletedStateImpl _value,
      $Res Function(_$OnboardingCompletedStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of OnboardingRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appliedConfigurations = null,
    Object? completionTimestamp = null,
  }) {
    return _then(_$OnboardingCompletedStateImpl(
      appliedConfigurations: null == appliedConfigurations
          ? _value._appliedConfigurations
          : appliedConfigurations // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      completionTimestamp: null == completionTimestamp
          ? _value.completionTimestamp
          : completionTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$OnboardingCompletedStateImpl implements OnboardingCompletedState {
  const _$OnboardingCompletedStateImpl(
      {required final Map<String, dynamic> appliedConfigurations,
      required this.completionTimestamp})
      : _appliedConfigurations = appliedConfigurations;

  final Map<String, dynamic> _appliedConfigurations;
  @override
  Map<String, dynamic> get appliedConfigurations {
    if (_appliedConfigurations is EqualUnmodifiableMapView)
      return _appliedConfigurations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_appliedConfigurations);
  }

  @override
  final DateTime completionTimestamp;

  @override
  String toString() {
    return 'OnboardingRiverpodState.completed(appliedConfigurations: $appliedConfigurations, completionTimestamp: $completionTimestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingCompletedStateImpl &&
            const DeepCollectionEquality()
                .equals(other._appliedConfigurations, _appliedConfigurations) &&
            (identical(other.completionTimestamp, completionTimestamp) ||
                other.completionTimestamp == completionTimestamp));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_appliedConfigurations),
      completionTimestamp);

  /// Create a copy of OnboardingRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingCompletedStateImplCopyWith<_$OnboardingCompletedStateImpl>
      get copyWith => __$$OnboardingCompletedStateImplCopyWithImpl<
          _$OnboardingCompletedStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)
        stepActive,
    required TResult Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)
        configuring,
    required TResult Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)
        completed,
    required TResult Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)
        error,
  }) {
    return completed(appliedConfigurations, completionTimestamp);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)?
        stepActive,
    TResult? Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)?
        configuring,
    TResult? Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)?
        completed,
    TResult? Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)?
        error,
  }) {
    return completed?.call(appliedConfigurations, completionTimestamp);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)?
        stepActive,
    TResult Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)?
        configuring,
    TResult Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)?
        completed,
    TResult Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)?
        error,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(appliedConfigurations, completionTimestamp);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnboardingInitialState value) initial,
    required TResult Function(OnboardingLoadingState value) loading,
    required TResult Function(OnboardingStepActiveState value) stepActive,
    required TResult Function(OnboardingConfiguringState value) configuring,
    required TResult Function(OnboardingCompletedState value) completed,
    required TResult Function(OnboardingErrorState value) error,
  }) {
    return completed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OnboardingInitialState value)? initial,
    TResult? Function(OnboardingLoadingState value)? loading,
    TResult? Function(OnboardingStepActiveState value)? stepActive,
    TResult? Function(OnboardingConfiguringState value)? configuring,
    TResult? Function(OnboardingCompletedState value)? completed,
    TResult? Function(OnboardingErrorState value)? error,
  }) {
    return completed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnboardingInitialState value)? initial,
    TResult Function(OnboardingLoadingState value)? loading,
    TResult Function(OnboardingStepActiveState value)? stepActive,
    TResult Function(OnboardingConfiguringState value)? configuring,
    TResult Function(OnboardingCompletedState value)? completed,
    TResult Function(OnboardingErrorState value)? error,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(this);
    }
    return orElse();
  }
}

abstract class OnboardingCompletedState implements OnboardingRiverpodState {
  const factory OnboardingCompletedState(
          {required final Map<String, dynamic> appliedConfigurations,
          required final DateTime completionTimestamp}) =
      _$OnboardingCompletedStateImpl;

  Map<String, dynamic> get appliedConfigurations;
  DateTime get completionTimestamp;

  /// Create a copy of OnboardingRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingCompletedStateImplCopyWith<_$OnboardingCompletedStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$OnboardingErrorStateImplCopyWith<$Res> {
  factory _$$OnboardingErrorStateImplCopyWith(_$OnboardingErrorStateImpl value,
          $Res Function(_$OnboardingErrorStateImpl) then) =
      __$$OnboardingErrorStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String message,
      OnboardingErrorCategory category,
      Map<String, dynamic>? errorContext});
}

/// @nodoc
class __$$OnboardingErrorStateImplCopyWithImpl<$Res>
    extends _$OnboardingRiverpodStateCopyWithImpl<$Res,
        _$OnboardingErrorStateImpl>
    implements _$$OnboardingErrorStateImplCopyWith<$Res> {
  __$$OnboardingErrorStateImplCopyWithImpl(_$OnboardingErrorStateImpl _value,
      $Res Function(_$OnboardingErrorStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of OnboardingRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? category = null,
    Object? errorContext = freezed,
  }) {
    return _then(_$OnboardingErrorStateImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as OnboardingErrorCategory,
      errorContext: freezed == errorContext
          ? _value._errorContext
          : errorContext // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$OnboardingErrorStateImpl implements OnboardingErrorState {
  const _$OnboardingErrorStateImpl(
      {required this.message,
      required this.category,
      final Map<String, dynamic>? errorContext})
      : _errorContext = errorContext;

  @override
  final String message;
  @override
  final OnboardingErrorCategory category;
  final Map<String, dynamic>? _errorContext;
  @override
  Map<String, dynamic>? get errorContext {
    final value = _errorContext;
    if (value == null) return null;
    if (_errorContext is EqualUnmodifiableMapView) return _errorContext;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'OnboardingRiverpodState.error(message: $message, category: $category, errorContext: $errorContext)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingErrorStateImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality()
                .equals(other._errorContext, _errorContext));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, category,
      const DeepCollectionEquality().hash(_errorContext));

  /// Create a copy of OnboardingRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingErrorStateImplCopyWith<_$OnboardingErrorStateImpl>
      get copyWith =>
          __$$OnboardingErrorStateImplCopyWithImpl<_$OnboardingErrorStateImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)
        stepActive,
    required TResult Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)
        configuring,
    required TResult Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)
        completed,
    required TResult Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)
        error,
  }) {
    return error(message, category, errorContext);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)?
        stepActive,
    TResult? Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)?
        configuring,
    TResult? Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)?
        completed,
    TResult? Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)?
        error,
  }) {
    return error?.call(message, category, errorContext);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            int currentStepIndex,
            OnboardingStepInfo currentStep,
            Map<String, dynamic> userSelections,
            Map<String, dynamic> stepConfiguration,
            bool canProgress,
            bool canGoBack,
            OnboardingProgress progress)?
        stepActive,
    TResult Function(OnboardingConfigurationType configurationType,
            Map<String, dynamic> configurationData)?
        configuring,
    TResult Function(Map<String, dynamic> appliedConfigurations,
            DateTime completionTimestamp)?
        completed,
    TResult Function(String message, OnboardingErrorCategory category,
            Map<String, dynamic>? errorContext)?
        error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, category, errorContext);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnboardingInitialState value) initial,
    required TResult Function(OnboardingLoadingState value) loading,
    required TResult Function(OnboardingStepActiveState value) stepActive,
    required TResult Function(OnboardingConfiguringState value) configuring,
    required TResult Function(OnboardingCompletedState value) completed,
    required TResult Function(OnboardingErrorState value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OnboardingInitialState value)? initial,
    TResult? Function(OnboardingLoadingState value)? loading,
    TResult? Function(OnboardingStepActiveState value)? stepActive,
    TResult? Function(OnboardingConfiguringState value)? configuring,
    TResult? Function(OnboardingCompletedState value)? completed,
    TResult? Function(OnboardingErrorState value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnboardingInitialState value)? initial,
    TResult Function(OnboardingLoadingState value)? loading,
    TResult Function(OnboardingStepActiveState value)? stepActive,
    TResult Function(OnboardingConfiguringState value)? configuring,
    TResult Function(OnboardingCompletedState value)? completed,
    TResult Function(OnboardingErrorState value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class OnboardingErrorState implements OnboardingRiverpodState {
  const factory OnboardingErrorState(
      {required final String message,
      required final OnboardingErrorCategory category,
      final Map<String, dynamic>? errorContext}) = _$OnboardingErrorStateImpl;

  String get message;
  OnboardingErrorCategory get category;
  Map<String, dynamic>? get errorContext;

  /// Create a copy of OnboardingRiverpodState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingErrorStateImplCopyWith<_$OnboardingErrorStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
