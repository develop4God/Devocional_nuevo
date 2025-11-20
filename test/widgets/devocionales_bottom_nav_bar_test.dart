import 'package:devocional_nuevo/widgets/devocionales_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DevocionalesBottomNavBar muestra botones y responde a taps',
      (WidgetTester tester) async {
    bool previousTapped = false;
    bool nextTapped = false;
    bool favoriteTapped = false;
    bool prayersTapped = false;
    bool bibleTapped = false;
    bool shareTapped = false;
    bool progressTapped = false;
    bool settingsTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: DevocionalesBottomNavBar(
            currentIndex: 1,
            isFavorite: false,
            onPrevious: () => previousTapped = true,
            onNext: () => nextTapped = true,
            onFavorite: () => favoriteTapped = true,
            onPrayers: () => prayersTapped = true,
            onBible: () => bibleTapped = true,
            onShare: () => shareTapped = true,
            onProgress: () => progressTapped = true,
            onSettings: () => settingsTapped = true,
            ttsPlayerWidget: const SizedBox(),
            appBarForegroundColor: Colors.white,
            appBarBackgroundColor: Colors.blue,
            totalDevotionals: 3,
            currentDevocionalIndex: 1,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('bottom_nav_previous_button')), findsOneWidget);
    expect(find.byKey(const Key('bottom_nav_next_button')), findsOneWidget);
    expect(
        find.byKey(const Key('bottom_appbar_favorite_icon')), findsOneWidget);
    expect(find.byKey(const Key('bottom_appbar_prayers_icon')), findsOneWidget);
    expect(find.byKey(const Key('bottom_appbar_bible_icon')), findsOneWidget);
    expect(find.byKey(const Key('bottom_appbar_share_icon')), findsOneWidget);
    expect(
        find.byKey(const Key('bottom_appbar_progress_icon')), findsOneWidget);
    expect(
        find.byKey(const Key('bottom_appbar_settings_icon')), findsOneWidget);

    await tester.tap(find.byKey(const Key('bottom_nav_previous_button')));
    await tester.tap(find.byKey(const Key('bottom_nav_next_button')));
    await tester.tap(find.byKey(const Key('bottom_appbar_favorite_icon')));
    await tester.tap(find.byKey(const Key('bottom_appbar_prayers_icon')));
    await tester.tap(find.byKey(const Key('bottom_appbar_bible_icon')));
    await tester.tap(find.byKey(const Key('bottom_appbar_share_icon')));
    await tester.tap(find.byKey(const Key('bottom_appbar_progress_icon')));
    await tester.tap(find.byKey(const Key('bottom_appbar_settings_icon')));

    expect(previousTapped, isTrue);
    expect(nextTapped, isTrue);
    expect(favoriteTapped, isTrue);
    expect(prayersTapped, isTrue);
    expect(bibleTapped, isTrue);
    expect(shareTapped, isTrue);
    expect(progressTapped, isTrue);
    expect(settingsTapped, isTrue);
  });
}
