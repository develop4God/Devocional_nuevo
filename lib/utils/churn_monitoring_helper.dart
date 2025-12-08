// lib/utils/churn_monitoring_helper.dart

import 'dart:developer' as developer;
import 'package:devocional_nuevo/services/churn_prediction_service.dart';
import 'package:devocional_nuevo/services/service_locator.dart';

/// Helper class to demonstrate integration of ChurnPredictionService
///
/// Usage Example:
/// ```dart
/// // In your app initialization or background task:
/// await ChurnMonitoringHelper.performDailyCheck();
///
/// // To get user engagement status:
/// final summary = await ChurnMonitoringHelper.getEngagementSummary();
/// print('User risk level: ${summary['churn_risk_level']}');
/// ```
class ChurnMonitoringHelper {
  /// Perform daily churn check and send notifications if needed
  /// This should be called once per day, ideally via a background task or
  /// when the app starts
  static Future<void> performDailyCheck() async {
    try {
      // Get a new instance of ChurnPredictionService from service locator
      final churnService = getService<ChurnPredictionService>();

      // Perform the daily check
      await churnService.performDailyChurnCheck();

      developer.log(
        'Daily churn monitoring check completed',
        name: 'ChurnMonitoringHelper',
      );
    } catch (e) {
      developer.log(
        'Error performing daily churn check: $e',
        name: 'ChurnMonitoringHelper',
        error: e,
      );
    }
  }

  /// Get current engagement summary for the user
  /// Returns a map with engagement metrics
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
      return ChurnRiskLevel.low;
    }
  }

  /// Manually trigger a churn prevention notification
  /// Useful for testing or specific scenarios
  static Future<void> sendChurnPreventionNotification() async {
    try {
      final churnService = getService<ChurnPredictionService>();
      final prediction = await churnService.predictChurnRisk();

      if (prediction.shouldSendNotification) {
        await churnService.sendChurnPreventionNotification(prediction);
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
}
