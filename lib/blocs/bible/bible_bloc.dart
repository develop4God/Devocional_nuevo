// lib/blocs/bible/bible_bloc.dart

import 'package:devocional_nuevo/models/bible_version.dart';
import 'package:devocional_nuevo/services/bible_reading_position_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bible_event.dart';
import 'bible_state.dart';

class BibleBloc extends Bloc<BibleEvent, BibleState> {
  final BibleReadingPositionService _positionService;

  BibleBloc({BibleReadingPositionService? positionService})
      : _positionService = positionService ?? BibleReadingPositionService(),
        super(BibleInitial()) {
    on<InitializeBible>(_onInitializeBible);
    on<SelectVersion>(_onSelectVersion);
    on<SelectBook>(_onSelectBook);
    on<SelectChapter>(_onSelectChapter);
    on<SelectVerse>(_onSelectVerse);
    on<GoToPreviousChapter>(_onGoToPreviousChapter);
    on<GoToNextChapter>(_onGoToNextChapter);
    on<ToggleVerseSelection>(_onToggleVerseSelection);
    on<TogglePersistentMark>(_onTogglePersistentMark);
    on<ClearVerseSelections>(_onClearVerseSelections);
    on<SearchBible>(_onSearchBible);
    on<JumpToSearchResult>(_onJumpToSearchResult);
    on<UpdateFontSize>(_onUpdateFontSize);
    on<LoadReadingPosition>(_onLoadReadingPosition);
    on<SaveReadingPosition>(_onSaveReadingPosition);
    on<RestorePosition>(_onRestorePosition);
  }

  /// Initialize Bible with language detection and version selection
  Future<void> _onInitializeBible(
    InitializeBible event,
    Emitter<BibleState> emit,
  ) async {
    emit(BibleLoading());

    try {
      // Filter versions by device language
      var availableVersions = event.availableVersions
          .where((v) => v.languageCode == event.deviceLanguage)
          .toList();

      // If no versions for device language, fall back to Spanish or all
      if (availableVersions.isEmpty) {
        availableVersions = event.availableVersions
            .where((v) => v.languageCode == 'es')
            .toList();
        if (availableVersions.isEmpty) {
          availableVersions = event.availableVersions;
        }
      }

      if (availableVersions.isEmpty) {
        emit(BibleError('No Bible versions available'));
        return;
      }

      // Try to restore last reading position
      final lastPosition = await _positionService.getLastPosition();
      BibleVersion selectedVersion;

      if (lastPosition != null &&
          availableVersions.any((v) =>
              v.name == lastPosition['version'] &&
              v.languageCode == lastPosition['languageCode'])) {
        // Restore last version
        selectedVersion = availableVersions.firstWhere(
          (v) =>
              v.name == lastPosition['version'] &&
              v.languageCode == lastPosition['languageCode'],
        );
      } else {
        // Use first available version
        selectedVersion = availableVersions.first;
      }

      // Load books for selected version
      final books = await selectedVersion.service!.getAllBooks();

      // Load font size
      final fontSize = await _loadFontSize();

      // Load marked verses
      final markedVerses = await _loadMarkedVerses();

      emit(BibleLoaded(
        selectedVersion: selectedVersion,
        availableVersions: availableVersions,
        books: books,
        fontSize: fontSize,
        persistentlyMarkedVerses: markedVerses,
      ));

      // If we have a last position, restore it
      if (lastPosition != null) {
        add(RestorePosition(lastPosition));
      }
    } catch (e) {
      debugPrint('Error initializing Bible: $e');
      emit(BibleError('Failed to initialize Bible: ${e.toString()}'));
    }
  }

  /// Select a different Bible version
  Future<void> _onSelectVersion(
    SelectVersion event,
    Emitter<BibleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BibleLoaded) return;

    emit(BibleLoading());

