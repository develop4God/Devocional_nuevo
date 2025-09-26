import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devocional_nuevo/providers/onboarding/onboarding_notifier.dart';
import 'package:devocional_nuevo/providers/onboarding/onboarding_state.dart';
import 'package:devocional_nuevo/providers/theme/theme_providers.dart';
import 'package:devocional_nuevo/services/onboarding_service.dart';

class MockOnboardingService extends Mock implements OnboardingService {}

void main() {
  group('OnboardingNotifier Unit Tests', () {
    late MockOnboardingService mockOnboardingService;
    late ProviderContainer container;

    setUp(() {
      mockOnboardingService = MockOnboardingService();
      SharedPreferences.setMockInitialValues({});
      
      container = ProviderContainer(
        overrides: [
          // Override the onboarding service dependency
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with initial state', () {
      final notifier = OnboardingNotifier(
        onboardingService: mockOnboardingService,
        ref: container,
      );

      expect(notifier.state, isA<OnboardingInitialState>());
    });

    test('should transition to loading state during initialization', () async {
      when(() => mockOnboardingService.isOnboardingComplete())
          .thenAnswer((_) async => false);

      final notifier = OnboardingNotifier(
        onboardingService: mockOnboardingService,
        ref: container,
      );

      final states = <OnboardingRiverpodState>[];
      final subscription = notifier.stream.listen(states.add);

      await notifier.initialize();

      // Should have transitioned through loading state
      expect(states.any((state) => state is OnboardingLoadingState), isTrue);

      subscription.cancel();
    });

    test('should handle completed onboarding', () async {
      when(() => mockOnboardingService.isOnboardingComplete())
          .thenAnswer((_) async => true);

      final notifier = OnboardingNotifier(
        onboardingService: mockOnboardingService,
        ref: container,
      );

      await notifier.initialize();

      expect(notifier.state, isA<OnboardingCompletedState>());
    });

    test('should load saved configuration during initialization', () async {
      // Set up SharedPreferences with saved data
      SharedPreferences.setMockInitialValues({
        'onboarding_configuration': '{"selectedThemeFamily": "Green"}',
        'onboarding_progress': 2,
      });

      when(() => mockOnboardingService.isOnboardingComplete())
          .thenAnswer((_) async => false);

      final notifier = OnboardingNotifier(
        onboardingService: mockOnboardingService,
        ref: container,
      );

      await notifier.initialize();

      expect(notifier.state, isA<OnboardingStepActiveState>());
      final activeState = notifier.state as OnboardingStepActiveState;
      expect(activeState.userSelections['selectedThemeFamily'], equals('Green'));
      expect(activeState.currentStepIndex, equals(1)); // Should be step 1 (2-1)
    });

    test('should handle theme selection', () async {
      when(() => mockOnboardingService.isOnboardingComplete())
          .thenAnswer((_) async => false);

      final notifier = OnboardingNotifier(
        onboardingService: mockOnboardingService,
        ref: container,
      );

      // Initialize first
      await notifier.initialize();
      
      final initialState = notifier.state as OnboardingStepActiveState;

      // Select theme
      await notifier.selectTheme('Cyan');

      expect(notifier.state, isA<OnboardingStepActiveState>());
      final updatedState = notifier.state as OnboardingStepActiveState;
      expect(updatedState.userSelections['selectedThemeFamily'], equals('Cyan'));
    });

    test('should handle backup configuration', () async {
      when(() => mockOnboardingService.isOnboardingComplete())
          .thenAnswer((_) async => false);

      final notifier = OnboardingNotifier(
        onboardingService: mockOnboardingService,
        ref: container,
      );

      // Initialize first
      await notifier.initialize();

      // Configure backup
      await notifier.configureBackupOption(true);

      expect(notifier.state, isA<OnboardingStepActiveState>());
      final updatedState = notifier.state as OnboardingStepActiveState;
      expect(updatedState.userSelections['backupEnabled'], equals(true));
    });

    test('should handle step progression', () async {
      when(() => mockOnboardingService.isOnboardingComplete())
          .thenAnswer((_) async => false);

      final notifier = OnboardingNotifier(
        onboardingService: mockOnboardingService,
        ref: container,
      );

      await notifier.initialize();
      
      final initialState = notifier.state as OnboardingStepActiveState;
      expect(initialState.currentStepIndex, equals(0));

      await notifier.progressToStep(2);

      final updatedState = notifier.state as OnboardingStepActiveState;
      expect(updatedState.currentStepIndex, equals(2));
    });

    test('should complete onboarding successfully', () async {
      when(() => mockOnboardingService.isOnboardingComplete())
          .thenAnswer((_) async => false);
      when(() => mockOnboardingService.setOnboardingComplete())
          .thenAnswer((_) async => {});

      final notifier = OnboardingNotifier(
        onboardingService: mockOnboardingService,
        ref: container,
      );

      await notifier.initialize();
      await notifier.complete();

      expect(notifier.state, isA<OnboardingCompletedState>());
      verify(() => mockOnboardingService.setOnboardingComplete()).called(1);
    });

    test('should handle go back functionality', () async {
      when(() => mockOnboardingService.isOnboardingComplete())
          .thenAnswer((_) async => false);

      final notifier = OnboardingNotifier(
        onboardingService: mockOnboardingService,
        ref: container,
      );

      await notifier.initialize();
      await notifier.progressToStep(2);

      final beforeGoBack = notifier.state as OnboardingStepActiveState;
      expect(beforeGoBack.currentStepIndex, equals(2));

      await notifier.goBack();

      final afterGoBack = notifier.state as OnboardingStepActiveState;
      expect(afterGoBack.currentStepIndex, equals(1));
    });

    test('should prevent going back from step 0', () async {
      when(() => mockOnboardingService.isOnboardingComplete())
          .thenAnswer((_) async => false);

      final notifier = OnboardingNotifier(
        onboardingService: mockOnboardingService,
        ref: container,
      );

      await notifier.initialize();
      
      final beforeGoBack = notifier.state as OnboardingStepActiveState;
      expect(beforeGoBack.currentStepIndex, equals(0));
      expect(beforeGoBack.canGoBack, isFalse);

      await notifier.goBack();

      // Should still be at step 0
      final afterGoBack = notifier.state as OnboardingStepActiveState;
      expect(afterGoBack.currentStepIndex, equals(0));
    });

    test('should handle skip functionality', () async {
      when(() => mockOnboardingService.isOnboardingComplete())
          .thenAnswer((_) async => false);

      final notifier = OnboardingNotifier(
        onboardingService: mockOnboardingService,
        ref: container,
      );

      await notifier.initialize();
      
      final beforeSkip = notifier.state as OnboardingStepActiveState;
      expect(beforeSkip.currentStepIndex, equals(0));

      await notifier.skipCurrentStep();

      final afterSkip = notifier.state as OnboardingStepActiveState;
      expect(afterSkip.currentStepIndex, equals(1));
    });

    test('should handle errors gracefully', () async {
      when(() => mockOnboardingService.isOnboardingComplete())
          .thenThrow(Exception('Service unavailable'));

      final notifier = OnboardingNotifier(
        onboardingService: mockOnboardingService,
        ref: container,
      );

      await notifier.initialize();

      expect(notifier.state, isA<OnboardingErrorState>());
      final errorState = notifier.state as OnboardingErrorState;
      expect(errorState.message, contains('Service unavailable'));
    });

    test('should persist configuration to SharedPreferences', () async {
      when(() => mockOnboardingService.isOnboardingComplete())
          .thenAnswer((_) async => false);

      final notifier = OnboardingNotifier(
        onboardingService: mockOnboardingService,
        ref: container,
      );

      await notifier.initialize();
      await notifier.selectTheme('Pink');

      final prefs = await SharedPreferences.getInstance();
      final savedConfig = prefs.getString('onboarding_configuration');
      expect(savedConfig, isNotNull);
      expect(savedConfig, contains('Pink'));
    });

    test('should track progress correctly', () async {
      when(() => mockOnboardingService.isOnboardingComplete())
          .thenAnswer((_) async => false);

      final notifier = OnboardingNotifier(
        onboardingService: mockOnboardingService,
        ref: container,
      );

      await notifier.initialize();
      
      var activeState = notifier.state as OnboardingStepActiveState;
      expect(activeState.progress.completedSteps, equals(0));

      await notifier.selectTheme('Green');
      
      activeState = notifier.state as OnboardingStepActiveState;
      expect(activeState.progress.completedSteps, equals(1));
      expect(activeState.progress.progressPercentage, greaterThan(0));

      await notifier.configureBackupOption(true);
      
      activeState = notifier.state as OnboardingStepActiveState;
      expect(activeState.progress.completedSteps, equals(2));
      expect(activeState.progress.progressPercentage, greaterThan(25));
    });

    group('Step Validation Tests', () {
      test('should require theme selection to progress from step 1', () async {
        when(() => mockOnboardingService.isOnboardingComplete())
            .thenAnswer((_) async => false);

        final notifier = OnboardingNotifier(
          onboardingService: mockOnboardingService,
          ref: container,
        );

        await notifier.initialize();
        await notifier.progressToStep(1); // Go to theme selection step

        var activeState = notifier.state as OnboardingStepActiveState;
        expect(activeState.canProgress, isFalse); // No theme selected yet

        await notifier.selectTheme('Green');

        activeState = notifier.state as OnboardingStepActiveState;
        expect(activeState.canProgress, isTrue); // Theme selected, can progress
      });

      test('should require backup configuration to progress from step 2', () async {
        when(() => mockOnboardingService.isOnboardingComplete())
            .thenAnswer((_) async => false);

        final notifier = OnboardingNotifier(
          onboardingService: mockOnboardingService,
          ref: container,
        );

        await notifier.initialize();
        await notifier.progressToStep(2); // Go to backup configuration step

        var activeState = notifier.state as OnboardingStepActiveState;
        expect(activeState.canProgress, isFalse); // No backup config yet

        await notifier.configureBackupOption(false);

        activeState = notifier.state as OnboardingStepActiveState;
        expect(activeState.canProgress, isTrue); // Backup configured, can progress
      });
    });
  });
}