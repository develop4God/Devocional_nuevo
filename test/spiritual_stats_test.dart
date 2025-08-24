// test/spiritual_stats_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devocional_nuevo/models/spiritual_stats_model.dart';
import 'package:devocional_nuevo/services/spiritual_stats_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Spiritual Stats Tests', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      // Initialize SharedPreferences mock for each test
      SharedPreferences.setMockInitialValues({});
    });

    test('SpiritualStats model creation and serialization', () {
      final stats = SpiritualStats(
        totalDevocionalesRead: 5,
        currentStreak: 3,
        longestStreak: 7,
        lastActivityDate: DateTime(2025, 1, 1),
        favoritesCount: 2,
        readDevocionalIds: ['dev1', 'dev2', 'dev3'],
      );

      expect(stats.totalDevocionalesRead, 5);
      expect(stats.currentStreak, 3);
      expect(stats.longestStreak, 7);
      expect(stats.favoritesCount, 2);
      expect(stats.readDevocionalIds.length, 3);

      // Test serialization
      final json = stats.toJson();
      final statsFromJson = SpiritualStats.fromJson(json);

      expect(statsFromJson.totalDevocionalesRead, stats.totalDevocionalesRead);
      expect(statsFromJson.currentStreak, stats.currentStreak);
      expect(statsFromJson.longestStreak, stats.longestStreak);
      expect(statsFromJson.favoritesCount, stats.favoritesCount);
      expect(statsFromJson.readDevocionalIds, stats.readDevocionalIds);
    });

    test('Achievement model creation and serialization', () {
      final achievement = Achievement(
        id: 'test_achievement',
        title: 'Test Achievement',
        description: 'Test description',
        icon: Icons.star,
        color: Colors.blue,
        threshold: 5,
        type: AchievementType.reading,
        isUnlocked: true,
      );

      expect(achievement.isUnlocked, true);
      expect(achievement.threshold, 5);
      expect(achievement.type, AchievementType.reading);

      // Test serialization
      final json = achievement.toJson();
      final achievementFromJson = Achievement.fromJson(json);

      expect(achievementFromJson.id, achievement.id);
      expect(achievementFromJson.title, achievement.title);
      expect(achievementFromJson.isUnlocked, achievement.isUnlocked);
      expect(achievementFromJson.type, achievement.type);
    });

    test('PredefinedAchievements contains expected achievements', () {
      final achievements = PredefinedAchievements.all;

      expect(achievements.isNotEmpty, true);
      expect(achievements.length, greaterThanOrEqualTo(8));

      // Check for specific achievements
      final firstReadAchievement = achievements.firstWhere(
        (a) => a.id == 'first_read',
        orElse: () => throw Exception('first_read achievement not found'),
      );

      expect(firstReadAchievement.title, 'Primer Paso');
      expect(firstReadAchievement.threshold, 1);
      expect(firstReadAchievement.type, AchievementType.reading);
    });

    test('SpiritualStatsService handles insufficient criteria', () async {
      final service = SpiritualStatsService();

      // Get initial stats
      final initialStats = await service.getStats();
      expect(initialStats.totalDevocionalesRead, 0);
      expect(initialStats.currentStreak, 0);
      expect(initialStats.readDevocionalIds, isEmpty);

      // Record a devotional read with insufficient criteria (0 seconds, 0% scroll)
      final updatedStats = await service.recordDevocionalRead(
        devocionalId: 'devotional_123',
      );
      expect(updatedStats.totalDevocionalesRead, 0); // Should remain 0
      expect(updatedStats.currentStreak, 0); // Should remain 0
      expect(updatedStats.readDevocionalIds, isEmpty); // Should remain empty

      // Update favorites count (this should still work)
      final statsWithFavorites = await service.updateFavoritesCount(5);
      expect(statsWithFavorites.favoritesCount, 5);
    });

    test('Insufficient criteria prevents duplicate counting', () async {
      final service = SpiritualStatsService();

      // Record the same devotional multiple times with insufficient criteria
      await service.recordDevocionalRead(devocionalId: 'devotional_456');
      await service.recordDevocionalRead(devocionalId: 'devotional_456');
      await service.recordDevocionalRead(devocionalId: 'devotional_456');

      final stats = await service.getStats();

      // Should not count any due to insufficient criteria
      expect(stats.totalDevocionalesRead, 0);
      expect(stats.readDevocionalIds.length, 0);
    });

    test('Insufficient criteria shows no reading activity', () async {
      final service = SpiritualStatsService();

      // Record first read with insufficient criteria
      final firstStats = await service.recordDevocionalRead(
        devocionalId: 'devotional_spam_test',
      );
      expect(firstStats.totalDevocionalesRead,
          0); // Should be 0 due to insufficient criteria

      // Try to record the same devotional again (still insufficient criteria)
      final secondStats = await service.recordDevocionalRead(
        devocionalId: 'devotional_spam_test',
      );
      expect(secondStats.totalDevocionalesRead, 0); // Should remain 0
    });

    test('Multiple devotionals with insufficient criteria', () async {
      final service = SpiritualStatsService();

      // Record multiple different devotionals with insufficient criteria
      await service.recordDevocionalRead(devocionalId: 'devotional_1');
      await service.recordDevocionalRead(devocionalId: 'devotional_2');
      await service.recordDevocionalRead(devocionalId: 'devotional_3');

      final stats = await service.getStats();

      expect(stats.totalDevocionalesRead,
          0); // Should be 0 due to insufficient criteria
      expect(stats.currentStreak, 0); // Should be 0 due to no valid reads
      expect(stats.readDevocionalIds.length,
          0); // Should be empty due to insufficient criteria
    });

    test('No achievements unlocked with insufficient criteria', () async {
      final service = SpiritualStatsService();

      // Try to record devotional read with insufficient criteria
      final stats = await service.recordDevocionalRead(
        devocionalId: 'devotional_achievement_test',
      );

      // Check that no achievements were unlocked
      expect(stats.unlockedAchievements.isEmpty, true);
    });

    test('Favorites count achievement unlocking', () async {
      final service = SpiritualStatsService();

      // Update favorites count to unlock achievement
      final stats = await service.updateFavoritesCount(1);

      // Check if first favorite achievement is unlocked
      final firstFavoriteAchievement = stats.unlockedAchievements.firstWhere(
        (achievement) => achievement.id == 'first_favorite',
        orElse: () =>
            throw Exception('First favorite achievement should be unlocked'),
      );

      expect(firstFavoriteAchievement.isUnlocked, true);
    });

    test('hasDevocionalBeenRead with insufficient criteria', () async {
      final service = SpiritualStatsService();

      // Initially, no devotional has been read
      expect(await service.hasDevocionalBeenRead('test_devotional'), false);

      // Record a devotional read with insufficient criteria
      await service.recordDevocionalRead(devocionalId: 'test_devotional');

      // Should still return false due to insufficient criteria
      expect(await service.hasDevocionalBeenRead('test_devotional'), false);

      // Other devotionals should also return false
      expect(await service.hasDevocionalBeenRead('other_devotional'), false);
    });

    test('Reset stats clears all data', () async {
      final service = SpiritualStatsService();

      // Add some data (though reading won't count due to insufficient criteria)
      await service.recordDevocionalRead(devocionalId: 'test_reset');
      await service.updateFavoritesCount(5);

      // Verify only favorites count exists (reading doesn't count due to criteria)
      var stats = await service.getStats();
      expect(stats.totalDevocionalesRead,
          0); // Should be 0 due to insufficient criteria
      expect(stats.favoritesCount, 5); // This should be set

      // Reset and verify data is cleared
      await service.resetStats();
      stats = await service.getStats();
      expect(stats.totalDevocionalesRead, 0);
      expect(stats.favoritesCount, 0);
      expect(stats.readDevocionalIds, isEmpty);
    });
  });
}
