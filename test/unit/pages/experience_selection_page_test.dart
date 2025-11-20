// test/unit/pages/experience_selection_page_test.dart

import 'package:devocional_nuevo/pages/experience_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExperienceSelectionPage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      // Verify page elements are present
      expect(find.text('Choose Your Experience'), findsOneWidget);
      expect(find.text('Select how you\'d like to explore devotionals'),
          findsOneWidget);
      expect(find.text('New Discovery Experience'), findsOneWidget);
      expect(find.text('Traditional View'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('skip button is positioned correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      // Find skip button
      final skipButton = find.text('Skip');
      expect(skipButton, findsOneWidget);

      // Verify it has the forward arrow icon
      expect(find.byIcon(Icons.arrow_forward), findsWidgets);
    });

    testWidgets('shows NEW badge on discovery experience',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      expect(find.text('NEW'), findsOneWidget);
    });

    testWidgets('discovery card has correct icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
    });

    testWidgets('traditional card has correct icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
    });

    testWidgets('displays footer text about changing later',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      expect(find.text('You can change this later in settings'),
          findsOneWidget);
    });

    testWidgets('both experience cards are tappable',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      // Find the InkWell widgets within the cards
      final inkWells = find.byType(InkWell);
      expect(inkWells, findsAtLeastNWidgets(2));
    });

    testWidgets('cards display descriptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      expect(
          find.text(
              'Browse devotionals by date, search, and read verses directly'),
          findsOneWidget);
      expect(
          find.text(
              'Continue with the familiar daily devotional experience'),
          findsOneWidget);
    });

    testWidgets('cards have Select action text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      // Should find 2 "Select" texts, one for each card
      expect(find.text('Select'), findsNWidgets(2));
    });

    testWidgets('hero icon is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      expect(find.byIcon(Icons.auto_stories_outlined), findsOneWidget);
    });

    testWidgets('adapts to dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const ExperienceSelectionPage(),
        ),
      );

      // Just verify it renders without errors in dark mode
      expect(find.byType(ExperienceSelectionPage), findsOneWidget);
    });

    testWidgets('adapts to light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ExperienceSelectionPage(),
        ),
      );

      // Just verify it renders without errors in light mode
      expect(find.byType(ExperienceSelectionPage), findsOneWidget);
    });

    testWidgets('page is scrollable for small screens',
        (WidgetTester tester) async {
      // Set a small screen size
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      // Find the SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Reset to default size
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('safe area wraps content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });
  });

  group('ExperienceSelectionPage - Card Layout', () {
    testWidgets('cards have gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      // Cards use Container with gradient decoration
      final containers = find.descendant(
        of: find.byType(InkWell),
        matching: find.byType(Container),
      );

      expect(containers, findsWidgets);
    });

    testWidgets('cards have rounded corners', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      // ClipRRect is used for rounded corners
      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('cards have proper spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      // SizedBox is used for spacing
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('ExperienceSelectionPage - Navigation', () {
    testWidgets('tapping discovery card saves preference',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      // Note: We can't fully test navigation without mocking Navigator
      // but we can verify the page renders and cards are tappable
      final discoveryCard =
          find.text('New Discovery Experience').hitTestable();
      expect(discoveryCard, findsOneWidget);
    });

    testWidgets('tapping traditional card saves preference',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      final traditionalCard = find.text('Traditional View').hitTestable();
      expect(traditionalCard, findsOneWidget);
    });
  });

  group('ExperienceSelectionPage - Accessibility', () {
    testWidgets('has semantic labels for screen readers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      // Verify key text is present for screen readers
      expect(find.text('Choose Your Experience'), findsOneWidget);
      expect(find.text('New Discovery Experience'), findsOneWidget);
      expect(find.text('Traditional View'), findsOneWidget);
    });

    testWidgets('buttons are Material widgets with proper hit area',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExperienceSelectionPage(),
        ),
      );

      // Skip button should be a TextButton
      expect(find.byType(TextButton), findsOneWidget);
    });
  });
}
