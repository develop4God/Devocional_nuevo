// test/integration/churn_monitoring_integration_test.dart

import 'package:devocional_nuevo/models/spiritual_stats_model.dart';
import 'package:devocional_nuevo/services/churn_prediction_service.dart';
import 'package:devocional_nuevo/services/localization_service.dart';
import 'package:devocional_nuevo/services/notification_service.dart';
import 'package:devocional_nuevo/services/service_locator.dart';
import 'package:devocional_nuevo/services/spiritual_stats_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock services
class MockNotificationService extends Mock implements NotificationService {}

class MockLocalizationService extends Mock implements LocalizationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChurnMonitoring Integration Tests - End-to-End Workflows', () {
    late SpiritualStatsService statsService;
    late MockNotificationService mockNotificationService;
    late MockLocalizationService mockLocalizationService;
    late ChurnPredictionService churnService;
    late ServiceLocator serviceLocator;

    setUp(() async {
      // Reset SharedPreferences for clean state
      SharedPreferences.setMockInitialValues({});

      // Setup service locator
      serviceLocator = ServiceLocator();
      serviceLocator.reset();

      // Create services
      statsService = SpiritualStatsService();
      mockNotificationService = MockNotificationService();
      mockLocalizationService = MockLocalizationService();

      // Register mocks
      serviceLocator.registerFactory<LocalizationService>(
        () => mockLocalizationService,
      );

      // Setup localization mocks
      when(() => mockLocalizationService.translate(any()))
          .thenReturn('Translated');
      when(() => mockLocalizationService.translate(any(), any()))
          .thenReturn('Translated with params');
      when(() => mockLocalizationService
          .translate('achievements.first_read_title')).thenReturn('First Step');
      when(() => mockLocalizationService
              .translate('achievements.first_read_description'))
          .thenReturn('Read your first devotional');

      // Mock notification service methods
      when(() => mockNotificationService.areNotificationsEnabled())
          .thenAnswer((_) async => true);
      when(() => mockNotificationService.showImmediateNotification(
            any(),
            any(),
            payload: any(named: 'payload'),
            id: any(named: 'id'),
          )).thenAnswer((_) async {});

      churnService = ChurnPredictionService(
        statsService: statsService,
        notificationService: mockNotificationService,
      );

      // Reset stats for clean test state
      await statsService.resetStats();
    });

    tearDown(() {
      serviceLocator.reset();
    });

    test('performs daily check workflow for new user', () async {
      // Arrange: New user with no activity
      final initialStats = await statsService.getStats();
      expect(initialStats.totalDevocionalesRead, equals(0));

      // Act: Perform daily check
      await churnService.performDailyChurnCheck();

      // Assert: Check completed without errors and risk calculated
      final prediction = await churnService.predictChurnRisk();
      expect(prediction.riskLevel, isNotNull);
      expect(prediction.daysSinceLastActivity, greaterThan(0));
    });

    test('retrieves engagement summary with correct structure', () async {
      // Arrange: User with no readings
      final summary = await churnService.getEngagementSummary();

      // Assert: Verify structure
      expect(summary, isNotEmpty);
      expect(summary.containsKey('total_readings'), isTrue);
      expect(summary.containsKey('current_streak'), isTrue);
      expect(summary.containsKey('churn_risk_level'), isTrue);
      expect(summary.containsKey('engagement_status'), isTrue);
    });

    test('detects high risk for inactive user', () async {
      // Arrange: Setup user with old activity date
      final stats = SpiritualStats(
        totalDevocionalesRead: 5,
        currentStreak: 0,
        longestStreak: 5,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 8)),
      );
      await statsService.saveStats(stats);

      // Act: Check user risk
      final prediction = await churnService.predictChurnRisk();

      // Assert: Inactive user should have high risk
      expect(prediction.riskLevel, equals(ChurnRiskLevel.high));
      expect(prediction.daysSinceLastActivity, greaterThanOrEqualTo(7));
    });

    test('churn check performance meets SLA', () async {
      // Arrange: Setup basic stats
      final stats = SpiritualStats(
        totalDevocionalesRead: 1,
        currentStreak: 1,
        longestStreak: 1,
        lastActivityDate: DateTime.now(),
      );
      await statsService.saveStats(stats);

      // Act: Measure performance
      final stopwatch = Stopwatch()..start();
      await churnService.performDailyChurnCheck();
      stopwatch.stop();

      // Assert: Should complete within 2 seconds (SLA)
      expect(stopwatch.elapsedMilliseconds, lessThan(2000),
          reason: 'Churn check should complete within 2 second SLA');
    });

    test('handles edge case of user with no last activity date', () async {
      // Arrange: User stats with null last activity
      final stats = SpiritualStats(
        totalDevocionalesRead: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastActivityDate: null,
      );
      await statsService.saveStats(stats);

      // Act: Predict churn risk
      final prediction = await churnService.predictChurnRisk();

      // Assert: Should handle null gracefully
      expect(prediction.riskLevel, isNotNull);
      expect(prediction.shouldSendNotification, isFalse);
    });
  });
}
