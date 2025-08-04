import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devocional_nuevo/devocionales_page.dart';

void main() {
  testWidgets('DevocionalesPage se renderiza correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: DevocionalesPage()));
    expect(find.byType(DevocionalesPage), findsOneWidget);
  });
}