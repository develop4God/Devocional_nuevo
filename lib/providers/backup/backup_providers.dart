// lib/providers/backup/backup_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devocional_nuevo/services/google_drive_backup_service.dart';
import 'package:devocional_nuevo/services/backup_scheduler_service.dart';
import 'package:devocional_nuevo/services/google_drive_auth_service.dart';
import 'package:devocional_nuevo/services/connectivity_service.dart';
import 'package:devocional_nuevo/services/spiritual_stats_service.dart';
import '../app_providers.dart';
import 'backup_state.dart';
import 'backup_repository.dart';
import 'backup_notifier.dart';

/// Provider for BackupRepository with all required dependencies
final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final devocionalProviderInstance = ref.read(devocionalProvider);
  
  final backupService = GoogleDriveBackupService(
    authService: GoogleDriveAuthService(),
    connectivityService: ConnectivityService(),
    statsService: SpiritualStatsService(),
  );

  return BackupRepository(
    backupService: backupService,
    schedulerService: null, // Can be null as handled in repository
    devocionalProvider: devocionalProviderInstance,
  );
});

/// Main provider for backup state management
/// Replaces BackupBloc with modern Riverpod StateNotifier pattern
final backupProvider = StateNotifierProvider<BackupNotifier, BackupRiverpodState>((ref) {
  final repository = ref.watch(backupRepositoryProvider);
  return BackupNotifier(repository);
});

/// Convenience provider for auto backup enabled status
/// Fallback to false if not loaded
final autoBackupEnabledProvider = Provider<bool>((ref) {
  final state = ref.watch(backupProvider);
  return state.mapOrNull(
    loaded: (loaded) => loaded.autoBackupEnabled,
  ) ?? false;
});

/// Convenience provider for backup frequency
/// Fallback to 'weekly' if not loaded
final backupFrequencyProvider = Provider<String>((ref) {
  final state = ref.watch(backupProvider);
  return state.mapOrNull(
    loaded: (loaded) => loaded.backupFrequency,
  ) ?? 'weekly';
});

/// Convenience provider for WiFi-only setting
/// Fallback to true if not loaded
final wifiOnlyEnabledProvider = Provider<bool>((ref) {
  final state = ref.watch(backupProvider);
  return state.mapOrNull(
    loaded: (loaded) => loaded.wifiOnlyEnabled,
  ) ?? true;
});

/// Convenience provider for compression enabled status
/// Fallback to true if not loaded
final compressionEnabledProvider = Provider<bool>((ref) {
  final state = ref.watch(backupProvider);
  return state.mapOrNull(
    loaded: (loaded) => loaded.compressionEnabled,
  ) ?? true;
});

/// Convenience provider for backup options (what to include)
/// Fallback to default options if not loaded
final backupOptionsProvider = Provider<Map<String, bool>>((ref) {
  final state = ref.watch(backupProvider);
  return state.mapOrNull(
    loaded: (loaded) => loaded.backupOptions,
  ) ?? {
    'devotionals': true,
    'prayers': true,
    'settings': true,
    'favorites': true,
  };
});

/// Convenience provider for last backup time
/// Returns null if not available
final lastBackupTimeProvider = Provider<DateTime?>((ref) {
  final state = ref.watch(backupProvider);
  return state.mapOrNull(
    loaded: (loaded) => loaded.lastBackupTime,
  );
});

/// Convenience provider for next backup time
/// Returns null if not available
final nextBackupTimeProvider = Provider<DateTime?>((ref) {
  final state = ref.watch(backupProvider);
  return state.mapOrNull(
    loaded: (loaded) => loaded.nextBackupTime,
  );
});

/// Convenience provider for estimated backup size
/// Fallback to 0 if not loaded
final estimatedBackupSizeProvider = Provider<int>((ref) {
  final state = ref.watch(backupProvider);
  return state.mapOrNull(
    loaded: (loaded) => loaded.estimatedSize,
  ) ?? 0;
});

/// Convenience provider for storage information
/// Fallback to empty map if not loaded
final storageInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(backupProvider);
  return state.mapOrNull(
    loaded: (loaded) => loaded.storageInfo,
  ) ?? {};
});

/// Convenience provider for authentication status
/// Fallback to false if not loaded
final isAuthenticatedProvider = Provider<bool>((ref) {
  final state = ref.watch(backupProvider);
  return state.mapOrNull(
    loaded: (loaded) => loaded.isAuthenticated,
  ) ?? false;
});

/// Convenience provider for user email
/// Returns null if not authenticated or not loaded
final userEmailProvider = Provider<String?>((ref) {
  final state = ref.watch(backupProvider);
  return state.mapOrNull(
    loaded: (loaded) => loaded.userEmail,
  );
});

/// Convenience provider for checking if backup is loading
final backupLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(backupProvider);
  return state.isLoading;
});

/// Convenience provider for checking if backup is loaded
final backupLoadedProvider = Provider<bool>((ref) {
  final state = ref.watch(backupProvider);
  return state.isLoaded;
});

/// Convenience provider for checking if backup operation is in progress
final backupInProgressProvider = Provider<bool>((ref) {
  final state = ref.watch(backupProvider);
  return state.isInProgress;
});

/// Convenience provider for checking if there's a backup error
final backupHasErrorProvider = Provider<bool>((ref) {
  final state = ref.watch(backupProvider);
  return state.hasError;
});

/// Convenience provider for backup error message
final backupErrorMessageProvider = Provider<String?>((ref) {
  final state = ref.watch(backupProvider);
  return state.errorMessage;
});

/// Convenience provider for loaded backup state data
/// Returns null if not in loaded state
final backupLoadedDataProvider = Provider<BackupRiverpodStateLoaded?>((ref) {
  final state = ref.watch(backupProvider);
  return state.loadedData;
});