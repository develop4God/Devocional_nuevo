// lib/blocs/bible/bible_state.dart

import 'package:devocional_nuevo/models/bible_version.dart';

abstract class BibleState {}

/// Initial state when the bloc is created
class BibleInitial extends BibleState {}

/// State when Bible data is being loaded
class BibleLoading extends BibleState {}

/// State when Bible is ready with data
class BibleLoaded extends BibleState {
  final BibleVersion selectedVersion;
  final List<BibleVersion> availableVersions;
  final List<Map<String, dynamic>> books;
  final String? selectedBookName;
  final int? selectedBookNumber;
  final int? selectedChapter;
  final int? selectedVerse;
  final int maxChapter;
  final int maxVerse;
  final List<Map<String, dynamic>> verses;
  final Set<String> selectedVerses;
  final Set<String> persistentlyMarkedVerses;
  final double fontSize;
  final bool isSearching;
  final List<Map<String, dynamic>> searchResults;

  BibleLoaded({
    required this.selectedVersion,
    required this.availableVersions,
    required this.books,
    this.selectedBookName,
    this.selectedBookNumber,
    this.selectedChapter,
    this.selectedVerse,
    this.maxChapter = 1,
    this.maxVerse = 1,
    this.verses = const [],
    this.selectedVerses = const {},
    this.persistentlyMarkedVerses = const {},
    this.fontSize = 18.0,
    this.isSearching = false,
    this.searchResults = const [],
  });

  /// Create a copy of this state with updated values
  BibleLoaded copyWith({
    BibleVersion? selectedVersion,
    List<BibleVersion>? availableVersions,
    List<Map<String, dynamic>>? books,
    String? selectedBookName,
    int? selectedBookNumber,
    int? selectedChapter,
    int? selectedVerse,
    int? maxChapter,
    int? maxVerse,
    List<Map<String, dynamic>>? verses,
    Set<String>? selectedVerses,
    Set<String>? persistentlyMarkedVerses,
    double? fontSize,
    bool? isSearching,
    List<Map<String, dynamic>>? searchResults,
    bool clearBookSelection = false,
    bool clearChapterSelection = false,
    bool clearVerseSelection = false,
  }) {
    return BibleLoaded(
      selectedVersion: selectedVersion ?? this.selectedVersion,
      availableVersions: availableVersions ?? this.availableVersions,
      books: books ?? this.books,
      selectedBookName: clearBookSelection
          ? null
          : (selectedBookName ?? this.selectedBookName),
      selectedBookNumber: clearBookSelection
          ? null
          : (selectedBookNumber ?? this.selectedBookNumber),
      selectedChapter: clearChapterSelection
          ? null
          : (selectedChapter ?? this.selectedChapter),
      selectedVerse:
          clearVerseSelection ? null : (selectedVerse ?? this.selectedVerse),
      maxChapter: maxChapter ?? this.maxChapter,
      maxVerse: maxVerse ?? this.maxVerse,
      verses: verses ?? this.verses,
      selectedVerses: selectedVerses ?? this.selectedVerses,
      persistentlyMarkedVerses:
          persistentlyMarkedVerses ?? this.persistentlyMarkedVerses,
      fontSize: fontSize ?? this.fontSize,
      isSearching: isSearching ?? this.isSearching,
      searchResults: searchResults ?? this.searchResults,
    );
  }

  /// Check if a verse is currently selected
  bool isVerseSelected(String verseKey) {
    return selectedVerses.contains(verseKey);
  }

  /// Check if a verse is persistently marked
  bool isVersePersistentlyMarked(String verseKey) {
    return persistentlyMarkedVerses.contains(verseKey);
  }

  /// Get selected verses text for sharing
  String getSelectedVersesText() {
    final List<String> lines = [];
    final sortedVerses = selectedVerses.toList()..sort();

    for (final key in sortedVerses) {
      final parts = key.split('|');
      if (parts.length != 3) continue;

      final book = parts[0];
      final chapter = parts[1];
      final verseNum = int.tryParse(parts[2]);
      if (verseNum == null) continue;

      final verse = verses.firstWhere(
        (v) => v['verse'] == verseNum,
        orElse: () => {},
      );

      if (verse.isNotEmpty) {
        lines.add('$book $chapter:$verseNum - ${verse['text']}');
      }
    }

    return lines.join('\n\n');
  }

  /// Get selected verses reference (e.g., "Juan 3:16-20")
  String getSelectedVersesReference() {
    if (selectedVerses.isEmpty) return '';

    final sortedVerses = selectedVerses.toList()..sort();
    final parts = sortedVerses.first.split('|');
    if (parts.length != 3) return '';

    final book = parts[0];
    final chapter = parts[1];

    if (selectedVerses.length == 1) {
      final verse = parts[2];
      return '$book $chapter:$verse';
    } else {
      final firstVerse = int.tryParse(parts[2]);
      final lastParts = sortedVerses.last.split('|');
      final lastVerse =
          lastParts.length >= 3 ? int.tryParse(lastParts[2]) : null;

      if (firstVerse == null || lastVerse == null) {
        return '$book $chapter:${parts[2]}';
      }

      if (firstVerse == lastVerse) {
        return '$book $chapter:$firstVerse';
      } else {
        return '$book $chapter:$firstVerse-$lastVerse';
      }
    }
  }
}

/// State when there's an error
class BibleError extends BibleState {
  final String message;

  BibleError(this.message);
}
