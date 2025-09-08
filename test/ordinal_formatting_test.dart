import 'package:devocional_nuevo/services/tts/bible_text_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ordinal Formatting Tests', () {
    test('should format Spanish ordinals correctly', () {
      expect(BibleTextFormatter.formatBibleBook('1 Juan', 'es'), contains('Primera de Juan'));
      expect(BibleTextFormatter.formatBibleBook('2 Corintios', 'es'),
          contains('Segunda de Corintios'));
      expect(BibleTextFormatter.formatBibleBook('3 Juan', 'es'), contains('Tercera de Juan'));
      expect(BibleTextFormatter.formatBibleBook('Génesis', 'es'),
          equals('Génesis')); // No ordinal change
    });

    test('should format English ordinals correctly', () {
      expect(BibleTextFormatter.formatBibleBook('1 John', 'en'), contains('First John'));
      expect(BibleTextFormatter.formatBibleBook('2 Corinthians', 'en'),
          contains('Second Corinthians'));
      expect(BibleTextFormatter.formatBibleBook('3 John', 'en'), contains('Third John'));
      expect(BibleTextFormatter.formatBibleBook('Genesis', 'en'),
          equals('Genesis')); // No ordinal change
    });

    test('should format Portuguese ordinals correctly', () {
      expect(BibleTextFormatter.formatBibleBook('1 João', 'pt'), contains('Primeiro João'));
      expect(BibleTextFormatter.formatBibleBook('2 Coríntios', 'pt'),
          contains('Segundo Coríntios'));
      expect(BibleTextFormatter.formatBibleBook('3 João', 'pt'), contains('Terceiro João'));
      expect(BibleTextFormatter.formatBibleBook('Gênesis', 'pt'),
          equals('Gênesis')); // No ordinal change
    });

    test('should format French ordinals correctly', () {
      expect(BibleTextFormatter.formatBibleBook('1 Jean', 'fr'), contains('Premier Jean'));
      expect(BibleTextFormatter.formatBibleBook('2 Corinthiens', 'fr'),
          contains('Deuxième Corinthiens'));
      expect(BibleTextFormatter.formatBibleBook('3 Jean', 'fr'), contains('Troisième Jean'));
      expect(BibleTextFormatter.formatBibleBook('Genèse', 'fr'),
          equals('Genèse')); // No ordinal change
    });

    test('should default to Spanish when unknown language', () {
      expect(BibleTextFormatter.formatBibleBook('1 Juan', 'unknown'), contains('Primera de Juan'));
      expect(BibleTextFormatter.formatBibleBook('2 Pedro', 'unknown'), contains('Segunda de Pedro'));
    });
  });
}