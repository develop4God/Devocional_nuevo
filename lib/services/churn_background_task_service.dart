// lib/services/churn_background_task_service.dart

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../services/churn_prediction_service.dart';
import '../services/service_locator.dart';
import '../utils/churn_monitoring_helper.dart';
import '../utils/time_provider.dart';

/// Background task service for proactive churn detection
///
/// Migrated from habitus_faith architecture for true background execution.
/// Runs daily at 6:00 AM without requiring the app to be opened.
class ChurnBackgroundTaskService {
  static const String _dailyChurnCheckTask = 'churn_daily_check';
  static const String _prefKeyTaskRegistered = 'churn_task_registered';

  /// Initialize WorkManager and register the daily churn check task
  /// Should be called once during app initialization
  static Future<void> initialize() async {
    try {
      developer.log(
        'Initializing ChurnBackgroundTaskService',
        name: 'ChurnBackgroundTask',
      );

      // Check if feature is enabled via feature flag
      if (!serviceLocator.isRegistered<ChurnPredictionService>()) {
        developer.log(
          'Churn prediction feature disabled - skipping background task registration',
          name: 'ChurnBackgroundTask',
        );
        return;
      }

      // Check if task is already registered (avoid re-registration)
      final prefs = await SharedPreferences.getInstance();
      final isRegistered = prefs.getBool(_prefKeyTaskRegistered) ?? false;

      if (isRegistered) {
        developer.log(
          'Daily churn check task already registered',
          name: 'ChurnBackgroundTask',
        );
        return;
      }

      // Initialize WorkManager
      await Workmanager().initialize(
        callbackDispatcher,
      );

      // Register periodic task (runs daily at approximately 6:00 AM)
      await Workmanager().registerPeriodicTask(
        _dailyChurnCheckTask,
        _dailyChurnCheckTask,
        frequency: const Duration(hours: 24),
        initialDelay: _calculateInitialDelay(),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 15),
        existingWorkPolicy: ExistingWorkPolicy.keep,
      );

      // Mark task as registered
      await prefs.setBool(_prefKeyTaskRegistered, true);

      developer.log(
        'Daily churn check task registered successfully. Next run in ${_calculateInitialDelay().inHours}h ${_calculateInitialDelay().inMinutes % 60}m',
        name: 'ChurnBackgroundTask',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error initializing background task: $e',
        name: 'ChurnBackgroundTask',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculate delay until next 6:00 AM
  static Duration _calculateInitialDelay() {
    final now = _timeProvider.now();
    var nextRun = DateTime(now.year, now.month, now.day, 6, 0);

    // Si ya pasó las 6 AM, programa para el siguiente día
    if (now.isAfter(nextRun)) {
      nextRun = nextRun.add(const Duration(days: 1));
      developer.log(
        '🌅 [BG] Cambio de día detectado, próxima ejecución: $nextRun',
        name: 'ChurnBackgroundTask',
      );
      debugPrint(
          '🌅 [BG] Cambio de día detectado, próxima ejecución: $nextRun');
    } else {
      developer.log(
        '⏰ [BG] Próxima ejecución hoy a las 6:00 AM: $nextRun',
        name: 'ChurnBackgroundTask',
      );
      debugPrint('⏰ [BG] Próxima ejecución hoy a las 6:00 AM: $nextRun');
    }

    final delay = nextRun.difference(now);
    developer.log(
      '🕒 [BG] Delay calculado: ${delay.inHours}h ${delay.inMinutes % 60}m',
      name: 'ChurnBackgroundTask',
    );
    debugPrint(
        '🕒 [BG] Delay calculado: ${delay.inHours}h ${delay.inMinutes % 60}m');

    return delay;
  }

  /// Cancel the daily churn check task (for testing or user opt-out)
  static Future<void> cancelDailyTask() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await Workmanager().cancelByUniqueName(_dailyChurnCheckTask);
      await prefs.setBool(_prefKeyTaskRegistered, false);
      developer.log(
        'Daily churn check task cancelled',
        name: 'ChurnBackgroundTask',
      );
    } catch (e) {
      // Even if WorkManager throws, clear the registration flag
      await prefs.setBool(_prefKeyTaskRegistered, false);
      developer.log(
        'Error cancelling background task: $e (flag cleared anyway)',
        name: 'ChurnBackgroundTask',
        error: e,
      );
    }
  }

