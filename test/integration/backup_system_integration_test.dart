// test/integration/backup_system_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:devocional_nuevo/providers/backup/backup_providers.dart';
import 'package:devocional_nuevo/providers/backup/backup_state.dart';
import 'package:devocional_nuevo/providers/backup/backup_repository.dart';
import 'package:devocional_nuevo/services/google_drive_backup_service.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';

// Mock classes for integration testing
class MockBackupRepository extends Mock implements BackupRepository {}
class MockGoogleDriveBackupService extends Mock implements GoogleDriveBackupService {}
class MockDevocionalProvider extends Mock implements DevocionalProvider {}

void main() {
  group('Backup System Integration Tests', () {
    late MockBackupRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockBackupRepository();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should load backup settings and display correctly', (WidgetTester tester) async {
      // Setup successful repository response
      when(() => mockRepository.loadBackupSettings()).thenAnswer((_) async => (
        autoBackupEnabled: true,
        backupFrequency: 'daily',
        wifiOnlyEnabled: false,
        compressionEnabled: true,
        backupOptions: {
          'devotionals': true,
          'prayers': false,
          'settings': true,
          'favorites': true,
        },
        lastBackupTime: DateTime(2024, 1, 15, 10, 30),
        nextBackupTime: DateTime(2024, 1, 16, 10, 30),
        estimatedSize: 1024 * 1024, // 1MB
        storageInfo: <String, dynamic>{
          'totalSpace': 15 * 1024 * 1024 * 1024, // 15GB
          'usedSpace': 5 * 1024 * 1024 * 1024,   // 5GB
        },
        isAuthenticated: true,
        userEmail: 'test@example.com',
      ));

      // Create container with mocked repository
      container = ProviderContainer(
        overrides: [
          backupRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Read the backup provider to trigger loading
      container.read(backupProvider);

      // Wait for async loading
      await tester.binding.delayed(const Duration(milliseconds: 200));

      // Verify the state is loaded
      final backupState = container.read(backupProvider);
      expect(backupState, isA<BackupRiverpodStateLoaded>());

      final loadedState = backupState as BackupRiverpodStateLoaded;
      expect(loadedState.autoBackupEnabled, true);
      expect(loadedState.backupFrequency, 'daily');
      expect(loadedState.wifiOnlyEnabled, false);
      expect(loadedState.compressionEnabled, true);
      expect(loadedState.isAuthenticated, true);
      expect(loadedState.userEmail, 'test@example.com');

      // Verify convenience providers return correct values
      expect(container.read(autoBackupEnabledProvider), true);
      expect(container.read(backupFrequencyProvider), 'daily');
      expect(container.read(wifiOnlyEnabledProvider), false);
      expect(container.read(compressionEnabledProvider), true);
      expect(container.read(isAuthenticatedProvider), true);
      expect(container.read(userEmailProvider), 'test@example.com');
    });

    testWidgets('should handle backup settings changes', (WidgetTester tester) async {
      // Setup initial loaded state
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

      // Setup save methods
      when(() => mockRepository.saveAutoBackupEnabled(any())).thenAnswer((_) async {});
      when(() => mockRepository.saveBackupFrequency(any())).thenAnswer((_) async {});
      when(() => mockRepository.saveWifiOnlyEnabled(any())).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          backupRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Initial load
      container.read(backupProvider);
      await tester.binding.delayed(const Duration(milliseconds: 100));

      // Change auto backup setting
      await container.read(backupProvider.notifier).toggleAutoBackup(true);
      expect(container.read(autoBackupEnabledProvider), true);

      // Change backup frequency
      await container.read(backupProvider.notifier).changeBackupFrequency('daily');
      expect(container.read(backupFrequencyProvider), 'daily');

      // Change WiFi-only setting
      await container.read(backupProvider.notifier).toggleWifiOnly(false);
      expect(container.read(wifiOnlyEnabledProvider), false);

      // Verify repository methods were called
      verify(() => mockRepository.saveAutoBackupEnabled(true)).called(1);
      verify(() => mockRepository.saveBackupFrequency('daily')).called(1);
      verify(() => mockRepository.saveWifiOnlyEnabled(false)).called(1);
    });

    testWidgets('should handle manual backup creation', (WidgetTester tester) async {
      final backupTimestamp = DateTime(2024, 1, 15, 14, 30);

      // Setup initial loaded state
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
        isAuthenticated: true,
        userEmail: 'test@example.com',
      ));

      // Setup successful backup creation
      when(() => mockRepository.createManualBackup())
          .thenAnswer((_) async => backupTimestamp);

      container = ProviderContainer(
        overrides: [
          backupRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Initial load
      container.read(backupProvider);
      await tester.binding.delayed(const Duration(milliseconds: 100));

      // Create manual backup
      container.read(backupProvider.notifier).createManualBackup();

      // Should be in creating state initially
      await tester.binding.delayed(const Duration(milliseconds: 50));
      expect(container.read(backupInProgressProvider), true);

      // Wait for completion
      await tester.binding.delayed(const Duration(milliseconds: 1200));

      // Should transition through created state to success state
      final currentState = container.read(backupProvider);
      expect(currentState, anyOf([
        isA<BackupRiverpodStateCreated>(),
        isA<BackupRiverpodStateSuccess>(),
        isA<BackupRiverpodStateLoaded>(),
      ]));

      // Verify repository was called
      verify(() => mockRepository.createManualBackup()).called(1);
    });

    testWidgets('should handle Google Drive authentication', (WidgetTester tester) async {
      // Setup initial unauthenticated state
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

      // Setup successful sign in
      when(() => mockRepository.signInToGoogleDrive())
          .thenAnswer((_) async => 'user@gmail.com');

      container = ProviderContainer(
        overrides: [
          backupRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Initial load
      container.read(backupProvider);
      await tester.binding.delayed(const Duration(milliseconds: 100));

      // Verify initially unauthenticated
      expect(container.read(isAuthenticatedProvider), false);
      expect(container.read(userEmailProvider), null);

      // Sign in to Google Drive
      container.read(backupProvider.notifier).signInToGoogleDrive();

      // Wait for authentication process
      await tester.binding.delayed(const Duration(milliseconds: 2200));

      // Should be authenticated
      expect(container.read(isAuthenticatedProvider), true);
      expect(container.read(userEmailProvider), 'user@gmail.com');

      // Verify repository was called
      verify(() => mockRepository.signInToGoogleDrive()).called(1);
    });

    testWidgets('should handle backup options updates', (WidgetTester tester) async {
      // Setup initial state
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

      // Setup save backup options
      when(() => mockRepository.saveBackupOptions(any())).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          backupRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Initial load
      container.read(backupProvider);
      await tester.binding.delayed(const Duration(milliseconds: 100));

      // Verify initial options
      final initialOptions = container.read(backupOptionsProvider);
      expect(initialOptions['devotionals'], true);
      expect(initialOptions['prayers'], true);

      // Update backup options
      final newOptions = {
        'devotionals': true,
        'prayers': false, // Changed
        'settings': true,
        'favorites': false, // Changed
      };

      await container.read(backupProvider.notifier).updateBackupOptions(newOptions);

      // Verify updated options
      final updatedOptions = container.read(backupOptionsProvider);
      expect(updatedOptions['devotionals'], true);
      expect(updatedOptions['prayers'], false);
      expect(updatedOptions['settings'], true);
      expect(updatedOptions['favorites'], false);

      // Verify repository was called
      verify(() => mockRepository.saveBackupOptions(newOptions)).called(1);
    });

    testWidgets('should handle errors gracefully', (WidgetTester tester) async {
      // Setup repository to throw error on load
      when(() => mockRepository.loadBackupSettings())
          .thenThrow(Exception('Network error'));

      container = ProviderContainer(
        overrides: [
          backupRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Try to load backup settings
      container.read(backupProvider);
      await tester.binding.delayed(const Duration(milliseconds: 100));

      // Should be in error state
      expect(container.read(backupHasErrorProvider), true);
      expect(container.read(backupErrorMessageProvider), contains('Failed to load backup settings'));

      // Convenience providers should return default values
      expect(container.read(autoBackupEnabledProvider), false);
      expect(container.read(backupFrequencyProvider), 'weekly');
      expect(container.read(isAuthenticatedProvider), false);
    });

    testWidgets('should maintain provider consistency across multiple operations', (WidgetTester tester) async {
      // Setup repository with successful responses
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

      when(() => mockRepository.saveAutoBackupEnabled(any())).thenAnswer((_) async {});
      when(() => mockRepository.saveBackupFrequency(any())).thenAnswer((_) async {});
      when(() => mockRepository.saveCompressionEnabled(any())).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          backupRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Initial load
      container.read(backupProvider);
      await tester.binding.delayed(const Duration(milliseconds: 100));

      // Perform multiple rapid operations
      final notifier = container.read(backupProvider.notifier);
      
      await notifier.toggleAutoBackup(true);
      await tester.binding.delayed(const Duration(milliseconds: 600));
      
      await notifier.changeBackupFrequency('daily');
      await tester.binding.delayed(const Duration(milliseconds: 600));
      
      await notifier.toggleCompression(false);
      await tester.binding.delayed(const Duration(milliseconds: 600));

      // All convenience providers should be consistent
      expect(container.read(autoBackupEnabledProvider), true);
      expect(container.read(backupFrequencyProvider), 'daily');
      expect(container.read(compressionEnabledProvider), false);

      // State should be loaded (not error or loading)
      expect(container.read(backupLoadedProvider), true);
      expect(container.read(backupHasErrorProvider), false);
    });
  });
}