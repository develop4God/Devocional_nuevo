// test/unit/providers/backup_providers_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:devocional_nuevo/providers/backup/backup_providers.dart';
import 'package:devocional_nuevo/providers/backup/backup_state.dart';
import 'package:devocional_nuevo/providers/backup/backup_repository.dart';
import 'package:devocional_nuevo/providers/backup/backup_notifier.dart';
import 'package:devocional_nuevo/services/google_drive_backup_service.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';

// Mock classes
class MockBackupRepository extends Mock implements BackupRepository {}

class MockGoogleDriveBackupService extends Mock
    implements GoogleDriveBackupService {}

class MockDevocionalProvider extends Mock implements DevocionalProvider {}

void main() {
  group('Backup Providers Unit Tests', () {
    late MockBackupRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockBackupRepository();

      // Setup default successful repository responses
      when(() => mockRepository.loadBackupSettings()).thenAnswer((_) async => (
            autoBackupEnabled: false,
            backupFrequency: 'weekly',
            wifiOnlyEnabled: true,
            compressionEnabled: true,
            backupOptions: {
              'devotionals': true,
              'prayers': true,
              'settings': true,
              'favorites': true,
            },
            lastBackupTime: null,
            nextBackupTime: null,
            estimatedSize: 512 * 1024,
            storageInfo: <String, dynamic>{},
            isAuthenticated: false,
            userEmail: null,
          ));

      // Create container with mocked repository
      container = ProviderContainer(
        overrides: [
          backupRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Backup Provider', () {
      test('should initialize with loading state (auto-loads on creation)', () {
        final backupState = container.read(backupProvider);
        expect(backupState, const BackupRiverpodState.loading());
      });

      test('should load backup settings on initialization', () async {
        // Read the provider to trigger initialization
        container.read(backupProvider);

        // Wait for async initialization
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify repository was called
        verify(() => mockRepository.loadBackupSettings()).called(1);
      });

      test('should emit loaded state with correct data', () async {
        // Read the provider to trigger initialization
        container.read(backupProvider);

        // Wait for async initialization
        await Future.delayed(const Duration(milliseconds: 100));

        final backupState = container.read(backupProvider);

        expect(backupState, isA<BackupRiverpodStateLoaded>());
        final loadedState = backupState as BackupRiverpodStateLoaded;

        expect(loadedState.autoBackupEnabled, false);
        expect(loadedState.backupFrequency, 'weekly');
        expect(loadedState.wifiOnlyEnabled, true);
        expect(loadedState.compressionEnabled, true);
        expect(loadedState.backupOptions, {
          'devotionals': true,
          'prayers': true,
          'settings': true,
          'favorites': true,
        });
        expect(loadedState.isAuthenticated, false);
      });

      test('should handle repository errors gracefully', () async {
        // Setup repository to throw error
        when(() => mockRepository.loadBackupSettings())
            .thenThrow(Exception('Failed to load'));

        // Read the provider to trigger initialization
        container.read(backupProvider);

        // Wait for async initialization
        await Future.delayed(const Duration(milliseconds: 100));

        final backupState = container.read(backupProvider);

        expect(backupState, isA<BackupRiverpodStateError>());
        final errorState = backupState as BackupRiverpodStateError;
        expect(errorState.message, contains('Failed to load backup settings'));
      });
    });

    group('Convenience Providers - Default Values', () {
      test('should return default values when not loaded', () {
        expect(container.read(autoBackupEnabledProvider), false);
        expect(container.read(backupFrequencyProvider), 'weekly');
        expect(container.read(wifiOnlyEnabledProvider), true);
        expect(container.read(compressionEnabledProvider), true);
        expect(container.read(backupOptionsProvider), {
          'devotionals': true,
          'prayers': true,
          'settings': true,
          'favorites': true,
        });
        expect(container.read(lastBackupTimeProvider), null);
        expect(container.read(nextBackupTimeProvider), null);
        expect(container.read(estimatedBackupSizeProvider), 0);
        expect(container.read(storageInfoProvider), {});
        expect(container.read(isAuthenticatedProvider), false);
        expect(container.read(userEmailProvider), null);
      });

      test('should return correct state flags when not loaded', () {
        // Note: BackupProvider auto-loads on creation, so it will be in loading state initially
        expect(
            container.read(backupLoadingProvider), true); // Loading initially
        expect(container.read(backupLoadedProvider), false);
        expect(container.read(backupInProgressProvider), false);
        expect(container.read(backupHasErrorProvider), false);
        expect(container.read(backupErrorMessageProvider), null);
        expect(container.read(backupLoadedDataProvider), null);
      });
    });

    group('Convenience Providers - Loaded Values', () {
      setUp(() async {
        // Trigger loading and wait for completion
        container.read(backupProvider);
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should return loaded values when available', () {
        expect(container.read(autoBackupEnabledProvider), false);
        expect(container.read(backupFrequencyProvider), 'weekly');
        expect(container.read(wifiOnlyEnabledProvider), true);
        expect(container.read(compressionEnabledProvider), true);
        expect(container.read(backupOptionsProvider), {
          'devotionals': true,
          'prayers': true,
          'settings': true,
          'favorites': true,
        });
        expect(container.read(estimatedBackupSizeProvider), 512 * 1024);
        expect(container.read(isAuthenticatedProvider), false);
      });

      test('should return correct state flags when loaded', () {
        expect(container.read(backupLoadingProvider), false);
        expect(container.read(backupLoadedProvider), true);
        expect(container.read(backupInProgressProvider), false);
        expect(container.read(backupHasErrorProvider), false);
        expect(container.read(backupErrorMessageProvider), null);
        expect(container.read(backupLoadedDataProvider),
            isA<BackupRiverpodStateLoaded>());
      });
    });

    group('Provider Reactivity', () {
      test('should update all convenience providers when state changes',
          () async {
        // Initial load
        container.read(backupProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        // Setup successful toggle response
        when(() => mockRepository.saveAutoBackupEnabled(true))
            .thenAnswer((_) async {});

        // Toggle auto backup
        await container.read(backupProvider.notifier).toggleAutoBackup(true);

        // Verify the convenience provider reflects the change
        expect(container.read(autoBackupEnabledProvider), true);
      });

      test('should handle multiple rapid state changes', () async {
        // Initial load
        container.read(backupProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        // Setup repository responses
        when(() => mockRepository.saveBackupFrequency(any()))
            .thenAnswer((_) async {});

        // Make rapid changes
        final notifier = container.read(backupProvider.notifier);
        await notifier.changeBackupFrequency('daily');
        await notifier.changeBackupFrequency('monthly');
        await notifier.changeBackupFrequency('weekly');

        // Final state should be 'weekly'
        expect(container.read(backupFrequencyProvider), 'weekly');
      });

      test('should handle provider disposal properly', () {
        // Create new temporary container for disposal test
        final tempContainer = ProviderContainer(
          overrides: [
            backupRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        // Read providers
        tempContainer.read(backupProvider);
        tempContainer.read(autoBackupEnabledProvider);
        tempContainer.read(backupFrequencyProvider);

        // Dispose container immediately to avoid async issues
        tempContainer.dispose();

        // No exceptions should be thrown during disposal
        expect(true, true); // Test passes if no exceptions
      });
    });

    group('Error State Handling', () {
      test('should handle toggle auto backup errors', () async {
        // Initial load
        container.read(backupProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        // Setup repository to throw error
        when(() => mockRepository.saveAutoBackupEnabled(any()))
            .thenThrow(Exception('Save failed'));

        // Attempt to toggle auto backup
        await container.read(backupProvider.notifier).toggleAutoBackup(true);

        // Should be in error state
        expect(container.read(backupHasErrorProvider), true);
        expect(container.read(backupErrorMessageProvider),
            contains('Failed to update auto backup setting'));
      });

      test('should handle create backup errors', () async {
        // Initial load
        container.read(backupProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        // Setup repository to throw error
        when(() => mockRepository.createManualBackup())
            .thenThrow(Exception('Backup failed'));

        // Attempt to create backup
        await container.read(backupProvider.notifier).createManualBackup();

        // Should be in error state
        expect(container.read(backupHasErrorProvider), true);
        expect(container.read(backupErrorMessageProvider),
            contains('Failed to create backup'));
      });
    });

    group('Authentication Flow', () {
      test('should handle sign in to Google Drive', () async {
        // Initial load
        container.read(backupProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        // Setup successful sign in
        when(() => mockRepository.signInToGoogleDrive())
            .thenAnswer((_) async => 'user@example.com');

        // Sign in
        await container.read(backupProvider.notifier).signInToGoogleDrive();

        // Wait for state updates
        await Future.delayed(const Duration(milliseconds: 100));

        // Should be authenticated
        expect(container.read(isAuthenticatedProvider), true);
        expect(container.read(userEmailProvider), 'user@example.com');
      });

      test('should handle sign out from Google Drive', () async {
        // Setup initial authenticated state
        when(() => mockRepository.loadBackupSettings())
            .thenAnswer((_) async => (
                  autoBackupEnabled: false,
                  backupFrequency: 'weekly',
                  wifiOnlyEnabled: true,
                  compressionEnabled: true,
                  backupOptions: {
                    'devotionals': true,
                    'prayers': true,
                    'settings': true,
                    'favorites': true,
                  },
                  lastBackupTime: null,
                  nextBackupTime: null,
                  estimatedSize: 512 * 1024,
                  storageInfo: <String, dynamic>{},
                  isAuthenticated: true,
                  userEmail: 'user@example.com',
                ));

        // Initial load
        container.read(backupProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        // Setup successful sign out
        when(() => mockRepository.signOutFromGoogleDrive())
            .thenAnswer((_) async {});

        // Sign out
        await container.read(backupProvider.notifier).signOutFromGoogleDrive();

        // Wait for state updates
        await Future.delayed(const Duration(milliseconds: 100));

        // Should not be authenticated
        expect(container.read(isAuthenticatedProvider), false);
        expect(container.read(userEmailProvider), null);
      });
    });
  });
}
