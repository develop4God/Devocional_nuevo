// lib/utils/churn_monitoring_helper.dart

import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devocional_nuevo/services/churn_prediction_service.dart';
import 'package:devocional_nuevo/services/notification_service.dart';
import 'package:devocional_nuevo/services/localization_service.dart';
import 'package:devocional_nuevo/services/service_locator.dart';

/// Helper class for churn monitoring with rate limiting and analytics
///
/// GAP-3: Separates notification logic from prediction service
/// GAP-4: Adds basic analytics logging
/// GAP-7: Implements rate limiting (max 2 notifications per week)
class ChurnMonitoringHelper {
  // GAP-7: Rate limiting constants
  static const int _maxNotificationsPerWeek = 2;
  static const String _prefKeyNotificationHistory = 'churn_notifications_sent';
  static const Duration _rateLimitWindow = Duration(days: 7);

  /// Perform daily churn check with rate limiting and analytics
  /// This should be called once per day via background task or app start
  static Future<void> performDailyCheck() async {
    try {
      // Check if churn notifications are enabled by user
      final prefs = await SharedPreferences.getInstance();
      final churnNotificationsEnabled =
          prefs.getBool('churn_notifications_enabled') ?? true;

      if (!churnNotificationsEnabled) {
        developer.log(
          'ChurnAnalytics: check_skipped reason=user_disabled',
          name: 'ChurnMonitoringHelper',
        );
        return;
      }

      // Get prediction from service
      final churnService = getService<ChurnPredictionService>();
      final prediction = await churnService.predictChurnRisk();

      // GAP-4: Log prediction event
      developer.log(
        'ChurnAnalytics: prediction_made '
        'risk=${prediction.riskLevel.name} '
        'score=${prediction.riskScore.toStringAsFixed(2)} '
        'inactive_days=${prediction.daysSinceLastActivity}',
        name: 'ChurnMonitoringHelper',
      );

      // GAP-3: Handle notification logic here (separated from service)
      if (prediction.shouldSendNotification) {
        // GAP-7: Check rate limiting before sending
        final canSend = await _canSendNotification();
        if (canSend) {
          await _sendChurnNotification(prediction);

          // GAP-4: Log notification sent
          developer.log(
            'ChurnAnalytics: notification_sent level=${prediction.riskLevel.name}',
            name: 'ChurnMonitoringHelper',
          );

          // Record notification in history
          await _recordNotificationSent();
        } else {
          developer.log(
            'ChurnAnalytics: notification_rate_limited',
            name: 'ChurnMonitoringHelper',
          );
        }
      }

      developer.log(
        'Daily churn monitoring check completed',
        name: 'ChurnMonitoringHelper',
      );
    } catch (e, stackTrace) {
      // GAP-4: Log errors
      developer.log(
        'ChurnAnalytics: check_failed error=$e',
        name: 'ChurnMonitoringHelper',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// GAP-7: Check if notification can be sent (rate limiting)
  static Future<bool> _canSendNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_prefKeyNotificationHistory) ?? [];

      // Parse and filter notifications within the rate limit window
      final cutoffTime = DateTime.now().toUtc().subtract(_rateLimitWindow);

      final recentNotifications = history
          .map((timestamp) {
            try {
              return DateTime.parse(timestamp);
            } catch (e) {
              return null;
            }
          })
          .where((date) => date != null && date.isAfter(cutoffTime))
          .length;

      return recentNotifications < _maxNotificationsPerWeek;
    } catch (e) {
      developer.log(
        'Error checking notification rate limit: $e',
        name: 'ChurnMonitoringHelper',
      );
      // On error, allow sending (fail open)
      return true;
    }
  }

