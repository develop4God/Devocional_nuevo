import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/utils/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Language Selector Widget', () {
    setUp(() {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Mock MethodChannel for platform-specific services
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/shared_preferences'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getAll') {
            return <String, dynamic>{}; // Empty preferences
          }
          return null;
        },
      );

      // Mock other necessary channels
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_tts'),
        (MethodCall methodCall) async {
          return null;
        },
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          return '/mock/path';
        },
      );
    });

    tearDown(() {
      // Clean up method channel mocks
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/shared_preferences'),
        null,
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_tts'),
        null,
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
    });

    testWidgets('displays supported languages correctly', (tester) async {
      // Test that supported languages are available
      const supportedLanguages = Constants.supportedLanguages;

      expect(supportedLanguages, isNotEmpty);
      expect(supportedLanguages.containsKey('es'), isTrue);
      expect(supportedLanguages.containsKey('en'), isTrue);
      expect(supportedLanguages['es'], equals('Español'));
      expect(supportedLanguages['en'], equals('English'));
    });

    testWidgets('provider language switching works', (tester) async {
      // Test basic provider functionality without complex UI
      final provider = DevocionalProvider();

      // Initially should be Spanish
      expect(provider.selectedLanguage, equals('es'));
      expect(provider.selectedVersion, equals('RVR1960'));

      // Switch to English
      provider.setSelectedLanguage('en');
      expect(provider.selectedLanguage, equals('en'));

      // Allow provider to dispose cleanly
      await tester.binding.delayed(const Duration(milliseconds: 100));
    });

    testWidgets('available versions change with language', (tester) async {
      // Test version availability per language
      final provider = DevocionalProvider();

      // Spanish versions
      expect(provider.selectedLanguage, equals('es'));
      final spanishVersions = provider.availableVersions;
      expect(spanishVersions, contains('RVR1960'));
      expect(spanishVersions, contains('NVI'));

      // Switch to English
      provider.setSelectedLanguage('en');
      expect(provider.selectedLanguage, equals('en'));

      final englishVersions = provider.availableVersions;
      expect(englishVersions, contains('KJV'));
      expect(englishVersions, contains('NIV'));

      // Allow provider to dispose cleanly
      await tester.binding.delayed(const Duration(milliseconds: 100));
    });

    testWidgets('unsupported language handling', (tester) async {
      // Test graceful handling of unsupported languages
      final provider = DevocionalProvider();

      // Initially Spanish
      expect(provider.selectedLanguage, equals('es'));

      // Try to set unsupported language
      provider.setSelectedLanguage('de'); // German

      // Should remain Spanish (fallback)
      expect(provider.selectedLanguage, equals('es'));
      expect(provider.selectedVersion, equals('RVR1960'));

      // Allow provider to dispose cleanly
      await tester.binding.delayed(const Duration(milliseconds: 100));
    });

    testWidgets('constants validation in UI context', (tester) async {
      // Test that constants are properly structured for UI use

      // All supported languages should have versions
      for (final language in Constants.supportedLanguages.keys) {
        final versions = Constants.bibleVersionsByLanguage[language];
        expect(versions, isNotNull,
            reason: 'Language $language should have versions');
        expect(versions!.isNotEmpty, isTrue,
            reason: 'Language $language should have at least one version');

        final defaultVersion = Constants.defaultVersionByLanguage[language];
        expect(defaultVersion, isNotNull,
            reason: 'Language $language should have default version');
        expect(versions.contains(defaultVersion), isTrue,
            reason: 'Default version should be in available versions');
      }
    });

    testWidgets('language context consistency', (tester) async {
      // Test that language and version combinations are consistent
      final provider = DevocionalProvider();

      // For each supported language, test consistency
      for (final language in Constants.supportedLanguages.keys) {
        provider.setSelectedLanguage(language);
        expect(provider.selectedLanguage, equals(language));

        final versions = provider.availableVersions;
        expect(versions.isNotEmpty, isTrue);
        expect(versions.contains(provider.selectedVersion), isTrue);
      }

      // Allow provider to dispose cleanly
      await tester.binding.delayed(const Duration(milliseconds: 100));
    });

    testWidgets('version switching within language', (tester) async {
      // Test switching versions within the same language
      final provider = DevocionalProvider();

      // Start with Spanish
      expect(provider.selectedLanguage, equals('es'));
      expect(provider.selectedVersion, equals('RVR1960'));

      // Switch to NVI
      provider.setSelectedVersion('NVI');
      expect(provider.selectedLanguage, equals('es')); // Should remain Spanish
      expect(provider.selectedVersion, equals('NVI'));

      // Switch back to RVR1960
      provider.setSelectedVersion('RVR1960');
      expect(provider.selectedVersion, equals('RVR1960'));

      // Allow provider to dispose cleanly
      await tester.binding.delayed(const Duration(milliseconds: 100));
    });
  });
}
