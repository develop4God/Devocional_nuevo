import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devocional_nuevo/providers/onboarding/onboarding_providers.dart';
import 'package:devocional_nuevo/providers/onboarding/onboarding_state.dart';
import 'package:devocional_nuevo/providers/theme/theme_providers.dart';
import 'package:devocional_nuevo/utils/theme_constants.dart';

/// Integration test to validate the Riverpod onboarding system works end-to-end
void main() {
  group('Onboarding Riverpod Integration Test', () {
    testWidgets('should initialize and display onboarding correctly', (WidgetTester tester) async {
      // Create a test app with Riverpod onboarding providers
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final onboardingState = ref.watch(onboardingProvider);
                final currentStep = ref.watch(currentOnboardingStepProvider);
                final isLoading = ref.watch(onboardingLoadingProvider);
                
                return Scaffold(
                  appBar: AppBar(title: const Text('Onboarding Test')),
                  body: Column(
                    children: [
                      Text('Onboarding State: ${onboardingState.runtimeType}'),
                      Text('Current Step: $currentStep'),
                      Text('Is Loading: $isLoading'),
                      if (onboardingState is OnboardingStepActiveState) ...[
                        Text('Step Title: ${onboardingState.currentStep.title}'),
                        Text('Can Progress: ${onboardingState.canProgress}'),
                        Text('Can Go Back: ${onboardingState.canGoBack}'),
                      ],
                      ElevatedButton(
                        onPressed: () {
                          ref.read(onboardingProvider.notifier).initialize();
                        },
                        child: const Text('Initialize'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(onboardingProvider.notifier).selectTheme('Green');
                        },
                        child: const Text('Select Green Theme'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(onboardingProvider.notifier).progressToStep(2);
                        },
                        child: const Text('Progress to Step 2'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(onboardingProvider.notifier).complete();
                        },
                        child: const Text('Complete'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Allow async operations to complete
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Is Loading: true'), findsOneWidget);

      // Initialize onboarding
      await tester.tap(find.text('Initialize'));
      await tester.pumpAndSettle();
      
      // Should show step active state
      expect(find.textContaining('Onboarding State: OnboardingStepActiveState'), findsOneWidget);
      expect(find.text('Current Step: 0'), findsOneWidget);
      expect(find.text('Is Loading: false'), findsOneWidget);

      // Test theme selection
      await tester.tap(find.text('Select Green Theme'));
      await tester.pumpAndSettle();
      
      // Should update user selections
      expect(find.textContaining('Onboarding State: OnboardingStepActiveState'), findsOneWidget);

      // Test step progression
      await tester.tap(find.text('Progress to Step 2'));
      await tester.pumpAndSettle();
      
      expect(find.text('Current Step: 2'), findsOneWidget);
    });

    testWidgets('should handle theme selection and update providers', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final selectedTheme = ref.watch(onboardingSelectedThemeProvider);
                final currentThemeFamily = ref.watch(currentThemeFamilyProvider);
                
                return Scaffold(
                  body: Column(
                    children: [
                      Text('Selected Theme: ${selectedTheme ?? "None"}'),
                      Text('Current Theme: $currentThemeFamily'),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(onboardingProvider.notifier).initialize();
                        },
                        child: const Text('Initialize'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(onboardingProvider.notifier).selectTheme('Pink');
                        },
                        child: const Text('Select Pink'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initialize onboarding
      await tester.tap(find.text('Initialize'));
      await tester.pumpAndSettle();

      // Select theme
      await tester.tap(find.text('Select Pink'));
      await tester.pumpAndSettle();

      // Verify theme selection is reflected in providers
      expect(find.text('Selected Theme: Pink'), findsOneWidget);
      expect(find.text('Current Theme: Pink'), findsOneWidget);
    });

    testWidgets('should provide correct convenience provider values', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final userSelections = ref.watch(onboardingUserSelectionsProvider);
                final isCompleted = ref.watch(onboardingCompletedProvider);
                final hasError = ref.watch(onboardingHasErrorProvider);
                final backupEnabled = ref.watch(onboardingBackupEnabledProvider);
                
                return Scaffold(
                  body: Column(
                    children: [
                      Text('User Selections: ${userSelections.length} items'),
                      Text('Is Completed: $isCompleted'),
                      Text('Has Error: $hasError'),
                      Text('Backup Enabled: $backupEnabled'),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(onboardingProvider.notifier).initialize();
                        },
                        child: const Text('Initialize'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(onboardingProvider.notifier).configureBackupOption(true);
                        },
                        child: const Text('Enable Backup'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial convenience provider values
      expect(find.textContaining('User Selections: 0 items'), findsOneWidget);
      expect(find.text('Is Completed: false'), findsOneWidget);
      expect(find.text('Has Error: false'), findsOneWidget);
      expect(find.text('Backup Enabled: false'), findsOneWidget);

      // Initialize onboarding
      await tester.tap(find.text('Initialize'));
      await tester.pumpAndSettle();

      // Configure backup
      await tester.tap(find.text('Enable Backup'));
      await tester.pumpAndSettle();

      // Verify backup selection is reflected
      expect(find.text('Backup Enabled: true'), findsOneWidget);
      expect(find.textContaining('User Selections: 1 items'), findsOneWidget);
    });

    test('should have required theme families available', () {
      final expectedThemes = ['Deep Purple', 'Green', 'Pink', 'Cyan', 'Light Blue'];
      
      for (final theme in expectedThemes) {
        expect(appThemeFamilies.containsKey(theme), isTrue, 
               reason: 'Theme family $theme should exist');
        expect(appThemeFamilies[theme]!.containsKey('light'), isTrue,
               reason: 'Light variant for $theme should exist');
        expect(appThemeFamilies[theme]!.containsKey('dark'), isTrue,
               reason: 'Dark variant for $theme should exist');
      }
      
      expect(themeDisplayNames.keys.length, equals(expectedThemes.length),
             reason: 'Display names should match theme families');
    });
  });
}