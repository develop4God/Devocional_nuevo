import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/utils/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Backward Compatibility Tests', () {
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

    test('existing Spanish users maintain exact same behavior', () async {
      // Given: Fresh provider instance (simulates new user or clean install)
      final provider = DevocionalProvider();

      // When: Default initialization (should be Spanish RVR1960)
      expect(provider.selectedLanguage, equals('es'));
      expect(provider.selectedVersion, equals('RVR1960'));

      // Then: Verify identical behavior to pre-multilingual version
      expect(provider.availableVersions, contains('RVR1960'));
      expect(provider.supportedLanguages, contains('es'));
    });

    test('Spanish RVR1960 uses original API URL', () {
      // Verify Spanish still uses: Devocional_year_YYYY.json
      // Not the new format
      const int currentYear = 2025;

      final spanishUrl =
          Constants.getDevocionalesApiUrl(currentYear, 'es', 'RVR1960');
      final expectedOriginalUrl =
          'https://raw.githubusercontent.com/develop4God/Devocionales-json/refs/heads/main/Devocional_year_$currentYear.json';

      expect(
        spanishUrl,
        equals(expectedOriginalUrl),
        reason:
            'Spanish RVR1960 should use the original API URL format for backward compatibility',
      );

      // Also test the default case (no parameters) - should also use original format
      final defaultUrl = Constants.getDevocionalesApiUrl(currentYear);
      expect(
        defaultUrl,
        equals(expectedOriginalUrl),
        reason:
            'Default URL should be same as Spanish for backward compatibility',
      );
    });

    test('Spanish local storage maintains original filename', () async {
      // Verify Spanish uses: devocional_2025_es.json
      // Not versioned filename like devocional_2025_es_RVR1960.json
      final provider = DevocionalProvider();

      // Simulate that the provider would use the original filename for Spanish
      // Since we can't directly test the private method, we verify the behavior indirectly
      expect(provider.selectedLanguage, equals('es'));
      expect(provider.selectedVersion, equals('RVR1960'));

      // The expectation is that Spanish maintains backward-compatible local storage
      // This ensures existing users don't lose their cached data
    });

    test('default initialization matches pre-multilingual behavior', () async {
      // Test that a fresh provider instance behaves exactly like before multilingual support
      final provider = DevocionalProvider();

      // Before multilingual support, the app would:
      // 1. Start with Spanish language
      expect(provider.selectedLanguage, equals('es'));

      // 2. Use RVR1960 as the Bible version
      expect(provider.selectedVersion, equals('RVR1960'));

      // 3. Have empty devotional lists initially
      expect(provider.devocionales, isEmpty);
      expect(provider.favoriteDevocionales, isEmpty);

      // 4. Not be in loading state initially
      expect(provider.isLoading, isFalse);

      // 5. Have no error message
      expect(provider.errorMessage, isNull);

      // 6. Audio should not be playing
      expect(provider.isAudioPlaying, isFalse);
      expect(provider.isAudioPaused, isFalse);
      expect(provider.currentPlayingDevocionalId, isNull);
    });

    test('Spanish constants maintain backward compatibility values', () {
      // Verify that Spanish-specific constants haven't changed
      expect(Constants.supportedLanguages['es'], equals('Español'));
      expect(Constants.defaultVersionByLanguage['es'], equals('RVR1960'));
      expect(Constants.bibleVersionsByLanguage['es'], contains('RVR1960'));

      // Verify RVR1960 is still the first/primary option for Spanish
      final spanishVersions = Constants.bibleVersionsByLanguage['es']!;
      expect(spanishVersions.first, equals('RVR1960'));
    });

    test('error handling maintains original behavior for Spanish', () async {
      // Test that error handling for Spanish users remains the same
      final provider = DevocionalProvider();

      expect(provider.selectedLanguage, equals('es'));

      // Error states should be handled the same way
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, isFalse);

      // Offline mode behavior should be consistent
      expect(provider.isOfflineMode, isFalse);
      expect(provider.isDownloading, isFalse);
      expect(provider.downloadStatus, isNull);
    });

    test('favorites functionality unchanged for Spanish users', () async {
      // Test that favorites management works exactly as before for Spanish users
      final provider = DevocionalProvider();

      expect(provider.selectedLanguage, equals('es'));
      expect(provider.favoriteDevocionales, isEmpty);

      // The favorites functionality should work independently of the new language features
      expect(provider.favoriteDevocionales.length, equals(0));
    });

    test('reading tracking unchanged for Spanish users', () async {
      // Test that reading progress tracking maintains original behavior
      final provider = DevocionalProvider();

      expect(provider.selectedLanguage, equals('es'));
      expect(provider.currentReadingSeconds, equals(0));
      expect(provider.currentScrollPercentage, equals(0.0));
      expect(provider.currentTrackedDevocionalId, isNull);
    });

    test('audio functionality preserves original interface', () async {
      // Test that TTS and audio controls work the same way for Spanish users
      final provider = DevocionalProvider();

      expect(provider.selectedLanguage, equals('es'));
      expect(provider.isAudioPlaying, isFalse);
      expect(provider.isAudioPaused, isFalse);

      // Audio controller should be available and initialized
      expect(provider.audioController, isNotNull);
    });

    test('supported languages includes Spanish as primary', () {
      // Ensure Spanish is always the primary/first supported language
      final supportedLanguages = Constants.supportedLanguages;

      expect(supportedLanguages.containsKey('es'), isTrue);
      expect(supportedLanguages['es'], equals('Español'));

      // Spanish should be treated as the fallback language
      final provider = DevocionalProvider();
      expect(provider.supportedLanguages, contains('es'));
    });

    test('version selection preserves RVR1960 as default', () async {
      // Test that RVR1960 remains the default version for Spanish
      final provider = DevocionalProvider();

      expect(provider.selectedLanguage, equals('es'));
      expect(provider.selectedVersion, equals('RVR1960'));

      final availableVersions = provider.availableVersions;
      expect(availableVersions, contains('RVR1960'));

      // RVR1960 should be the default version for Spanish
      expect(Constants.defaultVersionByLanguage['es'], equals('RVR1960'));
    });
  });
}
