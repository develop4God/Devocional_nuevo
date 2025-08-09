import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:devocional_nuevo/widgets/devocionales_page_drawer.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/providers/theme_provider.dart';

// Mock for DevocionalProvider
class MockDevocionalProvider extends DevocionalProvider with Mock {}

// Mock for ThemeProvider
class MockThemeProvider extends ThemeProvider with Mock {}

void main() {
  late MockDevocionalProvider mockDevocionalProvider;
  late MockThemeProvider mockThemeProvider;

  setUp(() {
    mockDevocionalProvider = MockDevocionalProvider();
    mockThemeProvider = MockThemeProvider();
    
    // Setup default values for required getters
    when(() => mockDevocionalProvider.selectedVersion).thenReturn('RVR1960');
    when(() => mockThemeProvider.currentBrightness).thenReturn(Brightness.light);
    when(() => mockThemeProvider.currentThemeFamily).thenReturn('default');
    when(() => mockThemeProvider.dividerAdaptiveColor).thenReturn(Colors.grey);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<DevocionalProvider>.value(value: mockDevocionalProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
        ],
        child: Scaffold(
          drawer: const DevocionalesDrawer(),
          appBar: AppBar(),
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: const Text('Open Drawer'),
            ),
          ),
        ),
      ),
    );
  }

  group('DevocionalesDrawer Offline Integration', () {
    testWidgets('should show "Descargar devocionales" when no local data', (WidgetTester tester) async {
      // Mock no local data available
      when(() => mockDevocionalProvider.hasCurrentYearLocalData())
          .thenAnswer((_) async => false);
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Open the drawer
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();
      
      expect(find.text('Descargar devocionales'), findsOneWidget);
      expect(find.text('Toca para gestionar'), findsOneWidget);
      expect(find.byIcon(Icons.download_outlined), findsOneWidget);
    });

    testWidgets('should show "Devocionales descargados" with check icon when local data exists', (WidgetTester tester) async {
      // Mock local data available
      when(() => mockDevocionalProvider.hasCurrentYearLocalData())
          .thenAnswer((_) async => true);
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Open the drawer
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();
      
      expect(find.text('Devocionales descargados'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should open offline manager dialog when tapped', (WidgetTester tester) async {
      when(() => mockDevocionalProvider.hasCurrentYearLocalData())
          .thenAnswer((_) async => false);
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Open the drawer
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();
      
      // Tap on the offline management option
      await tester.tap(find.text('Descargar devocionales'));
      await tester.pumpAndSettle();
      
      // Check that dialog is opened
      expect(find.text('Gestión de contenido offline'), findsOneWidget);
      expect(find.text('Cerrar'), findsOneWidget);
      expect(find.byIcon(Icons.offline_pin), findsOneWidget);
    });

    testWidgets('should have proper drawer structure', (WidgetTester tester) async {
      when(() => mockDevocionalProvider.hasCurrentYearLocalData())
          .thenAnswer((_) async => false);
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Open the drawer
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();
      
      // Check that all expected sections are present
      expect(find.text('Tu Biblia, tu estilo'), findsOneWidget);
      expect(find.text('Versión Bíblica'), findsOneWidget);
      expect(find.text('Favoritos guardados'), findsOneWidget);
      expect(find.text('Luz baja (modo oscuro)'), findsOneWidget);
      expect(find.text('Compartir esta app'), findsOneWidget);
      expect(find.text('Descargar devocionales'), findsOneWidget);
    });
  });
}