  /// GAP-7: Record that a notification was sent
  static Future<void> _recordNotificationSent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_prefKeyNotificationHistory) ?? [];

      // Add current timestamp
      history.add(DateTime.now().toUtc().toIso8601String());

      // Clean up old entries (older than rate limit window)
      final cutoffTime = DateTime.now().toUtc().subtract(_rateLimitWindow);

      final cleanedHistory = history.where((timestamp) {
        try {
          final date = DateTime.parse(timestamp);
          return date.isAfter(cutoffTime);
        } catch (e) {
          return false;
        }
      }).toList();

      await prefs.setStringList(_prefKeyNotificationHistory, cleanedHistory);
    } catch (e) {
      developer.log(
        'Error recording notification history: $e',
        name: 'ChurnMonitoringHelper',
      );
    }
  }

  /// GAP-3: Send churn notification (notification logic separated from service)
  static Future<void> _sendChurnNotification(ChurnPrediction prediction) async {
    try {
      final notificationService = NotificationService();
      final localizationService = getService<LocalizationService>();

      // Get localized notification content
      String title;
      String body;

      switch (prediction.riskLevel) {
        case ChurnRiskLevel.high:
          title =
              localizationService.translate('churn_notification.high_title');
          body = localizationService.translate(
            'churn_notification.high_body',
            {'days': prediction.daysSinceLastActivity.toString()},
          );
          break;
        case ChurnRiskLevel.medium:
          title =
              localizationService.translate('churn_notification.medium_title');
          body =
              localizationService.translate('churn_notification.medium_body');
          break;
        default:
          // Don't send notification for low or unknown risk
          return;
      }

      await notificationService.showImmediateNotification(
        title,
        body,
        payload: 'churn_prevention',
        id: DateTime.now().millisecondsSinceEpoch,
      );

      developer.log(
        'Churn notification sent: $title',
        name: 'ChurnMonitoringHelper',
      );
    } catch (e) {
      developer.log(
        'Error sending churn notification: $e',
        name: 'ChurnMonitoringHelper',
        error: e,
      );
    }
  }

  /// Get current engagement summary for the user
  static Future<Map<String, dynamic>> getEngagementSummary() async {
    try {
      final churnService = getService<ChurnPredictionService>();
      return await churnService.getEngagementSummary();
    } catch (e) {
      developer.log(
        'Error getting engagement summary: $e',
        name: 'ChurnMonitoringHelper',
        error: e,
      );
      return {};
    }
  }

  /// Check if user is at risk and return risk level
  static Future<ChurnRiskLevel> checkUserRisk() async {
    try {
      final churnService = getService<ChurnPredictionService>();
      final prediction = await churnService.predictChurnRisk();
      return prediction.riskLevel;
    } catch (e) {
      developer.log(
        'Error checking user risk: $e',
        name: 'ChurnMonitoringHelper',
        error: e,
      );
      return ChurnRiskLevel.unknown;
    }
  }

  /// Manually trigger a churn prevention notification (for testing)
  static Future<void> sendChurnPreventionNotification() async {
    try {
      final churnService = getService<ChurnPredictionService>();
      final prediction = await churnService.predictChurnRisk();

      if (prediction.shouldSendNotification) {
        // Bypass rate limiting for manual sends
        await _sendChurnNotification(prediction);
        developer.log(
          'Churn prevention notification sent manually',
          name: 'ChurnMonitoringHelper',
        );
      } else {
        developer.log(
          'Notification not needed for current risk level',
          name: 'ChurnMonitoringHelper',
        );
      }
    } catch (e) {
      developer.log(
        'Error sending churn prevention notification: $e',
        name: 'ChurnMonitoringHelper',
        error: e,
      );
    }
  }

  /// Get notification history count (for debugging)
  static Future<int> getNotificationHistoryCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_prefKeyNotificationHistory) ?? [];

      final cutoffTime = DateTime.now().toUtc().subtract(_rateLimitWindow);

      return history
          .map((timestamp) {
            try {
              return DateTime.parse(timestamp);
            } catch (e) {
              return null;
            }
          })
          .where((date) => date != null && date.isAfter(cutoffTime))
          .length;
    } catch (e) {
      return 0;
    }
  }
}