    try {
      final books = await event.version.service!.getAllBooks();

      emit(currentState.copyWith(
        selectedVersion: event.version,
        books: books,
        verses: [],
        clearBookSelection: true,
        clearChapterSelection: true,
        clearVerseSelection: true,
      ));
    } catch (e) {
      debugPrint('Error selecting version: $e');
      emit(BibleError('Failed to load version: ${e.toString()}'));
    }
  }

  /// Select a book
  Future<void> _onSelectBook(
    SelectBook event,
    Emitter<BibleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BibleLoaded) return;

    try {
      // Load max chapters for the book
      final maxChapter = await currentState.selectedVersion.service!
          .getMaxChapter(event.bookNumber);

      emit(currentState.copyWith(
        selectedBookName: event.bookName,
        selectedBookNumber: event.bookNumber,
        selectedChapter: 1,
        maxChapter: maxChapter,
        selectedVerse: 1,
        verses: [],
      ));

      // Load verses for chapter 1
      add(SelectChapter(1));
    } catch (e) {
      debugPrint('Error selecting book: $e');
      emit(BibleError('Failed to select book: ${e.toString()}'));
    }
  }

  /// Select a chapter
  Future<void> _onSelectChapter(
    SelectChapter event,
    Emitter<BibleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BibleLoaded) return;

    if (currentState.selectedBookNumber == null) return;

    try {
      final verses =
          await currentState.selectedVersion.service!.getChapterVerses(
        currentState.selectedBookNumber!,
        event.chapter,
      );

      final maxVerse =
          verses.isNotEmpty ? (verses.last['verse'] as int? ?? 1) : 1;

      emit(currentState.copyWith(
        selectedChapter: event.chapter,
        verses: verses,
        maxVerse: maxVerse,
        selectedVerse: 1,
      ));

      // Save reading position
      if (currentState.selectedBookName != null) {
        await _positionService.savePosition(
          bookName: currentState.selectedBookName!,
          bookNumber: currentState.selectedBookNumber!,
          chapter: event.chapter,
          version: currentState.selectedVersion.name,
          languageCode: currentState.selectedVersion.languageCode,
        );
      }
    } catch (e) {
      debugPrint('Error selecting chapter: $e');
      emit(BibleError('Failed to load chapter: ${e.toString()}'));
    }
  }

  /// Select a verse
  Future<void> _onSelectVerse(
    SelectVerse event,
    Emitter<BibleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BibleLoaded) return;

    emit(currentState.copyWith(selectedVerse: event.verse));
  }

  /// Navigate to the previous chapter
  Future<void> _onGoToPreviousChapter(
    GoToPreviousChapter event,
    Emitter<BibleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BibleLoaded) return;

    if (currentState.selectedBookNumber == null ||
        currentState.selectedChapter == null) {
      return;
    }

    if (currentState.selectedChapter! > 1) {
      // Go to previous chapter in same book
      add(SelectChapter(currentState.selectedChapter! - 1));
    } else if (currentState.selectedBookNumber! > 1) {
      // Go to last chapter of previous book
      final previousBookNumber = currentState.selectedBookNumber! - 1;
      final previousBook = currentState.books.firstWhere(
        (b) => b['book_number'] == previousBookNumber,
        orElse: () => {},
      );

      if (previousBook.isNotEmpty) {
        final maxChapter = await currentState.selectedVersion.service!
            .getMaxChapter(previousBookNumber);

        add(SelectBook(
          bookName: previousBook['short_name'],
          bookNumber: previousBookNumber,
        ));
        // The chapter will be set to maxChapter after book is selected
        add(SelectChapter(maxChapter));
      }
    }
  }

  /// Navigate to the next chapter
  Future<void> _onGoToNextChapter(
    GoToNextChapter event,
    Emitter<BibleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BibleLoaded) return;

    if (currentState.selectedBookNumber == null ||
        currentState.selectedChapter == null) {
      return;
    }

    if (currentState.selectedChapter! < currentState.maxChapter) {
      // Go to next chapter in same book
      add(SelectChapter(currentState.selectedChapter! + 1));
    } else if (currentState.selectedBookNumber! < currentState.books.length) {
      // Go to first chapter of next book
      final nextBookNumber = currentState.selectedBookNumber! + 1;
      final nextBook = currentState.books.firstWhere(
        (b) => b['book_number'] == nextBookNumber,
        orElse: () => {},
      );

      if (nextBook.isNotEmpty) {
        add(SelectBook(
          bookName: nextBook['short_name'],
          bookNumber: nextBookNumber,
        ));
      }
    }
  }

  /// Toggle verse selection
  Future<void> _onToggleVerseSelection(
    ToggleVerseSelection event,
    Emitter<BibleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BibleLoaded) return;

    final newSelectedVerses = Set<String>.from(currentState.selectedVerses);
    if (newSelectedVerses.contains(event.verseKey)) {
      newSelectedVerses.remove(event.verseKey);
    } else {
      newSelectedVerses.add(event.verseKey);
    }

    emit(currentState.copyWith(selectedVerses: newSelectedVerses));
  }

  /// Toggle persistent verse marking
  Future<void> _onTogglePersistentMark(
    TogglePersistentMark event,
    Emitter<BibleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BibleLoaded) return;

    final newMarkedVerses =
        Set<String>.from(currentState.persistentlyMarkedVerses);
    if (newMarkedVerses.contains(event.verseKey)) {
      newMarkedVerses.remove(event.verseKey);
    } else {
      newMarkedVerses.add(event.verseKey);
    }

    emit(currentState.copyWith(persistentlyMarkedVerses: newMarkedVerses));

    // Save to storage
    await _saveMarkedVerses(newMarkedVerses);
  }

  /// Clear verse selections
  Future<void> _onClearVerseSelections(
    ClearVerseSelections event,
    Emitter<BibleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BibleLoaded) return;

    emit(currentState.copyWith(selectedVerses: <String>{}));
  }

  /// Perform a Bible search
  Future<void> _onSearchBible(
    SearchBible event,
    Emitter<BibleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BibleLoaded) return;

    if (event.query.trim().isEmpty) {
      emit(currentState.copyWith(
        isSearching: false,
        searchResults: [],
      ));
      return;
    }

    try {
      final results =
          await currentState.selectedVersion.service!.searchVerses(event.query);

      emit(currentState.copyWith(
        isSearching: true,
        searchResults: results,
      ));
    } catch (e) {
      debugPrint('Error searching Bible: $e');
      emit(BibleError('Search failed: ${e.toString()}'));
    }
  }

  /// Jump to a search result
  Future<void> _onJumpToSearchResult(
    JumpToSearchResult event,
    Emitter<BibleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BibleLoaded) return;

    final result = event.result;
    final bookNumber = result['book_number'] as int;
    final chapter = result['chapter'] as int;
    final verse = result['verse'] as int;

    // Find the book
    final book = currentState.books.firstWhere(
      (b) => b['book_number'] == bookNumber,
      orElse: () => {},
    );

    if (book.isEmpty) return;

    // Select the book and chapter
    add(SelectBook(
      bookName: book['short_name'],
      bookNumber: bookNumber,
    ));
    add(SelectChapter(chapter));
    add(SelectVerse(verse));

    // Clear search
    emit(currentState.copyWith(
      isSearching: false,
      searchResults: [],
    ));
  }

  /// Update font size
  Future<void> _onUpdateFontSize(
    UpdateFontSize event,
    Emitter<BibleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BibleLoaded) return;

    emit(currentState.copyWith(fontSize: event.fontSize));

    // Save to storage
    await _saveFontSize(event.fontSize);
  }

  /// Load reading position
  Future<void> _onLoadReadingPosition(
    LoadReadingPosition event,
    Emitter<BibleState> emit,
  ) async {
    final position = await _positionService.getLastPosition();
    if (position != null) {
      add(RestorePosition(position));
    }
  }

  /// Save reading position
  Future<void> _onSaveReadingPosition(
    SaveReadingPosition event,
    Emitter<BibleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BibleLoaded) return;

    if (currentState.selectedBookName != null &&
        currentState.selectedBookNumber != null &&
        currentState.selectedChapter != null) {
      await _positionService.savePosition(
        bookName: currentState.selectedBookName!,
        bookNumber: currentState.selectedBookNumber!,
        chapter: currentState.selectedChapter!,
        version: currentState.selectedVersion.name,
        languageCode: currentState.selectedVersion.languageCode,
      );
    }
  }

  /// Restore a specific position
  Future<void> _onRestorePosition(
    RestorePosition event,
    Emitter<BibleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BibleLoaded) return;

    final position = event.position;
    final book = currentState.books.firstWhere(
      (b) =>
          b['short_name'] == position['bookName'] ||
          b['book_number'] == position['bookNumber'],
      orElse: () => currentState.books.isNotEmpty ? currentState.books[0] : {},
    );

    if (book.isNotEmpty) {
      add(SelectBook(
        bookName: book['short_name'],
        bookNumber: book['book_number'],
      ));
      add(SelectChapter(position['chapter']));
    }
  }

  /// Load font size from storage
  Future<double> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('bible_font_size') ?? 18.0;
  }

  /// Save font size to storage
  Future<void> _saveFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bible_font_size', fontSize);
  }

  /// Load marked verses from storage
  Future<Set<String>> _loadMarkedVerses() async {
    final prefs = await SharedPreferences.getInstance();
    final markedList = prefs.getStringList('marked_verses') ?? [];
    return Set<String>.from(markedList);
  }

  /// Save marked verses to storage
  Future<void> _saveMarkedVerses(Set<String> markedVerses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('marked_verses', markedVerses.toList());
  }
}
