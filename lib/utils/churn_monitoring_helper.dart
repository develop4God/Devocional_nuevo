// lib/utils/churn_monitoring_helper.dart

import 'dart:developer' as developer;

import 'package:devocional_nuevo/services/churn_prediction_service.dart';
import 'package:devocional_nuevo/services/localization_service.dart';
import 'package:devocional_nuevo/services/notification_service.dart';
import 'package:devocional_nuevo/services/service_locator.dart';
import 'package:devocional_nuevo/utils/time_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static TimeProvider? _customTimeProvider;

  static void setTimeProvider(TimeProvider provider) {
    developer.log('🛠️ [Logger] setTimeProvider: ${provider.runtimeType}',
        name: 'ChurnMonitoringHelper');
    _customTimeProvider = provider;
  }

  /// Perform daily churn check with rate limiting and analytics
  /// This should be called once per day via background task or app start
  static Future<void> performDailyCheck() async {
    try {
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

      final churnService = getService<ChurnPredictionService>();
      final prediction = await churnService.predictChurnRisk();

      // Log del razonamiento del modelo
      developer.log(
        '🔎 [QA] ChurnModel: risk=${prediction.riskLevel.name} score=${prediction.riskScore.toStringAsFixed(2)} inactive_days=${prediction.daysSinceLastActivity} reason=${prediction.reason}',
        name: 'ChurnMonitoringHelper',
      );

      if (prediction.shouldSendNotification) {
        final canSend = await _canSendNotification();
        developer.log(
          '🔔 [QA] Notificación aplica: SÍ | RateLimit: ${canSend ? "OK" : "LIMITADO"}',
          name: 'ChurnMonitoringHelper',
        );
        if (canSend) {
          await _sendChurnNotification(prediction);
          developer.log(
            'ChurnAnalytics: notification_sent level=${prediction.riskLevel.name}',
            name: 'ChurnMonitoringHelper',
          );
          await _recordNotificationSent();
        } else {
          developer.log(
            'ChurnAnalytics: notification_rate_limited',
            name: 'ChurnMonitoringHelper',
          );
        }
      } else {
        developer.log(
          '🔔 [QA] Notificación aplica: NO | Motivo: ${prediction.reason}',
          name: 'ChurnMonitoringHelper',
        );
      }
      developer.log(
        'Daily churn monitoring check completed',
        name: 'ChurnMonitoringHelper',
      );
    } catch (e, stackTrace) {
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
    developer.log(
        '🔎 [Logger] _canSendNotification: Iniciando verificación de rate limit',
        name: 'ChurnMonitoringHelper');
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_prefKeyNotificationHistory) ?? [];
      final cutoffTime = (_customTimeProvider ?? SystemTimeProvider())
          .now()
          .subtract(_rateLimitWindow);
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
      developer.log(
          '🔎 [Logger] _canSendNotification: Notificaciones recientes en ventana: $recentNotifications',
          name: 'ChurnMonitoringHelper');
      return recentNotifications < _maxNotificationsPerWeek;
    } catch (e) {
      developer.log('❌ [Logger] _canSendNotification: Error $e',
          name: 'ChurnMonitoringHelper');
      return true;
    }
  }

  /// GAP-7: Record that a notification was sent
  static Future<void> _recordNotificationSent() async {
    developer.log(
        '📝 [Logger] _recordNotificationSent: Registrando notificación enviada',
        name: 'ChurnMonitoringHelper');
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_prefKeyNotificationHistory) ?? [];
      history.add(((_customTimeProvider ?? SystemTimeProvider()).now())
          .toIso8601String());
      final cutoffTime = (_customTimeProvider ?? SystemTimeProvider())
          .now()
          .subtract(_rateLimitWindow);
      final cleanedHistory = history.where((timestamp) {
        try {
          final date = DateTime.parse(timestamp);
          return date.isAfter(cutoffTime);
        } catch (e) {
          return false;
        }
      }).toList();
      await prefs.setStringList(_prefKeyNotificationHistory, cleanedHistory);
      developer.log(
          '📝 [Logger] _recordNotificationSent: Historial actualizado: ${cleanedHistory.length} registros',
          name: 'ChurnMonitoringHelper');
    } catch (e) {
      developer.log('❌ [Logger] _recordNotificationSent: Error $e',
          name: 'ChurnMonitoringHelper');
    }
  }

  /// GAP-3: Send churn notification (notification logic separated from service)
  static Future<void> _sendChurnNotification(ChurnPrediction prediction) async {
    developer.log(
        '🚀 [Logger] _sendChurnNotification: Enviando notificación. Nivel: ${prediction.riskLevel.name}',
        name: 'ChurnMonitoringHelper');
    try {
      final notificationService = NotificationService();
      final localizationService = getService<LocalizationService>();
      String title;
      String body;
      switch (prediction.riskLevel) {
        case ChurnRiskLevel.high:
          title =
              localizationService.translate('churn_notification.high_title');
          body = localizationService.translate('churn_notification.high_body',
              {'days': prediction.daysSinceLastActivity.toString()});
          break;
        case ChurnRiskLevel.medium:
          title =
              localizationService.translate('churn_notification.medium_title');
          body =
              localizationService.translate('churn_notification.medium_body');
          break;
        default:
          developer.log(
              '🚫 [Logger] _sendChurnNotification: No aplica notificación para nivel ${prediction.riskLevel.name}',
              name: 'ChurnMonitoringHelper');
          return;
      }
      await notificationService.showImmediateNotification(
        title,
        body,
        payload: 'churn_prevention',
        id: (_customTimeProvider ?? SystemTimeProvider())
            .now()
            .millisecondsSinceEpoch,
      );
      developer.log(
          '✅ [Logger] _sendChurnNotification: Notificación enviada: $title',
          name: 'ChurnMonitoringHelper');
    } catch (e) {
      developer.log('❌ [Logger] _sendChurnNotification: Error $e',
          name: 'ChurnMonitoringHelper');
    }
  }

  /// Get current engagement summary for the user
  static Future<Map<String, dynamic>> getEngagementSummary() async {
    developer.log(
        '📊 [Logger] getEngagementSummary: Obteniendo resumen de engagement',
        name: 'ChurnMonitoringHelper');
    try {
      final churnService = getService<ChurnPredictionService>();
      return await churnService.getEngagementSummary();
    } catch (e) {
      developer.log('❌ [Logger] getEngagementSummary: Error $e',
          name: 'ChurnMonitoringHelper');
      return {};
    }
  }

  /// Check if user is at risk and return risk level
  static Future<ChurnRiskLevel> checkUserRisk() async {
    developer.log('🔎 [Logger] checkUserRisk: Verificando nivel de riesgo',
        name: 'ChurnMonitoringHelper');
    try {
      final churnService = getService<ChurnPredictionService>();
      final prediction = await churnService.predictChurnRisk();
      developer.log(
          '🔎 [Logger] checkUserRisk: Nivel de riesgo: ${prediction.riskLevel.name}',
          name: 'ChurnMonitoringHelper');
      return prediction.riskLevel;
    } catch (e) {
      developer.log('❌ [Logger] checkUserRisk: Error $e',
          name: 'ChurnMonitoringHelper');
      return ChurnRiskLevel.unknown;
    }
  }

  /// Manually trigger a churn prevention notification (for testing)
  static Future<void> sendChurnPreventionNotification() async {
    developer.log(
        '🚦 [Logger] sendChurnPreventionNotification: Forzando notificación manual',
        name: 'ChurnMonitoringHelper');
    try {
      final churnService = getService<ChurnPredictionService>();
      final prediction = await churnService.predictChurnRisk();
      if (prediction.shouldSendNotification) {
        await _sendChurnNotification(prediction);
        developer.log(
            '✅ [Logger] sendChurnPreventionNotification: Notificación enviada manualmente',
            name: 'ChurnMonitoringHelper');
      } else {
        developer.log(
            '🚫 [Logger] sendChurnPreventionNotification: No aplica notificación para el nivel actual',
            name: 'ChurnMonitoringHelper');
      }
    } catch (e) {
      developer.log('❌ [Logger] sendChurnPreventionNotification: Error $e',
          name: 'ChurnMonitoringHelper');
    }
  }

  /// Get notification history count (for debugging)
  static Future<int> getNotificationHistoryCount() async {
    developer.log(
        '📋 [Logger] getNotificationHistoryCount: Consultando historial de notificaciones',
        name: 'ChurnMonitoringHelper');
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_prefKeyNotificationHistory) ?? [];
      final cutoffTime = DateTime.now().toUtc().subtract(_rateLimitWindow);
      final count = history
          .map((timestamp) {
            try {
              return DateTime.parse(timestamp);
            } catch (e) {
              return null;
            }
          })
          .where((date) => date != null && date.isAfter(cutoffTime))
          .length;
      developer.log(
          '📋 [Logger] getNotificationHistoryCount: Total en ventana: $count',
          name: 'ChurnMonitoringHelper');
      return count;
    } catch (e) {
      developer.log('❌ [Logger] getNotificationHistoryCount: Error $e',
          name: 'ChurnMonitoringHelper');
      return 0;
    }
  }
}
