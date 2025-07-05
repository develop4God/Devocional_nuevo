// Script de debug para verificar el estado de las notificaciones
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lib/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  
  print('=== DEBUG NOTIFICACIONES ===');
  
  // Verificar configuración guardada
  final prefs = await SharedPreferences.getInstance();
  final notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
  final notificationTime = prefs.getString('notification_time') ?? '08:00';
  final lastNotificationDate = prefs.getString('last_notification_date') ?? 'nunca';
  
  print('Notificaciones habilitadas: $notificationsEnabled');
  print('Hora configurada: $notificationTime');
  print('Última notificación: $lastNotificationDate');
  print('Fecha actual: ${DateTime.now().toIso8601String().split('T')[0]}');
  
  // Verificar notificaciones pendientes
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  final pendingNotifications = await notificationService.getPendingNotifications();
  print('Notificaciones pendientes: ${pendingNotifications.length}');
  
  for (var notification in pendingNotifications) {
    print('- ID: ${notification.id}, Título: ${notification.title}, Cuerpo: ${notification.body}');
  }
  
  // Verificar timezone actual
  final now = tz.TZDateTime.now(tz.local);
  print('Timezone actual: ${now.location}');
  print('Hora actual con timezone: $now');
  
  // Simular programación de notificación
  final timeParts = notificationTime.split(':');
  final hour = int.parse(timeParts[0]);
  final minute = int.parse(timeParts[1]);
  
  var scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );
  
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  
  print('Próxima notificación programada para: $scheduledDate');
  print('Diferencia con ahora: ${scheduledDate.difference(now)}');
}