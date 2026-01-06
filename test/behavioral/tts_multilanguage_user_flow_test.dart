// test/behavioral/tts_multilanguage_user_flow_test.dart
// Real user behavior test: Devotional reading with TTS across all supported languages
// Validates that TTS normalizer and ordinal numbers work correctly for ES, EN, PT, FR, JA, ZH

import 'package:devocional_nuevo/services/tts/bible_text_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TTS Multilanguage User Flow - Real Scenarios', () {
    group('Spanish User Reading Devotional', () {
      test('User reads devotional with 1 Pedro reference and HTML tags', () {
        // Simulates Spanish devotional text with HTML tags and bracketed references
        // that would be read by TTS
        final devotionalText = '''
          Hoy reflexionamos sobre 1 Pedro 3:15-16 RVR1960<pb/>
          Sino santificad a Dios el Señor [1] en vuestros corazones,
          y estad siempre preparados<f>nota al pie</f>para presentar defensa.
        ''';

        final normalized = BibleTextFormatter.normalizeTtsText(
          devotionalText,
          'es',
        );

        // Should convert 1 Pedro to Primera de Pedro
        expect(normalized, contains('Primera de Pedro'));
        // Should expand version
        expect(normalized, contains('Reina Valera'));
        // Should format chapter:verse
        expect(normalized, contains('capítulo 3'));
        expect(normalized, contains('versículo 15'));
        // Should remove HTML tags
        expect(normalized, isNot(contains('<pb/>')));
        expect(normalized, isNot(contains('<f>')));
        // Should remove bracketed references
        expect(normalized, isNot(contains('[1]')));
        // Should preserve actual text
        expect(normalized, contains('Sino santificad'));
      });
    });

    group('English User Reading Devotional', () {
      test('User reads devotional with 1 John reference and annotations', () {
        final devotionalText = '''
          Today we reflect on 1 John 3:16 KJV<pb/>
          Hereby perceive we the love [a] of God,
          because he laid down<f>footnote</f>his life for us.
        ''';

        final normalized = BibleTextFormatter.normalizeTtsText(
          devotionalText,
          'en',
        );

        expect(normalized, contains('First John'));
        expect(normalized, contains('King James Version'));
        expect(normalized, contains('chapter 3'));
        expect(normalized, contains('verse 16'));
        expect(normalized, isNot(contains('<pb/>')));
        expect(normalized, isNot(contains('[a]')));
        expect(normalized, contains('Hereby perceive we'));
      });
    });

    group('Portuguese User Reading Devotional', () {
      test('User reads devotional with 2 Coríntios reference', () {
        final devotionalText = '''
          Hoje meditamos em 2 Coríntios 5:17 ARC<pb/>
          Assim que, se alguém [36†] está em Cristo,
          nova criatura é<f>ver nota</f>.
        ''';

        final normalized = BibleTextFormatter.normalizeTtsText(
          devotionalText,
          'pt',
        );

        expect(normalized, contains('Segundo Coríntios'));
        expect(normalized, contains('Almeida Revista'));
        expect(normalized, contains('capítulo 5'));
        expect(normalized, contains('versículo 17'));
        expect(normalized, isNot(contains('<pb/>')));
        expect(normalized, isNot(contains('[36†]')));
      });
    });

    group('French User Reading Devotional', () {
      test('User reads devotional with 3 Jean reference', () {
        final devotionalText = '''
          Aujourd'hui nous méditons sur 3 Jean 1:2 LSG1910<pb/>
          Bien-aimé, je souhaite [note] que tu prospères
          à tous égards<f>note</f>.
        ''';

        final normalized = BibleTextFormatter.normalizeTtsText(
          devotionalText,
          'fr',
        );

        expect(normalized, contains('Troisième Jean'));
        expect(normalized, contains('Louis Segond'));
        expect(normalized, contains('chapitre 1'));
        expect(normalized, contains('verset 2'));
        expect(normalized, isNot(contains('<pb/>')));
        expect(normalized, isNot(contains('[note]')));
      });
    });

    group('Japanese User Reading Devotional', () {
      test('User reads devotional with Japanese text and HTML tags', () {
        final devotionalText = '''
          今日はヨハネの手紙一 3:16 新改訳2003<pb/>について黙想します。
          私たちは、キリストが[1]私たちのために
          いのちを捨てて<f>脚注</f>くださったことによって、
          愛が何であるかを知りました。
        ''';

        final normalized = BibleTextFormatter.normalizeTtsText(
          devotionalText,
          'ja',
        );

        // Should preserve Japanese book name
        expect(normalized, contains('ヨハネの手紙一'));
        // Should expand Japanese version
        expect(normalized, contains('新改訳二千三年版'));
        // Should format chapter:verse in Japanese
        expect(normalized, contains('章 3'));
        expect(normalized, contains('節 16'));
        // Should remove HTML tags
        expect(normalized, isNot(contains('<pb/>')));
        expect(normalized, isNot(contains('<f>')));
        // Should remove bracketed references
        expect(normalized, isNot(contains('[1]')));
        // Should preserve Japanese text
        expect(normalized, contains('私たちは'));
      });

      test('User reads devotional with Arabic numeral book reference', () {
        final devotionalText = '''
          1 ヨハネ 4:7<pb/>を読みましょう。
          愛する者たち。[a]私たちは、互いに愛し合いましょう。
        ''';

        final normalized = BibleTextFormatter.normalizeTtsText(
          devotionalText,
          'ja',
        );

        // Should convert 1 ヨハネ to ヨハネ一
        expect(normalized, contains('ヨハネ一'));
        expect(normalized, contains('章 4'));
        expect(normalized, contains('節 7'));
        expect(normalized, isNot(contains('<pb/>')));
        expect(normalized, isNot(contains('[a]')));
      });
    });

    group('Chinese User Reading Devotional', () {
      test('User reads devotional with Chinese text and HTML tags', () {
        final devotionalText = '''
          今天我们默想约翰一书 3:16 和合本1919<pb/>
          主为我们舍命，[1]我们从此就知道
          何为爱<f>注释</f>。
        ''';

        final normalized = BibleTextFormatter.normalizeTtsText(
          devotionalText,
          'zh',
        );

        // Should preserve Chinese book name
        expect(normalized, contains('约翰一书'));
        // Should expand Chinese version
        expect(normalized, contains('和合本一九一九'));
        // Should format chapter:verse in Chinese
        expect(normalized, contains('章 3'));
        expect(normalized, contains('节 16'));
        // Should remove HTML tags
        expect(normalized, isNot(contains('<pb/>')));
        expect(normalized, isNot(contains('<f>')));
        // Should remove bracketed references
        expect(normalized, isNot(contains('[1]')));
        // Should preserve Chinese text
        expect(normalized, contains('我们从此就知道'));
      });

      test('User reads devotional with Arabic numeral book reference', () {
        final devotionalText = '''
          1 约翰 4:7-8<pb/>记载：
          亲爱的弟兄啊，[a]我们应当彼此相爱。
        ''';

        final normalized = BibleTextFormatter.normalizeTtsText(
          devotionalText,
          'zh',
        );

        // Should convert 1 约翰 to 约翰一
        expect(normalized, contains('约翰一'));
        expect(normalized, contains('章 4'));
        expect(normalized, contains('节 7'));
        expect(normalized, contains('至 8'));
        expect(normalized, isNot(contains('<pb/>')));
        expect(normalized, isNot(contains('[a]')));
      });

      test('User reads devotional with traditional Chinese characters', () {
        final devotionalText = '''
          今天讀彼得前書 1:3-5 新译本<pb/>
          願頌讚歸與我們[36†]主耶穌基督的父神。
        ''';

        final normalized = BibleTextFormatter.normalizeTtsText(
          devotionalText,
          'zh',
        );

        // Should preserve traditional characters
        expect(normalized, contains('彼得前書'));
        expect(normalized, contains('新译本'));
        expect(normalized, isNot(contains('<pb/>')));
        expect(normalized, isNot(contains('[36†]')));
      });
    });

    group('Edge Cases - Cross-Language Consistency', () {
      test('All languages consistently remove HTML tags', () {
        final testText = 'Text<pb/>with<f>tags</f>';

        for (final lang in ['es', 'en', 'pt', 'fr', 'ja', 'zh']) {
          final result = BibleTextFormatter.normalizeTtsText(testText, lang);
          expect(result, isNot(contains('<')), reason: 'Failed for $lang');
          expect(result, isNot(contains('>')), reason: 'Failed for $lang');
        }
      });

      test('All languages consistently remove bracketed references', () {
        final testText = 'Text [1] with [a] references [36†]';

        for (final lang in ['es', 'en', 'pt', 'fr', 'ja', 'zh']) {
          final result = BibleTextFormatter.normalizeTtsText(testText, lang);
          expect(result, isNot(contains('[')), reason: 'Failed for $lang');
          expect(result, isNot(contains(']')), reason: 'Failed for $lang');
        }
      });

      test('All languages handle empty text gracefully', () {
        for (final lang in ['es', 'en', 'pt', 'fr', 'ja', 'zh']) {
          final result = BibleTextFormatter.normalizeTtsText('', lang);
          expect(result, isEmpty, reason: 'Failed for $lang');
        }
      });

      test('All languages handle text with only whitespace', () {
        for (final lang in ['es', 'en', 'pt', 'fr', 'ja', 'zh']) {
          final result = BibleTextFormatter.normalizeTtsText('   ', lang);
          expect(result, isEmpty, reason: 'Failed for $lang');
        }
      });
    });

    group('Version Expansion - All Languages', () {
      test('Each language has version expansions configured', () {
        final languages = ['es', 'en', 'pt', 'fr', 'ja', 'zh'];

        for (final lang in languages) {
          final expansions = BibleTextFormatter.getBibleVersionExpansions(lang);
          expect(
            expansions,
            isNotEmpty,
            reason: '$lang should have version expansions',
          );
        }
      });
    });
  });
}
