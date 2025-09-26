import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:devocional_nuevo/models/onboarding_models.dart';

part 'onboarding_state.freezed.dart';

@freezed
class OnboardingRiverpodState with _$OnboardingRiverpodState {
  const factory OnboardingRiverpodState.initial() = OnboardingInitialState;
  
  const factory OnboardingRiverpodState.loading() = OnboardingLoadingState;
  
  const factory OnboardingRiverpodState.stepActive({
    required int currentStepIndex,
    required OnboardingStepInfo currentStep,
    required Map<String, dynamic> userSelections,
    required Map<String, dynamic> stepConfiguration,
    required bool canProgress,
    required bool canGoBack,
    required OnboardingProgress progress,
  }) = OnboardingStepActiveState;
  
  const factory OnboardingRiverpodState.configuring({
    required OnboardingConfigurationType configurationType,
    required Map<String, dynamic> configurationData,
  }) = OnboardingConfiguringState;
  
  const factory OnboardingRiverpodState.completed({
    required Map<String, dynamic> appliedConfigurations,
    required DateTime completionTimestamp,
  }) = OnboardingCompletedState;
  
  const factory OnboardingRiverpodState.error({
    required String message,
    required OnboardingErrorCategory category,
    Map<String, dynamic>? errorContext,
  }) = OnboardingErrorState;
}

// Extension methods for easier access
extension OnboardingRiverpodStateX on OnboardingRiverpodState {
  int? get currentStepIndexOrNull => maybeWhen(
        stepActive: (currentStepIndex, _, __, ___, ____, _____, ______) => currentStepIndex,
        orElse: () => null,
      );

  Map<String, dynamic>? get userSelectionsOrNull => maybeWhen(
        stepActive: (_, __, userSelections, ___, ____, _____, ______) => userSelections,
        orElse: () => null,
      );

  bool get isLoading => maybeWhen(
        loading: () => true,
        orElse: () => false,
      );

  bool get isError => maybeWhen(
        error: (_, __, ___) => true,
        orElse: () => false,
      );

  bool get isCompleted => maybeWhen(
        completed: (_, __) => true,
        orElse: () => false,
      );
}