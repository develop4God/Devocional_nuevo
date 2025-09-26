// lib/providers/backup/backup_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'backup_state.dart';
import 'backup_repository.dart';

/// StateNotifier for managing Google Drive backup functionality
/// Replaces the BackupBloc with modern Riverpod architecture
class BackupNotifier extends StateNotifier<BackupRiverpodState> {
  final BackupRepository _repository;

  /// Constructor initializes with loading state
  BackupNotifier(this._repository)
      : super(const BackupRiverpodState.initial()) {
    // Auto-load backup settings when notifier is created
    loadBackupSettings();
  }

  /// Load all backup settings and status
  Future<void> loadBackupSettings() async {
    try {
      // Set loading state
      state = const BackupRiverpodState.loading();

      // Load settings from repository
      final settings = await _repository.loadBackupSettings();

      // Update state with loaded data
      state = BackupRiverpodState.loaded(
        autoBackupEnabled: settings.autoBackupEnabled,
        backupFrequency: settings.backupFrequency,
        wifiOnlyEnabled: settings.wifiOnlyEnabled,
        compressionEnabled: settings.compressionEnabled,
        backupOptions: settings.backupOptions,
        lastBackupTime: settings.lastBackupTime,
        nextBackupTime: settings.nextBackupTime,
        estimatedSize: settings.estimatedSize,
        storageInfo: settings.storageInfo,
        isAuthenticated: settings.isAuthenticated,
        userEmail: settings.userEmail,
      );
    } catch (e) {
      // Handle errors gracefully
      state = BackupRiverpodState.error(
        message: 'Failed to load backup settings: ${e.toString()}',
      );
    }
  }

  /// Toggle automatic backup on/off
  Future<void> toggleAutoBackup(bool enabled) async {
    try {
      // Only proceed if we have loaded state
      if (state is! BackupRiverpodStateLoaded) return;

      final currentState = state as BackupRiverpodStateLoaded;

      // Save setting to repository
      await _repository.saveAutoBackupEnabled(enabled);

      // Update state with new value
      state = currentState.copyWith(autoBackupEnabled: enabled);

      // Show success feedback
      state = const BackupRiverpodState.settingsUpdated();

      // Return to loaded state after brief success feedback
      await Future.delayed(const Duration(milliseconds: 500));
      state = currentState.copyWith(autoBackupEnabled: enabled);
    } catch (e) {
      state = BackupRiverpodState.error(
        message: 'Failed to update auto backup setting: ${e.toString()}',
      );
    }
  }

  /// Change backup frequency (daily, weekly, monthly)
  Future<void> changeBackupFrequency(String frequency) async {
    try {
      if (state is! BackupRiverpodStateLoaded) return;

      final currentState = state as BackupRiverpodStateLoaded;

      // Save setting to repository
      await _repository.saveBackupFrequency(frequency);

      // Update state with new frequency
      state = currentState.copyWith(backupFrequency: frequency);

      // Show success feedback
      state = const BackupRiverpodState.settingsUpdated();
      await Future.delayed(const Duration(milliseconds: 500));
      state = currentState.copyWith(backupFrequency: frequency);
    } catch (e) {
      state = BackupRiverpodState.error(
        message: 'Failed to update backup frequency: ${e.toString()}',
      );
    }
  }

  /// Toggle WiFi-only backup
  Future<void> toggleWifiOnly(bool enabled) async {
    try {
      if (state is! BackupRiverpodStateLoaded) return;

      final currentState = state as BackupRiverpodStateLoaded;

      await _repository.saveWifiOnlyEnabled(enabled);
      state = currentState.copyWith(wifiOnlyEnabled: enabled);

      state = const BackupRiverpodState.settingsUpdated();
      await Future.delayed(const Duration(milliseconds: 500));
      state = currentState.copyWith(wifiOnlyEnabled: enabled);
    } catch (e) {
      state = BackupRiverpodState.error(
        message: 'Failed to update WiFi-only setting: ${e.toString()}',
      );
    }
  }

  /// Toggle data compression
  Future<void> toggleCompression(bool enabled) async {
    try {
      if (state is! BackupRiverpodStateLoaded) return;

      final currentState = state as BackupRiverpodStateLoaded;

      await _repository.saveCompressionEnabled(enabled);
      state = currentState.copyWith(compressionEnabled: enabled);

      state = const BackupRiverpodState.settingsUpdated();
      await Future.delayed(const Duration(milliseconds: 500));
      state = currentState.copyWith(compressionEnabled: enabled);
    } catch (e) {
      state = BackupRiverpodState.error(
        message: 'Failed to update compression setting: ${e.toString()}',
      );
    }
  }

  /// Update backup options (what to include)
  Future<void> updateBackupOptions(Map<String, bool> options) async {
    try {
      if (state is! BackupRiverpodStateLoaded) return;

      final currentState = state as BackupRiverpodStateLoaded;

      await _repository.saveBackupOptions(options);
      state = currentState.copyWith(backupOptions: options);

      state = const BackupRiverpodState.settingsUpdated();
      await Future.delayed(const Duration(milliseconds: 500));
      state = currentState.copyWith(backupOptions: options);
    } catch (e) {
      state = BackupRiverpodState.error(
        message: 'Failed to update backup options: ${e.toString()}',
      );
    }
  }

