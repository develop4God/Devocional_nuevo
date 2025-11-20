import 'package:devocional_nuevo/pages/devotional_modern_view.dart';
import 'package:devocional_nuevo/widgets/devocionales_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'DevocionalModernView muestra la barra de navegación inferior personalizada',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DevocionalModernView(
          currentIndex: 0,
          totalDevotionals: 2,
          isFavorite: false,
          onPrevious: () {},
          onNext: () {},
          onFavorite: () {},
          onPrayers: () {},
          onBible: () {},
          onShare: () {},
          onProgress: () {},
          onSettings: () {},
          ttsPlayerWidget: const SizedBox(),
          appBarForegroundColor: Colors.white,
          appBarBackgroundColor: Colors.blue,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DevocionalesBottomNavBar), findsOneWidget);
    expect(find.byKey(const Key('bottom_nav_previous_button')), findsOneWidget);
    expect(find.byKey(const Key('bottom_nav_next_button')), findsOneWidget);
  });
}
