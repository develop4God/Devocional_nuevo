// lib/pages/backup_settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/string_extensions.dart';
import '../providers/backup/backup_providers.dart';
import '../providers/backup/backup_state.dart';
import '../widgets/backup_configuration_sheet.dart';

/// BackupSettingsPage migrated to Riverpod architecture
class BackupSettingsPage extends ConsumerWidget {
  const BackupSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🏗️ [DEBUG] BackupSettingsPage build iniciado');
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('backup.title'.tr()),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final backupState = ref.watch(backupProvider);
          
          return backupState.when(
            initial: () => const Center(child: Text('Initializing...')),
            loading: () => const Center(child: CircularProgressIndicator()),
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
            ) => _buildLoadedView(
              context, 
              ref, 
              BackupRiverpodStateLoaded(
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
              )
            ),
            creating: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Creating backup...'),
                ],
              ),
            ),
            created: (timestamp) => const Center(child: Text('Backup created successfully!')),
            restoring: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Restoring backup...'),
                ],
              ),
            ),
            restored: () => const Center(child: Text('Backup restored successfully!')),
            settingsUpdated: () => const Center(child: Text('Settings updated successfully!')),
            success: (title, message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: colorScheme.primary, size: 48),
                  SizedBox(height: 16),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: colorScheme.error, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Error: $message',
                    style: TextStyle(color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(backupProvider.notifier).loadBackupSettings(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadedView(
    BuildContext context, 
    WidgetRef ref, 
    BackupRiverpodStateLoaded state
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'backup.status'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (state.isAuthenticated && state.userEmail != null) ...[
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'backup.signed_in_as'.tr() + ' ${state.userEmail}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    if (state.lastBackupTime != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'backup.last_backup'.tr() + ' ${_formatDateTime(state.lastBackupTime!)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ] else ...[
                    Row(
                      children: [
                        Icon(Icons.cloud_off, color: colorScheme.error),
                        const SizedBox(width: 8),
                        Text(
                          'backup.not_signed_in'.tr(),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Actions
          _buildActionButtons(context, ref, state),
          
          const SizedBox(height: 16),
          
          // Settings
          _buildSettings(context, ref, state),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context, 
    WidgetRef ref, 
    BackupRiverpodStateLoaded state
  ) {
    return Column(
      children: [
        if (!state.isAuthenticated) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => ref.read(backupProvider.notifier).signInToGoogleDrive(),
              icon: const Icon(Icons.cloud),
              label: Text('backup.sign_in'.tr()),
            ),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => ref.read(backupProvider.notifier).createManualBackup(),
                  icon: const Icon(Icons.backup),
                  label: Text('backup.create_backup'.tr()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => ref.read(backupProvider.notifier).restoreFromBackup(),
                  icon: const Icon(Icons.restore),
                  label: Text('backup.restore'.tr()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => ref.read(backupProvider.notifier).signOutFromGoogleDrive(),
              icon: const Icon(Icons.logout),
              label: Text('backup.sign_out'.tr()),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSettings(
    BuildContext context, 
    WidgetRef ref, 
    BackupRiverpodStateLoaded state
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'backup.settings'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Auto backup toggle
            SwitchListTile(
              title: Text('backup.auto_backup'.tr()),
              subtitle: Text('backup.auto_backup_subtitle'.tr()),
              value: state.autoBackupEnabled,
              onChanged: (value) => ref.read(backupProvider.notifier).toggleAutoBackup(value),
            ),
            
            const Divider(),
            
            // Backup frequency
            ListTile(
              title: Text('backup.frequency'.tr()),
              subtitle: Text(state.backupFrequency),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showFrequencySelector(context, ref, state.backupFrequency),
            ),
            
            const Divider(),
            
            // Advanced settings
            ListTile(
              title: Text('backup.advanced_settings'.tr()),
              subtitle: Text('backup.wifi_compression_options'.tr()),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => BackupConfigurationSheet.show(context, state),
            ),
          ],
        ),
      ),
    );
  }

  void _showFrequencySelector(BuildContext context, WidgetRef ref, String currentFrequency) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Daily',
            'Weekly', 
            'Monthly',
          ].map((frequency) => ListTile(
            title: Text(frequency),
            trailing: currentFrequency == frequency ? const Icon(Icons.check) : null,
            onTap: () {
              ref.read(backupProvider.notifier).changeBackupFrequency(frequency);
              Navigator.pop(context);
            },
          )).toList(),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}