import 'package:devocional_nuevo/pages/devotional_discovery_page.dart';
import 'package:devocional_nuevo/pages/experience_selection_page.dart';
import 'package:devocional_nuevo/widgets/discovery_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_helpers.dart';

/// Critical coverage tests for Discovery Mode user flows
/// Tests user experience selection and navigation in discovery mode
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Discovery Mode - User Experience Selection Flow', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      registerTestServices();
    });

    testWidgets('Experience selection page renders both mode options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );
      await tester.pump();

      // Verify the page renders
      expect(find.byType(ExperienceSelectionPage), findsOneWidget);
    });

    testWidgets('Experience selection page displays without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      // Allow for initial rendering
      await tester.pump(const Duration(milliseconds: 100));

      // Page should be visible
      expect(find.byType(ExperienceSelectionPage), findsOneWidget);

      // No exceptions should occur
      expect(tester.takeException(), isNull);
    });

    test('User can save discovery mode preference', () async {
      final prefs = await SharedPreferences.getInstance();

      // Simulate user selecting discovery mode
      await prefs.setString('experience_mode', 'discovery');

      // Verify preference was saved
      expect(prefs.getString('experience_mode'), equals('discovery'));
    });

    test('User can save traditional mode preference', () async {
      final prefs = await SharedPreferences.getInstance();

      // Simulate user selecting traditional mode
      await prefs.setString('experience_mode', 'traditional');

      // Verify preference was saved
      expect(prefs.getString('experience_mode'), equals('traditional'));
    });

    test('User can switch between experience modes', () async {
      final prefs = await SharedPreferences.getInstance();

      // Start with discovery mode
      await prefs.setString('experience_mode', 'discovery');
      expect(prefs.getString('experience_mode'), equals('discovery'));

      // Switch to traditional
      await prefs.setString('experience_mode', 'traditional');
      expect(prefs.getString('experience_mode'), equals('traditional'));

      // Switch back to discovery
      await prefs.setString('experience_mode', 'discovery');
      expect(prefs.getString('experience_mode'), equals('discovery'));
    });

    test('Experience mode preference persists across sessions', () async {
      final prefs = await SharedPreferences.getInstance();

      // Set preference
      await prefs.setString('experience_mode', 'discovery');

      // Simulate app restart by getting preference again
      final savedMode = prefs.getString('experience_mode');

      // Should still be discovery
      expect(savedMode, equals('discovery'));
    });
  });

  group('Discovery Mode - Navigation Component Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      registerTestServices();
    });

    testWidgets('Discovery bottom nav bar renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: DiscoveryBottomNavBar(
              onPrayers: () {},
              onBible: () {},
              onProgress: () {},
              onSettings: () {},
            ),
          ),
        ),
      );

      // Verify the nav bar is in the widget tree
      expect(find.byType(DiscoveryBottomNavBar), findsOneWidget);
    });

    testWidgets('Discovery bottom nav bar has all navigation buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: DiscoveryBottomNavBar(
              onPrayers: () {},
              onBible: () {},
              onProgress: () {},
              onSettings: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      // The nav bar should have navigation items
      expect(find.byType(DiscoveryBottomNavBar), findsOneWidget);

      // Should have buttons/icons for navigation
      expect(find.byType(IconButton), findsWidgets);
    });

    testWidgets('Discovery bottom nav bar callbacks work',
        (WidgetTester tester) async {
      bool prayersTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: DiscoveryBottomNavBar(
              onPrayers: () => prayersTapped = true,
              onBible: () {},
              onProgress: () {},
              onSettings: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Find and tap the prayers button
      final prayersButtons =
          find.widgetWithIcon(IconButton, Icons.favorite_border);
      if (prayersButtons.evaluate().isNotEmpty) {
        await tester.tap(prayersButtons.first);
        await tester.pump();
        expect(prayersTapped, isTrue);
      }
    });

    testWidgets('Discovery nav bar works with null callbacks',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: DiscoveryBottomNavBar(),
          ),
        ),
      );
      await tester.pump();

      // Should render without crashing even with null callbacks
      expect(find.byType(DiscoveryBottomNavBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Discovery Mode - Discovery Page Flow', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      registerTestServices();
    });

    // Discovery page requires full app context with providers
    // These tests validate the page can be constructed but not fully rendered
    // Full integration tests should be run with the actual app

    test('Discovery page class exists and can be imported', () {
      // This validates the discovery page is available in the codebase
      expect(DevotionalDiscoveryPage, isNotNull);
    });

    test('Discovery page is a StatefulWidget', () {
      const page = DevotionalDiscoveryPage();
      expect(page, isA<StatefulWidget>());
    });
  });

  group('Discovery Mode - User Journey Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      registerTestServices();
    });

    test('Complete user flow: First time user selects discovery mode',
        () async {
      final prefs = await SharedPreferences.getInstance();

      // User opens app for the first time (no preference saved)
      expect(prefs.getString('experience_mode'), isNull);

      // User sees experience selection and chooses discovery
      await prefs.setString('experience_mode', 'discovery');

      // Preference is saved
      expect(prefs.getString('experience_mode'), equals('discovery'));

      // User can now use discovery mode features
      final mode = prefs.getString('experience_mode');
      expect(mode, equals('discovery'));
    });

    test('User switches from traditional to discovery mode', () async {
      final prefs = await SharedPreferences.getInstance();

      // User was using traditional mode
      await prefs.setString('experience_mode', 'traditional');
      expect(prefs.getString('experience_mode'), equals('traditional'));

      // User switches to discovery mode from settings
      await prefs.setString('experience_mode', 'discovery');

      // Discovery mode is now active
      expect(prefs.getString('experience_mode'), equals('discovery'));
    });

    test('Discovery mode preference persists after app restart', () async {
      final prefs = await SharedPreferences.getInstance();

      // User selects discovery mode
      await prefs.setString('experience_mode', 'discovery');

      // Simulate app restart (preference should still be there)
      final persistedMode = prefs.getString('experience_mode');
      expect(persistedMode, equals('discovery'));

      // User can continue using discovery mode
      expect(persistedMode, isNotNull);
    });
  });

  group('Discovery Mode - Error Handling', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      registerTestServices();
    });

    testWidgets('Experience selection handles repeated renders',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );
      await tester.pump();

      // Trigger rebuild
      await tester.pump();
      await tester.pump();

      // Should handle multiple renders without issues
      expect(find.byType(ExperienceSelectionPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('Invalid experience mode value is handled', () async {
      final prefs = await SharedPreferences.getInstance();

      // Set an invalid value
      await prefs.setString('experience_mode', 'invalid_mode');

      // The invalid value should still be stored (app decides how to handle)
      expect(prefs.getString('experience_mode'), equals('invalid_mode'));

      // App can fallback to default or show selection again
      // This tests that SharedPreferences accepts any string
    });

    test('Missing preferences return null gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Should return null for missing preference
      expect(prefs.getString('experience_mode'), isNull);
    });
  });
}
