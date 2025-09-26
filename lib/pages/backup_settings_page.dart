// lib/pages/backup_settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/backup/backup_providers.dart';
import '../providers/backup/backup_state.dart';
import '../extensions/string_extensions.dart';
import '../widgets/backup_configuration_sheet.dart';

/// BackupSettingsPage migrated to Riverpod architecture
/// Replaces BLoC pattern with modern StateNotifier approach
class BackupSettingsPage extends ConsumerWidget {
  const BackupSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('backup.title'.tr()), elevation: 0),
      body: Consumer(
        builder: (context, ref, child) {
          // Listen to backup state changes
          ref.listen<BackupRiverpodState>(backupProvider, (previous, next) {
            // Handle state-based UI feedback
            next.when(
              initial: () {},
              loading: () {},
              loaded: (_) {},
              creating: () {},
              created: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('backup.backup_created'.tr()),
                    backgroundColor: colorScheme.primary,
                  ),
                );
              },
              restoring: () {},
              restored: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('backup.backup_restored'.tr()),
                    backgroundColor: colorScheme.primary,
                  ),
                );
              },
              settingsUpdated: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('backup.settings_updated'.tr()),
                    backgroundColor: colorScheme.secondary,
                  ),
                );
              },
              success: (title, message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              error: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            );
          });

          final backupState = ref.watch(backupProvider);

          return backupState.when(
            initial: () => const _InitialView(),
            loading: () => const _LoadingView(),
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
            ) =>
                _LoadedView(
              state: backupState as BackupRiverpodStateLoaded,
            ),
            creating: () => const _CreatingBackupView(),
            created: (_) => const _LoadingView(), // Will transition back
            restoring: () => const _RestoringBackupView(),
            restored: () => const _LoadingView(), // Will transition back
            settingsUpdated: () => const _LoadingView(), // Will transition back
            success: (title, message) => _SuccessView(title: title, message: message),
            error: (message) => _ErrorView(message: message),
          );
        },
      ),
    );
  }
}

class _InitialView extends StatelessWidget {
  const _InitialView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading backup settings...'),
        ],
      ),
    );
  }
}

class _CreatingBackupView extends StatelessWidget {
  const _CreatingBackupView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('backup.creating_backup'.tr()),
        ],
      ),
    );
  }
}

class _RestoringBackupView extends StatelessWidget {
  const _RestoringBackupView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('backup.restoring_backup'.tr()),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String title;
  final String message;

  const _SuccessView({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
    );
  }
}

