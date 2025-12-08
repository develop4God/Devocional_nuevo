// lib/services/churn_prediction_service.dart

import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/spiritual_stats_model.dart';
import '../services/spiritual_stats_service.dart';
import '../services/notification_service.dart';
import '../services/localization_service.dart';
import '../services/service_locator.dart';

/// Risk levels for user churn prediction
enum ChurnRiskLevel {
  unknown, // Insufficient data for prediction
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

/// Validation for minimum data requirements
class _ChurnValidation {
  static const int minReadings = 3;
  static const int minAccountAgeDays = 7;

  static bool hasMinimumData(SpiritualStats stats) {
    // Check if user has enough data for meaningful prediction
    if (stats.totalDevocionalesRead < minReadings) {
      return false;
    }

    // Check if account is old enough
    if (stats.lastActivityDate != null) {
      final accountAge = DateTime.now()
          .toUtc()
          .difference(stats.lastActivityDate!.toUtc())
          .inDays
          .abs();
      if (accountAge < minAccountAgeDays &&
          stats.totalDevocionalesRead < minReadings) {
        return false;
      }
    }

    // Must have last activity date
    if (stats.lastActivityDate == null && stats.totalDevocionalesRead == 0) {
      return false;
    }

    return true;
  }
}

/// Internal cache for engagement metrics
class _MetricsCache {
  Map<String, dynamic>? _cachedSummary;
  DateTime? _cacheTimestamp;
  static const _cacheDuration = Duration(minutes: 5);

  bool get isValid =>
      _cacheTimestamp != null &&
      DateTime.now().toUtc().difference(_cacheTimestamp!) < _cacheDuration;

  void set(Map<String, dynamic> summary) {
    _cachedSummary = summary;
    _cacheTimestamp = DateTime.now().toUtc();
    developer.log(
      'Metrics cache SET - valid for ${_cacheDuration.inMinutes} minutes',
      name: 'ChurnPredictionService',
    );
  }

  Map<String, dynamic>? get() {
    if (isValid && _cachedSummary != null) {
      developer.log(
        'Metrics cache HIT',
        name: 'ChurnPredictionService',
      );
      return Map<String, dynamic>.from(_cachedSummary!);
    }
    developer.log(
      'Metrics cache MISS',
      name: 'ChurnPredictionService',
    );
    return null;
  }

  void invalidate() {
    _cachedSummary = null;
    _cacheTimestamp = null;
    developer.log(
      'Metrics cache INVALIDATED',
      name: 'ChurnPredictionService',
    );
  }
}

/// Service for predicting user churn and triggering engagement notifications
/// This service is NOT a singleton - use dependency injection via ServiceLocator
class ChurnPredictionService {
  final SpiritualStatsService _statsService;
  final NotificationService _notificationService;
  final _MetricsCache _cache = _MetricsCache();

  // Shared Preferences key for churn notification setting
  static const String _prefKeyChurnNotifications =
      'churn_notifications_enabled';

  // Configuration constants
  static const int _inactiveDaysThresholdHigh = 7; // 1 week
  static const int _inactiveDaysThresholdMedium = 3; // 3 days
  static const int _minReadingsForPrediction =
      3; // Minimum readings to analyze patterns

  // Reading frequency risk constants
  static const int _inactivityDaysForPenalty =
      1; // Days threshold for inactivity penalty
  static const double _inactivityPenaltyScore =
      0.2; // Penalty score for inactive users

  ChurnPredictionService({
    required SpiritualStatsService statsService,
    required NotificationService notificationService,
  })  : _statsService = statsService,
        _notificationService = notificationService;

