// test/spiritual_stats_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devocional_nuevo/models/spiritual_stats_model.dart';
import 'package:devocional_nuevo/services/spiritual_stats_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Spiritual Stats Tests', () {
    setUp(() {
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
      );

      expect(stats.totalDevocionalesRead, 5);
      expect(stats.currentStreak, 3);
      expect(stats.longestStreak, 7);
      expect(stats.favoritesCount, 2);

      // Test serialization
      final json = stats.toJson();
      final statsFromJson = SpiritualStats.fromJson(json);

      expect(statsFromJson.totalDevocionalesRead, stats.totalDevocionalesRead);
      expect(statsFromJson.currentStreak, stats.currentStreak);
      expect(statsFromJson.longestStreak, stats.longestStreak);
      expect(statsFromJson.favoritesCount, stats.favoritesCount);
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

    test('SpiritualStatsService basic functionality', () async {
      final service = SpiritualStatsService();
      
      // Get initial stats
      final initialStats = await service.getStats();
      expect(initialStats.totalDevocionalesRead, 0);
      expect(initialStats.currentStreak, 0);
      
      // Record a devotional read
      final updatedStats = await service.recordDevocionalRead();
      expect(updatedStats.totalDevocionalesRead, 1);
      expect(updatedStats.currentStreak, 1);
      expect(updatedStats.lastActivityDate, isNotNull);
      
      // Update favorites count
      final statsWithFavorites = await service.updateFavoritesCount(5);
      expect(statsWithFavorites.favoritesCount, 5);
    });
  });
}