  /// Check if the daily task is registered
  static Future<bool> isTaskRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyTaskRegistered) ?? false;
  }

  /// Force re-register the task (useful after app updates)
  static Future<void> reregisterTask() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyTaskRegistered, false);
    await initialize();
  }
}

/// WorkManager callback dispatcher
/// This runs in a separate isolate and must be a top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  debugPrint('🚦 [BG] callbackDispatcher iniciado');
  Workmanager().executeTask((task, inputData) async {
    try {
      debugPrint('🚦 [BG] Tarea de background iniciada: $task');
      developer.log(
        '🚦 [BG] Tarea de background iniciada: $task',
        name: 'ChurnBackgroundTask',
      );
      switch (task) {
        case 'churn_daily_check':
          debugPrint('🔔 [BG] Ejecutando daily churn check');
          await _executeDailyChurnCheck();
          break;
        default:
          debugPrint('❓ [BG] Tarea desconocida: $task');
          developer.log(
            '❓ [BG] Tarea desconocida: $task',
            name: 'ChurnBackgroundTask',
          );
      }
      debugPrint('✅ [BG] Tarea de background completada: $task');
      developer.log(
        '✅ [BG] Tarea de background completada: $task',
        name: 'ChurnBackgroundTask',
      );
      return Future.value(true);
    } catch (e, stackTrace) {
      debugPrint('❌ [BG] Error en tarea de background: $task - $e');
      developer.log(
        '❌ [BG] Error en tarea de background: $task - $e',
        name: 'ChurnBackgroundTask',
        error: e,
        stackTrace: stackTrace,
      );
      return Future.value(false);
    }
  });
}

/// Execute the daily churn check
/// This runs in the background without the app being opened
Future<void> _executeDailyChurnCheck() async {
  try {
    developer.log(
      'Executing daily churn check from background task',
      name: 'ChurnBackgroundTask',
    );

    // Log de próxima ejecución y delay en cada ejecución diaria
    final delay = ChurnBackgroundTaskService._calculateInitialDelay();
    debugPrint(
        '🌅 [BG] (Ejecución diaria) Próxima ejecución: ${_timeProvider.now().add(delay)}');
    debugPrint(
        '🕒 [BG] (Ejecución diaria) Delay calculado: ${delay.inHours}h ${delay.inMinutes % 60}m');
    developer.log(
        '🌅 [BG] (Ejecución diaria) Próxima ejecución: ${_timeProvider.now().add(delay)}',
        name: 'ChurnBackgroundTask');
    developer.log(
        '🕒 [BG] (Ejecución diaria) Delay calculado: ${delay.inHours}h ${delay.inMinutes % 60}m',
        name: 'ChurnBackgroundTask');

    // Initialize service locator if not already initialized
    if (!serviceLocator.isRegistered<ChurnPredictionService>()) {
      // Service locator needs to be initialized in background isolate
      setupServiceLocator();
    }

    // Perform the daily check
    await ChurnMonitoringHelper.performDailyCheck();

    developer.log(
      'Daily churn check completed from background task',
      name: 'ChurnBackgroundTask',
    );
  } catch (e, stackTrace) {
    developer.log(
      'Error executing daily churn check: $e',
      name: 'ChurnBackgroundTask',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

TimeProvider _timeProvider = SystemTimeProvider();

/// Set a custom time provider
///
/// This can be used for testing or to simulate different time zones, etc.
void setTimeProvider(TimeProvider provider) {
  _timeProvider = provider;
}
