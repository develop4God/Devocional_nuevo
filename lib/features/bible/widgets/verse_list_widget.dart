import 'package:flutter/material.dart';
import 'package:devocional_nuevo/features/bible/utils/verse_text_formatter.dart';

/// Reusable verse list widget
/// Pure presentation component with no state management
class VerseListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> verses;
  final double fontSize;
  final Set<String> selectedVerses;
  final Set<String> bookmarkedVerses;
  final String bookName;
  final int chapter;
  final Function(int verseNumber) onVerseTap;
  final Function(String verseKey) onVerseLongPress;
  final ScrollController? scrollController;
  final Map<int, GlobalKey>? verseKeys;

  const VerseListWidget({
    super.key,
    required this.verses,
    required this.fontSize,
    required this.selectedVerses,
    required this.bookmarkedVerses,
    required this.bookName,
    required this.chapter,
    required this.onVerseTap,
    required this.onVerseLongPress,
    this.scrollController,
    this.verseKeys,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (verses.isEmpty) {
      return Center(child: Text('bible.no_verses'.tr()));
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: verses.length,
      itemBuilder: (context, idx) {
        final verse = verses[idx];
        final verseNumber = verse['verse'] as int;
        final key = "$bookName|$chapter|$verseNumber";
        final isSelected = selectedVerses.contains(key);
        final isBookmarked = bookmarkedVerses.contains(key);

        return GestureDetector(
          key: verseKeys?[verseNumber],
          onTap: () => onVerseTap(verseNumber),
          onLongPress: () => onVerseLongPress(key),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: isSelected
                ? BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  )
                : null,
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: fontSize,
                  color: colorScheme.onSurface,
                  height: 1.6,
                ),
                children: [
                  TextSpan(
                    text: "${verse['verse']} ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: VerseTextFormatter.clean(verse['text']),
                    style: isBookmarked
                        ? TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: colorScheme.secondary,
                            decorationThickness: 2,
                            fontWeight: FontWeight.w500,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Extension for translations - will work if extension is imported in page
extension StringTranslation on String {
  String tr([Map<String, String>? params]) {
    // This assumes the extension method is available in the calling context
    // The actual implementation will use the existing extension
    return this;
  }
}