  /// Analyze user behavior and predict churn risk
  Future<ChurnPrediction> predictChurnRisk() async {
    try {
      final stats = await _statsService.getStats();

      // GAP-2: Validate minimum data requirements
      if (!_ChurnValidation.hasMinimumData(stats)) {
        developer.log(
          'Insufficient data for churn prediction - returning unknown risk',
          name: 'ChurnPredictionService',
        );

        return ChurnPrediction(
          riskLevel: ChurnRiskLevel.unknown,
          riskScore: 0.0,
          daysSinceLastActivity: 0,
          shouldSendNotification: false,
          reason: 'Insufficient data for prediction',
          calculatedAt: DateTime.now().toUtc(),
        );
      }

      // GAP-5: UTC normalization for timezone consistency
      final nowUtc = DateTime.now().toUtc();

      // Calculate days since last activity with UTC normalization
      int daysSinceLastActivity = 999; // Default for null
      if (stats.lastActivityDate != null) {
        final lastActivityUtc = stats.lastActivityDate!.toUtc();
        daysSinceLastActivity = nowUtc.difference(lastActivityUtc).inDays;

        // Safety check: prevent negative values from date arithmetic
        if (daysSinceLastActivity < 0) {
          developer.log(
            'WARNING: Negative days since last activity detected, using 0',
            name: 'ChurnPredictionService',
          );
          daysSinceLastActivity = 0;
        }
      }

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
        calculatedAt: nowUtc,
      );

      // GAP-4: Basic analytics logging
      developer.log(
        'ChurnAnalytics: prediction_made '
        'risk=${riskLevel.name} '
        'score=${riskScore.toStringAsFixed(2)} '
        'inactive_days=$daysSinceLastActivity',
        name: 'ChurnPredictionService',
      );

      return prediction;
    } catch (e, stackTrace) {
      developer.log(
        'Error predicting churn risk: $e',
        name: 'ChurnPredictionService',
        error: e,
        stackTrace: stackTrace,
      );

      // GAP-4: Log analytics for failures
      developer.log(
        'ChurnAnalytics: prediction_failed error=$e',
        name: 'ChurnPredictionService',
      );

      // Return safe default - unknown risk, no notification
      return ChurnPrediction(
        riskLevel: ChurnRiskLevel.unknown,
        riskScore: 0.0,
        daysSinceLastActivity: 0,
        shouldSendNotification: false,
        reason: 'Error calculating churn risk',
        calculatedAt: DateTime.now().toUtc(),
      );
    }
  }

  /// Calculate churn risk score based on multiple factors
  double _calculateRiskScore(SpiritualStats stats, int daysSinceLastActivity) {
    double score = 0.0;

    // GAP-2: Safety check for negative or invalid values
    if (daysSinceLastActivity < 0) {
      developer.log(
        'WARNING: Invalid daysSinceLastActivity in score calculation',
        name: 'ChurnPredictionService',
      );
      daysSinceLastActivity = 0;
    }

    // Factor 1: Days since last activity (weight: 40%)
    if (daysSinceLastActivity >= _inactiveDaysThresholdHigh) {
      score += 0.4;
    } else if (daysSinceLastActivity >= _inactiveDaysThresholdMedium) {
      score += 0.2;
    }

    // Factor 2: Streak decline (weight: 30%)
    // GAP-2: Prevent division by zero
    if (stats.longestStreak > 0) {
      final streakDeclineRatio =
          1.0 - (stats.currentStreak / stats.longestStreak);
      score += streakDeclineRatio * 0.3;
    }

    // Factor 3: Reading frequency (weight: 20%)
    if (stats.totalDevocionalesRead < _minReadingsForPrediction) {
      score += _inactivityPenaltyScore; // New users are at risk
    } else if (daysSinceLastActivity > _inactivityDaysForPenalty) {
      // Check recent reading decline based on days since last activity
      // A user who was active but stopped is at higher risk
      score += _inactivityPenaltyScore;
    }

    // Factor 4: Zero current streak (weight: 10%)
    if (stats.currentStreak == 0 && stats.totalDevocionalesRead > 0) {
      score += 0.1;
    }

    // GAP-2: Clamp to valid range
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
  /// @deprecated Use ChurnMonitoringHelper.performDailyCheck() instead
  /// This method is kept for backward compatibility with existing tests
  /// GAP-3: Notification logic should be handled by ChurnMonitoringHelper
  @Deprecated('Use ChurnMonitoringHelper for notification handling')
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
      // Check if churn notifications are enabled by user
      final prefs = await SharedPreferences.getInstance();
      final churnNotificationsEnabled =
          prefs.getBool(_prefKeyChurnNotifications) ?? true; // Default: ON

      if (!churnNotificationsEnabled) {
        developer.log(
          'Churn notifications disabled by user preference - skipping',
          name: 'ChurnPredictionService',
        );
        return;
      }

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
        id: DateTime.now().toUtc().millisecondsSinceEpoch,
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
    final localization = getService<LocalizationService>();

    switch (riskLevel) {
      case ChurnRiskLevel.high:
        return localization.translate('churn_notification.high_title');
      case ChurnRiskLevel.medium:
        return localization.translate('churn_notification.medium_title');
      case ChurnRiskLevel.low:
        return localization.translate('churn_notification.low_title');
      case ChurnRiskLevel.unknown:
        return 'Notification'; // Fallback, should not send notification for unknown
    }
  }

