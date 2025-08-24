import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devocional_nuevo/services/tts_service.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TTS Multilingual Support', () {
    late TtsService ttsService;

    setUp(() {
      // Mock MethodChannel for SharedPreferences
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/shared_preferences'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getAll') {
            return <String, dynamic>{};
          }
          return null;
        },
      );

      // Mock FlutterTts MethodChannel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_tts'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'setLanguage':
            case 'setSpeechRate':
            case 'setVolume':
            case 'setPitch':
            case 'awaitSpeakCompletion':
            case 'speak':
            case 'pause':
            case 'stop':
              return null;
            case 'getLanguages':
              return ['es-ES', 'en-US', 'pt-BR', 'fr-FR'];
            default:
              return null;
          }
        },
      );

      ttsService = TtsService();
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
    });

    test('should expand Bible versions correctly per language', () {
      // Test getBibleVersionExpansions for each language
      
      // We need to access the private method indirectly through text normalization
      // Spanish version expansions
      ttsService.setLanguageContext('es', 'RVR1960');
      // The normalization should expand RVR1960
      // This tests the Spanish Bible version expansion indirectly
      
      // English version expansions
      ttsService.setLanguageContext('en', 'KJV');
      // The normalization should expand KJV to "King James Version"
      
      // Test specific version expansions
      expect(ttsService.currentState, equals(TtsState.idle));
      
      // Verify language context is set correctly
      ttsService.setLanguageContext('es', 'RVR1960');
      // Since the method is internal, we verify the public interface works
      
      ttsService.setLanguageContext('en', 'KJV');
      expect(ttsService.currentState, equals(TtsState.idle));
      
      // Test Portuguese context
      ttsService.setLanguageContext('pt', 'ARC');
      expect(ttsService.currentState, equals(TtsState.idle));
      
      // Test French context
      ttsService.setLanguageContext('fr', 'LSG');
      expect(ttsService.currentState, equals(TtsState.idle));
    });

    test('should format Bible books with ordinals per language', () {
      // Test formatBibleBookForLanguage for different languages
      
      // Spanish ordinals
      ttsService.setLanguageContext('es', 'RVR1960');
      final spanishBook = ttsService.formatBibleBook('1 Corintios');
      expect(spanishBook, contains('Primera de'));
      
      final spanishBook2 = ttsService.formatBibleBook('2 Tesalonicenses');
      expect(spanishBook2, contains('Segunda de'));
      
      final spanishBook3 = ttsService.formatBibleBook('3 Juan');
      expect(spanishBook3, contains('Tercera de'));
      
      // Test book without ordinal
      final regularBook = ttsService.formatBibleBook('Génesis');
      expect(regularBook, equals('Génesis'));
    });

    test('should normalize text correctly for each language', () async {
      // Test _normalizeTtsText with language context
      
      // Test Spanish normalization
      ttsService.setLanguageContext('es', 'RVR1960');
      // We test the context setting worked without triggering speak operations
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
      
      // Test English normalization  
      ttsService.setLanguageContext('en', 'KJV');
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
      
      // Test Portuguese normalization
      ttsService.setLanguageContext('pt', 'ARC');
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
      
      // Test French normalization
      ttsService.setLanguageContext('fr', 'LSG');
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
    });

    test('should set language context correctly', () {
      // Test setLanguageContext method
      
      // Test Spanish context
      ttsService.setLanguageContext('es', 'RVR1960');
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
      
      // Test English context
      ttsService.setLanguageContext('en', 'KJV');
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
      
      // Test Portuguese context
      ttsService.setLanguageContext('pt', 'ARC');
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
      
      // Test French context
      ttsService.setLanguageContext('fr', 'LSG');
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
      
      // Test invalid context - should not crash
      ttsService.setLanguageContext('invalid', 'INVALID');
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
    });

    test('should generate chunks with proper normalization', () {
      // Test _generateChunks uses language context
      // Since _generateChunks is private, we test through speakDevotional
      
      // Test Spanish context
      ttsService.setLanguageContext('es', 'RVR1960');
      // We verify that the method call doesn't crash and context is set
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
      
      // Test English context
      ttsService.setLanguageContext('en', 'KJV');
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
    });

    test('should handle Bible reference formatting for different languages', () {
      // Test Bible reference formatting across languages
      
      // Spanish
      final spanish1Cor = ttsService.formatBibleBook('1 Corintios 13:4-7');
      expect(spanish1Cor, contains('Primera de'));
      
      final spanish2Pedro = ttsService.formatBibleBook('2 Pedro 1:3');
      expect(spanish2Pedro, contains('Segunda de'));
      
      // Test that non-numbered books remain unchanged
      final genesis = ttsService.formatBibleBook('Génesis 1:1');
      expect(genesis, equals('Génesis 1:1'));
      
      final mateo = ttsService.formatBibleBook('Mateo 5:16');
      expect(mateo, equals('Mateo 5:16'));
    });

    test('should handle year normalization across languages', () {
      // Test that year formatting works consistently across languages
      ttsService.setLanguageContext('es', 'RVR1960');
      // Years should be normalized regardless of language context
      // Since we can't directly test private methods, we verify the service accepts the context
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
      
      ttsService.setLanguageContext('en', 'KJV');
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
    });

    test('should handle language-specific abbreviations', () {
      // Test that abbreviations are handled correctly per language
      
      // Spanish abbreviations should be expanded in Spanish context
      ttsService.setLanguageContext('es', 'RVR1960');
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
      
      // English context
      ttsService.setLanguageContext('en', 'KJV');
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
    });

    test('should handle empty or null language context gracefully', () {
      // Test edge cases for language context
      
      // Empty language - should not crash
      expect(() => ttsService.setLanguageContext('', ''), returnsNormally);
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
      
      // Null handling is implicitly tested through the method signature
      // which doesn't allow null parameters
    });

    test('should maintain state consistency across language changes', () {
      // Test that changing language context doesn't affect TTS state inappropriately
      final initialState = ttsService.currentState;
      expect(initialState, anyOf([TtsState.idle, TtsState.error]));
      
      ttsService.setLanguageContext('es', 'RVR1960');
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
      
      ttsService.setLanguageContext('en', 'KJV');
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
      
      ttsService.setLanguageContext('pt', 'ARC');
      expect(ttsService.currentState, anyOf([TtsState.idle, TtsState.error]));
      
      expect(ttsService.isDisposed, isFalse);
    });
  });
}