// lib/services/churn_background_task_service.dart

import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../services/churn_prediction_service.dart';
import '../services/service_locator.dart';
import '../utils/churn_monitoring_helper.dart';

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
        isInDebugMode: false, // Set to false in production
      );

      // Register periodic task (runs daily at approximately 6:00 AM)
      await Workmanager().registerPeriodicTask(
        _dailyChurnCheckTask,
        _dailyChurnCheckTask,
        frequency: const Duration(hours: 24),
        initialDelay: _calculateInitialDelay(),
        constraints: Constraints(
          networkType: NetworkType.not_required,
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
    final now = DateTime.now();
    var nextRun = DateTime(now.year, now.month, now.day, 6, 0);

    // If it's past 6 AM today, schedule for 6 AM tomorrow
    if (now.isAfter(nextRun)) {
      nextRun = nextRun.add(const Duration(days: 1));
    }

    final delay = nextRun.difference(now);
    developer.log(
      'Next churn check scheduled for: $nextRun (in ${delay.inHours}h ${delay.inMinutes % 60}m)',
      name: 'ChurnBackgroundTask',
    );

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
  Workmanager().executeTask((task, inputData) async {
    try {
      developer.log(
        'Background task started: $task',
        name: 'ChurnBackgroundTask',
      );

      switch (task) {
        case 'churn_daily_check':
          await _executeDailyChurnCheck();
          break;
        default:
          developer.log(
            'Unknown task: $task',
            name: 'ChurnBackgroundTask',
          );
      }

      developer.log(
        'Background task completed: $task',
        name: 'ChurnBackgroundTask',
      );

      return Future.value(true);
    } catch (e, stackTrace) {
      developer.log(
        'Background task failed: $task - $e',
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
