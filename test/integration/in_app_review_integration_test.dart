import 'package:devocional_nuevo/services/spiritual_stats_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('In-App Review Integration Tests', () {
    late SpiritualStatsService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = SpiritualStatsService();
    });

    testWidgets('Review dialog should be triggered at 5th devotional',
        (WidgetTester tester) async {
      // Build a test widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () async {
                    // Simulate reading 5 devotionals
                    for (int i = 1; i <= 5; i++) {
                      await service.recordDevocionalRead(
                        devocionalId: 'devotional_$i',
                        favoritesCount: 0,
                        readingTimeSeconds: 60,
                        scrollPercentage: 0.8,
                        context: context,
                      );
                    }
                  },
                  child: const Text('Read 5 Devotionals'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to trigger reading 5 devotionals
      await tester.tap(find.text('Read 5 Devotionals'));
      await tester.pumpAndSettle();

      // Check if review dialog appeared
      expect(find.text('🙏'), findsOneWidget);
      expect(
          find.textContaining('constancia'), findsOneWidget); // Spanish default
    });

    testWidgets('Review dialog should not appear if user already rated',
        (WidgetTester tester) async {
      // Set user as already rated
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_rated_app', true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () async {
                    await service.recordDevocionalRead(
                      devocionalId: 'devotional_1',
                      favoritesCount: 0,
                      readingTimeSeconds: 60,
                      scrollPercentage: 0.8,
                      context: context,
                    );
                  },
                  child: const Text('Read Devotional'),
                );
              },
            ),
          ),
        ),
      );

      // Simulate reading at milestone (this would normally trigger review)
      final shouldShow = await service.shouldShowReviewRequest(5);
      expect(shouldShow, false);

      await tester.tap(find.text('Read Devotional'));
      await tester.pumpAndSettle();

      // Review dialog should not appear
      expect(find.text('🙏'), findsNothing);
    });

    testWidgets('Review dialog buttons work correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () async {
                    await service.showReviewDialog(context);
                  },
                  child: const Text('Show Review Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Show the review dialog
      await tester.tap(find.text('Show Review Dialog'));
      await tester.pumpAndSettle();

      // Check that all three buttons are present
      expect(find.textContaining('quiero compartir'), findsOneWidget);
      expect(find.textContaining('califiqué'), findsOneWidget);
      expect(find.textContaining('Ahora no'), findsOneWidget);

      // Test "Already rated" button
      await tester.tap(find.textContaining('califiqué'));
      await tester.pumpAndSettle();

      // Dialog should close
      expect(find.text('🙏'), findsNothing);

      // Check that user is marked as rated
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('user_rated_app'), true);
    });

    test('Integration test: Complete review flow milestones', () async {
      // Test milestone progression
      final milestones = [5, 25, 50, 100, 200];

      for (final milestone in milestones) {
        // Reset user preferences
        SharedPreferences.setMockInitialValues({});

        final shouldShow = await service.shouldShowReviewRequest(milestone);
        expect(shouldShow, true,
            reason: 'Should show review at milestone $milestone');
      }
    });

    test('Integration test: Cooldown periods work correctly', () async {
      final prefs = await SharedPreferences.getInstance();

      // Set last request to recent date (should prevent showing)
      final recentDate = DateTime.now().millisecondsSinceEpoch ~/ 1000 -
          (30 * 24 * 3600); // 30 days ago
      await prefs.setInt('last_review_request_date', recentDate);

      final shouldShow = await service.shouldShowReviewRequest(25);
      expect(shouldShow, false,
          reason: 'Should not show due to 90-day cooldown');

      // Set older date (should allow showing)
      final oldDate = DateTime.now().millisecondsSinceEpoch ~/ 1000 -
          (100 * 24 * 3600); // 100 days ago
      await prefs.setInt('last_review_request_date', oldDate);

      final shouldShowOld = await service.shouldShowReviewRequest(25);
      expect(shouldShowOld, true, reason: 'Should show after 90+ days');
    });
  });
}
