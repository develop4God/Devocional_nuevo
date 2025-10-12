import 'dart:ui' as ui;
import 'package:devocional_nuevo/features/bible/models/bible_reader_state.dart';
import 'package:devocional_nuevo/features/bible/utils/bible_reference_parser.dart';
import 'package:devocional_nuevo/models/bible_version.dart';
import 'package:devocional_nuevo/services/bible_db_service.dart';
import 'package:devocional_nuevo/services/bible_reading_position_service.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'bible_reader_provider.g.dart';

@riverpod
class BibleReader extends _$BibleReader {
  final BibleReadingPositionService _positionService =
      BibleReadingPositionService();
  ScrollController? _scrollController;
  final Map<int, GlobalKey> _verseKeys = {};

  @override
  Future<BibleReaderState> build(List<BibleVersion> versions) async {
    // 1. Detect device language
    final deviceLanguage = ui.PlatformDispatcher.instance.locale.languageCode;

    // 2. Filter versions by language
    var filteredVersions =
        versions.where((v) => v.languageCode == deviceLanguage).toList();

    // Fallback to Spanish if empty
    if (filteredVersions.isEmpty) {
      filteredVersions = versions.where((v) => v.languageCode == 'es').toList();
    }

    // Fallback to all versions if still empty
    if (filteredVersions.isEmpty) {
      filteredVersions = versions;
    }

    // 3. Load SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final fontSize = prefs.getDouble('bible_font_size') ?? 18.0;
    final markedVersesList = prefs.getStringList('bible_marked_verses') ?? [];
    final markedVerses = markedVersesList.toSet();

    // 4. Select first available version
    if (filteredVersions.isEmpty) {
      throw Exception('No Bible versions available');
    }

    final selectedVersion = filteredVersions.first;

    // Initialize service if needed
    if (selectedVersion.service == null) {
      selectedVersion.service = BibleDbService();
    }

    await selectedVersion.service!.initDb(
      selectedVersion.assetPath,
      selectedVersion.dbFileName,
    );

    // 5. Load books
    final books = await selectedVersion.service!.getAllBooks();

    // 6. Try to restore position
    final lastPosition = await _positionService.getLastPosition();
    String? selectedBookName;
    int? selectedBookNumber;
    int? selectedChapter;
    int? selectedVerse;
    int maxChapter = 1;
    int maxVerse = 1;
    List<Map<String, dynamic>> verses = [];

    if (lastPosition != null &&
        lastPosition['version'] == selectedVersion.name) {
      // Restore to last position
      selectedBookName = lastPosition['bookName'];
      selectedBookNumber = lastPosition['bookNumber'];
      selectedChapter = lastPosition['chapter'];
      selectedVerse = lastPosition['verse'] ?? 1;

      // Verify book exists
      final bookExists = books.any(
        (b) => b['book_number'] == selectedBookNumber,
      );

      if (bookExists) {
        maxChapter =
            await selectedVersion.service!.getMaxChapter(selectedBookNumber!);
        verses = await selectedVersion.service!.getChapterVerses(
          selectedBookNumber!,
          selectedChapter!,
        );
        maxVerse = verses.isNotEmpty ? (verses.last['verse'] as int? ?? 1) : 1;
      } else {
        // Book doesn't exist, fallback to first book
        final firstBook = books.first;
        selectedBookName = firstBook['short_name'];
        selectedBookNumber = firstBook['book_number'];
        selectedChapter = 1;
        selectedVerse = 1;
        maxChapter =
            await selectedVersion.service!.getMaxChapter(selectedBookNumber!);
        verses = await selectedVersion.service!.getChapterVerses(
          selectedBookNumber!,
          selectedChapter!,
        );
        maxVerse = verses.isNotEmpty ? (verses.last['verse'] as int? ?? 1) : 1;
      }
    } else {
      // Load first book, chapter 1
      final firstBook = books.first;
      selectedBookName = firstBook['short_name'];
      selectedBookNumber = firstBook['book_number'];
      selectedChapter = 1;
      selectedVerse = 1;
      maxChapter =
          await selectedVersion.service!.getMaxChapter(selectedBookNumber!);
      verses = await selectedVersion.service!.getChapterVerses(
        selectedBookNumber!,
        selectedChapter!,
      );
      maxVerse = verses.isNotEmpty ? (verses.last['verse'] as int? ?? 1) : 1;
    }

    // 7. Initialize verse keys
    _initVerseKeys(verses);

    // 8. Return initialized state
    return BibleReaderState(
      selectedVersion: selectedVersion,
      availableVersions: filteredVersions,
      books: books,
      verses: verses,
      selectedVerses: {},
      markedVerses: markedVerses,
      selectedBookName: selectedBookName,
      selectedBookNumber: selectedBookNumber,
      selectedChapter: selectedChapter,
      selectedVerse: selectedVerse,
      maxChapter: maxChapter,
      maxVerse: maxVerse,
      fontSize: fontSize,
      isLoading: false,
      isSearching: false,
      showFontControls: false,
      searchResults: [],
    );
  }

