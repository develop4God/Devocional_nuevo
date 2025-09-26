// lib/widgets/backup_configuration_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/backup/backup_providers.dart';
import '../providers/backup/backup_state.dart';
import '../extensions/string_extensions.dart';

/// Modal de configuración de backup migrado a Riverpod
class BackupConfigurationSheet extends ConsumerWidget {
  final BackupRiverpodStateLoaded initialState;

  const BackupConfigurationSheet({
    super.key,
    required this.initialState,
  });

  static void show(BuildContext context, BackupRiverpodStateLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => BackupConfigurationSheet(initialState: state),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Watch the backup state for real-time updates
    final backupState = ref.watch(backupProvider);
    
    // Get the current state to display
    final displayState = backupState.maybeWhen(
      loaded: (
        autoBackupEnabled,
        backupFrequency, 
        wifiOnlyEnabled,
        compressionEnabled,
        backupOptions,
        lastBackupTime,
        nextBackupTime,
        estimatedSize,
        storageInfo,
        isAuthenticated,
        userEmail,
      ) => BackupRiverpodStateLoaded(
        autoBackupEnabled: autoBackupEnabled,
        backupFrequency: backupFrequency,
        wifiOnlyEnabled: wifiOnlyEnabled,
        compressionEnabled: compressionEnabled,
        backupOptions: backupOptions,
        lastBackupTime: lastBackupTime,
        nextBackupTime: nextBackupTime,
        estimatedSize: estimatedSize,
        storageInfo: storageInfo,
        isAuthenticated: isAuthenticated,
        userEmail: userEmail,
      ),
      orElse: () => initialState,
    );

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Text(
                    'backup.advanced_settings'.tr(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNetworkSettings(context, ref, displayState, theme),
                    const SizedBox(height: 24),
                    _buildBackupOptions(context, ref, displayState, theme),
                    if (displayState.isAuthenticated) ...[
                      const SizedBox(height: 24),
                      _buildGoogleDriveInfo(context, ref, displayState, theme),
                    ],
                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkSettings(
    BuildContext context,
    WidgetRef ref,
    BackupRiverpodStateLoaded displayState,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'backup.network_settings'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: Text('backup.wifi_only'.tr()),
              subtitle: Text('backup.wifi_only_subtitle'.tr()),
              value: displayState.wifiOnlyEnabled,
              onChanged: (value) => ref.read(backupProvider.notifier).toggleWifiOnly(value),
            ),
            
            SwitchListTile(
              title: Text('backup.compress_data'.tr()),
              subtitle: Text('backup.compress_data_subtitle'.tr()),
              value: displayState.compressionEnabled,
              onChanged: (value) => ref.read(backupProvider.notifier).toggleCompression(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupOptions(
    BuildContext context,
    WidgetRef ref,
    BackupRiverpodStateLoaded displayState,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'backup.backup_options'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            ...displayState.backupOptions.entries.map((entry) {
              return CheckboxListTile(
                title: Text('backup.option_${entry.key}'.tr()),
                value: entry.value,
                onChanged: (value) => ref.read(backupProvider.notifier)
                    .toggleBackupOption(entry.key, value ?? false),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleDriveInfo(
    BuildContext context,
    WidgetRef ref,
    BackupRiverpodStateLoaded displayState,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'backup.google_drive_info'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            if (displayState.userEmail != null) ...[
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: Text('backup.signed_in_as'.tr()),
                subtitle: Text(displayState.userEmail!),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
            ],
            
            if (displayState.storageInfo.isNotEmpty) ...[
              ListTile(
                leading: const Icon(Icons.storage),
                title: Text('backup.storage_used'.tr()),
                subtitle: Text(_formatStorageInfo(displayState.storageInfo)),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
            ],
            
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text('backup.estimated_size'.tr()),
              subtitle: Text(_formatBytes(displayState.estimatedSize)),
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showSignOutDialog(context, ref),
                icon: const Icon(Icons.logout),
                label: Text('backup.sign_out'.tr()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('backup.confirm_sign_out'.tr()),
          content: Text('backup.sign_out_warning'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('backup.cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                Navigator.of(context).pop(); // Close modal
                ref.read(backupProvider.notifier).signOutFromGoogleDrive();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: Text('backup.sign_out'.tr()),
            ),
          ],
        );
      },
    );
  }

  String _formatStorageInfo(Map<String, dynamic> storageInfo) {
    if (storageInfo.isEmpty) return 'Unknown';
    
    final used = storageInfo['used'] ?? 0;
    final total = storageInfo['total'] ?? 0;
    
    if (total > 0) {
      final percentage = (used / total * 100).toStringAsFixed(1);
      return '${_formatBytes(used)} / ${_formatBytes(total)} ($percentage%)';
    }
    
    return _formatBytes(used);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}