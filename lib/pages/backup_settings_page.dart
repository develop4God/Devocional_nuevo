import 'package:devocional_nuevo/extensions/string_extensions.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/services/google_drive_backup_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BackupSettingsPage extends StatefulWidget {
  const BackupSettingsPage({super.key});

  @override
  State<BackupSettingsPage> createState() => _BackupSettingsPageState();
}

class _BackupSettingsPageState extends State<BackupSettingsPage> {
  final GoogleDriveBackupService _backupService = GoogleDriveBackupService();
  
  bool _isSignedIn = false;
  bool _isLoading = false;
  bool _isCreatingBackup = false;
  String? _userEmail;
  
  // Backup options
  bool _includeStats = true;
  bool _includeFavorites = true;
  bool _includePrayers = true;

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
  }

  Future<void> _checkSignInStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final isSignedIn = await _backupService.isSignedIn();
      final user = await _backupService.getCurrentUser();
      
      setState(() {
        _isSignedIn = isSignedIn;
        _userEmail = user?.email;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackBar('settings.backup_drive_error'.tr());
      }
    }
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    
    try {
      final account = await _backupService.signIn();
      if (account != null) {
        setState(() {
          _isSignedIn = true;
          _userEmail = account.email;
        });
        _showSuccessSnackBar('settings.backup_connected'.tr());
      }
    } catch (e) {
      _showErrorSnackBar('settings.backup_drive_error'.tr());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    
    try {
      await _backupService.signOut();
      setState(() {
        _isSignedIn = false;
        _userEmail = null;
      });
    } catch (e) {
      _showErrorSnackBar('settings.backup_drive_error'.tr());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createBackup() async {
    if (!_isSignedIn) {
      _showErrorSnackBar('settings.backup_login_required'.tr());
      return;
    }

    if (!_includeStats && !_includeFavorites && !_includePrayers) {
      _showErrorSnackBar('Selecciona al menos una opción para respaldar');
      return;
    }

    setState(() => _isCreatingBackup = true);

    try {
      final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
      
      final backupId = await _backupService.createBackup(
        includeStats: _includeStats,
        includeFavorites: _includeFavorites,
        includePrayers: _includePrayers,
        devocionalProvider: devocionalProvider,
      );

      debugPrint('Backup created with ID: $backupId');
      _showSuccessSnackBar('settings.backup_success'.tr());
    } catch (e) {
      _showErrorSnackBar('settings.backup_error'.tr({'error': e.toString()}));
    } finally {
      setState(() => _isCreatingBackup = false);
    }
  }

  void _toggleSelectAll() {
    final allSelected = _includeStats && _includeFavorites && _includePrayers;
    setState(() {
      _includeStats = !allSelected;
      _includeFavorites = !allSelected;
      _includePrayers = !allSelected;
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings.backup_title'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'settings.backup_title'.tr(),
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'settings.backup_description'.tr(),
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // Google Drive connection section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isSignedIn ? Icons.cloud_done : Icons.cloud_off,
                                color: _isSignedIn ? Colors.green : Colors.grey,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Google Drive',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          
                          if (_isSignedIn && _userEmail != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'settings.backup_connected'.tr(),
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              _userEmail!,
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 8),
                            Text(
                              'settings.backup_login_required'.tr(),
                              style: textTheme.bodySmall,
                            ),
                          ],
                          
                          const SizedBox(height: 12),
                          
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSignedIn ? _signOut : _signIn,
                              icon: Icon(_isSignedIn ? Icons.logout : Icons.login),
                              label: Text(
                                _isSignedIn 
                                    ? 'settings.backup_logout_button'.tr()
                                    : 'settings.backup_login_button'.tr(),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isSignedIn 
                                    ? colorScheme.error 
                                    : colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Backup options section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'settings.backup_options'.tr(),
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: _toggleSelectAll,
                                child: Text('settings.backup_select_all'.tr()),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          CheckboxListTile(
                            title: Text('settings.backup_stats'.tr()),
                            subtitle: const Text('Incluye progreso de lectura, logros y estadísticas'),
                            value: _includeStats,
                            onChanged: (value) {
                              setState(() => _includeStats = value ?? false);
                            },
                            secondary: const Icon(Icons.analytics),
                          ),
                          
                          CheckboxListTile(
                            title: Text('settings.backup_favorites'.tr()),
                            subtitle: const Text('Incluye todos tus devocionales favoritos guardados'),
                            value: _includeFavorites,
                            onChanged: (value) {
                              setState(() => _includeFavorites = value ?? false);
                            },
                            secondary: const Icon(Icons.favorite),
                          ),
                          
                          CheckboxListTile(
                            title: Text('settings.backup_prayers'.tr()),
                            subtitle: const Text('Incluye oraciones personales guardadas'),
                            value: _includePrayers,
                            onChanged: (value) {
                              setState(() => _includePrayers = value ?? false);
                            },
                            secondary: const Icon(Icons.church),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Create backup button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isCreatingBackup ? null : _createBackup,
                      icon: _isCreatingBackup 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.backup),
                      label: Text(
                        _isCreatingBackup 
                            ? 'settings.backup_progress'.tr()
                            : 'settings.backup_create'.tr(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Information card
                  Card(
                    color: colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Los respaldos se almacenan de forma segura en tu Google Drive personal. Solo tú tienes acceso a estos archivos.',
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}