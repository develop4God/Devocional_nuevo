import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:devocional_nuevo/main.dart' as app;
import 'package:devocional_nuevo/pages/devocionales_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('smoke test: DevocionalesPage loads and drawer opens', (WidgetTester tester) async {
    app.main();

    // Espera 15 segundos para la carga inicial y splash
    await tester.pumpAndSettle(const Duration(seconds: 15));

    // Verifica que la pantalla principal se cargó
    expect(find.byType(DevocionalesPage), findsOneWidget);

    // Encuentra el botón sandwich que abre el Drawer (usualmente Icons.menu)
    final menuButtonFinder = find.byIcon(Icons.menu);
    expect(menuButtonFinder, findsOneWidget);

    // Toca el botón sandwich para abrir el Drawer
    await tester.tap(menuButtonFinder);
    await tester.pumpAndSettle();

    // Verifica que el Drawer está abierto
    expect(find.byType(Drawer), findsOneWidget);
  });
}