  /// Initialize verse keys for scrolling
  void _initVerseKeys(List<Map<String, dynamic>> verses) {
    _verseKeys.clear();
    for (final verse in verses) {
      final verseNum = verse['verse'] as int;
      _verseKeys[verseNum] = GlobalKey();
    }
  }

  /// Expose verse keys for widget to access
  Map<int, GlobalKey> get verseKeys => _verseKeys;

  /// Attach scroll controller for scroll operations
  void attachScrollController(ScrollController controller) {
    _scrollController = controller;
  }

  /// Select a book and load its verses
  Future<void> selectBook({
    required Map<String, dynamic> book,
    int? chapter,
    bool goToLastChapter = false,
  }) async {
    final currentState = await future;
    final service = currentState.selectedVersion.service!;

    final bookName = book['short_name'] as String;
    final bookNumber = book['book_number'] as int;

    final maxChapter = await service.getMaxChapter(bookNumber);
    final targetChapter = goToLastChapter ? maxChapter : (chapter ?? 1);

    final verses = await service.getChapterVerses(bookNumber, targetChapter);
    final maxVerse =
        verses.isNotEmpty ? (verses.last['verse'] as int? ?? 1) : 1;

    _initVerseKeys(verses);

    state = AsyncValue.data(currentState.copyWith(
      selectedBookName: bookName,
      selectedBookNumber: bookNumber,
      selectedChapter: targetChapter,
      selectedVerse: 1,
      maxChapter: maxChapter,
      maxVerse: maxVerse,
      verses: verses,
      selectedVerses: {},
    ));

    // Save position
    await _positionService.savePosition(
      bookName: bookName,
      bookNumber: bookNumber,
      chapter: targetChapter,
      version: currentState.selectedVersion.name,
      languageCode: currentState.selectedVersion.languageCode,
    );
  }

  /// Select a chapter and load its verses
  Future<void> selectChapter(int chapter) async {
    final currentState = await future;
    final service = currentState.selectedVersion.service!;

    if (currentState.selectedBookNumber == null) return;

    final verses = await service.getChapterVerses(
      currentState.selectedBookNumber!,
      chapter,
    );
    final maxVerse =
        verses.isNotEmpty ? (verses.last['verse'] as int? ?? 1) : 1;

    _initVerseKeys(verses);

    state = AsyncValue.data(currentState.copyWith(
      selectedChapter: chapter,
      selectedVerse: 1,
      maxVerse: maxVerse,
      verses: verses,
      selectedVerses: {},
    ));

    // Save position
    if (currentState.selectedBookName != null &&
        currentState.selectedBookNumber != null) {
      await _positionService.savePosition(
        bookName: currentState.selectedBookName!,
        bookNumber: currentState.selectedBookNumber!,
        chapter: chapter,
        version: currentState.selectedVersion.name,
        languageCode: currentState.selectedVersion.languageCode,
      );
    }

    // Scroll to top
    _scrollToTop();
  }

