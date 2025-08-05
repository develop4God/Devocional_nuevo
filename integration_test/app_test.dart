import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:devocional_nuevo/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Pruebas de integración de la app', () {
    testWidgets('Verifica que la app inicie correctamente', (WidgetTester tester) async {
      // Iniciar la app
      app.main();
      
      // Primera verificación rápida - no debe fallar incluso con SplashScreen
      await tester.pump(); 
      expect(tester.binding.debugDidSendFirstFrameEvent, isTrue);
      
      // Busca cualquier widget en la jerarquía que pueda indicar que la app está funcionando
      // Si estás usando MaterialApp, esto siempre debería existir
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Buscar un Scaffold con tiempos de espera progresivos
      bool foundScaffold = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (tester.any(find.byType(Scaffold))) {
          foundScaffold = true;
          break;
        }
      }
      
      expect(foundScaffold, true, reason: 'No se encontró un Scaffold después de 10 segundos');
    });
    
    // Si necesitas probar más aspectos específicos de la UI, agrégalos aquí
    // como testWidgets adicionales
  });
}
