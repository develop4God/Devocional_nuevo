// lib/services/churn_prediction_service.dart

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../models/spiritual_stats_model.dart';
import '../services/spiritual_stats_service.dart';
import '../services/notification_service.dart';

/// Risk levels for user churn prediction
enum ChurnRiskLevel {
  low, // User is actively engaged
  medium, // User shows signs of decreased engagement
  high, // User is at high risk of churning
}

/// Model for churn prediction result
class ChurnPrediction {
  final ChurnRiskLevel riskLevel;
  final double riskScore; // 0.0 to 1.0
  final int daysSinceLastActivity;
  final bool shouldSendNotification;
  final String reason;
  final DateTime calculatedAt;

  ChurnPrediction({
    required this.riskLevel,
    required this.riskScore,
    required this.daysSinceLastActivity,
    required this.shouldSendNotification,
    required this.reason,
    required this.calculatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'riskLevel': riskLevel.toString(),
      'riskScore': riskScore,
      'daysSinceLastActivity': daysSinceLastActivity,
      'shouldSendNotification': shouldSendNotification,
      'reason': reason,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }
}

/// Service for predicting user churn and triggering engagement notifications
/// This service is NOT a singleton - use dependency injection via ServiceLocator
class ChurnPredictionService {
  final SpiritualStatsService _statsService;
  final NotificationService _notificationService;

  // Configuration constants
  static const int _inactiveDaysThresholdHigh = 7; // 1 week
  static const int _inactiveDaysThresholdMedium = 3; // 3 days
  static const int _minReadingsForPrediction =
      3; // Minimum readings to analyze patterns

  ChurnPredictionService({
    required SpiritualStatsService statsService,
    required NotificationService notificationService,
  })  : _statsService = statsService,
        _notificationService = notificationService;

  /// Analyze user behavior and predict churn risk
  Future<ChurnPrediction> predictChurnRisk() async {
    try {
      final stats = await _statsService.getStats();
      final now = DateTime.now();

      // Calculate days since last activity
      final daysSinceLastActivity = stats.lastActivityDate != null
          ? now.difference(stats.lastActivityDate!).inDays
          : 999; // Very high number if never active

      // Calculate churn risk score (0.0 to 1.0)
      final riskScore = _calculateRiskScore(stats, daysSinceLastActivity);

      // Determine risk level
      final riskLevel = _determineRiskLevel(riskScore, daysSinceLastActivity);

      // Decide if notification should be sent
      final shouldSendNotification = _shouldSendNotification(
        riskLevel,
        daysSinceLastActivity,
        stats,
      );

      // Generate reason for the prediction
      final reason = _generateReason(
        stats,
        daysSinceLastActivity,
        riskScore,
        riskLevel,
      );

      final prediction = ChurnPrediction(
        riskLevel: riskLevel,
        riskScore: riskScore,
        daysSinceLastActivity: daysSinceLastActivity,
        shouldSendNotification: shouldSendNotification,
        reason: reason,
        calculatedAt: now,
      );

      developer.log(
        'Churn prediction calculated: $reason (risk: ${riskLevel.toString()}, score: ${riskScore.toStringAsFixed(2)})',
        name: 'ChurnPredictionService',
      );

      return prediction;
    } catch (e) {
      developer.log(
        'Error predicting churn risk: $e',
        name: 'ChurnPredictionService',
        error: e,
      );

      // Return safe default
      return ChurnPrediction(
        riskLevel: ChurnRiskLevel.low,
        riskScore: 0.0,
        daysSinceLastActivity: 0,
        shouldSendNotification: false,
        reason: 'Error calculating churn risk',
        calculatedAt: DateTime.now(),
      );
    }
  }

