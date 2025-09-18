import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/backup_bloc.dart';
import '../blocs/backup_event.dart';
import '../blocs/backup_state.dart';
import '../blocs/prayer_bloc.dart';
import '../extensions/string_extensions.dart';
import '../providers/devocional_provider.dart';
import '../services/backup_scheduler_service.dart';
import '../services/connectivity_service.dart';
import '../services/google_drive_auth_service.dart';
import '../services/google_drive_backup_service.dart';
import '../services/spiritual_stats_service.dart';

/// BackupSettingsPage with simplified progressive UI
class BackupSettingsPage extends StatelessWidget {
  final BackupBloc? bloc; // Optional bloc for testing

  const BackupSettingsPage({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ [DEBUG] BackupSettingsPage build iniciado');

    // If bloc is provided (e.g., in tests), use it directly
    if (bloc != null) {
      return BlocProvider.value(
        value: bloc!,
        child: const _BackupSettingsView(),
      );
    }

    // Otherwise, create services with dependencies (production)
    final authService = GoogleDriveAuthService();
    debugPrint('🔧 [DEBUG] GoogleDriveAuthService creado');

    final connectivityService = ConnectivityService();
    debugPrint('🔧 [DEBUG] ConnectivityService creado');

    final statsService = SpiritualStatsService();
    debugPrint('🔧 [DEBUG] SpiritualStatsService creado');

    final backupService = GoogleDriveBackupService(
      authService: authService,
      connectivityService: connectivityService,
      statsService: statsService,
    );
    debugPrint('🔧 [DEBUG] GoogleDriveBackupService creado con dependencias');

    return BlocProvider(
      create: (context) {
        // 🔧 CRÍTICO: Restaurar BackupSchedulerService
        final schedulerService = BackupSchedulerService(
          backupService: backupService,
          connectivityService: connectivityService,
        );
        final bloc = BackupBloc(
          backupService: backupService,
          schedulerService: schedulerService, // 🔧 RESTAURADO
          devocionalProvider:
              Provider.of<DevocionalProvider>(context, listen: false),
          prayerBloc: context.read<PrayerBloc>(), // 🔧 RESTAURADO
        );
        bloc.add(const LoadBackupSettings());
        return bloc;
      },
      child: const _BackupSettingsView(),
    );
  }
}

class _BackupSettingsView extends StatelessWidget {
  const _BackupSettingsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('backup.title'.tr()),
        elevation: 0,
      ),
      body: BlocListener<BackupBloc, BackupState>(
        listener: (context, state) {
          debugPrint(
              '🔄 [DEBUG] BlocListener recibió estado: ${state.runtimeType}');
          if (state is BackupError) {
            debugPrint('❌ [DEBUG] BackupError recibido: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.tr()),
                backgroundColor: colorScheme.error,
              ),
            );
          } else if (state is BackupCreated) {
            debugPrint('✅ [DEBUG] BackupCreated recibido');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('backup.created_successfully'.tr()),
                backgroundColor: colorScheme.primary,
              ),
            );
          } else if (state is BackupRestored) {
            debugPrint('✅ [DEBUG] BackupRestored recibido');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('backup.restored_successfully'.tr()),
                backgroundColor: colorScheme.primary,
              ),
            );
          } else if (state is BackupExistingFound) {
            debugPrint('📋 [DEBUG] BackupExistingFound recibido');
            _showExistingBackupDialog(context, state.backupInfo);
          }
        },
        child: BlocBuilder<BackupBloc, BackupState>(
          builder: (context, state) {
            if (state is BackupLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BackupLoaded) {
              return _BackupSettingsContent(state: state);
            }

            if (state is BackupError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'backup.error_loading'.tr(),
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<BackupBloc>()
                            .add(const LoadBackupSettings());
                      },
                      child: Text('backup.retry'.tr()),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  /// Show dialog when existing backup is found
  void _showExistingBackupDialog(
      BuildContext context, Map<String, dynamic> backupInfo) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('backup.existing_backup_found'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('backup.existing_backup_message'.tr()),
              const SizedBox(height: 16),
              if (backupInfo['modifiedTime'] != null) ...[
                Text(
                  '${'backup.backup_date'.tr()}: ${_formatBackupDate(backupInfo['modifiedTime'])}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (backupInfo['size'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${'backup.size'.tr()}: ${_formatSize(int.tryParse(backupInfo['size'].toString()) ?? 0)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<BackupBloc>().add(const SkipExistingBackup());
              },
              child: Text('backup.skip_restore'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context
                    .read<BackupBloc>()
                    .add(RestoreExistingBackup(backupInfo['fileId']));
              },
              child: Text('backup.restore_backup'.tr()),
            ),
          ],
        );
      },
    );
  }

  /// Format backup date for display
  String _formatBackupDate(String isoDateString) {
    try {
      final date = DateTime.parse(isoDateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'backup.today'.tr();
      } else if (difference.inDays == 1) {
        return 'backup.yesterday'.tr();
      } else if (difference.inDays < 7) {
        return 'backup.days_ago'
            .tr()
            .replaceAll('{days}', difference.inDays.toString());
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return isoDateString;
    }
  }

  /// Format size in bytes to human readable format
  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

class _BackupSettingsContent extends StatelessWidget {
  final BackupLoaded state;

  const _BackupSettingsContent({required this.state});

  @override
  Widget build(BuildContext context) {
    // Check if this is the first time connecting (no lastBackupTime and auto not configured yet)
    final hasConnectedBefore =
        state.lastBackupTime != null || state.autoBackupEnabled;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Always show intro section
          _buildIntroSection(context),
          const SizedBox(height: 20),

          // Progressive content based on state
          if (!state.isAuthenticated) ...[
            // State 1: Not connected - Only connection card
            _buildConnectionPrompt(context),
          ] else if (state.isAuthenticated && !hasConnectedBefore) ...[
            // State 2: Just connected - Show success and initial setup
            _buildJustConnectedState(context),
          ] else if (state.isAuthenticated && state.autoBackupEnabled) ...[
            // State 3: Auto backup is ON - Show protection title + simplified card
            _buildProtectionTitle(context),
            const SizedBox(height: 12),
            _buildAutoBackupActiveState(context),
          ] else if (state.isAuthenticated && !state.autoBackupEnabled) ...[
            // State 4: Auto backup is OFF - Show manual backup option
            _buildManualBackupState(context),
          ],

          // Security info (always at bottom)
          const SizedBox(height: 24),
          _buildSecurityInfo(context),
        ],
      ),
    );
  }

  Widget _buildIntroSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.3),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'backup.description_title'.tr(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'backup.description_text'.tr(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionPrompt(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          debugPrint('🔄 [DEBUG] Usuario tapeó conectar Google Drive');
          context.read<BackupBloc>().add(const SignInToGoogleDrive());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'backup.connect_to_google_drive'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'backup.tap_to_connect_protect'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    debugPrint('🔄 [DEBUG] Botón conectar presionado');
                    context.read<BackupBloc>().add(const SignInToGoogleDrive());
                  },
                  icon: const Icon(Icons.account_circle),
                  label: Text('backup.connect_to_google_drive'.tr()),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJustConnectedState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Success message
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'backup.sign_in_success'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (state.userEmail != null) ...[
                Text(
                  '${'backup.backup_email'.tr()}: ${state.userEmail!}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Auto-enable automatic backup
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.autorenew,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'backup.automatic_protection_enabled'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '¿Quieres que respaldemos automáticamente todos los días a las 2:00 AM?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Activate automatic backup with all defaults
                      context
                          .read<BackupBloc>()
                          .add(const ToggleAutoBackup(true));
                      context
                          .read<BackupBloc>()
                          .add(const ToggleWifiOnly(true));
                      context
                          .read<BackupBloc>()
                          .add(const ToggleCompression(true));
                    },
                    child: Text('backup.activate_automatic'.tr()),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Skip to manual backup
                    context
                        .read<BackupBloc>()
                        .add(const ToggleAutoBackup(false));
                  },
                  child: Text('backup.prefer_manual'.tr()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🎯 NEW: Protection title outside the card (only when authenticated and auto backup active)
  Widget _buildProtectionTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(Icons.security, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(
            'backup.protection_active'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 SIMPLIFIED: Auto backup active state with clean card
  Widget _buildAutoBackupActiveState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User email
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  '${'backup.backup_email'.tr()}: ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    state.userEmail ?? 'backup.no_email'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Last backup
            if (state.lastBackupTime != null) ...[
              Row(
                children: [
                  Icon(Icons.schedule,
                      size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    '${'backup.last_backup'.tr()}: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _formatLastBackupTime(context, state.lastBackupTime!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Next backup
            if (state.nextBackupTime != null) ...[
              Row(
                children: [
                  Icon(Icons.schedule_send,
                      size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    '${'backup.next_backup'.tr()}: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _formatNextBackupTime(context, state.nextBackupTime!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Switch and settings row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'backup.enable_auto_backup'.tr(),
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        'backup.auto_backup_subtitle'.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: state.autoBackupEnabled,
                  onChanged: (value) {
                    context.read<BackupBloc>().add(ToggleAutoBackup(value));
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showConfigurationModal(context),
                  icon: Icon(Icons.settings, color: colorScheme.primary),
                  tooltip: 'backup.configuration'.tr(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 NEW: Configuration Modal with consistent visual style
  void _showConfigurationModal(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - consistent with your visual style
                Row(
                  children: [
                    Icon(Icons.settings, color: colorScheme.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'backup.configuration_title'.tr(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Technical Information Section - styled as card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'backup.technical_info'.tr(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FutureBuilder<Map<String, dynamic>>(
                                future: _getDynamicBackupOptions(context),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  final backupData = snapshot.data ?? {};
                                  return Column(
                                    children: [
                                      _buildInfoRow(
                                        context,
                                        'backup.spiritual_stats'.tr(),
                                        _formatBackupOptionSize(
                                            backupData['spiritual_stats']),
                                      ),
                                      _buildInfoRow(
                                        context,
                                        'backup.favorite_devotionals'.tr(),
                                        _formatBackupOptionSize(
                                            backupData['favorite_devotionals']),
                                      ),
                                      _buildInfoRow(
                                        context,
                                        'backup.saved_prayers'.tr(),
                                        _formatBackupOptionSize(
                                            backupData['saved_prayers']),
                                      ),
                                      const Divider(height: 20),
                                      _buildInfoRow(
                                        context,
                                        'backup.total_estimated'.tr(),
                                        _formatSize(state.estimatedSize),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Configuration Section - styled as card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'backup.configuration'.tr(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildSwitchTile(
                                context,
                                'backup.wifi_only'.tr(),
                                'backup.wifi_only_subtitle'.tr(),
                                state.wifiOnlyEnabled,
                                (value) => context
                                    .read<BackupBloc>()
                                    .add(ToggleWifiOnly(value)),
                              ),
                              const Divider(),
                              _buildSwitchTile(
                                context,
                                'backup.compress_data'.tr(),
                                'backup.compress_data_subtitle'.tr(),
                                state.compressionEnabled,
                                (value) => context
                                    .read<BackupBloc>()
                                    .add(ToggleCompression(value)),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Actions Section - styled as buttons
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _handleRestore(context);
                            },
                            icon: const Icon(Icons.download),
                            label: Text('backup.restore_backup'.tr()),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showLogoutDialog(context);
                            },
                            icon: const Icon(Icons.logout),
                            label: Text('backup.logout'.tr()),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              foregroundColor: Colors.red,
                              side: BorderSide(
                                  color: Colors.red.withValues(alpha: 0.3)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Handle restore action
  void _handleRestore(BuildContext context) {
    // Show confirmation dialog first
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('backup.restore_confirmation_title'.tr()),
          content: Text('backup.restore_confirmation_message'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('backup.backup_cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Trigger restore - this will find and restore existing backup
                context.read<BackupBloc>().add(const LoadBackupSettings());
              },
              child: Text('backup.restore_backup'.tr()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildManualBackupState(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Manual backup card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.touch_app,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'backup.manual_backup_active'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'backup.manual_backup_description'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Show email in manual state too
                if (state.userEmail != null) ...[
                  Text(
                    '${'backup.backup_email'.tr()}: ${state.userEmail!}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<BackupBloc>()
                          .add(const CreateManualBackup());
                    },
                    icon: const Icon(Icons.backup),
                    label: Text('backup.create_backup'.tr()),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    context
                        .read<BackupBloc>()
                        .add(const ToggleAutoBackup(true));
                  },
                  child: Text('backup.enable_auto_backup'.tr()),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: Icon(
                    Icons.logout_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text('backup.backup_logout_confirmation_title'.tr()),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Last backup info if available
        if (state.lastBackupTime != null) ...[
          Card(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${'backup.last_backup'.tr()}: ${_formatLastBackupTime(context, state.lastBackupTime!)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSecurityInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.security,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'backup.security_title'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'backup.security_text'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  /// Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('backup.backup_logout_confirmation_title'.tr()),
          content: Text('backup.backup_logout_confirmation_message'.tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('backup.backup_cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<BackupBloc>().add(const SignOutFromGoogleDrive());
              },
              child: Text('backup.backup_confirm'.tr()),
            ),
          ],
        );
      },
    );
  }

  /// Get dynamic backup options with actual file sizes (from RAW original)
  Future<Map<String, dynamic>> _getDynamicBackupOptions(
      BuildContext context) async {
    try {
      debugPrint('📊 [DEBUG] Obteniendo opciones dinámicas de backup...');

      // Get actual data from services
      final statsService = SpiritualStatsService();
      final devocionalProvider =
          Provider.of<DevocionalProvider>(context, listen: false);
      debugPrint('📊 [DEBUG] Servicios obtenidos para calcular tamaños');

      // Get spiritual stats data
      final statsData = await statsService.getAllStats();
      final statsSize = _calculateJsonSize(statsData);

      // Get favorite devotionals count and size
      final favoriteCount = devocionalProvider.favoriteDevocionales.length;
      final favoritesSize =
          _calculateJsonSize(devocionalProvider.favoriteDevocionales);

      // Get saved prayers data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final prayersJson = prefs.getString('prayers') ?? '[]';
      final prayersList = json.decode(prayersJson) as List<dynamic>;
      final prayersCount = prayersList.length;
      final prayersSize = _calculateJsonSize(prayersList);

      return {
        'spiritual_stats': {
          'count': 1,
          'size': statsSize,
          'description': '1 archivo, ~${_formatSize(statsSize)}',
        },
        'favorite_devotionals': {
          'count': favoriteCount,
          'size': favoritesSize,
          'description':
              '$favoriteCount ${favoriteCount == 1 ? 'elemento' : 'elementos'}, ~${_formatSize(favoritesSize)}',
        },
        'saved_prayers': {
          'count': prayersCount,
          'size': prayersSize,
          'description':
              '$prayersCount ${prayersCount == 1 ? 'elemento' : 'elementos'}, ~${_formatSize(prayersSize)}',
        },
      };
    } catch (e) {
      debugPrint('❌ [DEBUG] Error getting dynamic backup options: $e');
      return {
        'spiritual_stats': {
          'count': 0,
          'size': 0,
          'description': '0 KB',
        },
        'favorite_devotionals': {
          'count': 0,
          'size': 0,
          'description': '0 elementos, 0 KB',
        },
        'saved_prayers': {
          'count': 0,
          'size': 0,
          'description': '0 elementos, 0 KB',
        },
      };
    }
  }

  /// Calculate the JSON size of data
  int _calculateJsonSize(dynamic data) {
    try {
      final jsonString = jsonEncode(data);
      return utf8.encode(jsonString).length;
    } catch (e) {
      return 0;
    }
  }

  /// Format backup option size description
  String _formatBackupOptionSize(Map<String, dynamic>? optionData) {
    if (optionData == null) return '0 KB';
    return optionData['description'] ?? '0 KB';
  }

  String _formatLastBackupTime(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return 'backup.today'.tr();
    } else if (difference.inDays == 1) {
      return 'backup.yesterday'.tr();
    } else {
      return 'backup.days_ago'
          .tr()
          .replaceAll('{days}', difference.inDays.toString());
    }
  }

  String _formatNextBackupTime(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final nowDate = DateTime(now.year, now.month, now.day);
    final timeDate = DateTime(time.year, time.month, time.day);
    final daysDifference = timeDate.difference(nowDate).inDays;

    // Formatear la hora exacta del backup programado
    final hour = time.hour;
    final minute = time.minute;
    String timeString;

    if (hour == 0 && minute == 0) {
      timeString = '12:00 AM';
    } else if (hour < 12) {
      timeString =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} AM';
    } else if (hour == 12) {
      timeString = '12:${minute.toString().padLeft(2, '0')} PM';
    } else {
      timeString =
          '${(hour - 12).toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} PM';
    }

    // Casos especiales para 2:00 AM (más legible)
    if (hour == 2 && minute == 0) {
      timeString = '2:00 AM';
    }

    if (daysDifference == 0) {
      return '${'backup.today'.tr()} $timeString';
    } else if (daysDifference == 1) {
      return '${'backup.tomorrow'.tr()} $timeString';
    } else {
      return '${'backup.in_days'.tr().replaceAll('{days}', daysDifference.toString())} $timeString';
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
