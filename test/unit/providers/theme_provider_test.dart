import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:devocional_nuevo/providers/theme/theme_providers.dart';
import 'package:devocional_nuevo/providers/theme/theme_repository.dart';
import 'package:devocional_nuevo/providers/theme/theme_state.dart';
import 'package:devocional_nuevo/utils/theme_constants.dart';

// Mock classes for testing
class MockThemeRepository extends Mock implements ThemeRepository {}

void main() {
  group('Theme Riverpod Provider Tests', () {
    late MockThemeRepository mockRepo;
    late ProviderContainer container;

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue('');
      registerFallbackValue(Brightness.light);
    });

    setUp(() {
      mockRepo = MockThemeRepository();

      // Create container with overridden repository
      container = ProviderContainer(
        overrides: [
          themeRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial Theme Loading', () {
      test('should load default theme when no saved preferences', () async {
        // Arrange - mock empty preferences
        when(() => mockRepo.getThemePreferences()).thenAnswer(
            (_) async => (themeFamily: 'Deep Purple', brightness: 'light'));

        // Act - let the StateNotifier initialize
        await pumpEventQueue(); // Allow async operations to complete

        // Assert - should be loaded state with defaults
        final state = container.read(themeProvider);
        expect(state, isA<ThemeStateLoaded>());

        final loadedState = state as ThemeStateLoaded;
        expect(loadedState.themeFamily, equals('Deep Purple'));
        expect(loadedState.brightness, equals(Brightness.light));
        expect(loadedState.themeData,
            equals(appThemeFamilies['Deep Purple']!['light']!));
      });

      test('should load saved theme preferences correctly', () async {
        // Arrange - mock saved preferences
        when(() => mockRepo.getThemePreferences()).thenAnswer(
            (_) async => (themeFamily: 'Green', brightness: 'dark'));

        // Act
        await pumpEventQueue();

        // Assert
        final state = container.read(themeProvider) as ThemeStateLoaded;
        expect(state.themeFamily, equals('Green'));
        expect(state.brightness, equals(Brightness.dark));
        expect(state.themeData, equals(appThemeFamilies['Green']!['dark']!));
      });

      test('should fallback to default when invalid theme family is saved',
          () async {
        // Arrange - repository returns invalid theme but handles it internally
        when(() => mockRepo.getThemePreferences()).thenAnswer((_) async => (
              themeFamily:
                  'Deep Purple', // Repository should handle invalid themes internally
              brightness: 'light'
            ));

        // Act
        await pumpEventQueue();

        // Assert - should use default
        final state = container.read(themeProvider) as ThemeStateLoaded;
        expect(state.themeFamily, equals('Deep Purple'));
        expect(state.brightness, equals(Brightness.light));
      });
    });

    group('Theme Family Changes', () {
      test('should update theme family and persist to storage', () async {
        // Arrange - mock successful operations
        when(() => mockRepo.getThemePreferences()).thenAnswer(
            (_) async => (themeFamily: 'Deep Purple', brightness: 'light'));
        when(() => mockRepo.setThemeFamily(any())).thenAnswer((_) async => {});

        await pumpEventQueue(); // Wait for initial load

        // Act - change theme family
        await container.read(themeProvider.notifier).setThemeFamily('Pink');

        // Assert - state should be updated
        final state = container.read(themeProvider) as ThemeStateLoaded;
        expect(state.themeFamily, equals('Pink'));
        expect(state.brightness,
            equals(Brightness.light)); // Should preserve brightness
        expect(state.themeData, equals(appThemeFamilies['Pink']!['light']!));

        // Verify persistence call
        verify(() => mockRepo.setThemeFamily('Pink')).called(1);
      });

      test('should not change theme when setting same family', () async {
        // Arrange
        when(() => mockRepo.getThemePreferences()).thenAnswer(
            (_) async => (themeFamily: 'Cyan', brightness: 'light'));

        await pumpEventQueue();
        reset(mockRepo); // Reset to clear setup calls

        // Act - set same theme
        await container.read(themeProvider.notifier).setThemeFamily('Cyan');

        // Assert - no persistence call should be made
        verifyNever(() => mockRepo.setThemeFamily(any()));
      });

      test('should ignore invalid theme family changes', () async {
        // Arrange
        when(() => mockRepo.getThemePreferences()).thenAnswer(
            (_) async => (themeFamily: 'Green', brightness: 'light'));

        await pumpEventQueue();
        final initialState = container.read(themeProvider) as ThemeStateLoaded;

        // Act - try to set invalid theme
        await container
            .read(themeProvider.notifier)
            .setThemeFamily('InvalidTheme');

        // Assert - state should not change
        final finalState = container.read(themeProvider) as ThemeStateLoaded;
        expect(finalState.themeFamily, equals(initialState.themeFamily));
        expect(finalState.brightness, equals(initialState.brightness));
      });
    });

    group('Brightness Changes', () {
      test('should update brightness and persist to storage', () async {
        // Arrange
        when(() => mockRepo.getThemePreferences()).thenAnswer(
            (_) async => (themeFamily: 'Light Blue', brightness: 'light'));
        when(() => mockRepo.setBrightness(any())).thenAnswer((_) async => {});

        await pumpEventQueue();

        // Act - change brightness
        await container
            .read(themeProvider.notifier)
            .setBrightness(Brightness.dark);

        // Assert - state should be updated
        final state = container.read(themeProvider) as ThemeStateLoaded;
        expect(state.themeFamily,
            equals('Light Blue')); // Should preserve theme family
        expect(state.brightness, equals(Brightness.dark));
        expect(
            state.themeData, equals(appThemeFamilies['Light Blue']!['dark']!));

        // Verify persistence call
        verify(() => mockRepo.setBrightness('dark')).called(1);
      });

      test('should not change brightness when setting same value', () async {
        // Arrange
        when(() => mockRepo.getThemePreferences())
            .thenAnswer((_) async => (themeFamily: 'Pink', brightness: 'dark'));

        await pumpEventQueue();
        reset(mockRepo); // Clear setup calls

        // Act - set same brightness
        await container
            .read(themeProvider.notifier)
            .setBrightness(Brightness.dark);

        // Assert - no persistence call should be made
        verifyNever(() => mockRepo.setBrightness(any()));
      });
    });

    group('Convenience Providers', () {
      test('currentThemeFamilyProvider should return correct value', () async {
        // Arrange
        when(() => mockRepo.getThemePreferences()).thenAnswer(
            (_) async => (themeFamily: 'Cyan', brightness: 'light'));

        // Act
        await pumpEventQueue();

        // Assert
        expect(container.read(currentThemeFamilyProvider), equals('Cyan'));
      });

      test('currentBrightnessProvider should return correct value', () async {
        // Arrange
        when(() => mockRepo.getThemePreferences()).thenAnswer(
            (_) async => (themeFamily: 'Green', brightness: 'dark'));

        // Act
        await pumpEventQueue();

        // Assert
        expect(
            container.read(currentBrightnessProvider), equals(Brightness.dark));
      });

      test('currentThemeDataProvider should return correct ThemeData',
          () async {
        // Arrange
        when(() => mockRepo.getThemePreferences()).thenAnswer(
            (_) async => (themeFamily: 'Pink', brightness: 'light'));

        // Act
        await pumpEventQueue();

        // Assert
        expect(
          container.read(currentThemeDataProvider),
          equals(appThemeFamilies['Pink']!['light']!),
        );
      });

      test('dividerAdaptiveColorProvider should return correct color',
          () async {
        // Test light mode
        when(() => mockRepo.getThemePreferences()).thenAnswer(
            (_) async => (themeFamily: 'Green', brightness: 'light'));

        await pumpEventQueue();
        expect(
            container.read(dividerAdaptiveColorProvider), equals(Colors.black));

        // Reset and test dark mode
        container.invalidate(themeProvider);
        when(() => mockRepo.getThemePreferences()).thenAnswer(
            (_) async => (themeFamily: 'Green', brightness: 'dark'));
        await pumpEventQueue();
        expect(
            container.read(dividerAdaptiveColorProvider), equals(Colors.white));
      });

      test('themeLoadingProvider should indicate loading state correctly',
          () async {
        // Initially loading
        expect(container.read(themeLoadingProvider), isTrue);

        // Mock async operation
        when(() => mockRepo.getThemePreferences()).thenAnswer(
            (_) async => (themeFamily: 'Deep Purple', brightness: 'light'));

        // After loading completes
        await pumpEventQueue();
        expect(container.read(themeLoadingProvider), isFalse);
      });
    });

    group('Error Handling', () {
      test('should handle repository exceptions gracefully', () async {
        // Arrange - mock repository to throw
        when(() => mockRepo.getThemePreferences())
            .thenThrow(Exception('Storage error'));

        // Act & Assert - should not throw, should fallback to defaults
        await pumpEventQueue();

        final state = container.read(themeProvider) as ThemeStateLoaded;
        expect(state.themeFamily, equals('Deep Purple'));
        expect(state.brightness, equals(Brightness.light));
      });

      test('should handle setThemeFamily storage failures gracefully',
          () async {
        // Arrange
        when(() => mockRepo.getThemePreferences()).thenAnswer(
            (_) async => (themeFamily: 'Green', brightness: 'light'));
        when(() => mockRepo.setThemeFamily(any()))
            .thenThrow(Exception('Write failed'));

        await pumpEventQueue();
        final initialState = container.read(themeProvider) as ThemeStateLoaded;

        // Act - try to change theme (should not throw)
        await container.read(themeProvider.notifier).setThemeFamily('Pink');

        // Assert - state should remain unchanged due to error
        final finalState = container.read(themeProvider) as ThemeStateLoaded;
        expect(finalState.themeFamily, equals(initialState.themeFamily));
      });
    });

    group('Behavioral Integration Tests', () {
      test('theme changes should be immediately reflected in all providers',
          () async {
        // Arrange
        when(() => mockRepo.getThemePreferences()).thenAnswer(
            (_) async => (themeFamily: 'Deep Purple', brightness: 'light'));
        when(() => mockRepo.setThemeFamily(any())).thenAnswer((_) async => {});
        when(() => mockRepo.setBrightness(any())).thenAnswer((_) async => {});

        await pumpEventQueue();

        // Act - change both family and brightness
        await container.read(themeProvider.notifier).setThemeFamily('Cyan');
        await container
            .read(themeProvider.notifier)
            .setBrightness(Brightness.dark);

        // Assert - all providers should reflect the changes
        expect(container.read(currentThemeFamilyProvider), equals('Cyan'));
        expect(
            container.read(currentBrightnessProvider), equals(Brightness.dark));
        expect(
          container.read(currentThemeDataProvider),
          equals(appThemeFamilies['Cyan']!['dark']!),
        );
        expect(
            container.read(dividerAdaptiveColorProvider), equals(Colors.white));
        expect(container.read(themeLoadingProvider), isFalse);
      });

      test('theme persistence should survive app restarts (simulated)',
          () async {
        // Simulate app start with saved preferences
        when(() => mockRepo.getThemePreferences())
            .thenAnswer((_) async => (themeFamily: 'Pink', brightness: 'dark'));

        // First "app session"
        final container1 = ProviderContainer(
          overrides: [
            themeRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );

        await pumpEventQueue();
        final state1 = container1.read(themeProvider) as ThemeStateLoaded;

        expect(state1.themeFamily, equals('Pink'));
        expect(state1.brightness, equals(Brightness.dark));

        container1.dispose();

        // Second "app session" - should load same preferences
        final container2 = ProviderContainer(
          overrides: [
            themeRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );

        await pumpEventQueue();
        final state2 = container2.read(themeProvider) as ThemeStateLoaded;

        expect(state2.themeFamily, equals('Pink'));
        expect(state2.brightness, equals(Brightness.dark));
        expect(state2.themeData, equals(appThemeFamilies['Pink']!['dark']!));

        container2.dispose();
      });
    });

    group('ThemeRepository Integration', () {
      test('repository methods are called with correct parameters', () async {
        // Arrange
        when(() => mockRepo.getThemePreferences()).thenAnswer(
            (_) async => (themeFamily: 'Deep Purple', brightness: 'light'));
        when(() => mockRepo.setThemeFamily(any())).thenAnswer((_) async => {});
        when(() => mockRepo.setBrightness(any())).thenAnswer((_) async => {});

        await pumpEventQueue();

        // Act - perform theme operations
        await container.read(themeProvider.notifier).setThemeFamily('Green');
        await container
            .read(themeProvider.notifier)
            .setBrightness(Brightness.dark);

        // Assert - verify repository interactions
        verify(() => mockRepo.getThemePreferences()).called(greaterThan(0));
        verify(() => mockRepo.setThemeFamily('Green')).called(1);
        verify(() => mockRepo.setBrightness('dark')).called(1);
      });
    });
  });
}