class _ErrorView extends ConsumerWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('backup.error'.tr()),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(backupProvider.notifier).loadBackupSettings();
            },
            child: Text('backup.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _LoadedView extends ConsumerWidget {
  final BackupRiverpodStateLoaded state;

  const _LoadedView({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Authentication section
        Card(
          child: ListTile(
            leading: Icon(
              state.isAuthenticated ? Icons.cloud_done : Icons.cloud_off,
              color: state.isAuthenticated ? Colors.green : Colors.grey,
            ),
            title: Text(state.isAuthenticated 
                ? 'backup.signed_in'.tr() 
                : 'backup.sign_in_required'.tr()),
            subtitle: state.userEmail != null 
                ? Text(state.userEmail!) 
                : Text('backup.sign_in_to_google_drive'.tr()),
            trailing: TextButton(
              onPressed: () {
                if (state.isAuthenticated) {
                  ref.read(backupProvider.notifier).signOutFromGoogleDrive();
                } else {
                  ref.read(backupProvider.notifier).signInToGoogleDrive();
                }
              },
              child: Text(state.isAuthenticated 
                  ? 'backup.sign_out'.tr() 
                  : 'backup.sign_in'.tr()),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Auto backup toggle
        Card(
          child: SwitchListTile(
            title: Text('backup.auto_backup'.tr()),
            subtitle: Text('backup.auto_backup_description'.tr()),
            value: state.autoBackupEnabled,
            onChanged: state.isAuthenticated
                ? (value) {
                    ref.read(backupProvider.notifier).toggleAutoBackup(value);
                  }
                : null,
          ),
        ),

        // Backup frequency
        if (state.autoBackupEnabled)
          Card(
            child: ListTile(
              title: Text('backup.frequency'.tr()),
              subtitle: Text('backup.current_frequency'.tr(args: [state.backupFrequency])),
              trailing: DropdownButton<String>(
                value: state.backupFrequency,
                items: [
                  DropdownMenuItem(value: 'daily', child: Text('backup.daily'.tr())),
                  DropdownMenuItem(value: 'weekly', child: Text('backup.weekly'.tr())),
                  DropdownMenuItem(value: 'monthly', child: Text('backup.monthly'.tr())),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(backupProvider.notifier).changeBackupFrequency(value);
                  }
                },
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Manual backup options
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.backup),
                title: Text('backup.create_manual_backup'.tr()),
                subtitle: state.lastBackupTime != null
                    ? Text('backup.last_backup'.tr(args: [
                        state.lastBackupTime.toString(),
                      ]))
                    : Text('backup.no_backup_yet'.tr()),
                trailing: ElevatedButton(
                  onPressed: state.isAuthenticated
                      ? () {
                          ref.read(backupProvider.notifier).createManualBackup();
                        }
                      : null,
                  child: Text('backup.create_backup'.tr()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: Text('backup.restore_backup'.tr()),
                subtitle: Text('backup.restore_description'.tr()),
                trailing: ElevatedButton(
                  onPressed: state.isAuthenticated
                      ? () {
                          ref.read(backupProvider.notifier).restoreFromBackup();
                        }
                      : null,
                  child: Text('backup.restore'.tr()),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Advanced settings
        Card(
          child: ExpansionTile(
            title: Text('backup.advanced_settings'.tr()),
            children: [
              SwitchListTile(
                title: Text('backup.wifi_only'.tr()),
                subtitle: Text('backup.wifi_only_description'.tr()),
                value: state.wifiOnlyEnabled,
                onChanged: (value) {
                  ref.read(backupProvider.notifier).toggleWifiOnly(value);
                },
              ),
              SwitchListTile(
                title: Text('backup.compression'.tr()),
                subtitle: Text('backup.compression_description'.tr()),
                value: state.compressionEnabled,
                onChanged: (value) {
                  ref.read(backupProvider.notifier).toggleCompression(value);
                },
              ),
              ListTile(
                title: Text('backup.backup_options'.tr()),
                subtitle: Text('backup.backup_options_description'.tr()),
                trailing: const Icon(Icons.settings),
                onTap: () {
                  BackupConfigurationSheet.show(context, state);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Storage info
        if (state.storageInfo.isNotEmpty)
          Card(
            child: ListTile(
              title: Text('backup.storage_info'.tr()),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('backup.estimated_size'.tr(args: [
                    '${(state.estimatedSize / 1024).toStringAsFixed(1)} KB'
                  ])),
                  // Add more storage info display as needed
                ],
              ),
            ),
          ),
      ],
    );
  }
}
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
          } else if (state is BackupSuccess) {
            debugPrint('✅ [DEBUG] BackupSuccess recibido');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.title.tr(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(state.message.tr()),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
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
                        context.read<BackupBloc>().add(
                              const LoadBackupSettings(),
                            );
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
          const SizedBox(height: 8),

          // Progressive content based on state
          if (!state.isAuthenticated) ...[
            // State 1: Not connected - Only connection card
            _buildConnectionPrompt(context),
          ] else if (state.isAuthenticated && !hasConnectedBefore) ...[
            // State 2: Just connected - Show success and initial setup
            _buildJustConnectedState(context),
          ] else if (state.isAuthenticated && state.autoBackupEnabled) ...[
            // State 3: Auto backup is ON - Show protection title + simplified card
            const SizedBox(height: 8),
            _buildProtectionTitle(context),
            const SizedBox(height: 12),
            _buildAutoBackupActiveState(context),
          ] else if (state.isAuthenticated && !state.autoBackupEnabled) ...[
            // State 4: Auto backup is OFF - Show manual backup option
            const SizedBox(height: 8),
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
        // Mantener el título a la izquierda
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            // Asegurar que el Row esté a la izquierda
            children: [
              Icon(Icons.shield_outlined, color: colorScheme.primary, size: 28),
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
          Align(
            // Envuelve el subtítulo en un widget Align
            alignment: Alignment.center,
            child: Text(
              'backup.description_text'.tr(),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center, // Centrar el texto
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
                  label: Text('backup.google_drive_connection'.tr()),
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
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
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
                    Icon(Icons.autorenew, color: colorScheme.primary),
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
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Activate automatic backup with all defaults
                      context.read<BackupBloc>().add(
                            const ToggleAutoBackup(true),
                          );
                      context.read<BackupBloc>().add(
                            const ToggleWifiOnly(true),
                          );
                      context.read<BackupBloc>().add(
                            const ToggleCompression(true),
                          );
                    },
                    child: Text('backup.activate_automatic'.tr()),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // CAMBIADO: En lugar de ir a manual, hacer logout
                    _showLogoutConfirmation(context);
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
          const Icon(Icons.security, color: Colors.green, size: 20),
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
            // Header row with title and 3 dots
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
                    ],
                  ),
                ),
                // 🔧 CAMBIADO: Switch con confirmación de logout
                Switch(
                  value: state.autoBackupEnabled,
                  onChanged: (value) {
                    if (value) {
                      // Si está activando, simplemente activar
                      context.read<BackupBloc>().add(ToggleAutoBackup(true));
                    } else {
                      // Si está desactivando, mostrar confirmación de logout
                      _showLogoutConfirmation(context);
                    }
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () =>
                      BackupConfigurationSheet.show(context, state),
                  icon: Icon(Icons.more_vert, color: colorScheme.primary),
                  tooltip: 'backup.more_options'.tr(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            //Google drive signing
            Row(
              children: [
                Icon(
                  Icons.cloud_done,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'backup.connected_to_google_drive'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // User email
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
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
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
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
                  Icon(
                    Icons.schedule_send,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
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
            ],
          ],
        ),
      ),
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

                // Google Drive connection status (ARRIBA del email)
                Row(
                  children: [
                    Icon(
                      Icons.cloud_done,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'backup.connected_to_google_drive'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // User email (ABAJO del Google Drive)
                if (state.userEmail != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${'backup.backup_email'.tr()}: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          state.userEmail!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<BackupBloc>().add(
                            const CreateManualBackup(),
                          );
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
                    context.read<BackupBloc>().add(
                          const ToggleAutoBackup(true),
                        );
                  },
                  child: Text('backup.enable_auto_backup'.tr()),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Last backup info if available
        if (state.lastBackupTime != null) ...[
          Card(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
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

  // 🔧 ELIMINADO: _buildManualBackupState - Ya no se usa

  // 🔧 NUEVO: Metodo de confirmación de logout
  void _showLogoutConfirmation(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('backup.backup_logout_confirmation_title'.tr()),
          content: Text('backup.backup_logout_confirmation_message'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'backup.backup_cancel'.tr(),
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                // Hacer logout y desconectar todo
                context.read<BackupBloc>().add(const SignOutFromGoogleDrive());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: Text('backup.backup_confirm'.tr()),
            ),
          ],
        );
      },
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
          Icon(Icons.security, color: colorScheme.primary, size: 20),
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

  String _formatLastBackupTime(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return 'backup.today'.tr();
    } else if (difference.inDays == 1) {
      return 'backup.yesterday'.tr();
    } else {
      return 'backup.days_ago'.tr().replaceAll(
            '{days}',
            difference.inDays.toString(),
          );
    }
  }

  String _formatNextBackupTime(BuildContext context, DateTime time) {
    // Startup backup approach - always shows "today"
    return 'backup.today_on_app_start'.tr(); // "hoy al abrir la app"
  }
}
