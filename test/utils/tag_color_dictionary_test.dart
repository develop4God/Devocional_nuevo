import 'package:devocional_nuevo/utils/tag_color_dictionary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TagColorDictionary', () {
    test('getGradientForTag returns correct gradient for known tag', () {
      final gradient = TagColorDictionary.getGradientForTag('tag.faith');
      expect(gradient, isA<List<Color>>());
      expect(gradient.length, 2);
      expect(gradient.first, Color(0xFF9C27B0));
      expect(gradient.last, Color(0xFF673AB7));
    });

    test('getGradientForTag returns default gradient for unknown tag', () {
      final gradient = TagColorDictionary.getGradientForTag('tag.unknown');
      expect(gradient, [Color(0xFF607D8B), Color(0xFF455A64)]);
    });

    test(
        'getTagTranslation returns correct translation for known tag and language',
        () {
      expect(TagColorDictionary.getTagTranslation('tag.faith', 'es'), 'Fe');
      expect(TagColorDictionary.getTagTranslation('tag.faith', 'en'), 'Faith');
      expect(TagColorDictionary.getTagTranslation('tag.faith', 'pt'), 'Fé');
      expect(TagColorDictionary.getTagTranslation('tag.faith', 'fr'), 'Foi');
      expect(TagColorDictionary.getTagTranslation('tag.faith', 'ja'), '信仰');
      expect(TagColorDictionary.getTagTranslation('tag.faith', 'zh'), '信仰');
    });

    test('getTagTranslation returns key for unknown tag or language', () {
      expect(TagColorDictionary.getTagTranslation('tag.unknown', 'es'),
          'tag.unknown');
      expect(
          TagColorDictionary.getTagTranslation('tag.faith', 'ru'), 'tag.faith');
    });
  });
}
