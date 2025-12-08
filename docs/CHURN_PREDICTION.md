# User Churn Detection & Prediction Feature

## Overview

The User Churn Prediction feature analyzes user engagement patterns to identify users at risk of churning (stopping app usage) and automatically sends targeted re-engagement notifications.

## Features

### 1. Churn Risk Analysis
- **Multi-factor Algorithm**: Analyzes user behavior based on:
  - Days since last activity
  - Current streak vs. longest streak
  - Reading frequency patterns
  - Overall engagement metrics
  
- **Risk Levels**:
  - **Low**: User is actively engaged
  - **Medium**: User shows signs of decreased engagement
  - **High**: User is at high risk of churning

### 2. Intelligent Notifications
- **Risk-based Messaging**: Different notification content for each risk level
- **Timezone-aware**: Uses existing timezone infrastructure (`flutter_timezone`)
- **Permission-aware**: Respects user notification preferences
- **Local Notifications**: Leverages `flutter_local_notifications` package

### 3. Dependency Injection
- **Non-Singleton Pattern**: Service is registered as factory in `ServiceLocator`
- **Testable**: Easy to mock and test
- **No Shared State**: Each instance is independent

## Architecture

```
ChurnPredictionService (Factory)
├── Dependencies
│   ├── SpiritualStatsService
│   └── NotificationService
├── Risk Calculation
│   ├── Days since last activity (40% weight)
│   ├── Streak decline (30% weight)
│   ├── Reading frequency (20% weight)
│   └── Zero current streak (10% weight)
└── Notification Logic
    ├── Risk-based decisions
    ├── User preference checks
    └── Targeted messaging
```

## Usage

### Basic Usage

```dart
import 'package:devocional_nuevo/services/service_locator.dart';
import 'package:devocional_nuevo/utils/churn_monitoring_helper.dart';

// Perform daily churn check (call from background task or app startup)
await ChurnMonitoringHelper.performDailyCheck();
```

### Advanced Usage

```dart
import 'package:devocional_nuevo/services/churn_prediction_service.dart';
import 'package:devocional_nuevo/services/service_locator.dart';

// Get service instance
final churnService = getService<ChurnPredictionService>();

// 1. Get current risk prediction
final prediction = await churnService.predictChurnRisk();
print('Risk Level: ${prediction.riskLevel}');
print('Risk Score: ${prediction.riskScore}');
print('Days Inactive: ${prediction.daysSinceLastActivity}');
print('Reason: ${prediction.reason}');

// 2. Send manual notification if needed
if (prediction.shouldSendNotification) {
  await churnService.sendChurnPreventionNotification(prediction);
}

// 3. Get engagement summary
final summary = await churnService.getEngagementSummary();
print('Total Readings: ${summary['total_readings']}');
print('Current Streak: ${summary['current_streak']}');
print('Engagement Status: ${summary['engagement_status']}');
```

### Helper Methods

The `ChurnMonitoringHelper` class provides convenient methods:

```dart
// Check if user is at risk
final riskLevel = await ChurnMonitoringHelper.checkUserRisk();

// Get engagement summary
final summary = await ChurnMonitoringHelper.getEngagementSummary();

// Manually trigger notification
await ChurnMonitoringHelper.sendChurnPreventionNotification();
```

## Configuration

### Risk Thresholds

The service uses the following default thresholds (configurable via constants):

```dart
_inactiveDaysThresholdHigh = 7;    // 1 week of inactivity = HIGH risk
_inactiveDaysThresholdMedium = 3;  // 3 days of inactivity = MEDIUM risk
_minReadingsForPrediction = 3;     // Minimum readings to analyze patterns
```

### Notification Content

| Risk Level | Title | Body |
|------------|-------|------|
| High | ¡Te extrañamos! 🙏 | Han pasado X días. Vuelve a conectarte con tu fe. |
| Medium | Tu devocional te está esperando 📖 | No pierdas tu racha. Lee el devocional de hoy. |
| Low | ¡Continúa tu racha! 🔥 | ¡Sigue así! Tu dedicación es inspiradora. |

## Integration

### 1. Service Registration

The service is automatically registered in `setupServiceLocator()`:

```dart
// lib/services/service_locator.dart
locator.registerFactory<ChurnPredictionService>(
  () => ChurnPredictionService(
    statsService: SpiritualStatsService(),
    notificationService: NotificationService(),
  ),
);
```

### 2. Background Tasks

To integrate with background tasks or scheduled jobs:

```dart
// Example: Daily background task
void scheduleDailyChurnCheck() {
  // Use your preferred background task scheduler
  // (e.g., workmanager, flutter_background_service)
  
  Workmanager().registerPeriodicTask(
    "churn-check",
    "churnCheck",
    frequency: Duration(hours: 24),
    constraints: Constraints(
      networkType: NetworkType.not_required,
    ),
  );
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await ChurnMonitoringHelper.performDailyCheck();
    return Future.value(true);
  });
}
```

### 3. App Startup Integration

```dart
// In your main.dart or app initialization
void initializeChurnMonitoring() async {
  // Perform initial check on app startup
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... other initialization ...
  
  // Check churn risk on app start
  try {
    await ChurnMonitoringHelper.performDailyCheck();
  } catch (e) {
    debugPrint('Churn check failed: $e');
  }
}
```

## Testing

The feature includes comprehensive test coverage:

### Test Statistics
- **Total Tests**: 24
- **Service Tests**: 15
- **Integration Helper Tests**: 9
- **Coverage**: Risk calculation, notifications, error handling, edge cases

### Running Tests

```bash
# Run churn prediction service tests
flutter test test/services/churn_prediction_service_test.dart

# Run helper tests
flutter test test/utils/churn_monitoring_helper_test.dart

# Run all tests
flutter test
```

### Test Examples

```dart
// Example: Testing risk prediction
test('predicts HIGH risk for inactive user', () async {
  final stats = SpiritualStats(
    totalDevocionalesRead: 10,
    currentStreak: 0,
    longestStreak: 10,
    lastActivityDate: DateTime.now().subtract(Duration(days: 8)),
  );
  
  final prediction = await churnService.predictChurnRisk();
  
  expect(prediction.riskLevel, ChurnRiskLevel.high);
  expect(prediction.shouldSendNotification, true);
});
```

## Algorithm Details

### Risk Score Calculation

The risk score (0.0 to 1.0) is calculated using weighted factors:

1. **Inactivity (40% weight)**
   - ≥7 days inactive: +0.4
   - ≥3 days inactive: +0.2
   
2. **Streak Decline (30% weight)**
   - Score = (1 - current_streak / longest_streak) × 0.3
   
3. **Reading Frequency (20% weight)**
   - <3 total readings: +0.2
   - Reading rate <0.3/day: +0.2
   
4. **Zero Current Streak (10% weight)**
   - Current streak = 0 (but has history): +0.1

### Decision Logic

```
if (riskScore ≥ 0.6 OR daysInactive ≥ 7):
  riskLevel = HIGH
  shouldSendNotification = true
  
elif (riskScore ≥ 0.3 OR daysInactive ≥ 3):
  riskLevel = MEDIUM
  shouldSendNotification = true (if ≥3 days inactive)
  
else:
  riskLevel = LOW
  shouldSendNotification = false
```

## Dependencies

The feature uses existing infrastructure:

- `flutter_local_notifications`: ^19.3.0 - Local notification display
- `timezone`: ^0.10.1 - Timezone calculations
- `permission_handler`: ^12.0.1 - Permission management
- `flutter_timezone`: ^4.1.1 - Device timezone detection

## Best Practices

1. **Call Daily**: Perform churn checks once per day via background task
2. **Respect Preferences**: Always check user notification preferences
3. **Monitor Performance**: Track notification open rates and engagement
4. **Adjust Thresholds**: Fine-tune risk thresholds based on your user base
5. **Test Thoroughly**: Use provided tests as examples for custom scenarios

## Troubleshooting

### Notifications Not Sending

1. Check notification permissions:
   ```dart
   final enabled = await notificationService.areNotificationsEnabled();
   ```

2. Verify user has activity history:
   ```dart
   final stats = await statsService.getStats();
   print('Total readings: ${stats.totalDevocionalesRead}');
   ```

3. Check risk prediction:
   ```dart
   final prediction = await churnService.predictChurnRisk();
   print('Should send: ${prediction.shouldSendNotification}');
   print('Reason: ${prediction.reason}');
   ```

### High False Positives

If too many users are marked as high risk:
- Increase `_inactiveDaysThresholdHigh` (default: 7)
- Adjust risk score weights
- Add additional engagement signals

### Low Detection Rate

If at-risk users aren't being detected:
- Decrease `_inactiveDaysThresholdMedium` (default: 3)
- Lower the medium risk score threshold (default: 0.3)
- Add more sensitive engagement metrics

## Future Enhancements

Potential improvements:
- Machine learning-based predictions
- A/B testing for notification content
- Time-of-day optimization
- Personalized re-engagement strategies
- Integration with Firebase Analytics
- Cohort analysis

## License

This feature is part of the Devocional Nuevo app and follows the same license terms.

## Support

For questions or issues:
1. Check the test files for usage examples
2. Review the inline documentation
3. Create an issue in the repository
