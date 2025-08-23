import 'package:devocional_nuevo/providers/localization_provider.dart';
import 'package:devocional_nuevo/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Language Switching Integration Tests', () {
    testWidgets('Settings page should show language selector with 4 languages',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      final localizationProvider = LocalizationProvider();
      await localizationProvider.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<LocalizationProvider>.value(
                value: localizationProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<LocalizationProvider>(
                builder: (context, localization, child) {
                  return Column(
                    children: [
                      // App title in current language
                      Text('app.title'.tr()),

                      // Language dropdown
                      DropdownButton<String>(
                        value: localization.currentLanguage,
                        items: localization.supportedLanguages
                            .map((String languageCode) {
                          return DropdownMenuItem(
                            value: languageCode,
                            child: Text('languages.$languageCode'.tr()),
                          );
                        }).toList(),
                        onChanged: (String? newValue) async {
                          if (newValue != null) {
                            await localization.setLanguage(newValue);
                          }
                        },
                      ),

                      // Settings strings
                      Text('settings.title'.tr()),
                      Text('settings.language'.tr()),
                      Text('settings.audio_settings'.tr()),

                      // About strings
                      Text('about.description'.tr()),
                      Text('about.main_features'.tr()),

                      // TTS strings
                      Text('tts.play'.tr()),
                      Text('tts.pause'.tr()),
                      Text('tts.loading'.tr()),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show current language dropdown
      expect(find.byType(DropdownButton<String>), findsOneWidget);

      // Should show translated app title (different for each language)
      expect(find.text('app.title'.tr()), findsOneWidget);

      // Test switching to English
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Should show language options (at least English should be visible in dropdown)
      if (localizationProvider.supportedLanguages.contains('en')) {
        await tester.tap(find.text('English').last);
        await tester.pumpAndSettle();

        // Verify language changed
        expect(localizationProvider.currentLanguage, equals('en'));
      }
    });

    testWidgets('TTS locale should update when language changes',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      final localizationProvider = LocalizationProvider();
      await localizationProvider.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<LocalizationProvider>.value(
                value: localizationProvider),
          ],
          child: const MaterialApp(home: Scaffold(body: SizedBox())),
        ),
      );

      // Test different language TTS mappings
      await localizationProvider.setLanguage('es');
      expect(localizationProvider.getTtsLocale(), equals('es-ES'));

      await localizationProvider.setLanguage('en');
      expect(localizationProvider.getTtsLocale(), equals('en-US'));

      await localizationProvider.setLanguage('pt');
      expect(localizationProvider.getTtsLocale(), equals('pt-BR'));

      await localizationProvider.setLanguage('fr');
      expect(localizationProvider.getTtsLocale(), equals('fr-FR'));
    });

    testWidgets('App should remember language preference across sessions',
        (WidgetTester tester) async {
      // Set initial preference
      SharedPreferences.setMockInitialValues({'selected_language': 'pt'});

      final localizationProvider = LocalizationProvider();
      await localizationProvider.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<LocalizationProvider>.value(
                value: localizationProvider),
          ],
          child: const MaterialApp(home: Scaffold(body: SizedBox())),
        ),
      );

      // Should load the saved preference
      expect(localizationProvider.currentLanguage, equals('pt'));
    });

    testWidgets('Unsupported language should fallback to default',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      final localizationProvider = LocalizationProvider();
      await localizationProvider.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<LocalizationProvider>.value(
                value: localizationProvider),
          ],
          child: const MaterialApp(home: Scaffold(body: SizedBox())),
        ),
      );

      // Try to set unsupported language
      await localizationProvider.setLanguage('de'); // German not supported

      // Should fallback to default (Spanish)
      expect(localizationProvider.currentLanguage, equals('es'));
    });
  });
}
