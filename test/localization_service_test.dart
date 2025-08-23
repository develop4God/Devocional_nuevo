import 'package:devocional_nuevo/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalizationService Tests', () {
    late LocalizationService localizationService;

    setUp(() {
      // Reset shared preferences for each test
      SharedPreferences.setMockInitialValues({});
      localizationService = LocalizationService();
    });

    test('should initialize with default or detected language', () async {
      await localizationService.initialize();
      // Should be one of the supported languages
      expect(localizationService.supportedLanguages,
          contains(localizationService.currentLanguage));
    });

    test('should support all required languages', () {
      expect(localizationService.supportedLanguages, contains('es'));
      expect(localizationService.supportedLanguages, contains('en'));
      expect(localizationService.supportedLanguages, contains('pt'));
      expect(localizationService.supportedLanguages, contains('fr'));
    });

    test('should change language correctly', () async {
      await localizationService.initialize();

      await localizationService.setLanguage('en');
      expect(localizationService.currentLanguage, equals('en'));

      await localizationService.setLanguage('pt');
      expect(localizationService.currentLanguage, equals('pt'));

      await localizationService.setLanguage('fr');
      expect(localizationService.currentLanguage, equals('fr'));
    });

    test('should fallback to default language for unsupported language',
        () async {
      await localizationService.initialize();

      await localizationService.setLanguage('de'); // Unsupported language
      expect(localizationService.currentLanguage, equals('es'));
    });

    test('should persist language preference', () async {
      await localizationService.initialize();
      await localizationService.setLanguage('en');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_language'), equals('en'));
    });

    test('should return correct TTS locale for each language', () async {
      await localizationService.initialize();

      await localizationService.setLanguage('es');
      expect(localizationService.getTtsLocale(), equals('es-ES'));

      await localizationService.setLanguage('en');
      expect(localizationService.getTtsLocale(), equals('en-US'));

      await localizationService.setLanguage('pt');
      expect(localizationService.getTtsLocale(), equals('pt-BR'));

      await localizationService.setLanguage('fr');
      expect(localizationService.getTtsLocale(), equals('fr-FR'));
    });

    test('should return correct locale object', () async {
      await localizationService.initialize();

      await localizationService.setLanguage('en');
      final locale = localizationService.getLocale();
      expect(locale.languageCode, equals('en'));
    });

    test('should correctly identify supported languages', () {
      expect(localizationService.isLanguageSupported('es'), isTrue);
      expect(localizationService.isLanguageSupported('en'), isTrue);
      expect(localizationService.isLanguageSupported('pt'), isTrue);
      expect(localizationService.isLanguageSupported('fr'), isTrue);
      expect(localizationService.isLanguageSupported('de'), isFalse);
      expect(localizationService.isLanguageSupported('zh'), isFalse);
    });

    test('String extension .tr() should work', () {
      expect('test'.tr(),
          equals('test')); // Returns key when no translation loaded
    });
  });

  group('Translation Loading Tests', () {
    testWidgets('should load translations correctly',
        (WidgetTester tester) async {
      // Initialize widget binding for asset loading
      await tester.pumpWidget(MaterialApp(home: Container()));

      final localizationService = LocalizationService();
      await localizationService.initialize();

      // Test basic translation keys that should exist in all languages
      await localizationService.setLanguage('es');
      expect(localizationService.translate('app.title'), isNotEmpty);

      await localizationService.setLanguage('en');
      expect(localizationService.translate('app.title'), isNotEmpty);

      await localizationService.setLanguage('pt');
      expect(localizationService.translate('app.title'), isNotEmpty);

      await localizationService.setLanguage('fr');
      expect(localizationService.translate('app.title'), isNotEmpty);
    });

    testWidgets('should return key when translation not found',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));

      final localizationService = LocalizationService();
      await localizationService.initialize();

      // Test with non-existent key
      expect(localizationService.translate('non.existent.key'),
          equals('non.existent.key'));
    });
  });
}