  /// Calculate churn risk score based on multiple factors
  double _calculateRiskScore(SpiritualStats stats, int daysSinceLastActivity) {
    double score = 0.0;

    // Factor 1: Days since last activity (weight: 40%)
    if (daysSinceLastActivity >= _inactiveDaysThresholdHigh) {
      score += 0.4;
    } else if (daysSinceLastActivity >= _inactiveDaysThresholdMedium) {
      score += 0.2;
    }

    // Factor 2: Streak decline (weight: 30%)
    if (stats.longestStreak > 0) {
      final streakDeclineRatio =
          1.0 - (stats.currentStreak / stats.longestStreak);
      score += streakDeclineRatio * 0.3;
    }

    // Factor 3: Reading frequency (weight: 20%)
    if (stats.totalDevocionalesRead < _minReadingsForPrediction) {
      score += 0.2; // New users are at risk
    } else if (daysSinceLastActivity > 0) {
      // Check recent reading decline based on days since last activity
      // A user who was active but stopped is at higher risk
      if (daysSinceLastActivity > 1) {
        // Penalize for inactivity period
        score += 0.2;
      }
    }

    // Factor 4: Zero current streak (weight: 10%)
    if (stats.currentStreak == 0 && stats.totalDevocionalesRead > 0) {
      score += 0.1;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Determine risk level from risk score
  ChurnRiskLevel _determineRiskLevel(
      double riskScore, int daysSinceLastActivity) {
    if (riskScore >= 0.6 ||
        daysSinceLastActivity >= _inactiveDaysThresholdHigh) {
      return ChurnRiskLevel.high;
    } else if (riskScore >= 0.3 ||
        daysSinceLastActivity >= _inactiveDaysThresholdMedium) {
      return ChurnRiskLevel.medium;
    }
    return ChurnRiskLevel.low;
  }

  /// Decide if notification should be sent based on risk level and current state
  bool _shouldSendNotification(
    ChurnRiskLevel riskLevel,
    int daysSinceLastActivity,
    SpiritualStats stats,
  ) {
    // Don't send notifications if user has never read anything
    if (stats.totalDevocionalesRead == 0) {
      return false;
    }

    // Send notification for high risk users
    if (riskLevel == ChurnRiskLevel.high) {
      return true;
    }

    // Send notification for medium risk if enough time has passed
    if (riskLevel == ChurnRiskLevel.medium && daysSinceLastActivity >= 3) {
      return true;
    }

    return false;
  }

  /// Generate human-readable reason for the prediction
  String _generateReason(
    SpiritualStats stats,
    int daysSinceLastActivity,
    double riskScore,
    ChurnRiskLevel riskLevel,
  ) {
    if (stats.totalDevocionalesRead == 0) {
      return 'New user with no activity';
    }

    if (daysSinceLastActivity >= _inactiveDaysThresholdHigh) {
      return 'User inactive for $daysSinceLastActivity days';
    }

    if (daysSinceLastActivity >= _inactiveDaysThresholdMedium) {
      return 'User activity declining ($daysSinceLastActivity days since last read)';
    }

    if (stats.currentStreak == 0 && stats.longestStreak > 0) {
      return 'User lost their streak (was ${stats.longestStreak} days)';
    }

    if (riskLevel == ChurnRiskLevel.low) {
      return 'User actively engaged (${stats.currentStreak} day streak)';
    }

    return 'User engagement at medium risk (score: ${riskScore.toStringAsFixed(2)})';
  }

  /// Send engagement notification based on churn risk
  Future<void> sendChurnPreventionNotification(
      ChurnPrediction prediction) async {
    if (!prediction.shouldSendNotification) {
      developer.log(
        'Skipping notification - not needed for current risk level',
        name: 'ChurnPredictionService',
      );
      return;
    }

    try {
      final notificationsEnabled =
          await _notificationService.areNotificationsEnabled();
      if (!notificationsEnabled) {
        developer.log(
          'Notifications disabled by user - skipping churn prevention notification',
          name: 'ChurnPredictionService',
        );
        return;
      }

      final title = _getNotificationTitle(prediction.riskLevel);
      final body = _getNotificationBody(prediction);

      await _notificationService.showImmediateNotification(
        title,
        body,
        payload: 'churn_prevention',
        id: DateTime.now().millisecondsSinceEpoch,
      );

      developer.log(
        'Churn prevention notification sent: $title',
        name: 'ChurnPredictionService',
      );
    } catch (e) {
      developer.log(
        'Error sending churn prevention notification: $e',
        name: 'ChurnPredictionService',
        error: e,
      );
    }
  }

  /// Get notification title based on risk level
  String _getNotificationTitle(ChurnRiskLevel riskLevel) {
    switch (riskLevel) {
      case ChurnRiskLevel.high:
        return '¡Te extrañamos! 🙏';
      case ChurnRiskLevel.medium:
        return 'Tu devocional te está esperando 📖';
      case ChurnRiskLevel.low:
        return '¡Continúa tu racha! 🔥';
    }
  }

  /// Get notification body based on prediction
  String _getNotificationBody(ChurnPrediction prediction) {
    switch (prediction.riskLevel) {
      case ChurnRiskLevel.high:
        return 'Han pasado ${prediction.daysSinceLastActivity} días. Vuelve a conectarte con tu fe.';
      case ChurnRiskLevel.medium:
        return 'No pierdas tu racha. Lee el devocional de hoy.';
      case ChurnRiskLevel.low:
        return '¡Sigue así! Tu dedicación es inspiradora.';
    }
  }

  /// Schedule daily churn check (to be called periodically)
  Future<void> performDailyChurnCheck() async {
    try {
      developer.log(
        'Performing daily churn check',
        name: 'ChurnPredictionService',
      );

      final prediction = await predictChurnRisk();

      if (prediction.shouldSendNotification) {
        await sendChurnPreventionNotification(prediction);
      }

      debugPrint('Daily churn check completed: ${prediction.reason}');
    } catch (e) {
      developer.log(
        'Error in daily churn check: $e',
        name: 'ChurnPredictionService',
        error: e,
      );
    }
  }

  /// Get user engagement summary
  Future<Map<String, dynamic>> getEngagementSummary() async {
    try {
      final stats = await _statsService.getStats();
      final prediction = await predictChurnRisk();

      return {
        'total_readings': stats.totalDevocionalesRead,
        'current_streak': stats.currentStreak,
        'longest_streak': stats.longestStreak,
        'days_since_last_activity': prediction.daysSinceLastActivity,
        'churn_risk_level': prediction.riskLevel.toString(),
        'churn_risk_score': prediction.riskScore,
        'engagement_status': _getEngagementStatus(prediction.riskLevel),
        'last_activity_date': stats.lastActivityDate?.toIso8601String(),
      };
    } catch (e) {
      developer.log(
        'Error getting engagement summary: $e',
        name: 'ChurnPredictionService',
        error: e,
      );
      return {};
    }
  }

  /// Get engagement status text
  String _getEngagementStatus(ChurnRiskLevel riskLevel) {
    switch (riskLevel) {
      case ChurnRiskLevel.low:
        return 'Highly Engaged';
      case ChurnRiskLevel.medium:
        return 'Moderately Engaged';
      case ChurnRiskLevel.high:
        return 'At Risk';
    }
  }
}
