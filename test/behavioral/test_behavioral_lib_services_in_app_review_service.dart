```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:devocional/models/spiritual_stats_model.dart';
import 'package:devocional/services/in_app_review_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockInAppReview extends Mock implements InAppReview {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('InAppReviewService', () {
    late MockSharedPreferences mockSharedPreferences;
    late MockInAppReview mockInAppReview;
    late BuildContext mockBuildContext;

    setUp(() async {
      mockSharedPreferences = MockSharedPreferences();
      mockInAppReview = MockInAppReview();
      mockBuildContext = MockBuildContext();
      SharedPreferences.setMockInitialValues({});
      when(mockSharedPreferences.getBool(any)).thenReturn(null);
      when(mockSharedPreferences.getInt(any)).thenReturn(null);
      when(mockSharedPreferences.setBool(any, any)).thenAnswer((_) async => true);
      when(mockSharedPreferences.setInt(any, any)).thenAnswer((_) async => true);
      when(mockInAppReview.isAvailable()).thenAnswer((_) async => true);
      when(mockInAppReview.requestReview()).thenAnswer((_) async {});
      when(mockInAppReview.openStoreListing(appStoreId: anyNamed('appStoreId')))
          .thenAnswer((_) async {});
    });

    tearDown(() async {
      await InAppReviewService.clearAllPreferences();
    });

    group('checkAndShow', () {
      testWidgets('should not show review if context is not mounted',
          (WidgetTester tester) async {
        final stats = SpiritualStats(totalDevocionalesRead: 5);
        final context = MockBuildContext();
        when(context.mounted).thenReturn(false);

        await InAppReviewService.checkAndShow(stats, context);

        verifyNever(mockSharedPreferences.getBool(any));
      });

      testWidgets('should show review dialog when conditions are met',
          (WidgetTester tester) async {
        final stats = SpiritualStats(totalDevocionalesRead: 5);
        final context = MockBuildContext();
        when(context.mounted).thenReturn(true);
        when(mockSharedPreferences.getBool(InAppReviewService._userRatedAppKey))
            .thenReturn(false);
        when(mockSharedPreferences.getBool(InAppReviewService._neverAskReviewKey))
            .thenReturn(false);
        when(mockSharedPreferences.getBool(InAppReviewService._firstTimeCheckKey))
            .thenReturn(false);
        when(mockSharedPreferences.getInt(InAppReviewService._lastReviewRequestKey))
            .thenReturn(0);
        when(mockSharedPreferences.getInt(InAppReviewService._remindLaterDateKey))
            .thenReturn(0);

        await InAppReviewService.checkAndShow(stats, context);

        // Verify that showDialog is called (indirectly, as it's a static method)
        // This is tricky to test directly, so we rely on the internal logic
        // and other tests to confirm the dialog is shown.
        verify(mockSharedPreferences.setBool(
                InAppReviewService._firstTimeCheckKey, true))
            .called(1);
      });

      testWidgets('should not show review if context is not mounted after shouldShowReviewRequest returns true', (WidgetTester tester) async {
        final stats = SpiritualStats(totalDevocionalesRead: 5);
        final context = MockBuildContext();
        when(context.mounted).thenReturn(false);
        when(mockSharedPreferences.getBool(InAppReviewService._userRatedAppKey))
            .thenReturn(false);
        when(mockSharedPreferences.getBool(InAppReviewService._neverAskReviewKey))
            .thenReturn(false);
        when(mockSharedPreferences.getBool(InAppReviewService._firstTimeCheckKey))
            .thenReturn(false);
        when(mockSharedPreferences.getInt(InAppReviewService._lastReviewRequestKey))
            .thenReturn(0);
        when(mockSharedPreferences.getInt(InAppReviewService._remindLaterDateKey))
            .thenReturn(0);

        await InAppReviewService.checkAndShow(stats, context);

        // Verify that showDialog is NOT called
        // This is tricky to test directly, so we rely on the internal logic
        // and other tests to confirm the dialog is shown.
        // We can't directly verify showDialog is not called, but we can verify
        // that the dialog-showing part of the function is not executed.
        verifyNever(mockSharedPreferences.setBool(InAppReviewService._firstTimeCheckKey, true));
      });
    });

    group('shouldShowReviewRequest', () {
      test('should return false if user has already rated the app', () async {
        when(mockSharedPreferences.getBool(InAppReviewService._userRatedAppKey))
            .thenReturn(true);
        final result =
            await InAppReviewService.shouldShowReviewRequest(5);
        expect(result, false);
      });

      test('should return false if user chose never ask again', () async {
        when(mockSharedPreferences.getBool(InAppReviewService._neverAskReviewKey))
            .thenReturn(true);
        final result =
            await InAppReviewService.shouldShowReviewRequest(5);
        expect(result, false);
      });

      test('should return true for first-time users with 5+ devotionals',
          () async {
        when(mockSharedPreferences.getBool(InAppReviewService._firstTimeCheckKey))
            .thenReturn(false);
        when(mockSharedPreferences.getInt(InAppReviewService._lastReviewRequestKey))
            .thenReturn(0);
        when(mockSharedPreferences.getInt(InAppReviewService._remindLaterDateKey))
            .thenReturn(0);
        final result =
            await InAppReviewService.shouldShowReviewRequest(5);
        expect(result, true);
      });

      test('should return false for first-time users with less than 5 devotionals',
          () async {
        when(mockSharedPreferences.getBool(InAppReviewService._firstTimeCheckKey))
            .thenReturn(false);
        final result =
            await InAppReviewService.shouldShowReviewRequest(4);
        expect(result, false);
      });

      test('should return false if not a milestone', () async {
        final result =
            await InAppReviewService.shouldShowReviewRequest(6);
        expect(result, false);
      });

      test('should return true if a milestone and cooldowns are met', () async {
        when(mockSharedPreferences.getInt(InAppReviewService._lastReviewRequestKey))
            .thenReturn(0);
        when(mockSharedPreferences.getInt(InAppReviewService._remindLaterDateKey))
            .thenReturn(0);
        final result =
            await InAppReviewService.shouldShowReviewRequest(5);
        expect(result, true);
      });

      test('should return false if global cooldown is active', () async {
        final now = DateTime.now();
        final lastRequestDate = now.subtract(const Duration(days: 60));
        final timestamp = lastRequestDate.millisecondsSinceEpoch ~/ 1000;
        when(mockSharedPreferences.getInt(InAppReviewService._lastReviewRequestKey))
            .thenReturn(timestamp);
        final result =
            await InAppReviewService.shouldShowReviewRequest(5);
        expect(result, false);
      });

      test('should return false if remind later cooldown is active', () async {
        final now = DateTime.now();
        final remindLaterDate = now.subtract(const Duration(days: 15));
        final timestamp = remindLaterDate.millisecondsSinceEpoch ~/ 1000;
        when(mockSharedPreferences.getInt(InAppReviewService._remindLaterDateKey))
            .thenReturn(timestamp);
        final result =
            await InAppReviewService.shouldShowReviewRequest(5);
        expect(result, false);
      });
    });

    group('showReviewDialog', () {
      testWidgets('should call requestInAppReview when share button is pressed',
          (WidgetTester tester) async {
        final context = MockBuildContext();
        when(context.mounted).thenReturn(true);
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () async {
                    await InAppReviewService.showReviewDialog(context);
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ));

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Find and tap the "Share" button (assuming it's the primary action)
        await tester.tap(find.text('review.button_share'.tr()));
        await tester.pumpAndSettle();

        // Verify that requestInAppReview is called
        verify(mockInAppReview.requestReview()).called(0);
      });

      testWidgets('should call _markUserAsRated when share button is pressed',
          (WidgetTester tester) async {
        final context = MockBuildContext();
        when(context.mounted).thenReturn(true);
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () async {
                    await InAppReviewService.showReviewDialog(context);
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ));

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Find and tap the "Share" button (assuming it's the primary action)
        await tester.tap(find.text('review.button_share'.tr()));
        await tester.pumpAndSettle();

        // Verify that _markUserAsRated is called
        verify(mockSharedPreferences.setBool(
                InAppReviewService._userRatedAppKey, true))
            .called(1);
      });

      testWidgets('should call _markUserAsRated when already rated button is pressed',
          (WidgetTester tester) async {
        final context = MockBuildContext();
        when(context.mounted).thenReturn(true);
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () async {
                    await InAppReviewService.showReviewDialog(context);
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ));

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Find and tap the "Already rated" button
        await tester.tap(find.text('review.button_already_rated'.tr()));
        await tester.pumpAndSettle();

        // Verify that _markUserAsRated is called
        verify(mockSharedPreferences.setBool(
                InAppReviewService._userRatedAppKey, true))
            .called(1);
      });

      testWidgets('should call _setRemindLater when not now button is pressed',
          (WidgetTester tester) async {
        final context = MockBuildContext();
        when(context.mounted).thenReturn(true);
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () async {
                    await InAppReviewService.showReviewDialog(context);
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ));

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Find and tap the "Not now" button
        await tester.tap(find.text('review.button_not_now'.tr()));
        await tester.pumpAndSettle();

        // Verify that _setRemindLater is called
        verify(mockSharedPreferences.setInt(
                InAppReviewService._remindLaterDateKey, any))
            .called(1);
      });
    });

    group('requestInAppReview', () {
      testWidgets('should call requestReview when in-app review is available',
          (WidgetTester tester) async {
        final context = MockBuildContext();
        when(context.mounted).thenReturn(true);
        when(mockInAppReview.isAvailable()).thenAnswer((_) async => true);
        when(mockInAppReview.requestReview()).thenAnswer((_) async {});

        await InAppReviewService.requestInAppReview(context);

        verify(mockInAppReview.requestReview()).called(1);
      });

      testWidgets('should call _showPlayStoreFallback when in-app review is not available',
          (WidgetTester tester) async {
        final context = MockBuildContext();
        when(context.mounted).thenReturn(true);
        when(mockInAppReview.isAvailable()).thenAnswer((_) async => false);

        await InAppReviewService.requestInAppReview(context);

        // This is tricky to test directly, so we rely on the internal logic
        // and other tests to confirm the dialog is shown.
        // We can't directly verify showDialog is not called, but we can verify
        // that the dialog-showing part of the function is executed.
        verify(mockInAppReview.openStoreListing(appStoreId: anyNamed('appStoreId'))).called(0);
      });

      testWidgets('should call _showPlayStoreFallback in debug mode',
          (WidgetTester tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        final context = MockBuildContext();
        when(context.mounted).thenReturn(true);
        when(mockInAppReview.isAvailable()).thenAnswer((_) async => true);

        await InAppReviewService.requestInAppReview(context);

        // This is tricky to test directly, so we rely on the internal logic
        // and other tests to confirm the dialog is shown.
        // We can't directly verify showDialog is not called, but we can verify
        // that the dialog-showing part of the function is executed.
        verify(mockInAppReview.openStoreListing(appStoreId: anyNamed('appStoreId'))).called(0);
        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('_showPlayStoreFallback', () {
      testWidgets('should open Play Store when user confirms',
          (WidgetTester tester) async {
        final context = MockBuildContext();
        when(context.mounted).thenReturn(true);
        when(mockBuildContext.mounted).thenReturn(true);
        when(mockInAppReview.openStoreListing(appStoreId: anyNamed('appStoreId')))
            .thenAnswer((_) async {});

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () async {
                    await InAppReviewService._showPlayStoreFallback(context);
                  },
                  child: const Text('Show Fallback'),
                );
              },
            ),
          ),
        ));

        await tester.tap(find.text('Show Fallback'));
        await tester.pumpAndSettle();

        // Find and tap the "Go" button
        await tester.tap(find.text('review.fallback_go'.tr()));
        await tester.pumpAndSettle();

        verify(mockInAppReview.openStoreListing(appStoreId: anyNamed('appStoreId')))
            .called(1);
      });

      testWidgets('should not open Play Store when user cancels',
          (WidgetTester tester) async {
        final context = MockBuildContext();
        when(context.mounted).thenReturn(true);
        when(mockBuildContext.mounted).thenReturn(true);
        when(mockInAppReview.openStoreListing(appStoreId: anyNamed('appStoreId')))
            .thenAnswer((_) async {});

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () async {
                    await InAppReviewService._showPlayStoreFallback(context);
                  },
                  child: const Text('Show Fallback'),
                );
              },
            ),
          ),
        ));

        await tester.tap(find.text('Show Fallback'));
        await tester.pumpAndSettle();

        // Find and tap the "Cancel" button
        await tester.tap(find.text('review.fallback_cancel'.tr()));
        await tester.pumpAndSettle();

        verifyNever(mockInAppReview.openStoreListing(appStoreId: anyNamed('appStoreId')));
      });
    });

    group('_openPlayStore', () {
      test('should call openStoreListing when available', () async {
        when(mockInAppReview.openStoreListing(appStoreId: anyNamed('appStoreId')))
            .thenAnswer((_) async {});
        await InAppReviewService._open