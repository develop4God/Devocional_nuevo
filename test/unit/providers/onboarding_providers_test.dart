import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devocional_nuevo/providers/onboarding/onboarding_providers.dart';
import 'package:devocional_nuevo/providers/onboarding/onboarding_state.dart';

void main() {
  group('Onboarding Providers Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('onboardingProvider should provide OnboardingNotifier', () {
      final notifier = container.read(onboardingProvider.notifier);
      expect(notifier, isNotNull);
      
      final state = container.read(onboardingProvider);
      expect(state, isA<OnboardingInitialState>());
    });

    test('currentOnboardingStepProvider should return current step index', () {
      // Initial state
      final currentStep = container.read(currentOnboardingStepProvider);
      expect(currentStep, equals(0));
    });

    test('onboardingUserSelectionsProvider should return user selections', () {
      // Initial state
      final userSelections = container.read(onboardingUserSelectionsProvider);
      expect(userSelections, isEmpty);
    });

    test('onboardingLoadingProvider should return loading state', () {
      // Initial state
      final isLoading = container.read(onboardingLoadingProvider);
      expect(isLoading, isFalse);
    });

    test('onboardingCompletedProvider should return completion state', () {
      // Initial state
      final isCompleted = container.read(onboardingCompletedProvider);
      expect(isCompleted, isFalse);
    });

    test('onboardingHasErrorProvider should return error state', () {
      // Initial state
      final hasError = container.read(onboardingHasErrorProvider);
      expect(hasError, isFalse);
    });

    test('onboardingSelectedThemeProvider should return selected theme', () {
      // Initial state
      final selectedTheme = container.read(onboardingSelectedThemeProvider);
      expect(selectedTheme, isNull);
    });

    test('onboardingBackupEnabledProvider should return backup status', () {
      // Initial state
      final backupEnabled = container.read(onboardingBackupEnabledProvider);
      expect(backupEnabled, isFalse);
    });

    group('Provider State Changes', () {
      test('should update currentOnboardingStepProvider when step changes', () async {
        // Initialize onboarding
        await container.read(onboardingProvider.notifier).initialize();
        
        expect(container.read(currentOnboardingStepProvider), equals(0));

        // Progress to step 1
        await container.read(onboardingProvider.notifier).progressToStep(1);
        
        expect(container.read(currentOnboardingStepProvider), equals(1));
      });

      test('should update onboardingSelectedThemeProvider when theme is selected', () async {
        await container.read(onboardingProvider.notifier).initialize();
        
        expect(container.read(onboardingSelectedThemeProvider), isNull);

        await container.read(onboardingProvider.notifier).selectTheme('Green');
        
        expect(container.read(onboardingSelectedThemeProvider), equals('Green'));
      });

      test('should update onboardingBackupEnabledProvider when backup is configured', () async {
        await container.read(onboardingProvider.notifier).initialize();
        
        expect(container.read(onboardingBackupEnabledProvider), isFalse);

        await container.read(onboardingProvider.notifier).configureBackupOption(true);
        
        expect(container.read(onboardingBackupEnabledProvider), isTrue);
      });

      test('should update onboardingCompletedProvider when onboarding is completed', () async {
        await container.read(onboardingProvider.notifier).initialize();
        
        expect(container.read(onboardingCompletedProvider), isFalse);

        await container.read(onboardingProvider.notifier).complete();
        
        expect(container.read(onboardingCompletedProvider), isTrue);
      });

      test('should update userSelectionsProvider when selections are made', () async {
        await container.read(onboardingProvider.notifier).initialize();
        
        expect(container.read(onboardingUserSelectionsProvider), isEmpty);

        await container.read(onboardingProvider.notifier).selectTheme('Pink');
        
        final userSelections = container.read(onboardingUserSelectionsProvider);
        expect(userSelections['selectedThemeFamily'], equals('Pink'));
        expect(userSelections.length, equals(1));

        await container.read(onboardingProvider.notifier).configureBackupOption(false);
        
        final updatedSelections = container.read(onboardingUserSelectionsProvider);
        expect(updatedSelections.length, equals(2));
        expect(updatedSelections['backupEnabled'], isFalse);
      });
    });

    group('Provider Reactivity Tests', () {
      test('convenience providers should be reactive to state changes', () async {
        final states = <bool>[];
        
        // Listen to loading state changes
        container.listen(onboardingLoadingProvider, (previous, next) {
          states.add(next);
        });

        await container.read(onboardingProvider.notifier).initialize();

        // Should have captured state changes
        expect(states, isNotEmpty);
      });

      test('providers should handle null state gracefully', () {
        // Test providers with initial state
        expect(container.read(currentOnboardingStepProvider), equals(0));
        expect(container.read(onboardingUserSelectionsProvider), isEmpty);
        expect(container.read(onboardingSelectedThemeProvider), isNull);
        expect(container.read(onboardingBackupEnabledProvider), isFalse);
        expect(container.read(onboardingLoadingProvider), isFalse);
        expect(container.read(onboardingCompletedProvider), isFalse);
        expect(container.read(onboardingHasErrorProvider), isFalse);
      });
    });

    group('Provider Integration Tests', () {
      test('should handle complex workflow through providers', () async {
        // Start onboarding
        await container.read(onboardingProvider.notifier).initialize();
        expect(container.read(currentOnboardingStepProvider), equals(0));
        
        // Select theme
        await container.read(onboardingProvider.notifier).selectTheme('Cyan');
        expect(container.read(onboardingSelectedThemeProvider), equals('Cyan'));
        
        // Progress to backup step
        await container.read(onboardingProvider.notifier).progressToStep(2);
        expect(container.read(currentOnboardingStepProvider), equals(2));
        
        // Configure backup
        await container.read(onboardingProvider.notifier).configureBackupOption(true);
        expect(container.read(onboardingBackupEnabledProvider), isTrue);
        
        // Get selections before completing
        final selectionsBeforeComplete = container.read(onboardingUserSelectionsProvider);
        expect(selectionsBeforeComplete['selectedThemeFamily'], equals('Cyan'));
        expect(selectionsBeforeComplete['backupEnabled'], isTrue);
        
        // Complete onboarding
        await container.read(onboardingProvider.notifier).complete();
        expect(container.read(onboardingCompletedProvider), isTrue);
      });

      test('should maintain consistency between providers', () async {
        await container.read(onboardingProvider.notifier).initialize();
        
        // Make multiple selections
        await container.read(onboardingProvider.notifier).selectTheme('Light Blue');
        await container.read(onboardingProvider.notifier).configureBackupOption(false);
        
        // Verify consistency across providers
        final selectedTheme = container.read(onboardingSelectedThemeProvider);
        final backupEnabled = container.read(onboardingBackupEnabledProvider);
        final userSelections = container.read(onboardingUserSelectionsProvider);
        
        expect(selectedTheme, equals('Light Blue'));
        expect(selectedTheme, equals(userSelections['selectedThemeFamily']));
        
        expect(backupEnabled, isFalse);
        expect(backupEnabled, equals(userSelections['backupEnabled']));
      });
    });

    group('Edge Cases', () {
      test('should handle rapid state changes', () async {
        await container.read(onboardingProvider.notifier).initialize();
        
        // Make rapid changes
        await container.read(onboardingProvider.notifier).selectTheme('Green');
        await container.read(onboardingProvider.notifier).selectTheme('Pink');
        await container.read(onboardingProvider.notifier).selectTheme('Cyan');
        
        // Should have final state
        expect(container.read(onboardingSelectedThemeProvider), equals('Cyan'));
      });

      test('should handle operations on different states', () async {
        // Try to select theme before initialization (should handle gracefully)
        await container.read(onboardingProvider.notifier).selectTheme('Green');
        
        // State might remain initial or handle gracefully
        final state = container.read(onboardingProvider);
        // The exact behavior depends on implementation, but it shouldn't crash
        expect(state, isNotNull);
      });
    });
  });
}