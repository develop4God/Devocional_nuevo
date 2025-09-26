import 'dart:async';

import 'package:devocional_nuevo/extensions/string_extensions.dart';
import 'package:devocional_nuevo/providers/backup/backup_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingBackupConfigurationPage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const OnboardingBackupConfigurationPage({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  ConsumerState<OnboardingBackupConfigurationPage> createState() =>
      _OnboardingBackupConfigurationPageState();
}

class _OnboardingBackupConfigurationPageState
    extends ConsumerState<OnboardingBackupConfigurationPage> {
  bool _isConnecting = false;
  bool _isNavigating = false;
  Timer? _timeoutTimer;

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Load backup settings when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load initial backup settings
      ref.read(backupProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: widget.onBack,
                      child: Text('onboarding.onboarding_back'.tr()),
                    ),
                    TextButton(
                      onPressed: widget.onSkip,
                      child: Text('onboarding.onboarding_config_later'.tr()),
                    ),
                  ],
                ),
              ),
              // Main content
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final backupState = ref.watch(backupProvider);

                    // Listen for state changes
                    ref.listen<BackupRiverpodState>(backupProvider,
                        (previous, next) {
                      next.whenOrNull(
                        error: (message) {
                          debugPrint('🚨 [DEBUG] Error en backup: $message');
                          _showError(context, message);
                          _clearConnectingState();
                        },
                        created: (timestamp) {
                          debugPrint('✅ [DEBUG] Backup creado exitosamente');
                          _showSnackbar(context, 'backup_completed'.tr(),
                              isSuccess: true);
                        },
                        restored: () {
                          debugPrint(
                              '✅ [DEBUG] Backup restaurado exitosamente');
                          _showSnackbar(context, 'backup_restored'.tr(),
                              isSuccess: true);
                        },
                        loaded: (autoBackupEnabled,
                            backupFrequency,
                            wifiOnlyEnabled,
                            compressionEnabled,
                            backupOptions,
                            lastBackupTime,
                            nextBackupTime,
                            estimatedSize,
                            storageInfo,
                            isAuthenticated,
                            userEmail) {
                          debugPrint('✅ [DEBUG] Backup settings loaded');
                          _clearConnectingState();
                          _checkAndCreateInitialBackup(
                              context, isAuthenticated);
                        },
                      );
                    });

                    return backupState.when(
                      initial: () => _buildInitialContent(context),
                      loading: () => _buildLoadingContent(context),
                      loaded: (autoBackupEnabled,
                              backupFrequency,
                              wifiOnlyEnabled,
                              compressionEnabled,
                              backupOptions,
                              lastBackupTime,
                              nextBackupTime,
                              estimatedSize,
                              storageInfo,
                              isAuthenticated,
                              userEmail) =>
                          _buildLoadedContent(context, isAuthenticated),
                      creating: () => _buildCreatingContent(context),
                      created: (timestamp) =>
                          _buildLoadedContent(context, true),
                      restoring: () => _buildRestoringContent(context),
                      restored: () => _buildLoadedContent(context, true),
                      settingsUpdated: () => _buildLoadedContent(
                          context, ref.read(isAuthenticatedProvider)),
                      success: (title, message) => _buildLoadedContent(
                          context, ref.read(isAuthenticatedProvider)),
                      error: (message) => _buildErrorContent(context, message),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialContent(BuildContext context) {
    return _buildContent(context, isLoading: true);
  }

  Widget _buildLoadingContent(BuildContext context) {
    return _buildContent(context, isLoading: true);
  }

  Widget _buildLoadedContent(BuildContext context, bool isAuthenticated) {
    return _buildContent(context, isAuthenticated: isAuthenticated);
  }

  Widget _buildErrorContent(BuildContext context, String message) {
    return _buildContent(context, error: message);
  }

  Widget _buildCreatingContent(BuildContext context) {
    return _buildContent(context, isCreatingBackup: true);
  }

  Widget _buildRestoringContent(BuildContext context) {
    return _buildContent(context, isRestoring: true);
  }

  Widget _buildSigningInContent(BuildContext context) {
    return _buildContent(context, isLoading: true);
  }

  Widget _buildContent(
    BuildContext context, {
    bool isLoading = false,
    bool isAuthenticated = false,
    bool isCreatingBackup = false,
    bool isRestoring = false,
    String? error,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          // Title and subtitle section
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'onboarding.onboarding_backup_config_title'.tr(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'onboarding.onboarding_backup_config_subtitle'.tr(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Content based on state
          Expanded(
            flex: 3,
            child: _buildStateContent(
              context,
              isLoading: isLoading,
              isAuthenticated: isAuthenticated,
              isCreatingBackup: isCreatingBackup,
              isRestoring: isRestoring,
              error: error,
            ),
          ),

          // Action buttons
          _buildActionButtons(context, isAuthenticated: isAuthenticated),
        ],
      ),
    );
  }

  Widget _buildStateContent(
    BuildContext context, {
    required bool isLoading,
    required bool isAuthenticated,
    required bool isCreatingBackup,
    required bool isRestoring,
    String? error,
  }) {
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (isLoading || isCreatingBackup || isRestoring) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
          ],
        ),
      );
    }

    if (isAuthenticated) {
      return _buildAuthenticatedContent(context);
    }

    return _buildNotAuthenticatedContent(context);
  }

  Widget _buildNotAuthenticatedContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed:
                _isConnecting ? null : () => _connectGoogleDrive(context),
            icon: _isConnecting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud),
            label: Text(
              _isConnecting
                  ? 'backup.connecting'.tr()
                  : 'backup.sign_in_to_google_drive'.tr(),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedContent(BuildContext context) {
    final userEmail = ref.watch(userEmailProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_done_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'backup.connected_as'.tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            userEmail ?? 'N/A',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _autoConfigureBackup(context),
            child: Text('backup.auto_configure'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context,
      {required bool isAuthenticated}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAuthenticated)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!_isNavigating) {
                    setState(() {
                      _isNavigating = true;
                    });
                    widget.onNext();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('onboarding.continue'.tr()),
              ),
            ),
        ],
      ),
    );
  }

  void _connectGoogleDrive(BuildContext context) {
    debugPrint('🔄 [DEBUG] Onboarding Usuario tapeó conectar Google Drive');
    setState(() {
      _isConnecting = true;
    });

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (_isConnecting && mounted) {
        _clearConnectingState();
        _showError(context, 'backup.connection_timeout'.tr());
      }
    });

    debugPrint('🔄 [DEBUG] Onboarding Enviando signInToGoogleDrive');
    ref.read(backupProvider.notifier).signInToGoogleDrive();
  }

  void _autoConfigureBackup(BuildContext context) {
    debugPrint(
        '⚙️ [DEBUG] Onboarding Auto-configurando backup con configuración óptima');

    // Activate automatic backup with all defaults - same as BackupSettingsPage
    ref.read(backupProvider.notifier).toggleAutoBackup(true);
    ref.read(backupProvider.notifier).toggleWifiOnly(true);
    ref.read(backupProvider.notifier).toggleCompression(true);

    debugPrint('✅ [DEBUG] Onboarding Auto-configuración enviada');
  }

  void _checkAndCreateInitialBackup(
      BuildContext context, bool isAuthenticated) {
    if (!isAuthenticated) return;

    // Check if this is first time connecting (same logic as BackupSettingsPage)
    final hasConnectedBefore = ref.read(lastBackupTimeProvider) != null ||
        ref.read(autoBackupEnabledProvider);

    debugPrint('🔍 [DEBUG] hasConnectedBefore: $hasConnectedBefore');
    debugPrint(
        '🔍 [DEBUG] lastBackupTime: ${ref.read(lastBackupTimeProvider)}');
    debugPrint(
        '🔍 [DEBUG] autoBackupEnabled: ${ref.read(autoBackupEnabledProvider)}');

    if (!hasConnectedBefore) {
      debugPrint('🆕 [DEBUG] Usuario nuevo detectado - creando primer backup');
      // Create initial backup for new users
      ref.read(backupProvider.notifier).createManualBackup();
    } else {
      debugPrint('✅ [DEBUG] Usuario existente - no necesita backup inicial');
    }
  }

  void _clearConnectingState() {
    _timeoutTimer?.cancel();
    if (mounted) {
      setState(() {
        _isConnecting = false;
        _isNavigating = false;
      });
      debugPrint('🔄 [DEBUG] Estado de connecting limpiado en onboarding');
    }
  }

  void _showError(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.tr()),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showSnackbar(BuildContext context, String message,
      {bool isSuccess = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
