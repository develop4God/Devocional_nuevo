import 'package:devocional_nuevo/services/spiritual_stats_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('In-App Review Tests', () {
    late SpiritualStatsService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = SpiritualStatsService();
    });

    test('shouldShowReviewRequest returns false if user already rated',
        () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_rated_app', true);

      final shouldShow = await service.shouldShowReviewRequest(5);
      expect(shouldShow, false);
    });

    test('shouldShowReviewRequest returns false if never ask again', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('never_ask_review_again', true);

      final shouldShow = await service.shouldShowReviewRequest(5);
      expect(shouldShow, false);
    });

    test('shouldShowReviewRequest returns false if not at milestone', () async {
      final shouldShow = await service.shouldShowReviewRequest(3);
      expect(shouldShow, false);
    });

    test('shouldShowReviewRequest returns true at 5th devotional milestone',
        () async {
      final shouldShow = await service.shouldShowReviewRequest(5);
      expect(shouldShow, true);
    });

    test('shouldShowReviewRequest returns true at 25th devotional milestone',
        () async {
      final shouldShow = await service.shouldShowReviewRequest(25);
      expect(shouldShow, true);
    });

    test('shouldShowReviewRequest returns true at 50th devotional milestone',
        () async {
      final shouldShow = await service.shouldShowReviewRequest(50);
      expect(shouldShow, true);
    });

    test('shouldShowReviewRequest respects 90-day cooldown', () async {
      final prefs = await SharedPreferences.getInstance();

      // Set last request to 30 days ago (should not show)
      final thirtyDaysAgo =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 - (30 * 24 * 3600);
      await prefs.setInt('last_review_request_date', thirtyDaysAgo);

      final shouldShow = await service.shouldShowReviewRequest(25);
      expect(shouldShow, false);
    });

    test('shouldShowReviewRequest respects remind later 30-day period',
        () async {
      final prefs = await SharedPreferences.getInstance();

      // Set remind later to 15 days ago (should not show)
      final fifteenDaysAgo =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 - (15 * 24 * 3600);
      await prefs.setInt('review_remind_later_date', fifteenDaysAgo);

      final shouldShow = await service.shouldShowReviewRequest(25);
      expect(shouldShow, false);
    });

    test('Review milestones are correctly defined', () async {
      // Test all expected milestones
      final milestones = [5, 25, 50, 100, 200, 300, 500];

      for (final milestone in milestones) {
        final shouldShow = await service.shouldShowReviewRequest(milestone);
        expect(shouldShow, true,
            reason: 'Milestone $milestone should trigger review');
      }

      // Test non-milestones
      final nonMilestones = [1, 3, 10, 15, 30, 75, 150];

      for (final nonMilestone in nonMilestones) {
        final shouldShow = await service.shouldShowReviewRequest(nonMilestone);
        expect(shouldShow, false,
            reason: 'Non-milestone $nonMilestone should not trigger review');
      }
    });
  });
}
