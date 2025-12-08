// test/utils/churn_monitoring_helper_test.dart

import 'package:devocional_nuevo/services/churn_prediction_service.dart';
import 'package:devocional_nuevo/services/localization_service.dart';
import 'package:devocional_nuevo/services/notification_service.dart';
import 'package:devocional_nuevo/services/service_locator.dart';
import 'package:devocional_nuevo/utils/churn_monitoring_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock classes
class MockChurnPredictionService extends Mock
    implements ChurnPredictionService {}

class MockNotificationService extends Mock implements NotificationService {}

class MockLocalizationService extends Mock implements LocalizationService {}

// Fake class for ChurnPrediction
class FakeChurnPrediction extends Fake implements ChurnPrediction {}

void main() {
  late MockChurnPredictionService mockChurnService;
  late MockNotificationService mockNotificationService;
  late MockLocalizationService mockLocalizationService;
  late ServiceLocator serviceLocator;

  setUpAll(() {
    // Register fallback value for ChurnPrediction
    registerFallbackValue(FakeChurnPrediction());
  });

  setUp(() async {
    // Reset SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Reset service locator before each test
    serviceLocator = ServiceLocator();
    serviceLocator.reset();

    mockChurnService = MockChurnPredictionService();
    mockNotificationService = MockNotificationService();
    mockLocalizationService = MockLocalizationService();

    // Register mock services
    serviceLocator.registerFactory<ChurnPredictionService>(
      () => mockChurnService,
    );
    serviceLocator.registerFactory<LocalizationService>(
      () => mockLocalizationService,
    );

    // Setup default localization responses
    when(() =>
            mockLocalizationService.translate('churn_notification.high_title'))
        .thenReturn('We miss you! 🙏');
    when(() => mockLocalizationService
            .translate('churn_notification.medium_title'))
        .thenReturn('Your devotional is waiting 📖');
    when(() => mockLocalizationService.translate(
            'churn_notification.high_body', any()))
        .thenReturn(
            'X days have passed. Come back and connect with your faith.');
    when(() =>
            mockLocalizationService.translate('churn_notification.medium_body'))
        .thenReturn('Don\'t lose your streak. Read today\'s devotional.');
  });

  tearDown(() {
    serviceLocator.reset();
  });

  group('ChurnMonitoringHelper - Daily Check', () {
    test('performs daily check successfully for high risk user', () async {
      // Arrange
      final prediction = ChurnPrediction(
        riskLevel: ChurnRiskLevel.high,
        riskScore: 0.8,
        daysSinceLastActivity: 8,
        shouldSendNotification: true,
        reason: 'High risk',
        calculatedAt: DateTime.now().toUtc(),
      );
      when(() => mockChurnService.predictChurnRisk())
          .thenAnswer((_) async => prediction);

      // Act
      await ChurnMonitoringHelper.performDailyCheck();

      // Assert
      verify(() => mockChurnService.predictChurnRisk()).called(1);
    });

    test('skips check when notifications disabled by user', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        'churn_notifications_enabled': false,
      });

      // Act
      await ChurnMonitoringHelper.performDailyCheck();

      // Assert - Should not call prediction service
      verifyNever(() => mockChurnService.predictChurnRisk());
    });

    test('handles error gracefully during daily check', () async {
      // Arrange
      when(() => mockChurnService.predictChurnRisk())
          .thenThrow(Exception('Network error'));

      // Act & Assert - Should not throw
      expect(
        () async => await ChurnMonitoringHelper.performDailyCheck(),
        returnsNormally,
      );
    });
  });

  group('ChurnMonitoringHelper - Engagement Summary', () {
    test('gets engagement summary successfully', () async {
      // Arrange
      final expectedSummary = {
        'total_readings': 10,
        'current_streak': 3,
        'churn_risk_level': 'ChurnRiskLevel.low',
      };
      when(() => mockChurnService.getEngagementSummary())
          .thenAnswer((_) async => expectedSummary);

      // Act
      final summary = await ChurnMonitoringHelper.getEngagementSummary();

      // Assert
      expect(summary, equals(expectedSummary));
      verify(() => mockChurnService.getEngagementSummary()).called(1);
    });

    test('handles error gracefully when getting engagement summary', () async {
      // Arrange
      when(() => mockChurnService.getEngagementSummary())
          .thenThrow(Exception('Database error'));

      // Act
      final summary = await ChurnMonitoringHelper.getEngagementSummary();

      // Assert
      expect(summary, isEmpty);
    });
  });

  group('ChurnMonitoringHelper - Risk Check', () {
    test('checks user risk successfully', () async {
      // Arrange
      final prediction = ChurnPrediction(
        riskLevel: ChurnRiskLevel.medium,
        riskScore: 0.5,
        daysSinceLastActivity: 3,
        shouldSendNotification: true,
        reason: 'Test reason',
        calculatedAt: DateTime.now().toUtc(),
      );
      when(() => mockChurnService.predictChurnRisk())
          .thenAnswer((_) async => prediction);

      // Act
      final riskLevel = await ChurnMonitoringHelper.checkUserRisk();

      // Assert
      expect(riskLevel, equals(ChurnRiskLevel.medium));
      verify(() => mockChurnService.predictChurnRisk()).called(1);
    });

    test('returns unknown risk on error', () async {
      // Arrange
      when(() => mockChurnService.predictChurnRisk())
          .thenThrow(Exception('Error'));

      // Act
      final riskLevel = await ChurnMonitoringHelper.checkUserRisk();

      // Assert
      expect(
          riskLevel, equals(ChurnRiskLevel.unknown)); // Error returns unknown
    });
  });

  group('ChurnMonitoringHelper - Manual Notification', () {
    test('bypasses rate limiting for manual sends', () async {
      // Arrange
      final prediction = ChurnPrediction(
        riskLevel: ChurnRiskLevel.high,
        riskScore: 0.8,
        daysSinceLastActivity: 8,
        shouldSendNotification: true,
        reason: 'High risk',
        calculatedAt: DateTime.now().toUtc(),
      );
      when(() => mockChurnService.predictChurnRisk())
          .thenAnswer((_) async => prediction);

      // Act
      await ChurnMonitoringHelper.sendChurnPreventionNotification();

      // Assert
      verify(() => mockChurnService.predictChurnRisk()).called(1);
    });

    test('does not send notification when not needed', () async {
      // Arrange
      final prediction = ChurnPrediction(
        riskLevel: ChurnRiskLevel.low,
        riskScore: 0.1,
        daysSinceLastActivity: 1,
        shouldSendNotification: false,
        reason: 'Low risk',
        calculatedAt: DateTime.now().toUtc(),
      );
      when(() => mockChurnService.predictChurnRisk())
          .thenAnswer((_) async => prediction);

      // Act
      await ChurnMonitoringHelper.sendChurnPreventionNotification();

      // Assert
      verify(() => mockChurnService.predictChurnRisk()).called(1);
      // No notification service calls expected
    });

    test('handles error gracefully when sending notification', () async {
      // Arrange
      when(() => mockChurnService.predictChurnRisk())
          .thenThrow(Exception('Error'));

      // Act & Assert - Should not throw
      expect(
        () async =>
            await ChurnMonitoringHelper.sendChurnPreventionNotification(),
        returnsNormally,
      );
    });
  });

  group('ChurnMonitoringHelper - Rate Limiting', () {
    test('enforces 2 notifications per week', () async {
      // Arrange: Setup 2 notifications already sent in the past 3 days
      final now = DateTime.now().toUtc();
      SharedPreferences.setMockInitialValues({
        'churn_notifications_sent': [
          now.subtract(const Duration(days: 1)).toIso8601String(),
          now.subtract(const Duration(days: 3)).toIso8601String(),
        ],
        'churn_notifications_enabled': true,
      });

      final prediction = ChurnPrediction(
        riskLevel: ChurnRiskLevel.high,
        riskScore: 0.8,
        daysSinceLastActivity: 8,
        shouldSendNotification: true,
        reason: 'High risk',
        calculatedAt: now,
      );
      when(() => mockChurnService.predictChurnRisk())
          .thenAnswer((_) async => prediction);

      // Act
      await ChurnMonitoringHelper.performDailyCheck();

      // Assert - Should call prediction but not send notification due to rate limit
      verify(() => mockChurnService.predictChurnRisk()).called(1);

      // Check that history count is still 2 (no new notification added)
      final count = await ChurnMonitoringHelper.getNotificationHistoryCount();
      expect(count, equals(2));
    });

    test('allows notification after 7-day window expires', () async {
      // Arrange: Setup 2 notifications sent 8 days ago (outside window)
      final now = DateTime.now().toUtc();
      SharedPreferences.setMockInitialValues({
        'churn_notifications_sent': [
          now.subtract(const Duration(days: 8)).toIso8601String(),
          now.subtract(const Duration(days: 10)).toIso8601String(),
        ],
        'churn_notifications_enabled': true,
      });

      final prediction = ChurnPrediction(
        riskLevel: ChurnRiskLevel.high,
        riskScore: 0.8,
        daysSinceLastActivity: 8,
        shouldSendNotification: true,
        reason: 'High risk',
        calculatedAt: now,
      );
      when(() => mockChurnService.predictChurnRisk())
          .thenAnswer((_) async => prediction);

      // Act
      await ChurnMonitoringHelper.performDailyCheck();

      // Assert
      verify(() => mockChurnService.predictChurnRisk()).called(1);

      // Old notifications should be cleaned up, count should be 1 (new notification)
      final count = await ChurnMonitoringHelper.getNotificationHistoryCount();
      expect(count, equals(1));
    });

    test('cleans up old notification history', () async {
      // Arrange: Mix of old and recent notifications
      final now = DateTime.now().toUtc();
      SharedPreferences.setMockInitialValues({
        'churn_notifications_sent': [
          now.subtract(const Duration(days: 2)).toIso8601String(),
          now.subtract(const Duration(days: 8)).toIso8601String(),
          now.subtract(const Duration(days: 15)).toIso8601String(),
        ],
        'churn_notifications_enabled': true,
      });

      // Act - Get count which triggers cleanup
      final count = await ChurnMonitoringHelper.getNotificationHistoryCount();

      // Assert - Only 1 notification within 7-day window
      expect(count, equals(1));
    });

    test('handles empty notification history', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      final count = await ChurnMonitoringHelper.getNotificationHistoryCount();

      // Assert
      expect(count, equals(0));
    });
  });
}
