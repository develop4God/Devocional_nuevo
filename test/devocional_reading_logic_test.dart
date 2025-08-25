// test/devocional_reading_logic_test.dart

import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/services/spiritual_stats_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Devotional Reading Logic Tests', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      // Initialize SharedPreferences mock for each test
      SharedPreferences.setMockInitialValues({});
    });

    test(
        'DevocionalProvider recordDevocionalRead handles insufficient reading time',
        () async {
      final provider = DevocionalProvider();
      final statsService = SpiritualStatsService();

      // Record a devotional read with insufficient reading criteria (0 seconds, 0% scroll)
      await provider.recordDevocionalRead('test_devotional_123');

      // Verify it was NOT counted in stats due to insufficient criteria
      final stats = await statsService.getStats();
      expect(stats.totalDevocionalesRead,
          0); // Should be 0 due to insufficient criteria
      expect(stats.readDevocionalIds, isEmpty); // Should be empty
    });

    test('Empty devotional ID is handled gracefully', () async {
      final provider = DevocionalProvider();
      final statsService = SpiritualStatsService();

      // Try to record with empty ID
      await provider.recordDevocionalRead('');

      // Should not record anything
      final stats = await statsService.getStats();
      expect(stats.totalDevocionalesRead, 0);
      expect(stats.readDevocionalIds, isEmpty);
    });

    test('Real usage pattern: tracking with insufficient criteria', () async {
      final provider = DevocionalProvider();
      final statsService = SpiritualStatsService();

      // Simulate reading devotionals with unique consecutive IDs (but insufficient criteria)
      final devotionalIds = [
        'devotional_2025_01_01',
        'devotional_2025_01_02',
        'devotional_2025_01_03',
      ];

      for (final id in devotionalIds) {
        await provider.recordDevocionalRead(id);
      }

      final stats = await statsService.getStats();
      expect(stats.totalDevocionalesRead,
          0); // Should be 0 due to insufficient criteria
      expect(stats.readDevocionalIds.length, 0);
    });

    test('Rapid tapping with insufficient criteria', () async {
      final provider = DevocionalProvider();
      final statsService = SpiritualStatsService();

      // Try rapid tapping with insufficient reading criteria
      await provider.recordDevocionalRead('rapid_tap_test');
      await provider.recordDevocionalRead('rapid_tap_test');
      await provider.recordDevocionalRead('rapid_tap_test');
      await provider.recordDevocionalRead('rapid_tap_test');

      final stats = await statsService.getStats();
      expect(stats.totalDevocionalesRead,
          0); // Should be 0 due to insufficient criteria
    });

    test('Service handles insufficient criteria correctly', () async {
      final statsService = SpiritualStatsService();

      // Record initial read with insufficient criteria (0 time, 0 scroll)
      await statsService.recordDevocionalRead(devocionalId: 'time_test');

      final stats = await statsService.getStats();
      expect(stats.totalDevocionalesRead,
          0); // Should be 0 due to insufficient criteria

      // Verify the devotional is still not marked as read for statistics
      expect(await statsService.hasDevocionalBeenRead('time_test'), false);
    });

    test('Favorites count preserved regardless of reading criteria', () async {
      final statsService = SpiritualStatsService();

      // Record devotional read with favorites count but insufficient criteria
      await statsService.recordDevocionalRead(
        devocionalId: 'favorites_integration_test',
        favoritesCount: 3,
      );

      final stats = await statsService.getStats();
      expect(stats.totalDevocionalesRead,
          0); // Reading doesn't count due to criteria
      expect(
          stats.favoritesCount, 3); // But favorites count should be preserved
    });

    test('No achievements unlocked with insufficient criteria', () async {
      final provider = DevocionalProvider();
      final statsService = SpiritualStatsService();

      // Try to record devotional with insufficient criteria
      await provider.recordDevocionalRead('achievement_test_1');

      final stats = await statsService.getStats();
      expect(stats.totalDevocionalesRead, 0); // No reading counted

      // Check that no achievements were unlocked
      expect(stats.unlockedAchievements.isEmpty, true);
    });

    test('No streak with insufficient criteria', () async {
      final statsService = SpiritualStatsService();

      // Try to record devotional reads with insufficient criteria
      await statsService.recordDevocionalRead(devocionalId: 'day_1_devotional');

      // Check that no streak is established
      var stats = await statsService.getStats();
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);

      // Try another devotional with insufficient criteria
      await statsService.recordDevocionalRead(
          devocionalId: 'day_1_devotional_2');

      stats = await statsService.getStats();
      expect(stats.totalDevocionalesRead, 0); // No readings counted
    });

    test('Service handles malformed data gracefully', () async {
      final statsService = SpiritualStatsService();

      // Try to record with null-like values
      try {
        await statsService.recordDevocionalRead(devocionalId: '');
        // Should not throw an error, but also shouldn't record anything
      } catch (e) {
        fail('Service should handle empty ID gracefully');
      }

      final stats = await statsService.getStats();
      expect(stats.totalDevocionalesRead, 0);
    });

    test('No achievements with insufficient criteria', () async {
      final statsService = SpiritualStatsService();

      // Try to record multiple devotionals with insufficient criteria
      for (int i = 1; i <= 7; i++) {
        await statsService.recordDevocionalRead(devocionalId: 'devotional_$i');
      }

      final stats = await statsService.getStats();
      expect(stats.totalDevocionalesRead,
          0); // No readings counted due to criteria

      // Should not unlock any achievements
      expect(stats.unlockedAchievements.isEmpty, true);
    });
  });
}
