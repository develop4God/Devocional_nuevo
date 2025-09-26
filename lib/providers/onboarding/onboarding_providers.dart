import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devocional_nuevo/providers/onboarding/onboarding_state.dart';
import 'package:devocional_nuevo/providers/onboarding/onboarding_notifier.dart';
import 'package:devocional_nuevo/services/onboarding_service.dart';

/// Main onboarding provider that manages onboarding state
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingRiverpodState>((ref) {
  return OnboardingNotifier(
    onboardingService: OnboardingService.instance,
    ref: ref,
  );
});

/// Convenience provider to get current step index
final currentOnboardingStepProvider = Provider<int>((ref) {
  return ref.watch(onboardingProvider).currentStepIndexOrNull ?? 0;
});

/// Convenience provider to get user selections
final onboardingUserSelectionsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(onboardingProvider).userSelectionsOrNull ?? {};
});

/// Convenience provider to check if onboarding is loading
final onboardingLoadingProvider = Provider<bool>((ref) {
  return ref.watch(onboardingProvider).isLoading;
});

/// Convenience provider to check if onboarding is completed
final onboardingCompletedProvider = Provider<bool>((ref) {
  return ref.watch(onboardingProvider).isCompleted;
});

/// Convenience provider to check if onboarding has error
final onboardingHasErrorProvider = Provider<bool>((ref) {
  return ref.watch(onboardingProvider).isError;
});

/// Provider for selected theme family in onboarding
final onboardingSelectedThemeProvider = Provider<String?>((ref) {
  final userSelections = ref.watch(onboardingUserSelectionsProvider);
  return userSelections['selectedThemeFamily'] as String?;
});

/// Provider for backup enabled status in onboarding
final onboardingBackupEnabledProvider = Provider<bool>((ref) {
  final userSelections = ref.watch(onboardingUserSelectionsProvider);
  return userSelections['backupEnabled'] as bool? ?? false;
});