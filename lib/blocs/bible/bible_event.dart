// lib/blocs/bible/bible_event.dart

import 'package:devocional_nuevo/models/bible_version.dart';

abstract class BibleEvent {}

/// Event to initialize the Bible reader with language detection
class InitializeBible extends BibleEvent {
  final List<BibleVersion> availableVersions;
  final String deviceLanguage;

  InitializeBible({
    required this.availableVersions,
    required this.deviceLanguage,
  });
}

/// Event to select a different Bible version
class SelectVersion extends BibleEvent {
  final BibleVersion version;

  SelectVersion(this.version);
}

/// Event to select a book
class SelectBook extends BibleEvent {
  final String bookName;
  final int bookNumber;

  SelectBook({
    required this.bookName,
    required this.bookNumber,
  });
}

/// Event to select a chapter
class SelectChapter extends BibleEvent {
  final int chapter;

  SelectChapter(this.chapter);
}

/// Event to select a verse
class SelectVerse extends BibleEvent {
  final int verse;

  SelectVerse(this.verse);
}

/// Event to navigate to the previous chapter
class GoToPreviousChapter extends BibleEvent {}

/// Event to navigate to the next chapter
class GoToNextChapter extends BibleEvent {}

/// Event to toggle verse selection
class ToggleVerseSelection extends BibleEvent {
  final String verseKey;

  ToggleVerseSelection(this.verseKey);
}

/// Event to toggle persistent verse marking
class TogglePersistentMark extends BibleEvent {
  final String verseKey;

  TogglePersistentMark(this.verseKey);
}

/// Event to clear verse selections
class ClearVerseSelections extends BibleEvent {}

/// Event to perform a search
class SearchBible extends BibleEvent {
  final String query;

  SearchBible(this.query);
}

/// Event to jump to a search result
class JumpToSearchResult extends BibleEvent {
  final Map<String, dynamic> result;

  JumpToSearchResult(this.result);
}

/// Event to update font size
class UpdateFontSize extends BibleEvent {
  final double fontSize;

  UpdateFontSize(this.fontSize);
}

/// Event to load saved reading position
class LoadReadingPosition extends BibleEvent {}

/// Event to save current reading position
class SaveReadingPosition extends BibleEvent {}

/// Event to restore a specific position
class RestorePosition extends BibleEvent {
  final Map<String, dynamic> position;

  RestorePosition(this.position);
}