  /// Navigate to previous chapter
  Future<void> goToPreviousChapter() async {
    final currentState = await future;

    if (currentState.selectedBookNumber == null ||
        currentState.selectedChapter == null) {
      return;
    }

    if (currentState.selectedChapter! > 1) {
      // Go to previous chapter in same book
      await selectChapter(currentState.selectedChapter! - 1);
    } else {
      // Go to last chapter of previous book
      final currentBookIndex = currentState.books.indexWhere(
        (b) => b['book_number'] == currentState.selectedBookNumber,
      );
      if (currentBookIndex > 0) {
        final previousBook = currentState.books[currentBookIndex - 1];
        await selectBook(book: previousBook, goToLastChapter: true);
      }
    }
  }

  /// Navigate to next chapter
  Future<void> goToNextChapter() async {
    final currentState = await future;

    if (currentState.selectedBookNumber == null ||
        currentState.selectedChapter == null) {
      return;
    }

    if (currentState.selectedChapter! < currentState.maxChapter) {
      // Go to next chapter in same book
      await selectChapter(currentState.selectedChapter! + 1);
    } else {
      // Go to first chapter of next book
      final currentBookIndex = currentState.books.indexWhere(
        (b) => b['book_number'] == currentState.selectedBookNumber,
      );
      if (currentBookIndex < currentState.books.length - 1) {
        final nextBook = currentState.books[currentBookIndex + 1];
        await selectBook(book: nextBook, chapter: 1);
      }
    }
  }

