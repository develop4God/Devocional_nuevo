import 'package:flutter/material.dart';
import 'package:devocional_nuevo/utils/bible_text_normalizer.dart';

/// Utility class for formatting verse text
class VerseTextFormatter {
  /// Clean verse text by removing HTML tags and brackets
  static String clean(String? text) {
    return BibleTextNormalizer.clean(text?.toString());
  }

  /// Format selected verses as text
  static String formatSelection(
    List<Map<String, dynamic>> verses,
    Set<String> selectedKeys,
  ) {
    final List<String> lines = [];
    final sortedVerses = selectedKeys.toList()..sort();

    for (final key in sortedVerses) {
      final parts = key.split('|');
      final book = parts[0];
      final chapter = parts[1];
      final verseNum = int.parse(parts[2]);

      final verse = verses.firstWhere(
        (v) => v['verse'] == verseNum,
        orElse: () => {},
      );

      if (verse.isNotEmpty) {
        lines.add('$book $chapter:$verseNum - ${clean(verse['text'])}');
      }
    }

    return lines.join('\n\n');
  }

  /// Format reference for selected verses
  static String formatReference(Set<String> selectedKeys) {
    if (selectedKeys.isEmpty) return '';

    final sortedVerses = selectedKeys.toList()..sort();
    final parts = sortedVerses.first.split('|');
    final book = parts[0];
    final chapter = parts[1];

    if (selectedKeys.length == 1) {
      final verse = parts[2];
      return '$book $chapter:$verse';
    } else {
      final firstVerse = int.parse(parts[2]);
      final lastParts = sortedVerses.last.split('|');
      final lastVerse = int.parse(lastParts[2]);

      if (firstVerse == lastVerse) {
        return '$book $chapter:$firstVerse';
      } else {
        return '$book $chapter:$firstVerse-$lastVerse';
      }
    }
  }

  /// Build highlighted text spans for search results
  static List<TextSpan> highlightMatches(
    String text,
    String query,
    ColorScheme colorScheme,
  ) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int lastIndex = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // Add text before match
      if (index > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, index),
          style: TextStyle(color: colorScheme.onSurface),
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          backgroundColor: colorScheme.primaryContainer,
        ),
      ));

      lastIndex = index + query.length;
      index = lowerText.indexOf(lowerQuery, lastIndex);
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(color: colorScheme.onSurface),
      ));
    }

    return spans;
  }
}
