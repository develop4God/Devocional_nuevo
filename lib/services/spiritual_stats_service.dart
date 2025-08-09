// lib/services/spiritual_stats_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/spiritual_stats_model.dart';

class SpiritualStatsService {
  static const String _statsKey = 'spiritual_stats';
  static const String _readDatesKey = 'read_dates';

  /// Get current spiritual statistics
  Future<SpiritualStats> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    final String? statsJson = prefs.getString(_statsKey);
    
    if (statsJson != null) {
      try {
        final Map<String, dynamic> data = json.decode(statsJson);
        return SpiritualStats.fromJson(data);
      } catch (e) {
        debugPrint('Error parsing spiritual stats: $e');
      }
    }
    
    return SpiritualStats();
  }

  /// Save spiritual statistics
  Future<void> saveStats(SpiritualStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    final String statsJson = json.encode(stats.toJson());
    await prefs.setString(_statsKey, statsJson);
  }

  /// Record that a devotional was read today
  Future<SpiritualStats> recordDevocionalRead({int? favoritesCount}) async {
    final stats = await getStats();
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    
    // Get list of read dates
    final readDates = await _getReadDates();
    
    // Check if already read today
    final alreadyReadToday = readDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
    
    if (alreadyReadToday) {
      // If already read today, just update favorites count if provided
      final updatedStats = stats.copyWith(
        favoritesCount: favoritesCount ?? stats.favoritesCount,
      );
      await saveStats(updatedStats);
      return updatedStats;
    }
    
    // Add today to read dates
    readDates.add(todayDateOnly);
    await _saveReadDates(readDates);
    
    // Calculate new streak
    final newStreak = _calculateCurrentStreak(readDates);
    
    // Update stats
    final updatedStats = stats.copyWith(
      totalDevocionalesRead: stats.totalDevocionalesRead + 1,
      currentStreak: newStreak,
      longestStreak: newStreak > stats.longestStreak ? newStreak : stats.longestStreak,
      lastActivityDate: today,
      favoritesCount: favoritesCount ?? stats.favoritesCount,
      unlockedAchievements: _updateAchievements(stats, newStreak, stats.totalDevocionalesRead + 1, favoritesCount ?? stats.favoritesCount),
    );
    
    await saveStats(updatedStats);
    return updatedStats;
  }

  /// Update favorites count
  Future<SpiritualStats> updateFavoritesCount(int favoritesCount) async {
    final stats = await getStats();
    final updatedStats = stats.copyWith(
      favoritesCount: favoritesCount,
      unlockedAchievements: _updateAchievements(stats, stats.currentStreak, stats.totalDevocionalesRead, favoritesCount),
    );
    
    await saveStats(updatedStats);
    return updatedStats;
  }

  /// Get list of dates when devotionals were read
  Future<List<DateTime>> _getReadDates() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? dateStrings = prefs.getStringList(_readDatesKey);
    
    if (dateStrings == null) return [];
    
    return dateStrings.map((dateString) {
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        debugPrint('Error parsing read date: $dateString');
        return null;
      }
    }).where((date) => date != null).cast<DateTime>().toList();
  }

  /// Save list of read dates
  Future<void> _saveReadDates(List<DateTime> dates) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> dateStrings = dates
        .map((date) => date.toIso8601String().split('T').first)
        .toList();
    await prefs.setStringList(_readDatesKey, dateStrings);
  }

  /// Calculate current streak from read dates
  int _calculateCurrentStreak(List<DateTime> readDates) {
    if (readDates.isEmpty) return 0;
    
    // Sort dates in descending order
    readDates.sort((a, b) => b.compareTo(a));
    
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    
    int streak = 0;
    DateTime currentDate = todayDateOnly;
    
    for (final readDate in readDates) {
      final readDateOnly = DateTime(readDate.year, readDate.month, readDate.day);
      
      if (readDateOnly.isAtSameMomentAs(currentDate)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else if (readDateOnly.isBefore(currentDate)) {
        // Gap in streak
        break;
      }
    }
    
    return streak;
  }

  /// Update achievements based on current stats
  List<Achievement> _updateAchievements(SpiritualStats currentStats, int newStreak, int totalRead, int favoritesCount) {
    final allAchievements = PredefinedAchievements.all;
    final unlockedAchievements = List<Achievement>.from(currentStats.unlockedAchievements);
    
    for (final achievement in allAchievements) {
      final isAlreadyUnlocked = unlockedAchievements.any((a) => a.id == achievement.id);
      
      if (!isAlreadyUnlocked) {
        bool shouldUnlock = false;
        
        switch (achievement.type) {
          case AchievementType.reading:
            shouldUnlock = totalRead >= achievement.threshold;
            break;
          case AchievementType.streak:
            shouldUnlock = newStreak >= achievement.threshold;
            break;
          case AchievementType.favorites:
            shouldUnlock = favoritesCount >= achievement.threshold;
            break;
        }
        
        if (shouldUnlock) {
          unlockedAchievements.add(achievement.copyWith(isUnlocked: true));
        }
      }
    }
    
    return unlockedAchievements;
  }

  /// Reset all statistics (for testing purposes)
  Future<void> resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_statsKey);
    await prefs.remove(_readDatesKey);
  }

  /// Get read dates for streak visualization
  Future<List<DateTime>> getReadDatesForVisualization() async {
    return await _getReadDates();
  }
}