import 'package:devocional_nuevo/pages/devocionales_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'DevocionalesPage renderiza correctamente y muestra la barra de navegación',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DevocionalesPage(),
      ),
    );
    // Espera a que se renderice la barra de navegación inferior
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(BottomNavigationBar),
        findsNothing); // No debe haber BottomNavigationBar clásico
    expect(find.byType(BottomAppBar), findsWidgets); // Debe haber BottomAppBar
    expect(find.byKey(const Key('bottom_nav_previous_button')), findsOneWidget);
    expect(find.byKey(const Key('bottom_nav_next_button')), findsOneWidget);
  });
}
