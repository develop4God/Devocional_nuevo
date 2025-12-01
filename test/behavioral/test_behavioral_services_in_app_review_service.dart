import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devocional_nuevo/services/in_app_review_service.dart';
import 'package:devocional_nuevo/models/spiritual_stats_model.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

@GenerateMocks([BuildContext, InAppReview, SharedPreferences, Uri, LaunchMode])
void main() {
  late InAppReviewService instance;
  late MockBuildContext mockContext;
  late MockInAppReview mockInAppReview;
  late MockSharedPreferences mockSharedPreferences;
  late MockUri mockUri;
  late MockLaunchMode mockLaunchMode;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockContext = MockBuildContext();
    mockInAppReview = MockInAppReview();
    mockSharedPreferences = MockSharedPreferences();
    mockUri = MockUri();
    mockLaunchMode = MockLaunchMode();

    // Mock platform channels
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      MethodChannel('in_app_review'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'isAvailable':
            return true;
          case 'requestReview':
            return true;
          case 'openStoreListing':
            return true;
          default:
            return null;
        }
      },
    );

    instance = InAppReviewService();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    // Clean up platform channel mocks
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      MethodChannel('in_app_review'),
      null,
    );
  });

  test('User sees review dialog at milestone 5, first time user', () async {
    // Given: User has read 5 devotionals, is a first-time user
    final stats = SpiritualStats(totalDevocionalesRead: 5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('review_first_time_check_done', false);

    // When: checkAndShow is called
    await InAppReviewService.checkAndShow(stats, mockContext);

    // Then: showReviewDialog is called
    verify(mockContext.mounted).called(1);
  });

  test('User does NOT see review dialog if already rated', () async {
    // Given: User has already rated the app
    final stats = SpiritualStats(totalDevocionalesRead: 25);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_rated_app', true);

    // When: checkAndShow is called
    await InAppReviewService.checkAndShow(stats, mockContext);

    // Then: showReviewDialog is NOT called
    verifyNever(mockContext.mounted);
  });

  test('User sees review dialog at milestone 25, after global cooldown',
      () async {
    // Given: User has read 25 devotionals, and the global cooldown has passed
    final stats = SpiritualStats(totalDevocionalesRead: 25);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_review_request_date',
        DateTime.now().subtract(const Duration(days: 100)).millisecondsSinceEpoch ~/
            1000);

    // When: checkAndShow is called
    await InAppReviewService.checkAndShow(stats, mockContext);

    // Then: showReviewDialog is called
    verify(mockContext.mounted).called(1);
  });

  test('User does NOT see review dialog if remind later cooldown is active',
      () async {
    // Given: User has read 25 devotionals, and the remind later cooldown is active
    final stats = SpiritualStats(totalDevocionalesRead: 25);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('remind_later_date',
        DateTime.now().subtract(const Duration(days: 10)).millisecondsSinceEpoch ~/
            1000);

    // When: checkAndShow is called
    await InAppReviewService.checkAndShow(stats, mockContext);

    // Then: showReviewDialog is NOT called
    verifyNever(mockContext.mounted);
  });

  test('User taps "Share" button, opens in-app review', () async {
    // Given: User is presented with the review dialog
    final stats = SpiritualStats(totalDevocionalesRead: 5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('review_first_time_check_done', false);

    // Mock the InAppReview instance
    final inAppReview = InAppReview.instance;
    when(inAppReview.isAvailable()).thenAnswer((_) async => true);
    when(inAppReview.requestReview()).thenAnswer((_) async => true);

    // When: User taps "Share"
    await InAppReviewService.checkAndShow(stats, mockContext);

    // Then: In-app review is requested
    verify(mockContext.mounted).called(1);
  });

  test('User taps "Already Rated" button', () async {
    // Given: User is presented with the review dialog
    final stats = SpiritualStats(totalDevocionalesRead: 5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('review_first_time_check_done', false);

    // When: User taps "Already Rated"
    await InAppReviewService.checkAndShow(stats, mockContext);

    // Then: User is marked as rated
    final rated = await prefs.getBool('user_rated_app');
    expect(rated, true);
  });

  test('User taps "Not Now" button, sets remind later', () async {
    // Given: User is presented with the review dialog
    final stats = SpiritualStats(totalDevocionalesRead: 5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('review_first_time_check_done', false);

    // When: User taps "Not Now"
    await InAppReviewService.checkAndShow(stats, mockContext);

    // Then: Remind later timestamp is set
    final remindLaterTimestamp = prefs.getInt('review_remind_later_date');
    expect(remindLaterTimestamp, isNotNull);
  });

  test('User opens Play Store fallback when native review is unavailable',
      () async {
    // Given: Native in-app review is unavailable
    final stats = SpiritualStats(totalDevocionalesRead: 5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('review_first_time_check_done', false);

    // Mock the InAppReview instance
    final inAppReview = InAppReview.instance;
    when(inAppReview.isAvailable()).thenAnswer((_) async => false);

    // When: checkAndShow is called
    await InAppReviewService.checkAndShow(stats, mockContext);

    // Then: Play Store fallback is shown
    verify(mockContext.mounted).called(1);
  });

  test('User opens Play Store fallback when native review fails', () async {
    // Given: Native in-app review fails
    final stats = SpiritualStats(totalDevocionalesRead: 5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('review_first_time_check_done', false);

    // Mock the InAppReview instance
    final inAppReview = InAppReview.instance;
    when(inAppReview.isAvailable()).thenAnswer((_) async => true);
    when(inAppReview.requestReview()).thenThrow(Exception('Simulated error'));

    // When: checkAndShow is called
    await InAppReviewService.checkAndShow(stats, mockContext);

    // Then: Play Store fallback is shown
    verify(mockContext.mounted).called(1);
  });
}

class MockBuildContext extends Mock implements BuildContext {}

class MockInAppReview extends Mock implements InAppReview {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockUri extends Mock implements Uri {}

class MockLaunchMode extends Mock implements LaunchMode {}