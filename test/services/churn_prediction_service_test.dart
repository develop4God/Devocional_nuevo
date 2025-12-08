// test/services/churn_prediction_service_test.dart

import 'package:devocional_nuevo/models/spiritual_stats_model.dart';
import 'package:devocional_nuevo/services/churn_prediction_service.dart';
import 'package:devocional_nuevo/services/localization_service.dart';
import 'package:devocional_nuevo/services/notification_service.dart';
import 'package:devocional_nuevo/services/service_locator.dart';
import 'package:devocional_nuevo/services/spiritual_stats_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock classes
class MockSpiritualStatsService extends Mock implements SpiritualStatsService {}

class MockNotificationService extends Mock implements NotificationService {}

class MockLocalizationService extends Mock implements LocalizationService {}

void main() {
  late MockSpiritualStatsService mockStatsService;
  late MockNotificationService mockNotificationService;
  late MockLocalizationService mockLocalizationService;
  late ChurnPredictionService churnPredictionService;
  late ServiceLocator serviceLocator;

  setUp(() async {
    // Setup SharedPreferences with mock
    SharedPreferences.setMockInitialValues({});

    // Reset and setup service locator
    serviceLocator = ServiceLocator();
    serviceLocator.reset();

    mockStatsService = MockSpiritualStatsService();
    mockNotificationService = MockNotificationService();
    mockLocalizationService = MockLocalizationService();

    // Register mocks in service locator
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
    when(() =>
            mockLocalizationService.translate('churn_notification.low_title'))
        .thenReturn('Keep it up! 🔥');
    when(() => mockLocalizationService.translate(
            'churn_notification.high_body', any()))
        .thenReturn(
            'X days have passed. Come back and connect with your faith.');
    when(() =>
            mockLocalizationService.translate('churn_notification.medium_body'))
        .thenReturn('Don\'t lose your streak. Read today\'s devotional.');
    when(() => mockLocalizationService.translate('churn_notification.low_body'))
        .thenReturn('Your dedication is inspiring!');

    churnPredictionService = ChurnPredictionService(
      statsService: mockStatsService,
      notificationService: mockNotificationService,
    );
  });

  tearDown(() {
    serviceLocator.reset();
  });

  group('ChurnPredictionService - Risk Calculation', () {
    test('predicts LOW risk for actively engaged user', () async {
      // Arrange: User with current streak, recent activity
      final stats = SpiritualStats(
        totalDevocionalesRead: 10,
        currentStreak: 5,
        longestStreak: 7,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      when(() => mockStatsService.getStats()).thenAnswer((_) async => stats);

      // Act
      final prediction = await churnPredictionService.predictChurnRisk();

      // Assert
      expect(prediction.riskLevel, ChurnRiskLevel.low);
      expect(prediction.riskScore, lessThan(0.3));
      expect(prediction.shouldSendNotification, false);
      expect(prediction.daysSinceLastActivity, equals(1));
    });

    test('predicts MEDIUM risk for user with declining activity', () async {
      // Arrange: User inactive for 3 days with good history but lost streak
      final stats = SpiritualStats(
        totalDevocionalesRead: 10,
        currentStreak: 2,
        longestStreak: 5,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 3)),
      );
      when(() => mockStatsService.getStats()).thenAnswer((_) async => stats);

      // Act
      final prediction = await churnPredictionService.predictChurnRisk();

      // Assert
      expect(prediction.riskLevel, ChurnRiskLevel.medium);
      expect(prediction.riskScore, greaterThanOrEqualTo(0.3));
      expect(prediction.daysSinceLastActivity, equals(3));
      expect(prediction.shouldSendNotification, true);
    });

    test('predicts HIGH risk for user inactive for 7+ days', () async {
      // Arrange: User inactive for a week
      final stats = SpiritualStats(
        totalDevocionalesRead: 8,
        currentStreak: 0,
        longestStreak: 10,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 7)),
      );
      when(() => mockStatsService.getStats()).thenAnswer((_) async => stats);

      // Act
      final prediction = await churnPredictionService.predictChurnRisk();

      // Assert
      expect(prediction.riskLevel, ChurnRiskLevel.high);
      expect(prediction.riskScore, greaterThanOrEqualTo(0.6));
      expect(prediction.daysSinceLastActivity, equals(7));
      expect(prediction.shouldSendNotification, true);
    });

    test('predicts HIGH risk for user who lost long streak', () async {
      // Arrange: User with lost streak
      final stats = SpiritualStats(
        totalDevocionalesRead: 15,
        currentStreak: 0,
        longestStreak: 15,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 5)),
      );
      when(() => mockStatsService.getStats()).thenAnswer((_) async => stats);

      // Act
      final prediction = await churnPredictionService.predictChurnRisk();

      // Assert
      expect(prediction.riskLevel, ChurnRiskLevel.high);
      expect(prediction.daysSinceLastActivity, equals(5));
      expect(prediction.shouldSendNotification, true);
    });

    test('handles new user with no activity correctly', () async {
      // Arrange: Brand new user
      final stats = SpiritualStats(
        totalDevocionalesRead: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastActivityDate: null,
      );
      when(() => mockStatsService.getStats()).thenAnswer((_) async => stats);

      // Act
      final prediction = await churnPredictionService.predictChurnRisk();

      // Assert
      expect(prediction.riskLevel, ChurnRiskLevel.unknown); // Insufficient data
      expect(prediction.shouldSendNotification, false); // Don't spam new users
      expect(prediction.riskScore, equals(0.0)); // No risk score for unknown
    });

    test('handles user with minimal readings', () async {
      // Arrange: User with only 1 reading (insufficient for prediction)
      final stats = SpiritualStats(
        totalDevocionalesRead: 1,
        currentStreak: 1,
        longestStreak: 1,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 2)),
      );
      when(() => mockStatsService.getStats()).thenAnswer((_) async => stats);

      // Act
      final prediction = await churnPredictionService.predictChurnRisk();

      // Assert
      expect(prediction.riskLevel,
          ChurnRiskLevel.unknown); // Less than minimum 3 readings
      expect(prediction.riskScore, equals(0.0));
      expect(prediction.shouldSendNotification, false);
    });
  });

  group('ChurnPredictionService - Notification Sending', () {
    test('sends notification for high risk user when enabled', () async {
      // Arrange
      final stats = SpiritualStats(
        totalDevocionalesRead: 10,
        currentStreak: 0,
        longestStreak: 10,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 8)),
      );
      when(() => mockStatsService.getStats()).thenAnswer((_) async => stats);
      when(() => mockNotificationService.areNotificationsEnabled())
          .thenAnswer((_) async => true);
      when(() => mockNotificationService.showImmediateNotification(
            any(),
            any(),
            payload: any(named: 'payload'),
            id: any(named: 'id'),
          )).thenAnswer((_) async {});

      // Act
      final prediction = await churnPredictionService.predictChurnRisk();
      await churnPredictionService.sendChurnPreventionNotification(prediction);

      // Assert
      verify(() => mockNotificationService.showImmediateNotification(
            any(),
            any(),
            payload: 'churn_prevention',
            id: any(named: 'id'),
          )).called(1);
    });

    test('does not send notification when disabled by user', () async {
      // Arrange
      final stats = SpiritualStats(
        totalDevocionalesRead: 10,
        currentStreak: 0,
        longestStreak: 10,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 8)),
      );
      when(() => mockStatsService.getStats()).thenAnswer((_) async => stats);
      when(() => mockNotificationService.areNotificationsEnabled())
          .thenAnswer((_) async => false);

      // Act
      final prediction = await churnPredictionService.predictChurnRisk();
      await churnPredictionService.sendChurnPreventionNotification(prediction);

      // Assert
      verifyNever(() => mockNotificationService.showImmediateNotification(
            any(),
            any(),
            payload: any(named: 'payload'),
            id: any(named: 'id'),
          ));
    });

    test('does not send notification for low risk user', () async {
      // Arrange
      final stats = SpiritualStats(
        totalDevocionalesRead: 10,
        currentStreak: 5,
        longestStreak: 7,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      when(() => mockStatsService.getStats()).thenAnswer((_) async => stats);

      // Act
      final prediction = await churnPredictionService.predictChurnRisk();
      await churnPredictionService.sendChurnPreventionNotification(prediction);

      // Assert
      verifyNever(() => mockNotificationService.showImmediateNotification(
            any(),
            any(),
            payload: any(named: 'payload'),
            id: any(named: 'id'),
          ));
    });
  });

  group('ChurnPredictionService - Daily Check', () {
    test('performs daily churn check successfully', () async {
      // Arrange
      final stats = SpiritualStats(
        totalDevocionalesRead: 5,
        currentStreak: 0,
        longestStreak: 5,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 5)),
      );
      when(() => mockStatsService.getStats()).thenAnswer((_) async => stats);
      when(() => mockNotificationService.areNotificationsEnabled())
          .thenAnswer((_) async => true);
      when(() => mockNotificationService.showImmediateNotification(
            any(),
            any(),
            payload: any(named: 'payload'),
            id: any(named: 'id'),
          )).thenAnswer((_) async {});

      // Act
      await churnPredictionService.performDailyChurnCheck();

      // Assert
      verify(() => mockStatsService.getStats()).called(1);
      verify(() => mockNotificationService.areNotificationsEnabled()).called(1);
    });
  });

  group('ChurnPredictionService - Engagement Summary', () {
    test('generates engagement summary correctly', () async {
      // Arrange
      final stats = SpiritualStats(
        totalDevocionalesRead: 15,
        currentStreak: 3,
        longestStreak: 10,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 2)),
      );
      when(() => mockStatsService.getStats()).thenAnswer((_) async => stats);

      // Act
      final summary = await churnPredictionService.getEngagementSummary();

      // Assert
      expect(summary['total_readings'], equals(15));
      expect(summary['current_streak'], equals(3));
      expect(summary['longest_streak'], equals(10));
      expect(summary['days_since_last_activity'], equals(2));
      expect(summary['churn_risk_level'], isNotNull);
      expect(summary['churn_risk_score'], isA<double>());
      expect(summary['engagement_status'], isNotNull);
    });
  });

  group('ChurnPredictionService - Error Handling', () {
    test('handles error gracefully when stats service fails', () async {
      // Arrange
      when(() => mockStatsService.getStats())
          .thenThrow(Exception('Database error'));

      // Act
      final prediction = await churnPredictionService.predictChurnRisk();

      // Assert
      expect(prediction.riskLevel,
          ChurnRiskLevel.unknown); // Error case returns unknown
      expect(prediction.riskScore, equals(0.0));
      expect(prediction.shouldSendNotification, false);
      expect(prediction.reason, contains('Error'));
    });

    test('handles error gracefully when notification service fails', () async {
      // Arrange
      final stats = SpiritualStats(
        totalDevocionalesRead: 10,
        currentStreak: 0,
        longestStreak: 10,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 8)),
      );
      when(() => mockStatsService.getStats()).thenAnswer((_) async => stats);
      when(() => mockNotificationService.areNotificationsEnabled())
          .thenThrow(Exception('Permission error'));

      // Act & Assert - Should not throw
      final prediction = await churnPredictionService.predictChurnRisk();
      expect(
        () async => await churnPredictionService
            .sendChurnPreventionNotification(prediction),
        returnsNormally,
      );
    });
  });

  group('ChurnPredictionService - Edge Cases', () {
    test('handles user with same current and longest streak', () async {
      // Arrange
      final stats = SpiritualStats(
        totalDevocionalesRead: 10,
        currentStreak: 10,
        longestStreak: 10,
        lastActivityDate: DateTime.now(),
      );
      when(() => mockStatsService.getStats()).thenAnswer((_) async => stats);

      // Act
      final prediction = await churnPredictionService.predictChurnRisk();

      // Assert
      expect(prediction.riskLevel, ChurnRiskLevel.low);
      expect(prediction.daysSinceLastActivity, equals(0));
    });

    test('handles boundary conditions for inactive days', () async {
      // Arrange: Exactly at medium threshold
      final stats = SpiritualStats(
        totalDevocionalesRead: 5,
        currentStreak: 0,
        longestStreak: 5,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 3)),
      );
      when(() => mockStatsService.getStats()).thenAnswer((_) async => stats);

      // Act
      final prediction = await churnPredictionService.predictChurnRisk();

      // Assert
      expect(prediction.daysSinceLastActivity, equals(3));
      expect(prediction.shouldSendNotification, true);
    });
  });
}
