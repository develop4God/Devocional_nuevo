// lib/pages/notification_permission_page.dart

import 'package:devocional_nuevo/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/notification_service.dart';

class NotificationPermissionPage extends StatefulWidget {
  const NotificationPermissionPage({super.key});

  @override
  State<NotificationPermissionPage> createState() =>
      _NotificationPermissionPageState();
}

class _NotificationPermissionPageState
    extends State<NotificationPermissionPage> {
  bool _isLoading = false;
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notifications.permission_title'.tr(),
            style: const TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_active,
              size: 80,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 24),
            Text(
              'notifications.permission_headline'.tr(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'notifications.permission_description'.tr(),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.deepPurple)
                : ElevatedButton(
                    onPressed: _requestPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text('notifications.allow_notifications'.tr()),
                  ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'notifications.not_now'.tr(),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Puedes cambiar esta configuración en cualquier momento desde la pantalla de ajustes.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await Permission.notification.request();

      if (status.isGranted) {
        // Habilitar notificaciones en la app
        await _notificationService.setNotificationsEnabled(true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Notificaciones habilitadas correctamente!'),
              backgroundColor: Colors.green,
            ),
          );

          // Volver a la pantalla anterior con resultado positivo
          Navigator.of(context).pop(true);
        }
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          _showSettingsDialog();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permiso de notificaciones denegado'),
              backgroundColor: Colors.red,
            ),
          );

          // Volver a la pantalla anterior con resultado negativo
          Navigator.of(context).pop(false);
        }
      }
    } catch (e) {
      debugPrint('Error al solicitar permisos: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('notifications.permissions_required'.tr()),
        content: Text(
          'notifications.permissions_disabled_message'.tr(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: Text('notifications.open_settings'.tr()),
          ),
        ],
      ),
    );
  }
}
