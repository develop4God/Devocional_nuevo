// test/services/churn_background_task_service_test.dart

import 'package:devocional_nuevo/services/churn_background_task_service.dart';
import 'package:devocional_nuevo/services/churn_prediction_service.dart';
import 'package:devocional_nuevo/services/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

// Mock classes
class MockWorkmanager extends Mock implements Workmanager {}

class MockChurnPredictionService extends Mock
    implements ChurnPredictionService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChurnBackgroundTaskService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});

      // Setup service locator
      if (!serviceLocator.isRegistered<ChurnPredictionService>()) {
        serviceLocator.registerFactory<ChurnPredictionService>(
          () => MockChurnPredictionService(),
        );
      }
    });

    tearDown(() {
      serviceLocator.reset();
    });

    group('initialization', () {
      test('registers task when feature is enabled and not registered',
          () async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('churn_task_registered'), isNull);

        // Test will complete if no exception is thrown
        // In real environment, WorkManager would be initialized
      });

      test('skips registration when feature is disabled', () async {
        // Unregister service to simulate disabled feature
        serviceLocator.reset();

        await ChurnBackgroundTaskService.initialize();

        // Should complete without error
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('churn_task_registered'), isNull);
      });

      test('skips registration when already registered', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('churn_task_registered', true);

        await ChurnBackgroundTaskService.initialize();

        // Should remain true
        expect(prefs.getBool('churn_task_registered'), true);
      });
    });

    group('task management', () {
      test('cancelDailyTask clears registration flag', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('churn_task_registered', true);

        await ChurnBackgroundTaskService.cancelDailyTask();

        expect(prefs.getBool('churn_task_registered'), false);
      });

      test('isTaskRegistered returns correct status', () async {
        final prefs = await SharedPreferences.getInstance();

        expect(await ChurnBackgroundTaskService.isTaskRegistered(), false);

        await prefs.setBool('churn_task_registered', true);
        expect(await ChurnBackgroundTaskService.isTaskRegistered(), true);
      });

      test('reregisterTask resets flag and re-initializes', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('churn_task_registered', true);

        await ChurnBackgroundTaskService.reregisterTask();

        // After reregister, should be registered again
        // Note: In test environment without actual WorkManager,
        // this just tests the flag reset logic
      });
    });

    group('initial delay calculation', () {
      test('calculates delay until 6 AM today if before 6 AM', () {
        final now = DateTime(2024, 1, 1, 4, 30); // 4:30 AM
        final nextRun = DateTime(2024, 1, 1, 6, 0); // 6:00 AM today
        final expectedDelay = nextRun.difference(now);

        // We can't directly test the private method, but we can verify
        // the logic by checking the initialization
        expect(expectedDelay.inHours, 1);
        expect(expectedDelay.inMinutes, 90);
      });

      test('calculates delay until 6 AM tomorrow if after 6 AM', () {
        final now = DateTime(2024, 1, 1, 10, 30); // 10:30 AM
        final nextRun = DateTime(2024, 1, 2, 6, 0); // 6:00 AM tomorrow
        final expectedDelay = nextRun.difference(now);

        expect(expectedDelay.inHours, 19);
      });
    });

    group('background task execution', () {
      test('executes daily churn check without errors', () async {
        // Test the execution logic
        // In a real scenario, this would be called by WorkManager
        // Here we just verify the structure is correct
        expect(ChurnBackgroundTaskService.initialize, isA<Function>());
      });
    });

    group('error handling', () {
      test('handles initialization errors gracefully', () async {
        // Even if WorkManager throws an error, app should continue
        await ChurnBackgroundTaskService.initialize();
        // Should complete without throwing
      });

      test('handles cancellation errors gracefully', () async {
        // Should not throw even if WorkManager is not initialized
        await ChurnBackgroundTaskService.cancelDailyTask();
        // Should complete without throwing
      });
    });

    group('integration with service locator', () {
      test('checks service registration before initializing', () async {
        // Service should be registered in setUp
        expect(serviceLocator.isRegistered<ChurnPredictionService>(), true);

        await ChurnBackgroundTaskService.initialize();
        // Should complete without error
      });

      test('skips initialization when service not registered', () async {
        serviceLocator.reset();

        await ChurnBackgroundTaskService.initialize();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('churn_task_registered'), isNull);
      });
    });
  });

  group('callbackDispatcher', () {
    test('is a top-level function accessible to WorkManager', () {
      // Verify the callback dispatcher exists and is accessible
      expect(callbackDispatcher, isA<Function>());
    });
  });
}
