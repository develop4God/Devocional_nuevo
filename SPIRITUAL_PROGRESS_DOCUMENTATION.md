# Spiritual Progress Statistics - Documentation

## Overview

The Spiritual Progress Statistics system provides automatic tracking and analytics for spiritual activities within the devotional app. This includes tracking completed devotionals, prayer time, memorized verses, and maintaining streaks.

## Key Components

### 1. Models

#### `SpiritualProgressStats`
Main statistics model that tracks:
- `devotionalsCompleted`: Total number of devotionals completed
- `prayerTimeMinutes`: Total prayer time in minutes  
- `versesMemorized`: Total verses memorized
- `currentStreak`: Current consecutive days streak
- `consecutiveDays`: Total consecutive days
- `monthlyStats`: Breakdown by month
- `weeklyStats`: Breakdown by week

#### `SpiritualActivity`
Individual activity record that tracks:
- Activity type (devotional, prayer, verse memorization, etc.)
- Date and time
- Value (duration for prayer, count for activities)
- Metadata (additional context)

### 2. Service

#### `SpiritualProgressService`
Singleton service providing:
- Automatic activity recording
- Statistics aggregation
- Firebase Firestore integration
- Real-time statistics streaming

### 3. Provider Integration

The `DevocionalProvider` has been enhanced with spiritual progress tracking:

```dart
// Mark devotional as completed
await provider.markDevotionalAsCompleted(devocional);

// Record prayer time
await provider.recordPrayerTime(30); // 30 minutes

// Record memorized verse
await provider.recordVerseMemorized("Juan 3:16");

// Get current stats
final stats = await provider.getSpiritualProgressStats();

// Watch stats changes
provider.watchSpiritualProgressStats().listen((stats) {
  // Update UI with new stats
});
```

### 4. UI Widget

#### `SpiritualProgressTracker`
Ready-to-use widget that provides:
- Action buttons for completing activities
- Real-time statistics display
- Input dialogs for prayer time and verses
- Automatic UI updates

## Firebase Structure

### Collections

#### `spiritual_progress_stats`
```
users/{userId} -> {
  devotionalsCompleted: number,
  prayerTimeMinutes: number,
  versesMemorized: number,
  currentStreak: number,
  consecutiveDays: number,
  lastActivityDate: timestamp,
  createdAt: timestamp,
  updatedAt: timestamp,
  monthlyStats: {
    "2023-12": {
      "devotionalCompleted": 5,
      "prayerTime": 150
    }
  },
  weeklyStats: {
    "2023-W48": {
      "devotionalCompleted": 2,
      "prayerTime": 60
    }
  }
}
```

#### `spiritual_activities`
```
activities/{activityId} -> {
  userId: string,
  type: string, // "SpiritualActivityType.devotionalCompleted"
  date: timestamp,
  value: number,
  metadata: {
    devotionalId?: string,
    verse?: string,
    duration?: string
  }
}
```

## Usage Examples

### Basic Integration

```dart
// In a devotional reading page
class DevotionalPage extends StatelessWidget {
  final Devocional devocional;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Devotional content
          DevotionalContent(devocional: devocional),
          
          // Progress tracker
          SpiritualProgressTracker(
            currentDevocional: devocional,
            onProgressUpdated: () {
              // Refresh UI or show celebration
            },
          ),
        ],
      ),
    );
  }
}
```

### Custom Statistics Display

```dart
class StatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DevocionalProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<SpiritualProgressStats?>(
          stream: provider.watchSpiritualProgressStats(),
          builder: (context, snapshot) {
            final stats = snapshot.data;
            if (stats == null) return CircularProgressIndicator();
            
            return Column(
              children: [
                Text('Devotionals: ${stats.devotionalsCompleted}'),
                Text('Prayer: ${stats.prayerTimeMinutes} min'),
                Text('Verses: ${stats.versesMemorized}'),
                Text('Current Streak: ${stats.currentStreak} days'),
              ],
            );
          },
        );
      },
    );
  }
}
```

### Manual Activity Recording

```dart
// Record custom activities
final service = SpiritualProgressService();

// Record devotional completion with metadata
await service.recordDevotionalCompletion(
  devotionalId: 'dev_123',
  date: DateTime.now(),
  additionalMetadata: {
    'timeSpent': 15,
    'rating': 5,
  },
);

// Record prayer session
await service.recordPrayerTime(
  minutes: 20,
  additionalMetadata: {
    'type': 'morning_prayer',
    'focus': 'gratitude',
  },
);

// Record verse memorization
await service.recordVerseMemorized(
  verse: 'Filipenses 4:13',
  additionalMetadata: {
    'difficulty': 'medium',
    'method': 'repetition',
  },
);
```

## Features

### Automatic Tracking
- Activities are automatically recorded when users complete devotionals
- Streak calculation happens automatically
- Statistics are updated in real-time

### Data Persistence
- All data is stored in Firebase Firestore
- Offline support through Firestore caching
- Data synchronization across devices

### Analytics Ready
- Monthly and weekly breakdowns
- Historical activity records
- Configurable reporting periods

### Extensible
- Easy to add new activity types
- Flexible metadata system
- Plugin-ready architecture

## Testing

The implementation includes comprehensive tests:

```bash
# Run specific tests
flutter test test/spiritual_progress_stats_test.dart
flutter test test/spiritual_progress_service_test.dart

# Run all tests
flutter test
```

## Security & Privacy

- User data is isolated by Firebase Auth UID
- Firestore security rules should restrict access to user's own data
- No sensitive information is stored in statistics
- GDPR compliant (data can be deleted)

## Future Enhancements

Potential features for future development:
- Achievement system
- Goal setting and tracking
- Social features (sharing progress)
- Detailed analytics dashboard
- Export functionality
- Reminders and notifications based on activity patterns