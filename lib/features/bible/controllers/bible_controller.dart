import 'package:flutter/foundation.dart';
import 'package:devocional_nuevo/features/bible/models/bible_reader_state.dart';
import 'package:devocional_nuevo/services/bible_db_service.dart';
import 'package:devocional_nuevo/features/bible/utils/bible_reference_parser.dart';

/// Controller for Bible Reader business logic
/// Uses ChangeNotifier (compatible with both Riverpod and BLoC)
/// NO imports of flutter_riverpod or flutter_bloc
class BibleController extends ChangeNotifier {
  final BibleDbService _service;
  BibleReaderState _state = const BibleReaderState();

  BibleReaderState get state => _state;

  BibleController(this._service);

  /// Update state and notify listeners
  void _updateState(BibleReaderState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Initialize controller with books
  Future<void> loadBooks() async {
    final books = await _service.getAllBooks();
    _updateState(_state.copyWith(
      books: books,
      selectedBookName: books.isNotEmpty ? books[0]['short_name'] : null,
      selectedBookNumber: books.isNotEmpty ? books[0]['book_number'] : null,
      selectedChapter: books.isNotEmpty ? 1 : null,
    ));

    if (_state.selectedBookNumber != null) {
      await _loadMaxChapter();
      await loadChapter(_state.selectedChapter!);
    }
  }

  /// Load maximum chapter for current book
  Future<void> _loadMaxChapter() async {
    if (_state.selectedBookNumber == null) return;
    final maxChapter = await _service.getMaxChapter(_state.selectedBookNumber!);
    _updateState(_state.copyWith(maxChapter: maxChapter));
  }

  /// Load verses for a specific chapter
  Future<void> loadChapter(int chapter) async {
    if (_state.selectedBookNumber == null) return;

    final verses = await _service.getChapterVerses(
      _state.selectedBookNumber!,
      chapter,
    );

    _updateState(_state.copyWith(
      selectedChapter: chapter,
      verses: verses,
      maxVerse: verses.isNotEmpty ? (verses.last['verse'] as int? ?? 1) : 1,
      selectedVerse: (_state.selectedVerse == null ||
              _state.selectedVerse! > (verses.last['verse'] as int? ?? 1))
          ? 1
          : _state.selectedVerse,
    ));
  }

  /// Navigate to a specific book
  Future<void> _navigateToBook(
    Map<String, dynamic> book, {
    int? chapter,
    bool goToLastChapter = false,
  }) async {
    _updateState(_state.copyWith(
      selectedBookName: book['short_name'],
      selectedBookNumber: book['book_number'],
      selectedVerses: {},
    ));

    final maxChapter = await _service.getMaxChapter(book['book_number']);
    _updateState(_state.copyWith(maxChapter: maxChapter));

    final targetChapter = goToLastChapter ? maxChapter : (chapter ?? 1);
    await loadChapter(targetChapter);
  }

  /// Navigate to next chapter
  Future<void> goToNextChapter() async {
    if (_state.selectedChapter == null || _state.books.isEmpty) return;

    if (_state.selectedChapter! < _state.maxChapter) {
      // Next chapter in same book
      await loadChapter(_state.selectedChapter! + 1);
      _updateState(_state.copyWith(
        selectedVerse: 1,
        selectedVerses: {},
      ));
    } else {
      // Find next book
      final currentIndex = _state.books.indexWhere(
        (b) => b['book_number'] == _state.selectedBookNumber,
      );
      if (currentIndex >= 0 && currentIndex < _state.books.length - 1) {
        await _navigateToBook(_state.books[currentIndex + 1], chapter: 1);
      }
    }
  }

  /// Navigate to previous chapter
  Future<void> goToPreviousChapter() async {
    if (_state.selectedChapter == null || _state.books.isEmpty) return;

    if (_state.selectedChapter! > 1) {
      // Previous chapter in same book
      await loadChapter(_state.selectedChapter! - 1);
      _updateState(_state.copyWith(
        selectedVerse: 1,
        selectedVerses: {},
      ));
    } else {
      // Find previous book
      final currentIndex = _state.books.indexWhere(
        (b) => b['book_number'] == _state.selectedBookNumber,
      );
      if (currentIndex > 0) {
        await _navigateToBook(_state.books[currentIndex - 1],
            goToLastChapter: true);
      }
    }
  }

  /// Select a book and optionally navigate to a specific chapter
  Future<void> selectBook(
    Map<String, dynamic> book, {
    int? chapter,
  }) async {
    await _navigateToBook(book, chapter: chapter);
  }

  /// Search for verses or navigate to Bible reference
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _updateState(_state.copyWith(
        isSearching: false,
        searchResults: [],
      ));
      return;
    }

