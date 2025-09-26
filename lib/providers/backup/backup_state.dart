// lib/providers/backup/backup_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_state.freezed.dart';

/// Immutable states for Google Drive backup functionality using Freezed
@freezed
class BackupRiverpodState with _$BackupRiverpodState {
  /// Initial state when backup system is not yet loaded
  const factory BackupRiverpodState.initial() = BackupRiverpodStateInitial;

  /// Loading state while fetching backup settings
  const factory BackupRiverpodState.loading() = BackupRiverpodStateLoading;

  /// Loaded state with all backup settings and configuration
  const factory BackupRiverpodState.loaded({
    required bool autoBackupEnabled,
    required String backupFrequency,
    required bool wifiOnlyEnabled,
    required bool compressionEnabled,
    required Map<String, bool> backupOptions,
    DateTime? lastBackupTime,
    DateTime? nextBackupTime,
    required int estimatedSize,
    required Map<String, dynamic> storageInfo,
    required bool isAuthenticated,
    String? userEmail,
  }) = BackupRiverpodStateLoaded;

  /// Creating backup state
  const factory BackupRiverpodState.creating() = BackupRiverpodStateCreating;

  /// Backup created successfully
  const factory BackupRiverpodState.created({
    required DateTime timestamp,
  }) = BackupRiverpodStateCreated;

  /// Restoring backup state
  const factory BackupRiverpodState.restoring() = BackupRiverpodStateRestoring;

  /// Backup restored successfully
  const factory BackupRiverpodState.restored() = BackupRiverpodStateRestored;

  /// Settings updated successfully
  const factory BackupRiverpodState.settingsUpdated() =
      BackupRiverpodStateSettingsUpdated;

  /// Success state for UX feedback
  const factory BackupRiverpodState.success({
    required String title,
    required String message,
  }) = BackupRiverpodStateSuccess;

  /// Error state with message
  const factory BackupRiverpodState.error({
    required String message,
  }) = BackupRiverpodStateError;
}

/// Extensions for convenience methods
extension BackupRiverpodStateExtensions on BackupRiverpodState {
  /// Check if backup is currently loading
  bool get isLoading => this is BackupRiverpodStateLoading;

  /// Check if backup is loaded with settings
  bool get isLoaded => this is BackupRiverpodStateLoaded;

  /// Check if backup is in progress (creating or restoring)
  bool get isInProgress =>
      this is BackupRiverpodStateCreating ||
      this is BackupRiverpodStateRestoring;

  /// Check if there's an error
  bool get hasError => this is BackupRiverpodStateError;

  /// Get error message if available
  String? get errorMessage => mapOrNull(
        error: (error) => error.message,
      );

  /// Get loaded state data if available
  BackupRiverpodStateLoaded? get loadedData => mapOrNull(
        loaded: (loaded) => loaded,
      );
}
