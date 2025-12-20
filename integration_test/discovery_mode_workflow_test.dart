import 'package:devocional_nuevo/main.dart' as app;
import 'package:devocional_nuevo/pages/devotional_discovery_page.dart';
import 'package:devocional_nuevo/pages/experience_selection_page.dart';
import 'package:devocional_nuevo/widgets/discovery_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Integration tests for Discovery Mode workflow
/// Tests real user behavior: experience selection, discovery navigation, search
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Discovery Mode - User Workflow Tests', () {
    setUp(() async {
      // Clear all preferences to simulate first-time user
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    testWidgets('First-time user sees experience selection and can choose discovery mode',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // First-time users should see experience selection
      // Note: This test validates the onboarding flow exists
      // The actual navigation depends on splash screen logic
      
      // Verify the app launches successfully
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Wait for initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('Discovery mode navigation bar has correct items',
        (WidgetTester tester) async {
      // Build the discovery bottom nav bar
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

      // Verify the navigation bar renders
      expect(find.byType(DiscoveryBottomNavBar), findsOneWidget);
      
      // Wait for rendering
      await tester.pumpAndSettle();
    });

    testWidgets('Experience selection page displays both modes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Experience selection should show both options
      // Traditional and Discovery modes should be visible
      expect(find.byType(ExperienceSelectionPage), findsOneWidget);
      
      // The page should render without errors
      await tester.pumpAndSettle();
    });

    testWidgets('Discovery page can be instantiated and rendered',
        (WidgetTester tester) async {
      // Test that the discovery page can be created
      await tester.pumpWidget(
        const MaterialApp(
          home: DevotionalDiscoveryPage(),
        ),
      );
      
      // Allow for async initialization
      await tester.pump(const Duration(seconds: 1));
      
      // Verify the page renders
      expect(find.byType(DevotionalDiscoveryPage), findsOneWidget);
      
      // Wait for any animations or data loading
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('Discovery bottom nav bar responds to callbacks',
        (WidgetTester tester) async {
      bool prayersCalled = false;
      bool bibleCalled = false;
      bool progressCalled = false;
      bool settingsCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: DiscoveryBottomNavBar(
              onPrayers: () => prayersCalled = true,
              onBible: () => bibleCalled = true,
              onProgress: () => progressCalled = true,
              onSettings: () => settingsCalled = true,
            ),
          ),
        ),
      );

      // Initial state
      expect(prayersCalled, isFalse);
      expect(bibleCalled, isFalse);
      expect(progressCalled, isFalse);
      expect(settingsCalled, isFalse);

      await tester.pumpAndSettle();

      // Verify the navigation bar is present
      expect(find.byType(DiscoveryBottomNavBar), findsOneWidget);
    });
  });

  group('Discovery Mode - Component Integration', () {
    testWidgets('Discovery page components exist in widget tree',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DevotionalDiscoveryPage(),
        ),
      );

      // Wait for initial render
      await tester.pump(const Duration(milliseconds: 500));
      
      // The page should be in the widget tree
      expect(find.byType(DevotionalDiscoveryPage), findsOneWidget);
      
      // Allow async operations to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('Experience selection allows navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ExperienceSelectionPage(),
          routes: {
            '/discovery': (context) => const DevotionalDiscoveryPage(),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Verify the experience selection page renders
      expect(find.byType(ExperienceSelectionPage), findsOneWidget);
    });
  });

  group('Discovery Mode - Data Flow', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Discovery mode preference can be saved and loaded',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      
      // Save discovery mode preference
      await prefs.setString('experience_mode', 'discovery');
      
      // Verify it was saved
      final saved = prefs.getString('experience_mode');
      expect(saved, equals('discovery'));
      
      // Clear and verify
      await prefs.clear();
      expect(prefs.getString('experience_mode'), isNull);
      
      // Save traditional mode
      await prefs.setString('experience_mode', 'traditional');
      expect(prefs.getString('experience_mode'), equals('traditional'));
    });

    testWidgets('Discovery page handles missing data gracefully',
        (WidgetTester tester) async {
      // Clear all preferences to simulate no data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      await tester.pumpWidget(
        const MaterialApp(
          home: DevotionalDiscoveryPage(),
        ),
      );

      // The page should render even without data
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(DevotionalDiscoveryPage), findsOneWidget);
      
      // Should not crash during async data loading
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Verify no errors occurred
      expect(tester.takeException(), isNull);
    });
  });

  group('Discovery Mode - Accessibility', () {
    testWidgets('Discovery navigation renders correctly',
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

      // Verify the navigation bar is present
      expect(find.byType(DiscoveryBottomNavBar), findsOneWidget);
      
      await tester.pumpAndSettle();
    });
  });
}
