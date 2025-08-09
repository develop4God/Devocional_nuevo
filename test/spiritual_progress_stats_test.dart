import 'package:flutter_test/flutter_test.dart';
import 'package:devocional_nuevo/models/spiritual_progress_stats.dart';

void main() {
  group('SpiritualProgressStats Model Tests', () {
    test('should create initial stats correctly', () {
      const userId = 'test_user_123';
      final stats = SpiritualProgressStats.createInitial(userId);

      expect(stats.userId, equals(userId));
      expect(stats.devotionalsCompleted, equals(0));
      expect(stats.prayerTimeMinutes, equals(0));
      expect(stats.versesMemorized, equals(0));
      expect(stats.currentStreak, equals(0));
      expect(stats.consecutiveDays, equals(0));
      expect(stats.monthlyStats, isEmpty);
      expect(stats.weeklyStats, isEmpty);
    });

    test('should convert to and from JSON correctly', () {
      final originalStats = SpiritualProgressStats(
        userId: 'test_user_123',
        devotionalsCompleted: 5,
        prayerTimeMinutes: 120,
        versesMemorized: 3,
        consecutiveDays: 7,
        currentStreak: 7,
        lastActivityDate: DateTime(2023, 12, 1),
        createdAt: DateTime(2023, 11, 1),
        updatedAt: DateTime(2023, 12, 1),
        monthlyStats: {'2023-12': {'devotionalCompleted': 5}},
        weeklyStats: {'2023-W48': {'prayerTime': 120}},
      );

      final json = originalStats.toJson();
      final reconstructedStats = SpiritualProgressStats.fromJson(json);

      expect(reconstructedStats.userId, equals(originalStats.userId));
      expect(reconstructedStats.devotionalsCompleted, equals(originalStats.devotionalsCompleted));
      expect(reconstructedStats.prayerTimeMinutes, equals(originalStats.prayerTimeMinutes));
      expect(reconstructedStats.versesMemorized, equals(originalStats.versesMemorized));
      expect(reconstructedStats.currentStreak, equals(originalStats.currentStreak));
      expect(reconstructedStats.monthlyStats, equals(originalStats.monthlyStats));
      expect(reconstructedStats.weeklyStats, equals(originalStats.weeklyStats));
    });

    test('should create copy with updated values correctly', () {
      final originalStats = SpiritualProgressStats.createInitial('test_user');
      final updatedStats = originalStats.copyWith(
        devotionalsCompleted: 10,
        prayerTimeMinutes: 200,
        currentStreak: 5,
      );

      expect(updatedStats.userId, equals(originalStats.userId));
      expect(updatedStats.devotionalsCompleted, equals(10));
      expect(updatedStats.prayerTimeMinutes, equals(200));
      expect(updatedStats.currentStreak, equals(5));
      expect(updatedStats.versesMemorized, equals(originalStats.versesMemorized));
    });

    test('should handle equality comparison correctly', () {
      final stats1 = SpiritualProgressStats(
        userId: 'user1',
        devotionalsCompleted: 5,
        prayerTimeMinutes: 100,
        versesMemorized: 2,
        consecutiveDays: 3,
        currentStreak: 3,
        lastActivityDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final stats2 = SpiritualProgressStats(
        userId: 'user1',
        devotionalsCompleted: 5,
        prayerTimeMinutes: 100,
        versesMemorized: 2,
        consecutiveDays: 3,
        currentStreak: 3,
        lastActivityDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final stats3 = SpiritualProgressStats(
        userId: 'user1',
        devotionalsCompleted: 10, // Different value
        prayerTimeMinutes: 100,
        versesMemorized: 2,
        consecutiveDays: 3,
        currentStreak: 3,
        lastActivityDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(stats1, equals(stats2));
      expect(stats1, isNot(equals(stats3)));
    });
  });

  group('SpiritualActivity Model Tests', () {
    test('should create activity with all properties', () {
      final activity = SpiritualActivity(
        id: 'activity_123',
        userId: 'user_123',
        type: SpiritualActivityType.devotionalCompleted,
        date: DateTime(2023, 12, 1),
        metadata: {'devotionalId': 'dev_001'},
        value: 1,
      );

      expect(activity.id, equals('activity_123'));
      expect(activity.userId, equals('user_123'));
      expect(activity.type, equals(SpiritualActivityType.devotionalCompleted));
      expect(activity.value, equals(1));
      expect(activity.metadata['devotionalId'], equals('dev_001'));
    });

    test('should convert to Firestore format correctly', () {
      final activity = SpiritualActivity(
        id: 'activity_123',
        userId: 'user_123',
        type: SpiritualActivityType.prayerTime,
        date: DateTime(2023, 12, 1),
        metadata: {'duration': '30 minutes'},
        value: 30,
      );

      final firestoreData = activity.toFirestore();

      expect(firestoreData['userId'], equals('user_123'));
      expect(firestoreData['type'], equals('SpiritualActivityType.prayerTime'));
      expect(firestoreData['value'], equals(30));
      expect(firestoreData['metadata'], equals({'duration': '30 minutes'}));
    });
  });

  group('SpiritualActivityType Enum Tests', () {
    test('should have all expected activity types', () {
      final expectedTypes = [
        SpiritualActivityType.devotionalCompleted,
        SpiritualActivityType.prayerTime,
        SpiritualActivityType.verseMemorized,
        SpiritualActivityType.bibleReading,
        SpiritualActivityType.worship,
        SpiritualActivityType.service,
      ];

      expect(SpiritualActivityType.values.length, equals(expectedTypes.length));
      
      for (final type in expectedTypes) {
        expect(SpiritualActivityType.values, contains(type));
      }
    });
  });
}