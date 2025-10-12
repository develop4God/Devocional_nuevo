import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:devocional_nuevo/models/bible_version.dart';

part 'bible_reader_state.freezed.dart';

@freezed
class BibleReaderState with _$BibleReaderState {
  const factory BibleReaderState({
    required BibleVersion selectedVersion,
    required List<BibleVersion> availableVersions,
    @Default([]) List<Map<String, dynamic>> books,
    @Default([]) List<Map<String, dynamic>> verses,
    @Default({}) Set<String> selectedVerses, // Format: "bookName|chapter|verse"
    @Default({}) Set<String> markedVerses, // Persisted to SharedPreferences
    String? selectedBookName,
    int? selectedBookNumber,
    int? selectedChapter,
    int? selectedVerse,
    @Default(1) int maxChapter,
    @Default(1) int maxVerse,
    @Default(18.0) double fontSize,
    @Default(false) bool isLoading,
    @Default(false) bool isSearching,
    @Default(false) bool showFontControls,
    @Default([]) List<Map<String, dynamic>> searchResults,
  }) = _BibleReaderState;
}
