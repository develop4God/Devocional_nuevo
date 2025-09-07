import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Review Dialog Translation Validation', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('All review keys exist in all 4 language files', () async {
      final languages = ['es', 'en', 'pt', 'fr'];
      final requiredKeys = [
        'review.title',
        'review.message',
        'review.button_share',
        'review.button_already_rated',
        'review.button_not_now',
        'review.fallback_title',
        'review.fallback_message',
        'review.fallback_go',
        'review.fallback_cancel',
      ];

      for (final lang in languages) {
        // Load the JSON file for this language
        final jsonString = await rootBundle.loadString('i18n/$lang.json');
        final Map<String, dynamic> translations = json.decode(jsonString);

        // Check that review section exists
        expect(translations.containsKey('review'), true,
            reason: 'Language $lang should have review section');

        final reviewSection = translations['review'] as Map<String, dynamic>;

        // Check all required keys exist and are not empty
        for (final key in requiredKeys) {
          final keyParts = key.split('.');
          expect(keyParts.length, equals(2));
          expect(keyParts[0], equals('review'));

          final actualKey = keyParts[1];
          expect(reviewSection.containsKey(actualKey), true,
              reason:
                  'Language $lang should have key $actualKey in review section');

          final value = reviewSection[actualKey] as String;
          expect(value.isNotEmpty, true,
              reason: 'Key $actualKey should not be empty for language $lang');
        }
      }
    });

    test('Review messages contain proper line breaks', () async {
      final languages = ['es', 'en', 'pt', 'fr'];

      for (final lang in languages) {
        final jsonString = await rootBundle.loadString('i18n/$lang.json');
        final Map<String, dynamic> translations = json.decode(jsonString);

        final reviewSection = translations['review'] as Map<String, dynamic>;
        final message = reviewSection['message'] as String;

        // Check that message contains line breaks for proper formatting
        expect(message.contains('\n'), true,
            reason:
                'Message should contain line breaks for proper formatting in $lang');

        // Check that message has reasonable length
        expect(message.length, greaterThan(50),
            reason: 'Message should be meaningful length for $lang');
        expect(message.length, lessThan(300),
            reason: 'Message should not be too long for dialog for $lang');
      }
    });

    test('Review dialog titles are different across languages', () async {
      final languages = ['es', 'en', 'pt', 'fr'];
      final titles = <String>[];

      for (final lang in languages) {
        final jsonString = await rootBundle.loadString('i18n/$lang.json');
        final Map<String, dynamic> translations = json.decode(jsonString);

        final reviewSection = translations['review'] as Map<String, dynamic>;
        final title = reviewSection['title'] as String;

        // Ensure title contains expected elements
        expect(title.contains('🙏'), true,
            reason: 'Title should contain prayer hands emoji for $lang');

        titles.add(title);
      }

      // Ensure all titles are different
      final uniqueTitles = titles.toSet();
      expect(uniqueTitles.length, equals(4),
          reason: 'All language titles should be different: $titles');
    });

    test('Button texts are meaningful and different across languages',
        () async {
      final languages = ['es', 'en', 'pt', 'fr'];
      final buttonKeys = [
        'button_share',
        'button_already_rated',
        'button_not_now'
      ];

      for (final buttonKey in buttonKeys) {
        final buttonTexts = <String>[];

        for (final lang in languages) {
          final jsonString = await rootBundle.loadString('i18n/$lang.json');
          final Map<String, dynamic> translations = json.decode(jsonString);

          final reviewSection = translations['review'] as Map<String, dynamic>;
          final buttonText = reviewSection[buttonKey] as String;

          // Button text should be meaningful (not too short)
          expect(buttonText.length, greaterThan(3),
              reason: 'Button $buttonKey should be meaningful for $lang');

          buttonTexts.add(buttonText);
        }

        // Ensure button texts are different across languages
        final uniqueTexts = buttonTexts.toSet();
        expect(uniqueTexts.length, equals(4),
            reason:
                'Button $buttonKey should be different across languages: $buttonTexts');
      }
    });

    test('Fallback dialog texts are properly translated', () async {
      final languages = ['es', 'en', 'pt', 'fr'];
      final fallbackKeys = [
        'fallback_title',
        'fallback_message',
        'fallback_go',
        'fallback_cancel'
      ];

      for (final lang in languages) {
        final jsonString = await rootBundle.loadString('i18n/$lang.json');
        final Map<String, dynamic> translations = json.decode(jsonString);

        final reviewSection = translations['review'] as Map<String, dynamic>;

        for (final key in fallbackKeys) {
          final text = reviewSection[key] as String;
          expect(text.isNotEmpty, true,
              reason: 'Fallback key $key should not be empty for $lang');
          expect(text.length, greaterThan(3),
              reason: 'Fallback key $key should be meaningful for $lang');
        }
      }
    });

    test('Spanish translations match expected content', () async {
      final jsonString = await rootBundle.loadString('i18n/es.json');
      final Map<String, dynamic> translations = json.decode(jsonString);
      final reviewSection = translations['review'] as Map<String, dynamic>;

      expect(reviewSection['title'], contains('Gracias'));
      expect(reviewSection['title'], contains('constancia'));
      expect(reviewSection['button_share'], contains('quiero compartir'));
      expect(reviewSection['button_already_rated'], contains('califiqué'));
      expect(reviewSection['button_not_now'], contains('Ahora no'));
    });

    test('English translations match expected content', () async {
      final jsonString = await rootBundle.loadString('i18n/en.json');
      final Map<String, dynamic> translations = json.decode(jsonString);
      final reviewSection = translations['review'] as Map<String, dynamic>;

      expect(reviewSection['title'], contains('Thank you'));
      expect(reviewSection['title'], contains('faithfulness'));
      expect(reviewSection['button_share'], contains('want to share'));
      expect(reviewSection['button_already_rated'], contains('Already rated'));
      expect(reviewSection['button_not_now'], contains('Not now'));
    });
  });
}
