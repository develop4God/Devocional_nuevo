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

    // Watch backup options provider for real-time updates
    final backupOptions = ref.watch(backupOptionsProvider);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'backup.configuration_title'.tr(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Configuration options
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'backup.select_data_to_backup'.tr(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Backup options
                      ...backupOptions.entries.map((entry) {
                        final key = entry.key;
                        final value = entry.value;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: CheckboxListTile(
                            title: Text(_getBackupOptionTitle(key)),
                            subtitle: Text(_getBackupOptionSubtitle(key)),
                            value: value,
                            onChanged: (bool? newValue) {
                              if (newValue != null) {
                                final updatedOptions = Map<String, bool>.from(backupOptions);
                                updatedOptions[key] = newValue;
                                ref.read(backupProvider.notifier).updateBackupOptions(updatedOptions);
                              }
                            },
                            activeColor: colorScheme.primary,
                            checkColor: colorScheme.onPrimary,
                            controlAffinity: ListTileControlAffinity.trailing,
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 20),

                      // Estimated backup size
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'backup.estimated_size'.tr(),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final estimatedSize = ref.watch(estimatedBackupSizeProvider);
                                      return Text(
                                        _formatFileSize(estimatedSize),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('backup.cancel'.tr()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Options are saved automatically via state management
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('backup.save'.tr()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getBackupOptionTitle(String key) {
    switch (key) {
      case 'devotionals':
        return 'backup.option_devotionals'.tr();
      case 'prayers':
        return 'backup.option_prayers'.tr();
      case 'settings':
        return 'backup.option_settings'.tr();
      case 'favorites':
        return 'backup.option_favorites'.tr();
      default:
        return key;
    }
  }

  String _getBackupOptionSubtitle(String key) {
    switch (key) {
      case 'devotionals':
        return 'backup.option_devotionals_desc'.tr();
      case 'prayers':
        return 'backup.option_prayers_desc'.tr();
      case 'settings':
        return 'backup.option_settings_desc'.tr();
      case 'favorites':
        return 'backup.option_favorites_desc'.tr();
      default:
        return '';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
              ),
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
                  // Handle compacto
                  Container(
                    width: 32,
                    height: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header compacto
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
                    child: Row(
                      children: [
                        Icon(Icons.tune, color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'backup.configuration'.tr(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(32, 32),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contenido principal
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🆕 PUNTO #4A: REMOVIDO - Era sección redundante de backup automático

                          // 🆕 PUNTO #8: Opciones de optimización con consistencia visual
                          _buildOptimizationSection(context, displayState),

                          const SizedBox(height: 20),

                          // 🆕 PUNTO #5: Nueva sección de gestión de cuenta
                          _buildAccountSection(context),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🆕 PUNTO #8: Sección de optimización con consistencia visual del drawer
  Widget _buildOptimizationSection(
    BuildContext context,
    BackupLoaded displayState,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🆕 PUNTO #8: Header consistent con drawer
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            'Optimización',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 🆕 PUNTO #4B + #8: Switches nativos consistent con drawer
        _buildDrawerStyleToggle(
          context,
          icon: Icons.wifi,
          labelKey: 'backup.wifi_only',
          subtitleKey: 'backup.wifi_only_subtitle',
          value: displayState.wifiOnlyEnabled,
          onChanged: (value) => backupBloc.add(ToggleWifiOnly(value)),
        ),

        const SizedBox(height: 5), // 🆕 PUNTO #8: Spacing consistent con drawer

        _buildDrawerStyleToggle(
          context,
          icon: Icons.compress,
          labelKey: 'backup.compress_data',
          subtitleKey: 'backup.compress_data_subtitle',
          value: displayState.compressionEnabled,
          onChanged: (value) => backupBloc.add(ToggleCompression(value)),
        ),
      ],
    );
  }

  // 🆕 PUNTO #5: Nueva sección de gestión de cuenta con logout
  Widget _buildAccountSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            'Gestión de Cuenta',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 🆕 PUNTO #5: Botón de logout con confirmación
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('logout_button'),
            // 🆕 PUNTO #9: Testing key
            onPressed: () => _showLogoutConfirmation(context),
            icon: Icon(Icons.logout, color: colorScheme.error, size: 20),
            label: Text(
              'Cerrar Sesión de Google Drive',
              style: TextStyle(color: colorScheme.error),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // 🆕 PUNTO #8 + #4B: Toggle style consistent con drawer usando switches nativos
  Widget _buildDrawerStyleToggle(
    BuildContext context, {
    required IconData icon,
    required String labelKey,
    required String subtitleKey,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 🆕 PUNTO #8: Helper function exactly like drawerRow in devocionales_page_drawer.dart
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        // 🆕 PUNTO #8: Consistent padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 36, // 🆕 PUNTO #8: Fixed width like drawer
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  // 🆕 PUNTO #8: Same primary color as drawer
                  size: 28, // 🆕 PUNTO #8: Same icon size as drawer
                ),
              ),
            ),
            const SizedBox(width: 12), // 🆕 PUNTO #8: Same spacing as drawer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labelKey.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16, // 🆕 PUNTO #8: Same font size as drawer
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitleKey.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // 🆕 PUNTO #4B + #8: Native switch exactly like drawer
            Semantics(
              // 🆕 PUNTO #9: Accessibility
              label: labelKey.tr(),
              child: Switch(value: value, onChanged: onChanged),
            ),
          ],
        ),
      ),
    );
  }

  // 🆕 PUNTO #5: Confirmación de logout usando claves i18n existentes
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
                Navigator.of(context).pop(); // Close modal
                backupBloc.add(const SignOutFromGoogleDrive());
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
}