  /// Scroll to a specific verse using GlobalKey (FIX #1)
  void scrollToVerse(int verseNumber) {
    // Update selected verse in state
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(
        selectedVerse: verseNumber,
      ));
    });

    // Use delay to ensure layout is complete
    Future.delayed(const Duration(milliseconds: 150), () {
      final key = _verseKeys[verseNumber];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.2, // Position verse at 20% from top of viewport
        );
      }
    });
  }

  /// Scroll to top of chapter
  void _scrollToTop() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController != null && _scrollController!.hasClients) {
        _scrollController!.animateTo(
          0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Toggle verse selection for sharing/copying
  void toggleVerseSelection(int verseNumber) {
    state.whenData((currentState) {
      final key =
          "${currentState.selectedBookName}|${currentState.selectedChapter}|$verseNumber";
      final newSelectedVerses = Set<String>.from(currentState.selectedVerses);

      if (newSelectedVerses.contains(key)) {
        newSelectedVerses.remove(key);
      } else {
        newSelectedVerses.add(key);
      }

      state = AsyncValue.data(currentState.copyWith(
        selectedVerses: newSelectedVerses,
      ));
    });
  }

  /// Clear verse selection
  void clearSelection() {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(
        selectedVerses: {},
      ));
    });
  }

  /// Toggle persistent verse marking
  Future<void> toggleMarkedVerse(String verseKey) async {
    final currentState = await future;
    final newMarkedVerses = Set<String>.from(currentState.markedVerses);

    if (newMarkedVerses.contains(verseKey)) {
      newMarkedVerses.remove(verseKey);
    } else {
      newMarkedVerses.add(verseKey);
    }

    state = AsyncValue.data(currentState.copyWith(
      markedVerses: newMarkedVerses,
    ));

    // Persist to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bible_marked_verses', newMarkedVerses.toList());
  }

  /// Save selected verses as marked
  Future<void> saveSelectedVersesAsMarked() async {
    final currentState = await future;
    final newMarkedVerses = Set<String>.from(currentState.markedVerses);
    newMarkedVerses.addAll(currentState.selectedVerses);

    state = AsyncValue.data(currentState.copyWith(
      markedVerses: newMarkedVerses,
      selectedVerses: {},
    ));

    // Persist to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bible_marked_verses', newMarkedVerses.toList());
  }

  /// Increase font size
  Future<void> increaseFontSize() async {
    final currentState = await future;
    if (currentState.fontSize >= 30) return;

    final newFontSize = currentState.fontSize + 2;
    state = AsyncValue.data(currentState.copyWith(fontSize: newFontSize));

    // Persist to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bible_font_size', newFontSize);
  }

  /// Decrease font size
  Future<void> decreaseFontSize() async {
    final currentState = await future;
    if (currentState.fontSize <= 12) return;

    final newFontSize = currentState.fontSize - 2;
    state = AsyncValue.data(currentState.copyWith(fontSize: newFontSize));

    // Persist to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bible_font_size', newFontSize);
  }

  /// Toggle font controls visibility
  void toggleFontControls() {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(
        showFontControls: !currentState.showFontControls,
      ));
    });
  }

  /// Switch to a different Bible version
  Future<void> switchVersion(BibleVersion newVersion) async {
    // Initialize service if needed
    if (newVersion.service == null) {
      newVersion.service = BibleDbService();
    }

    await newVersion.service!.initDb(
      newVersion.assetPath,
      newVersion.dbFileName,
    );

    // Load books
    final books = await newVersion.service!.getAllBooks();

    // Load first book, chapter 1
    final firstBook = books.first;
    final bookName = firstBook['short_name'] as String;
    final bookNumber = firstBook['book_number'] as int;
    final maxChapter = await newVersion.service!.getMaxChapter(bookNumber);
    final verses = await newVersion.service!.getChapterVerses(bookNumber, 1);
    final maxVerse =
        verses.isNotEmpty ? (verses.last['verse'] as int? ?? 1) : 1;

    _initVerseKeys(verses);

    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(
      selectedVersion: newVersion,
      books: books,
      selectedBookName: bookName,
      selectedBookNumber: bookNumber,
      selectedChapter: 1,
      selectedVerse: 1,
      maxChapter: maxChapter,
      maxVerse: maxVerse,
      verses: verses,
      selectedVerses: {},
    ));

    // Save position
    await _positionService.savePosition(
      bookName: bookName,
      bookNumber: bookNumber,
      chapter: 1,
      version: newVersion.name,
      languageCode: newVersion.languageCode,
    );
  }

  /// Perform search (Bible reference or text search)
  Future<void> performSearch(String query) async {
    final currentState = await future;
    final service = currentState.selectedVersion.service!;

    // First, try to parse as Bible reference
    final reference = BibleReferenceParser.parse(query);

    if (reference != null) {
      final bookName = reference['bookName'] as String;
      final chapter = reference['chapter'] as int;
      final verse = reference['verse'] as int?;

      // Find book by name (supports partial matches)
      final book = await service.findBookByName(bookName);

      if (book != null) {
        // Validate chapter
        final maxChapter = await service.getMaxChapter(book['book_number']);
        if (chapter > 0 && chapter <= maxChapter) {
          // Navigate to book/chapter
          await selectBook(book: book, chapter: chapter);

          // If verse specified, scroll to it
          if (verse != null) {
            scrollToVerse(verse);
          }

          // Clear search state
          state = AsyncValue.data((await future).copyWith(
            isSearching: false,
            searchResults: [],
          ));

          return;
        }
      }
    }

    // Fallback to text search
    final results = await service.searchVerses(query);

    state = AsyncValue.data(currentState.copyWith(
      isSearching: true,
      searchResults: results,
    ));
  }

  /// Jump to a search result
  Future<void> jumpToSearchResult(Map<String, dynamic> result) async {
    final bookNumber = result['book_number'] as int;
    final chapter = result['chapter'] as int;
    final verse = result['verse'] as int;

    final currentState = await future;

    // Find the book
    final book = currentState.books.firstWhere(
      (b) => b['book_number'] == bookNumber,
      orElse: () => currentState.books[0],
    );

    await selectBook(book: book, chapter: chapter);

    // Clear search
    state = AsyncValue.data((await future).copyWith(
      isSearching: false,
      searchResults: [],
    ));

    // Scroll to verse
    scrollToVerse(verse);
  }

  /// Clear search
  void clearSearch() {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(
        isSearching: false,
        searchResults: [],
      ));
    });
  }
}