  /// Toggle individual backup option
  Future<void> toggleBackupOption(String key, bool enabled) async {
    if (state is! BackupRiverpodStateLoaded) return;

    final currentState = state as BackupRiverpodStateLoaded;
    final updatedOptions = Map<String, bool>.from(currentState.backupOptions);
    updatedOptions[key] = enabled;

    await updateBackupOptions(updatedOptions);
  }

  /// Create manual backup
  Future<void> createManualBackup() async {
    try {
      if (state is! BackupRiverpodStateLoaded) return;

      final currentState = state as BackupRiverpodStateLoaded;

      // Set creating state
      state = const BackupRiverpodState.creating();

      // Create backup via repository
      final timestamp = await _repository.createManualBackup();

      // Update to created state
      state = BackupRiverpodState.created(timestamp: timestamp);

      // Show success message
      await Future.delayed(const Duration(milliseconds: 1000));
      state = BackupRiverpodState.success(
        title: 'Backup Created',
        message: 'Your data has been successfully backed up to Google Drive.',
      );

      // Return to loaded state with updated last backup time
      await Future.delayed(const Duration(seconds: 2));
      state = currentState.copyWith(lastBackupTime: timestamp);
    } catch (e) {
      state = BackupRiverpodState.error(
        message: 'Failed to create backup: ${e.toString()}',
      );
    }
  }

  /// Restore from backup
  Future<void> restoreFromBackup() async {
    try {
      if (state is! BackupRiverpodStateLoaded) return;

      final currentState = state as BackupRiverpodStateLoaded;

      // Set restoring state
      state = const BackupRiverpodState.restoring();

      // Restore backup via repository
      await _repository.restoreFromBackup();

      // Update to restored state
      state = const BackupRiverpodState.restored();

      // Show success message
      await Future.delayed(const Duration(milliseconds: 1000));
      state = const BackupRiverpodState.success(
        title: 'Backup Restored',
        message: 'Your data has been successfully restored from Google Drive.',
      );

      // Return to loaded state
      await Future.delayed(const Duration(seconds: 2));
      state = currentState;
    } catch (e) {
      state = BackupRiverpodState.error(
        message: 'Failed to restore backup: ${e.toString()}',
      );
    }
  }

  /// Sign in to Google Drive
  Future<void> signInToGoogleDrive() async {
    try {
      if (state is! BackupRiverpodStateLoaded) return;

      final currentState = state as BackupRiverpodStateLoaded;

      // Set loading state temporarily
      state = const BackupRiverpodState.loading();

      // Sign in via repository
      final userEmail = await _repository.signInToGoogleDrive();

      // Update state with authentication info
      state = currentState.copyWith(
        isAuthenticated: true,
        userEmail: userEmail,
      );

      // Show success message
      state = const BackupRiverpodState.success(
        title: 'Signed In',
        message: 'Successfully signed in to Google Drive.',
      );

      await Future.delayed(const Duration(seconds: 2));
      state = currentState.copyWith(
        isAuthenticated: true,
        userEmail: userEmail,
      );
    } catch (e) {
      state = BackupRiverpodState.error(
        message: 'Failed to sign in to Google Drive: ${e.toString()}',
      );
    }
  }

  /// Sign out from Google Drive
  Future<void> signOutFromGoogleDrive() async {
    try {
      if (state is! BackupRiverpodStateLoaded) return;

      final currentState = state as BackupRiverpodStateLoaded;

      // Sign out via repository
      await _repository.signOutFromGoogleDrive();

      // Update state to remove authentication
      state = currentState.copyWith(
        isAuthenticated: false,
        userEmail: null,
      );

      // Show success message
      state = const BackupRiverpodState.success(
        title: 'Signed Out',
        message: 'Successfully signed out from Google Drive.',
      );

      await Future.delayed(const Duration(seconds: 2));
      state = currentState.copyWith(
        isAuthenticated: false,
        userEmail: null,
      );
    } catch (e) {
      state = BackupRiverpodState.error(
        message: 'Failed to sign out from Google Drive: ${e.toString()}',
      );
    }
  }

  /// Check for startup backup (24h+ elapsed)
  Future<void> checkStartupBackup() async {
    try {
      final shouldBackup = await _repository.shouldPerformStartupBackup();

      if (shouldBackup) {
        // Automatically create backup if needed
        await createManualBackup();
      }
    } catch (e) {
      // Don't show error for startup backup check - it's a background operation
      // Just log it or handle silently
    }
  }

  /// Refresh backup status and reload settings
  Future<void> refreshBackupStatus() async {
    await loadBackupSettings();
  }

  /// Load storage information
  Future<void> loadStorageInfo() async {
    try {
      if (state is! BackupRiverpodStateLoaded) return;

      final currentState = state as BackupRiverpodStateLoaded;

      // Reload settings to get fresh storage info
      await loadBackupSettings();
    } catch (e) {
      state = BackupRiverpodState.error(
        message: 'Failed to load storage information: ${e.toString()}',
      );
    }
  }
}
