// test/unit/tts/bible_text_formatter_ja_zh_ordinals_test.dart
// Tests for Japanese and Chinese ordinal number handling in Bible book names
// Validates conversion from Arabic numerals (1/2/3) to native ordinals

import 'package:devocional_nuevo/services/tts/bible_text_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BibleTextFormatter - Japanese Ordinals', () {
    group('Arabic to Japanese Numeral Conversion', () {
      test('converts 1 to 一 for Japanese Bible books', () {
        final result = BibleTextFormatter.formatBibleBook('1 ヨハネ', 'ja');
        expect(result, 'ヨハネ一');
      });

      test('converts 2 to 二 for Japanese Bible books', () {
        final result = BibleTextFormatter.formatBibleBook('2 コリント', 'ja');
        expect(result, 'コリント二');
      });

      test('converts 3 to 三 for Japanese Bible books', () {
        final result = BibleTextFormatter.formatBibleBook('3 ヨハネ', 'ja');
        expect(result, 'ヨハネ三');
      });

      test('handles mixed hiragana and katakana book names', () {
        final result = BibleTextFormatter.formatBibleBook('1 テサロニケ', 'ja');
        expect(result, 'テサロニケ一');
      });

      test('handles kanji book names', () {
        final result = BibleTextFormatter.formatBibleBook('1 列王記', 'ja');
        expect(result, '列王記一');
      });
    });

    group('Preserves Native Japanese Ordinals', () {
      test('preserves existing 一 ordinal', () {
        final result = BibleTextFormatter.formatBibleBook('ヨハネの手紙一', 'ja');
        expect(result, 'ヨハネの手紙一');
      });

      test('preserves existing 二 ordinal', () {
        final result = BibleTextFormatter.formatBibleBook('コリント人への手紙二', 'ja');
        expect(result, 'コリント人への手紙二');
      });

      test('preserves existing 三 ordinal', () {
        final result = BibleTextFormatter.formatBibleBook('ヨハネの手紙三', 'ja');
        expect(result, 'ヨハネの手紙三');
      });
    });

    group('Japanese Real User Scenarios', () {
      test('normalizes complete Japanese reference with Arabic numeral', () {
        final result = BibleTextFormatter.normalizeTtsText(
          '1 ヨハネ 3:16',
          'ja',
        );
        expect(result, contains('ヨハネ一'));
        expect(result, contains('章 3'));
        expect(result, contains('節 16'));
      });

      test('normalizes Japanese reference that already has native ordinal', () {
        final result = BibleTextFormatter.normalizeTtsText(
          'ヨハネの手紙一 3:16',
          'ja',
        );
        expect(result, contains('ヨハネの手紙一'));
        expect(result, contains('章 3'));
        expect(result, contains('節 16'));
      });

      test('handles Japanese text in middle of sentence', () {
        final result = BibleTextFormatter.formatBibleBook(
          '聖書の 2 テモテ では',
          'ja',
        );
        expect(result, contains('テモテ二'));
      });

      test('handles multiple Japanese books in same text', () {
        final result = BibleTextFormatter.formatBibleBook(
          '1 ヨハネ と 2 ペトロ',
          'ja',
        );
        expect(result, contains('ヨハネ一'));
        expect(result, contains('ペトロ二'));
      });
    });

    group('Japanese Edge Cases', () {
      test('leaves Japanese books without numbers unchanged', () {
        final result = BibleTextFormatter.formatBibleBook('創世記', 'ja');
        expect(result, '創世記');
      });

      test('handles empty Japanese text', () {
        final result = BibleTextFormatter.formatBibleBook('', 'ja');
        expect(result, isEmpty);
      });

      test('trims Japanese whitespace', () {
        final result = BibleTextFormatter.formatBibleBook('  マタイ  ', 'ja');
        expect(result, 'マタイ');
      });

      test('handles Japanese text with only numbers', () {
        final result = BibleTextFormatter.formatBibleBook('1 2 3', 'ja');
        // Should not match pattern since no Japanese characters follow
        expect(result, '1 2 3');
      });
    });
  });

  group('BibleTextFormatter - Chinese Ordinals', () {
    group('Arabic to Chinese Numeral Conversion', () {
      test('converts 1 to 一 for Chinese Bible books', () {
        final result = BibleTextFormatter.formatBibleBook('1 约翰', 'zh');
        expect(result, '约翰一');
      });

      test('converts 2 to 二 for Chinese Bible books', () {
        final result = BibleTextFormatter.formatBibleBook('2 哥林多', 'zh');
        expect(result, '哥林多二');
      });

      test('converts 3 to 三 for Chinese Bible books', () {
        final result = BibleTextFormatter.formatBibleBook('3 约翰', 'zh');
        expect(result, '约翰三');
      });

      test('handles simplified Chinese characters', () {
        final result = BibleTextFormatter.formatBibleBook('1 彼得', 'zh');
        expect(result, '彼得一');
      });

      test('handles traditional Chinese characters', () {
        final result = BibleTextFormatter.formatBibleBook('1 彼得', 'zh');
        expect(result, '彼得一');
      });
    });

    group('Preserves Native Chinese Ordinals', () {
      test('preserves existing 前书 (first epistle)', () {
        final result = BibleTextFormatter.formatBibleBook('彼得前书', 'zh');
        expect(result, '彼得前书');
      });

      test('preserves existing 后书 (second epistle)', () {
        final result = BibleTextFormatter.formatBibleBook('彼得后书', 'zh');
        expect(result, '彼得后书');
      });

      test('preserves existing 一书 ordinal', () {
        final result = BibleTextFormatter.formatBibleBook('约翰一书', 'zh');
        expect(result, '约翰一书');
      });

      test('preserves existing 二书 ordinal', () {
        final result = BibleTextFormatter.formatBibleBook('约翰二书', 'zh');
        expect(result, '约翰二书');
      });

      test('preserves existing 三书 ordinal', () {
        final result = BibleTextFormatter.formatBibleBook('约翰三书', 'zh');
        expect(result, '约翰三书');
      });
    });

    group('Chinese Real User Scenarios', () {
      test('normalizes complete Chinese reference with Arabic numeral', () {
        final result = BibleTextFormatter.normalizeTtsText(
          '1 约翰 3:16',
          'zh',
        );
        expect(result, contains('约翰一'));
        expect(result, contains('章 3'));
        expect(result, contains('节 16'));
      });

      test('normalizes Chinese reference that already has native ordinal', () {
        final result = BibleTextFormatter.normalizeTtsText(
          '约翰一书 3:16',
          'zh',
        );
        expect(result, contains('约翰一书'));
        expect(result, contains('章 3'));
        expect(result, contains('节 16'));
      });

      test('normalizes Chinese reference with 前书/后书 format', () {
        final result = BibleTextFormatter.normalizeTtsText(
          '彼得前书 1:1',
          'zh',
        );
        expect(result, contains('彼得前书'));
        expect(result, contains('章 1'));
      });

      test('handles Chinese text in middle of sentence', () {
        final result = BibleTextFormatter.formatBibleBook(
          '圣经中 2 提摩太 说',
          'zh',
        );
        expect(result, contains('提摩太二'));
      });

      test('handles multiple Chinese books in same text', () {
        final result = BibleTextFormatter.formatBibleBook(
          '1 约翰 和 2 彼得',
          'zh',
        );
        expect(result, contains('约翰一'));
        expect(result, contains('彼得二'));
      });
    });

    group('Chinese Edge Cases', () {
      test('leaves Chinese books without numbers unchanged', () {
        final result = BibleTextFormatter.formatBibleBook('创世记', 'zh');
        expect(result, '创世记');
      });

      test('handles empty Chinese text', () {
        final result = BibleTextFormatter.formatBibleBook('', 'zh');
        expect(result, isEmpty);
      });

      test('trims Chinese whitespace', () {
        final result = BibleTextFormatter.formatBibleBook('  马太福音  ', 'zh');
        expect(result, '马太福音');
      });

      test('handles Chinese text with only numbers', () {
        final result = BibleTextFormatter.formatBibleBook('1 2 3', 'zh');
        // Should not match pattern since no Chinese characters follow
        expect(result, '1 2 3');
      });

      test('handles mixed traditional and simplified', () {
        final simplified = BibleTextFormatter.formatBibleBook('1 约翰', 'zh');
        final traditional = BibleTextFormatter.formatBibleBook('1 約翰', 'zh');
        expect(simplified, '约翰一');
        expect(traditional, '約翰一');
      });
    });
  });

  group('BibleTextFormatter - JA/ZH Version Expansions', () {
    test('Japanese version expansions are present', () {
      final expansions = BibleTextFormatter.getBibleVersionExpansions('ja');
      expect(expansions, isNotEmpty);
      expect(expansions.containsKey('新改訳2003'), isTrue);
      expect(expansions.containsKey('リビングバイブル'), isTrue);
    });

    test('Japanese version 新改訳2003 expands correctly', () {
      final expansions = BibleTextFormatter.getBibleVersionExpansions('ja');
      expect(expansions['新改訳2003'], '新改訳二千三年版');
    });

    test('Japanese version リビングバイブル expands correctly', () {
      final expansions = BibleTextFormatter.getBibleVersionExpansions('ja');
      expect(expansions['リビングバイブル'], 'リビングバイブル');
    });

    test('Chinese version expansions are present', () {
      final expansions = BibleTextFormatter.getBibleVersionExpansions('zh');
      expect(expansions, isNotEmpty);
      expect(expansions.containsKey('和合本1919'), isTrue);
    });

    test('normalizes Japanese text with version expansion', () {
      final result = BibleTextFormatter.normalizeTtsText(
        'ヨハネの手紙一 3:16 新改訳2003',
        'ja',
      );
      expect(result, contains('新改訳二千三年版'));
    });

    test('normalizes Chinese text with version expansion', () {
      final result = BibleTextFormatter.normalizeTtsText(
        '约翰一书 3:16 和合本1919',
        'zh',
      );
      expect(result, contains('和合本一九一九'));
    });
  });
}
