// test/utils/churn_monitoring_helper_test.dart

import 'package:devocional_nuevo/services/churn_prediction_service.dart';
import 'package:devocional_nuevo/services/notification_service.dart';
import 'package:devocional_nuevo/services/service_locator.dart';
import 'package:devocional_nuevo/services/spiritual_stats_service.dart';
import 'package:devocional_nuevo/utils/churn_monitoring_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockSpiritualStatsService extends Mock implements SpiritualStatsService {}

class MockNotificationService extends Mock implements NotificationService {}

class MockChurnPredictionService extends Mock
    implements ChurnPredictionService {}

// Fake class for ChurnPrediction
class FakeChurnPrediction extends Fake implements ChurnPrediction {}

void main() {
  late MockChurnPredictionService mockChurnService;
  late ServiceLocator serviceLocator;

  setUpAll(() {
    // Register fallback value for ChurnPrediction
    registerFallbackValue(FakeChurnPrediction());
  });

  setUp(() {
    // Reset service locator before each test
    serviceLocator = ServiceLocator();
    serviceLocator.reset();

    mockChurnService = MockChurnPredictionService();

    // Register mock service
    serviceLocator.registerFactory<ChurnPredictionService>(
      () => mockChurnService,
    );
  });

  tearDown(() {
    serviceLocator.reset();
  });

  group('ChurnMonitoringHelper - Daily Check', () {
    test('performs daily check successfully', () async {
      // Arrange
      when(() => mockChurnService.performDailyChurnCheck())
          .thenAnswer((_) async {});

      // Act
      await ChurnMonitoringHelper.performDailyCheck();

      // Assert
      verify(() => mockChurnService.performDailyChurnCheck()).called(1);
    });

    test('handles error gracefully during daily check', () async {
      // Arrange
      when(() => mockChurnService.performDailyChurnCheck())
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
        calculatedAt: DateTime.now(),
      );
      when(() => mockChurnService.predictChurnRisk())
          .thenAnswer((_) async => prediction);

      // Act
      final riskLevel = await ChurnMonitoringHelper.checkUserRisk();

      // Assert
      expect(riskLevel, equals(ChurnRiskLevel.medium));
      verify(() => mockChurnService.predictChurnRisk()).called(1);
    });

    test('returns low risk on error', () async {
      // Arrange
      when(() => mockChurnService.predictChurnRisk())
          .thenThrow(Exception('Error'));

      // Act
      final riskLevel = await ChurnMonitoringHelper.checkUserRisk();

      // Assert
      expect(riskLevel, equals(ChurnRiskLevel.low));
    });
  });

  group('ChurnMonitoringHelper - Manual Notification', () {
    test('sends notification when needed', () async {
      // Arrange
      final prediction = ChurnPrediction(
        riskLevel: ChurnRiskLevel.high,
        riskScore: 0.8,
        daysSinceLastActivity: 8,
        shouldSendNotification: true,
        reason: 'High risk',
        calculatedAt: DateTime.now(),
      );
      when(() => mockChurnService.predictChurnRisk())
          .thenAnswer((_) async => prediction);
      when(() => mockChurnService.sendChurnPreventionNotification(prediction))
          .thenAnswer((_) async {});

      // Act
      await ChurnMonitoringHelper.sendChurnPreventionNotification();

      // Assert
      verify(() => mockChurnService.predictChurnRisk()).called(1);
      verify(() => mockChurnService.sendChurnPreventionNotification(prediction))
          .called(1);
    });

    test('does not send notification when not needed', () async {
      // Arrange
      final prediction = ChurnPrediction(
        riskLevel: ChurnRiskLevel.low,
        riskScore: 0.1,
        daysSinceLastActivity: 1,
        shouldSendNotification: false,
        reason: 'Low risk',
        calculatedAt: DateTime.now(),
      );
      when(() => mockChurnService.predictChurnRisk())
          .thenAnswer((_) async => prediction);

      // Act
      await ChurnMonitoringHelper.sendChurnPreventionNotification();

      // Assert
      verify(() => mockChurnService.predictChurnRisk()).called(1);
      verifyNever(
        () => mockChurnService.sendChurnPreventionNotification(any()),
      );
    });

    test('handles error gracefully when sending notification', () async {
      // Arrange
      when(() => mockChurnService.predictChurnRisk())
          .thenThrow(Exception('Network error'));

      // Act & Assert - Should not throw
      expect(
        () async =>
            await ChurnMonitoringHelper.sendChurnPreventionNotification(),
        returnsNormally,
      );
    });
  });
}
