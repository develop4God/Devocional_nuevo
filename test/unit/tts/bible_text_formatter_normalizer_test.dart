// test/unit/tts/bible_text_formatter_normalizer_test.dart
// Tests for BibleTextNormalizer integration in TTS formatting
// Validates that HTML tags and bracketed references are removed for all languages

import 'package:devocional_nuevo/services/tts/bible_text_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BibleTextFormatter - Normalizer Integration', () {
    group('HTML Tag Removal - All Languages', () {
      test('removes HTML tags from Spanish text before TTS', () {
        final result = BibleTextFormatter.normalizeTtsText(
          'En el principio<pb/>creó Dios',
          'es',
        );
        expect(result, isNot(contains('<pb/>')));
        expect(result, contains('En el principio'));
        expect(result, contains('creó Dios'));
      });

      test('removes HTML tags from English text before TTS', () {
        final result = BibleTextFormatter.normalizeTtsText(
          'In the beginning<f>note</f>God created',
          'en',
        );
        expect(result, isNot(contains('<f>')));
        expect(result, isNot(contains('</f>')));
        expect(result, contains('In the beginning'));
        expect(result, contains('God created'));
      });

      test('removes HTML tags from Portuguese text before TTS', () {
        final result = BibleTextFormatter.normalizeTtsText(
          'No princípio<pb/>criou Deus',
          'pt',
        );
        expect(result, isNot(contains('<pb/>')));
        expect(result, contains('No princípio'));
      });

      test('removes HTML tags from French text before TTS', () {
        final result = BibleTextFormatter.normalizeTtsText(
          'Au commencement<pb/>Dieu créa',
          'fr',
        );
        expect(result, isNot(contains('<pb/>')));
        expect(result, contains('Au commencement'));
      });

      test('removes HTML tags from Japanese text before TTS', () {
        final result = BibleTextFormatter.normalizeTtsText(
          '初めに<pb/>神は',
          'ja',
        );
        expect(result, isNot(contains('<pb/>')));
        expect(result, contains('初めに'));
        expect(result, contains('神は'));
      });

      test('removes HTML tags from Chinese text before TTS', () {
        final result = BibleTextFormatter.normalizeTtsText(
          '起初<pb/>神创造',
          'zh',
        );
        expect(result, isNot(contains('<pb/>')));
        expect(result, contains('起初'));
        expect(result, contains('神创造'));
      });
    });

    group('Bracketed Reference Removal - All Languages', () {
      test('removes bracketed references from Spanish text', () {
        final result = BibleTextFormatter.normalizeTtsText(
          'Porque de tal manera [1] amó Dios',
          'es',
        );
        expect(result, isNot(contains('[1]')));
        expect(result, contains('Porque de tal manera'));
        expect(result, contains('amó Dios'));
      });

      test('removes bracketed references from English text', () {
        final result = BibleTextFormatter.normalizeTtsText(
          'For God so loved [a] the world',
          'en',
        );
        expect(result, isNot(contains('[a]')));
        expect(result, contains('For God so loved'));
        expect(result, contains('the world'));
      });

      test('removes bracketed references from Portuguese text', () {
        final result = BibleTextFormatter.normalizeTtsText(
          'Porque Deus amou [36†] o mundo',
          'pt',
        );
        expect(result, isNot(contains('[36†]')));
        expect(result, contains('Porque Deus amou'));
      });

      test('removes bracketed references from French text', () {
        final result = BibleTextFormatter.normalizeTtsText(
          'Car Dieu a tant aimé [note] le monde',
          'fr',
        );
        expect(result, isNot(contains('[note]')));
        expect(result, contains('Car Dieu a tant aimé'));
      });

      test('removes bracketed references from Japanese text', () {
        final result = BibleTextFormatter.normalizeTtsText(
          '神は実に[1]そのひとり子を',
          'ja',
        );
        expect(result, isNot(contains('[1]')));
        expect(result, contains('神は実に'));
        expect(result, contains('そのひとり子を'));
      });

      test('removes bracketed references from Chinese text', () {
        final result = BibleTextFormatter.normalizeTtsText(
          '神爱世人[a]，甚至',
          'zh',
        );
        expect(result, isNot(contains('[a]')));
        expect(result, contains('神爱世人'));
        expect(result, contains('甚至'));
      });
    });

    group('Combined Normalization - Real User Scenarios', () {
      test('normalizes complete Spanish devotional text with all elements', () {
        final result = BibleTextFormatter.normalizeTtsText(
          '1 Juan 3:16<pb/>Porque de tal manera [1] amó Dios RVR1960',
          'es',
        );
        expect(result, contains('Primera de Juan'));
        expect(result, contains('capítulo 3'));
        expect(result, contains('versículo 16'));
        expect(result, isNot(contains('<pb/>')));
        expect(result, isNot(contains('[1]')));
        expect(result, contains('Reina Valera'));
      });

      test('normalizes complete English devotional text with all elements', () {
        final result = BibleTextFormatter.normalizeTtsText(
          '1 John 3:16<f>note</f>For God [a] so loved KJV',
          'en',
        );
        expect(result, contains('First John'));
        expect(result, contains('chapter 3'));
        expect(result, contains('verse 16'));
        expect(result, isNot(contains('<f>')));
        expect(result, isNot(contains('[a]')));
        expect(result, contains('King James Version'));
      });

      test('normalizes complete Japanese devotional text with all elements',
          () {
        final result = BibleTextFormatter.normalizeTtsText(
          'ヨハネの手紙一 3:16<pb/>神は実に[1]そのひとり子を 新改訳2003',
          'ja',
        );
        expect(result, contains('ヨハネの手紙一'));
        expect(result, contains('章 3'));
        expect(result, contains('節 16'));
        expect(result, isNot(contains('<pb/>')));
        expect(result, isNot(contains('[1]')));
        expect(result, contains('新改訳二千三年版'));
      });

      test('normalizes complete Chinese devotional text with all elements', () {
        final result = BibleTextFormatter.normalizeTtsText(
          '约翰一书 3:16<pb/>神爱世人[a]，甚至 和合本1919',
          'zh',
        );
        expect(result, contains('约翰一书'));
        expect(result, contains('章 3'));
        expect(result, contains('节 16'));
        expect(result, isNot(contains('<pb/>')));
        expect(result, isNot(contains('[a]')));
        expect(result, contains('和合本一九一九'));
      });
    });

    group('Edge Cases - Normalizer Integration', () {
      test('handles text with multiple HTML tags', () {
        final result = BibleTextFormatter.normalizeTtsText(
          'Text<pb/>with<f>many</f>tags<br/>here',
          'es',
        );
        expect(result, isNot(contains('<')));
        expect(result, isNot(contains('>')));
      });

      test('handles text with multiple bracketed references', () {
        final result = BibleTextFormatter.normalizeTtsText(
          'Text [1] with [a] many [36†] references',
          'en',
        );
        expect(result, isNot(contains('[')));
        expect(result, isNot(contains(']')));
      });

      test('handles empty text', () {
        final result = BibleTextFormatter.normalizeTtsText('', 'es');
        expect(result, isEmpty);
      });

      test('handles text with only HTML tags', () {
        final result =
            BibleTextFormatter.normalizeTtsText('<pb/><f></f>', 'es');
        expect(result, isEmpty);
      });

      test('handles text with only brackets', () {
        final result =
            BibleTextFormatter.normalizeTtsText('[1][a][note]', 'en');
        expect(result, isEmpty);
      });

      test('preserves clean text without tags or brackets', () {
        final result = BibleTextFormatter.normalizeTtsText(
          'Clean text without any tags',
          'es',
        );
        expect(result, 'Clean text without any tags');
      });
    });
  });
}
