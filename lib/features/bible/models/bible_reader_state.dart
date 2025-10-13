/// Immutable state model for Bible Reader
/// Pure Dart class with no state management dependencies
class BibleReaderState {
  final String? selectedBookName;
  final int? selectedBookNumber;
  final int? selectedChapter;
  final int? selectedVerse;
  final int maxChapter;
  final int maxVerse;
  final List<Map<String, dynamic>> verses;
  final List<Map<String, dynamic>> books;
  final Set<String> selectedVerses;
  final Set<String> bookmarkedVerses;
  final double fontSize;
  final bool isLoading;
  final bool isSearching;
  final List<Map<String, dynamic>> searchResults;

  const BibleReaderState({
    this.selectedBookName,
    this.selectedBookNumber,
    this.selectedChapter,
    this.selectedVerse,
    this.maxChapter = 1,
    this.maxVerse = 1,
    this.verses = const [],
    this.books = const [],
    this.selectedVerses = const {},
    this.bookmarkedVerses = const {},
    this.fontSize = 18.0,
    this.isLoading = true,
    this.isSearching = false,
    this.searchResults = const [],
  });

  BibleReaderState copyWith({
    String? selectedBookName,
    int? selectedBookNumber,
    int? selectedChapter,
    int? selectedVerse,
    int? maxChapter,
    int? maxVerse,
    List<Map<String, dynamic>>? verses,
    List<Map<String, dynamic>>? books,
    Set<String>? selectedVerses,
    Set<String>? bookmarkedVerses,
    double? fontSize,
    bool? isLoading,
    bool? isSearching,
    List<Map<String, dynamic>>? searchResults,
  }) {
    return BibleReaderState(
      selectedBookName: selectedBookName ?? this.selectedBookName,
      selectedBookNumber: selectedBookNumber ?? this.selectedBookNumber,
      selectedChapter: selectedChapter ?? this.selectedChapter,
      selectedVerse: selectedVerse ?? this.selectedVerse,
      maxChapter: maxChapter ?? this.maxChapter,
      maxVerse: maxVerse ?? this.maxVerse,
      verses: verses ?? this.verses,
      books: books ?? this.books,
      selectedVerses: selectedVerses ?? this.selectedVerses,
      bookmarkedVerses: bookmarkedVerses ?? this.bookmarkedVerses,
      fontSize: fontSize ?? this.fontSize,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      searchResults: searchResults ?? this.searchResults,
    );
  }

  /// Create a unique key for a verse
  String makeVerseKey(String book, int chapter, int verse) =>
      '$book|$chapter|$verse';
}
