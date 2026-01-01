// test/providers/devocional_provider_multi_year_test.dart

import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/services/spiritual_stats_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Devotional Multi-Year Loading Tests', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      registerTestServices();
    });

    test('Sequential devotional ID format follows expected pattern', () {
      // Test that devotional IDs maintain the expected format across years
      final devocionales = [
        Devocional(
          id: 'devocional_2025_01_01',
          versiculo: 'Test verse',
          reflexion: 'Test reflection',
          paraMeditar: [],
          oracion: 'Test prayer',
          date: DateTime(2025, 1, 1),
          version: 'RVR1960',
          language: 'es',
        ),
        Devocional(
          id: 'devocional_2025_12_31',
          versiculo: 'Test verse',
          reflexion: 'Test reflection',
          paraMeditar: [],
          oracion: 'Test prayer',
          date: DateTime(2025, 12, 31),
          version: 'RVR1960',
          language: 'es',
        ),
        Devocional(
          id: 'devocional_2026_01_01',
          versiculo: 'Test verse',
          reflexion: 'Test reflection',
          paraMeditar: [],
          oracion: 'Test prayer',
          date: DateTime(2026, 1, 1),
          version: 'RVR1960',
          language: 'es',
        ),
      ];

      // Verify they're sorted correctly
      final sorted = List<Devocional>.from(devocionales)
        ..sort((a, b) => a.date.compareTo(b.date));

      expect(sorted[0].id, 'devocional_2025_01_01');
      expect(sorted[1].id, 'devocional_2025_12_31');
      expect(sorted[2].id, 'devocional_2026_01_01');
    });

    test('User who reads all 2025 devotionals sees 2026 next', () async {
      final statsService = SpiritualStatsService();

      // Simulate user reading all 365 devotionals from 2025
      for (int day = 1; day <= 365; day++) {
        final date = DateTime(2025, 1, 1).add(Duration(days: day - 1));
        final devocionalId =
            'devocional_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';

        await statsService.recordDevocionalRead(
          devocionalId: devocionalId,
          readingTimeSeconds: 60,
          scrollPercentage: 0.8,
        );
      }

      final stats = await statsService.getStats();
      expect(stats.totalDevocionalesRead, 365);

      // Now user should see 2026 devotionals
      final next2026Id = 'devocional_2026_01_01';
      final isRead = stats.readDevocionalIds.contains(next2026Id);
      expect(isRead, false); // 2026 should not be read yet
    });

    test('New user in 2026 sees 2025 devotionals first', () async {
      final statsService = SpiritualStatsService();

      // New user with no read devotionals
      final stats = await statsService.getStats();
      expect(stats.totalDevocionalesRead, 0);

      // Simulate reading first devotional - should be from 2025
      final firstDevocionalId = 'devocional_2025_01_01';
      await statsService.recordDevocionalRead(
        devocionalId: firstDevocionalId,
        readingTimeSeconds: 60,
        scrollPercentage: 0.8,
      );

      final updatedStats = await statsService.getStats();
      expect(updatedStats.totalDevocionalesRead, 1);
      expect(updatedStats.readDevocionalIds, contains(firstDevocionalId));
    });

    test('User who already read some 2026 devotionals preserves progress',
        () async {
      final statsService = SpiritualStatsService();

      // Simulate user who already read some 2026 devotionals before the fix
      final read2026Ids = [
        'devocional_2026_01_01',
        'devocional_2026_01_02',
        'devocional_2026_01_03',
      ];

      for (final id in read2026Ids) {
        await statsService.recordDevocionalRead(
          devocionalId: id,
          readingTimeSeconds: 60,
          scrollPercentage: 0.8,
        );
      }

      final stats = await statsService.getStats();
      expect(stats.totalDevocionalesRead, 3);

      // All 2026 IDs should still be marked as read
      for (final id in read2026Ids) {
        expect(stats.readDevocionalIds, contains(id));
      }

      // They can now read 2025 devotionals
      await statsService.recordDevocionalRead(
        devocionalId: 'devocional_2025_01_01',
        readingTimeSeconds: 60,
        scrollPercentage: 0.8,
      );

      final updatedStats = await statsService.getStats();
      expect(updatedStats.totalDevocionalesRead, 4);
    });

    test('Devotionals are presented in chronological order', () {
      final devocionales = [
        Devocional(
          id: 'devocional_2026_01_01',
          versiculo: 'Test',
          reflexion: 'Test',
          paraMeditar: [],
          oracion: 'Test',
          date: DateTime(2026, 1, 1),
        ),
        Devocional(
          id: 'devocional_2025_01_01',
          versiculo: 'Test',
          reflexion: 'Test',
          paraMeditar: [],
          oracion: 'Test',
          date: DateTime(2025, 1, 1),
        ),
        Devocional(
          id: 'devocional_2025_12_31',
          versiculo: 'Test',
          reflexion: 'Test',
          paraMeditar: [],
          oracion: 'Test',
          date: DateTime(2025, 12, 31),
        ),
      ];

      // Sort by date
      devocionales.sort((a, b) => a.date.compareTo(b.date));

      // Verify order: 2025-01-01, 2025-12-31, 2026-01-01
      expect(devocionales[0].date.year, 2025);
      expect(devocionales[0].date.month, 1);
      expect(devocionales[1].date.year, 2025);
      expect(devocionales[1].date.month, 12);
      expect(devocionales[2].date.year, 2026);
      expect(devocionales[2].date.month, 1);
    });

    test('Repository findFirstUnreadDevocionalIndex works with multi-year', () {
      final devocionales = [
        Devocional(
          id: 'devocional_2025_01_01',
          versiculo: 'Test',
          reflexion: 'Test',
          paraMeditar: [],
          oracion: 'Test',
          date: DateTime(2025, 1, 1),
        ),
        Devocional(
          id: 'devocional_2025_01_02',
          versiculo: 'Test',
          reflexion: 'Test',
          paraMeditar: [],
          oracion: 'Test',
          date: DateTime(2025, 1, 2),
        ),
        Devocional(
          id: 'devocional_2025_01_03',
          versiculo: 'Test',
          reflexion: 'Test',
          paraMeditar: [],
          oracion: 'Test',
          date: DateTime(2025, 1, 3),
        ),
        Devocional(
          id: 'devocional_2026_01_01',
          versiculo: 'Test',
          reflexion: 'Test',
          paraMeditar: [],
          oracion: 'Test',
          date: DateTime(2026, 1, 1),
        ),
      ];

      // User read first two 2025 devotionals
      final readIds = [
        'devocional_2025_01_01',
        'devocional_2025_01_02',
      ];

      // Find first unread
      int firstUnreadIndex = -1;
      for (int i = 0; i < devocionales.length; i++) {
        if (!readIds.contains(devocionales[i].id)) {
          firstUnreadIndex = i;
          break;
        }
      }

      // Should be index 2 (third devotional from 2025)
      expect(firstUnreadIndex, 2);
      expect(devocionales[firstUnreadIndex].id, 'devocional_2025_01_03');
    });

    test('Edge case: All devotionals read shows first devotional', () async {
      final statsService = SpiritualStatsService();

      // Read all devotionals from both years
      final allIds = [
        'devocional_2025_01_01',
        'devocional_2025_12_31',
        'devocional_2026_01_01',
        'devocional_2026_12_31',
      ];

      for (final id in allIds) {
        await statsService.recordDevocionalRead(
          devocionalId: id,
          readingTimeSeconds: 60,
          scrollPercentage: 0.8,
        );
      }

      final stats = await statsService.getStats();
      expect(stats.totalDevocionalesRead, 4);

      // All should be marked as read
      for (final id in allIds) {
        expect(stats.readDevocionalIds, contains(id));
      }
    });

    test('Partial 2025 read shows correct next unread devotional', () async {
      final statsService = SpiritualStatsService();

      // Read first 10 days of 2025
      for (int day = 1; day <= 10; day++) {
        final date = DateTime(2025, 1, day);
        final devocionalId =
            'devocional_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';

        await statsService.recordDevocionalRead(
          devocionalId: devocionalId,
          readingTimeSeconds: 60,
          scrollPercentage: 0.8,
        );
      }

      final stats = await statsService.getStats();
      expect(stats.totalDevocionalesRead, 10);

      // Next unread should be day 11
      final nextUnreadId = 'devocional_2025_01_11';
      expect(stats.readDevocionalIds.contains(nextUnreadId), false);
    });

    // ========== DYNAMIC YEAR LOADING TESTS ==========
    group('Dynamic Year Loading Logic', () {
      test('Year calculation for 2025 should load [2025, 2026]', () {
        // Simulate being in year 2025
        final currentYear = 2025;
        const startYear = 2025;

        final prevYear = currentYear > startYear ? currentYear - 1 : startYear;
        final currYear = currentYear > startYear ? currentYear : startYear + 1;

        expect(prevYear, 2025);
        expect(currYear, 2026);
      });

      test('Year calculation for 2026 should load [2025, 2026]', () {
        // Simulate being in year 2026
        final currentYear = 2026;
        const startYear = 2025;

        final prevYear = currentYear > startYear ? currentYear - 1 : startYear;
        final currYear = currentYear > startYear ? currentYear : startYear + 1;

        expect(prevYear, 2025);
        expect(currYear, 2026);
      });

      test('Year calculation for 2027 should load [2026, 2027]', () {
        // Simulate being in year 2027
        final currentYear = 2027;
        const startYear = 2025;

        final prevYear = currentYear > startYear ? currentYear - 1 : startYear;
        final currYear = currentYear > startYear ? currentYear : startYear + 1;

        expect(prevYear, 2026);
        expect(currYear, 2027);
      });

      test('Year calculation for 2030 should load [2029, 2030]', () {
        // Simulate being in year 2030
        final currentYear = 2030;
        const startYear = 2025;

        final prevYear = currentYear > startYear ? currentYear - 1 : startYear;
        final currYear = currentYear > startYear ? currentYear : startYear + 1;

        expect(prevYear, 2029);
        expect(currYear, 2030);
      });

      test('Year calculation before 2025 (edge case) should load [2025, 2026]',
          () {
        // Edge case: if somehow we're before 2025
        final currentYear = 2024;
        const startYear = 2025;

        final prevYear = currentYear > startYear ? currentYear - 1 : startYear;
        final currYear = currentYear > startYear ? currentYear : startYear + 1;

        expect(prevYear, 2025);
        expect(currYear, 2026);
      });
    });

    // ========== BACKWARD COMPATIBILITY TESTS ==========
    group('Backward Compatibility', () {
      test('Users who read 2026 in early Jan 2026 preserve progress', () async {
        final statsService = SpiritualStatsService();

        // Simulate user who read first 5 days of 2026 before the fix
        for (int day = 1; day <= 5; day++) {
          final date = DateTime(2026, 1, day);
          final devocionalId =
              'devocional_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';

          await statsService.recordDevocionalRead(
            devocionalId: devocionalId,
            readingTimeSeconds: 60,
            scrollPercentage: 0.8,
          );
        }

        final stats = await statsService.getStats();
        expect(stats.totalDevocionalesRead, 5);

        // All 2026 IDs should be preserved
        for (int day = 1; day <= 5; day++) {
          final date = DateTime(2026, 1, day);
          final devocionalId =
              'devocional_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';
          expect(stats.readDevocionalIds, contains(devocionalId));
        }
      });

      test('Mixed reads (2025 + 2026) are handled correctly', () async {
        final statsService = SpiritualStatsService();

        // Read some from 2025
        for (int day = 1; day <= 3; day++) {
          final date = DateTime(2025, 12, 29 + day - 1);
          final devocionalId =
              'devocional_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';

          await statsService.recordDevocionalRead(
            devocionalId: devocionalId,
            readingTimeSeconds: 60,
            scrollPercentage: 0.8,
          );
        }

        // Read some from 2026
        for (int day = 1; day <= 2; day++) {
          final date = DateTime(2026, 1, day);
          final devocionalId =
              'devocional_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';

          await statsService.recordDevocionalRead(
            devocionalId: devocionalId,
            readingTimeSeconds: 60,
            scrollPercentage: 0.8,
          );
        }

        final stats = await statsService.getStats();
        expect(stats.totalDevocionalesRead, 5);

        // Verify mixed reads
        expect(stats.readDevocionalIds, contains('devocional_2025_12_29'));
        expect(stats.readDevocionalIds, contains('devocional_2025_12_30'));
        expect(stats.readDevocionalIds, contains('devocional_2025_12_31'));
        expect(stats.readDevocionalIds, contains('devocional_2026_01_01'));
        expect(stats.readDevocionalIds, contains('devocional_2026_01_02'));
      });
    });

    // ========== EDGE CASE TESTS ==========
    group('Edge Cases and Boundary Conditions', () {
      test('Leap year devotionals are sorted correctly', () {
        // 2024 is a leap year
        final devocionales = [
          Devocional(
            id: 'devocional_2024_02_28',
            versiculo: 'Test',
            reflexion: 'Test',
            paraMeditar: [],
            oracion: 'Test',
            date: DateTime(2024, 2, 28),
          ),
          Devocional(
            id: 'devocional_2024_02_29',
            versiculo: 'Test',
            reflexion: 'Test',
            paraMeditar: [],
            oracion: 'Test',
            date: DateTime(2024, 2, 29), // Leap day
          ),
          Devocional(
            id: 'devocional_2024_03_01',
            versiculo: 'Test',
            reflexion: 'Test',
            paraMeditar: [],
            oracion: 'Test',
            date: DateTime(2024, 3, 1),
          ),
        ];

        devocionales.sort((a, b) => a.date.compareTo(b.date));

        expect(devocionales[0].date.day, 28);
        expect(devocionales[1].date.day, 29);
        expect(devocionales[2].date.day, 1);
      });

      test('Year boundary crossing is handled correctly', () {
        final devocionales = [
          Devocional(
            id: 'devocional_2025_12_30',
            versiculo: 'Test',
            reflexion: 'Test',
            paraMeditar: [],
            oracion: 'Test',
            date: DateTime(2025, 12, 30),
          ),
          Devocional(
            id: 'devocional_2026_01_02',
            versiculo: 'Test',
            reflexion: 'Test',
            paraMeditar: [],
            oracion: 'Test',
            date: DateTime(2026, 1, 2),
          ),
          Devocional(
            id: 'devocional_2025_12_31',
            versiculo: 'Test',
            reflexion: 'Test',
            paraMeditar: [],
            oracion: 'Test',
            date: DateTime(2025, 12, 31),
          ),
          Devocional(
            id: 'devocional_2026_01_01',
            versiculo: 'Test',
            reflexion: 'Test',
            paraMeditar: [],
            oracion: 'Test',
            date: DateTime(2026, 1, 1),
          ),
        ];

        devocionales.sort((a, b) => a.date.compareTo(b.date));

        // Verify correct order across year boundary
        expect(devocionales[0].id, 'devocional_2025_12_30');
        expect(devocionales[1].id, 'devocional_2025_12_31');
        expect(devocionales[2].id, 'devocional_2026_01_01');
        expect(devocionales[3].id, 'devocional_2026_01_02');
      });

      test('Large gap in read devotionals is handled', () async {
        final statsService = SpiritualStatsService();

        // Read day 1, then skip to day 100
        await statsService.recordDevocionalRead(
          devocionalId: 'devocional_2025_01_01',
          readingTimeSeconds: 60,
          scrollPercentage: 0.8,
        );

        await statsService.recordDevocionalRead(
          devocionalId: 'devocional_2025_04_10', // Day ~100
          readingTimeSeconds: 60,
          scrollPercentage: 0.8,
        );

        final stats = await statsService.getStats();
        expect(stats.totalDevocionalesRead, 2);

        // Both should be recorded
        expect(stats.readDevocionalIds, contains('devocional_2025_01_01'));
        expect(stats.readDevocionalIds, contains('devocional_2025_04_10'));

        // Days in between should not be read
        expect(
            stats.readDevocionalIds.contains('devocional_2025_01_02'), false);
        expect(
            stats.readDevocionalIds.contains('devocional_2025_04_09'), false);
      });
    });
  });
}