  /// Get notification body based on prediction
  String _getNotificationBody(ChurnPrediction prediction) {
    final localization = getService<LocalizationService>();

    switch (prediction.riskLevel) {
      case ChurnRiskLevel.high:
        return localization.translate(
          'churn_notification.high_body',
          {'days': prediction.daysSinceLastActivity.toString()},
        );
      case ChurnRiskLevel.medium:
        return localization.translate('churn_notification.medium_body');
      case ChurnRiskLevel.low:
        return localization.translate('churn_notification.low_body');
      case ChurnRiskLevel.unknown:
        return 'Insufficient data'; // Fallback, should not send notification for unknown
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

      developer.log(
        'Daily churn check completed: ${prediction.reason}',
        name: 'ChurnPredictionService',
      );
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
      // Check cache first
      final cached = _cache.get();
      if (cached != null) {
        return cached;
      }

      final stats = await _statsService.getStats();
      final prediction = await predictChurnRisk();

      final summary = {
        'total_readings': stats.totalDevocionalesRead,
        'current_streak': stats.currentStreak,
        'longest_streak': stats.longestStreak,
        'days_since_last_activity': prediction.daysSinceLastActivity,
        'churn_risk_level': prediction.riskLevel.toString(),
        'churn_risk_score': prediction.riskScore,
        'engagement_status': _getEngagementStatus(prediction.riskLevel),
        'last_activity_date': stats.lastActivityDate?.toIso8601String(),
      };

      // Cache the result
      _cache.set(summary);

      return summary;
    } catch (e) {
      developer.log(
        'Error getting engagement summary: $e',
        name: 'ChurnPredictionService',
        error: e,
      );
      return {};
    }
  }

  /// Invalidate the metrics cache (call when user stats change)
  void invalidateCache() {
    _cache.invalidate();
  }

  /// Check if churn notifications are enabled
  static Future<bool> areChurnNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyChurnNotifications) ?? true; // Default: ON
  }

  /// Set churn notification preference
  static Future<void> setChurnNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyChurnNotifications, enabled);
    developer.log(
      'Churn notifications ${enabled ? "enabled" : "disabled"}',
      name: 'ChurnPredictionService',
    );
  }

  /// Get engagement status text
  String _getEngagementStatus(ChurnRiskLevel riskLevel) {
    switch (riskLevel) {
      case ChurnRiskLevel.unknown:
        return 'Insufficient Data';
      case ChurnRiskLevel.low:
        return 'Highly Engaged';
      case ChurnRiskLevel.medium:
        return 'Moderately Engaged';
      case ChurnRiskLevel.high:
        return 'At Risk';
    }
  }
}