    // Try Bible reference first
    final reference = BibleReferenceParser.parse(query);
    if (reference != null) {
      final book = await _service.findBookByName(reference['bookName']);

      if (book != null) {
        final chapter = reference['chapter'] as int;
        final verse = reference['verse'] as int?;

        // Validate chapter exists
        final maxChapter = await _service.getMaxChapter(book['book_number']);
        if (chapter > 0 && chapter <= maxChapter) {
          await _navigateToBook(book, chapter: chapter);

          // If specific verse requested, store for auto-scroll
          if (verse != null) {
            _updateState(_state.copyWith(selectedVerse: verse));
          }

          // Clear search, return early
          _updateState(_state.copyWith(
            isSearching: false,
            searchResults: [],
          ));
          return;
        }
      }
    }

    // Fall back to text search
    final results = await _service.searchVerses(query);
    _updateState(_state.copyWith(
      isSearching: true,
      searchResults: results,
    ));
  }

  /// Jump to a search result
  Future<void> jumpToSearchResult(Map<String, dynamic> result) async {
    final bookNumber = result['book_number'] as int;
    final chapter = result['chapter'] as int;
    final verse = result['verse'] as int;

    final book = _state.books.firstWhere(
      (b) => b['book_number'] == bookNumber,
      orElse: () => _state.books.isNotEmpty ? _state.books[0] : {},
    );

    if (book.isNotEmpty) {
      await _navigateToBook(book, chapter: chapter);
      _updateState(_state.copyWith(
        selectedVerse: verse,
        isSearching: false,
        searchResults: [],
      ));
    }
  }

  /// Toggle verse selection
  void toggleVerseSelection(String verseKey) {
    final newSelection = Set<String>.from(_state.selectedVerses);
    if (newSelection.contains(verseKey)) {
      newSelection.remove(verseKey);
    } else {
      newSelection.add(verseKey);
    }
    _updateState(_state.copyWith(selectedVerses: newSelection));
  }

  /// Clear verse selection
  void clearVerseSelection() {
    _updateState(_state.copyWith(selectedVerses: {}));
  }

  /// Toggle bookmark for a verse
  void toggleBookmark(String verseKey) {
    final newBookmarks = Set<String>.from(_state.bookmarkedVerses);
    if (newBookmarks.contains(verseKey)) {
      newBookmarks.remove(verseKey);
    } else {
      newBookmarks.add(verseKey);
    }
    _updateState(_state.copyWith(bookmarkedVerses: newBookmarks));
  }

  /// Add selected verses to bookmarks
  void saveSelectedVersesToBookmarks() {
    final newBookmarks = Set<String>.from(_state.bookmarkedVerses);
    newBookmarks.addAll(_state.selectedVerses);
    _updateState(_state.copyWith(
      bookmarkedVerses: newBookmarks,
      selectedVerses: {},
    ));
  }

  /// Increase font size
  void increaseFontSize() {
    if (_state.fontSize < 30) {
      _updateState(_state.copyWith(fontSize: _state.fontSize + 2));
    }
  }

  /// Decrease font size
  void decreaseFontSize() {
    if (_state.fontSize > 12) {
      _updateState(_state.copyWith(fontSize: _state.fontSize - 2));
    }
  }

  /// Set font size directly
  void setFontSize(double size) {
    if (size >= 12 && size <= 30) {
      _updateState(_state.copyWith(fontSize: size));
    }
  }

  /// Set loading state
  void setLoading(bool loading) {
    _updateState(_state.copyWith(isLoading: loading));
  }

  /// Restore state from saved position
  Future<void> restorePosition({
    required String bookName,
    required int bookNumber,
    required int chapter,
  }) async {
    final book = _state.books.firstWhere(
      (b) => b['short_name'] == bookName || b['book_number'] == bookNumber,
      orElse: () => _state.books.isNotEmpty ? _state.books[0] : {},
    );

    if (book.isNotEmpty) {
      await _navigateToBook(book, chapter: chapter);
    }
  }

  /// Update books list (for version switching)
  void updateBooks(List<Map<String, dynamic>> books) {
    _updateState(_state.copyWith(books: books));
  }

  /// Initialize with bookmarked verses
  void initializeBookmarks(Set<String> bookmarks) {
    _updateState(_state.copyWith(bookmarkedVerses: bookmarks));
  }
}
