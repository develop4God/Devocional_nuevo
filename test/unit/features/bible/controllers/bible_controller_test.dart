import 'package:devocional_nuevo/features/bible/controllers/bible_controller.dart';
import 'package:devocional_nuevo/features/bible/models/bible_reader_state.dart';
import 'package:devocional_nuevo/services/bible_db_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock Bible DB Service for testing
class MockBibleDbService extends BibleDbService {
  final List<Map<String, dynamic>> _mockBooks = [
    {'book_number': 1, 'short_name': 'Gn', 'long_name': 'Génesis'},
    {'book_number': 2, 'short_name': 'Éx', 'long_name': 'Éxodo'},
    {'book_number': 3, 'short_name': 'Lv', 'long_name': 'Levítico'},
    {'book_number': 40, 'short_name': 'Mt', 'long_name': 'Mateo'},
    {'book_number': 43, 'short_name': 'Jn', 'long_name': 'Juan'},
  ];

  final Map<int, int> _mockMaxChapters = {
    1: 50, // Genesis
    2: 40, // Exodus
    3: 27, // Leviticus
    40: 28, // Matthew
    43: 21, // John
  };

  final Map<String, List<Map<String, dynamic>>> _mockVerses = {};

  MockBibleDbService() {
    // Create mock verses for Genesis 1
    _mockVerses['1-1'] = List.generate(
      31,
      (i) => {
        'book_number': 1,
        'chapter': 1,
        'verse': i + 1,
        'text': 'Verse text ${i + 1}',
      },
    );

    // Create mock verses for Genesis 2
    _mockVerses['1-2'] = List.generate(
      25,
      (i) => {
        'book_number': 1,
        'chapter': 2,
        'verse': i + 1,
        'text': 'Verse text ${i + 1}',
      },
    );

    // Create mock verses for John 3
    _mockVerses['43-3'] = List.generate(
      36,
      (i) => {
        'book_number': 43,
        'chapter': 3,
        'verse': i + 1,
        'text': 'Verse text ${i + 1}',
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getAllBooks() async {
    return _mockBooks;
  }

  @override
  Future<int> getMaxChapter(int bookNumber) async {
    return _mockMaxChapters[bookNumber] ?? 1;
  }

  @override
  Future<List<Map<String, dynamic>>> getChapterVerses(
      int bookNumber, int chapter) async {
    final key = '$bookNumber-$chapter';
    return _mockVerses[key] ?? [];
  }

  @override
  Future<Map<String, dynamic>?> findBookByName(String bookName) async {
    final lowerName = bookName.toLowerCase();
    return _mockBooks.firstWhere(
      (b) =>
          b['short_name'].toString().toLowerCase() == lowerName ||
          b['long_name'].toString().toLowerCase() == lowerName ||
          b['short_name'].toString().toLowerCase().contains(lowerName) ||
          b['long_name'].toString().toLowerCase().contains(lowerName),
      orElse: () => {},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> searchVerses(String searchQuery) async {
    return [
      {
        'book_number': 43,
        'chapter': 3,
        'verse': 16,
        'text': 'For God so loved the world',
        'short_name': 'Jn',
      }
    ];
  }
}

void main() {
  group('BibleController Tests', () {
    late BibleController controller;
    late MockBibleDbService mockService;

    setUp(() {
      mockService = MockBibleDbService();
      controller = BibleController(mockService);
    });

    test('should initialize with default state', () {
      expect(controller.state.isLoading, true);
      expect(controller.state.verses, isEmpty);
      expect(controller.state.books, isEmpty);
      expect(controller.state.fontSize, 18.0);
    });

    test('should load books successfully', () async {
      await controller.loadBooks();

      expect(controller.state.books.length, 5);
      expect(controller.state.selectedBookName, 'Gn');
      expect(controller.state.selectedBookNumber, 1);
      expect(controller.state.selectedChapter, 1);
      expect(controller.state.verses.length, 31); // Genesis 1 has 31 verses
    });

    test('should navigate to next chapter within same book', () async {
      await controller.loadBooks();

      await controller.goToNextChapter();

      expect(controller.state.selectedChapter, 2);
      expect(controller.state.selectedBookNumber, 1); // Still Genesis
      expect(controller.state.verses.length, 25); // Genesis 2 has 25 verses
    });

    test('should navigate to previous chapter within same book', () async {
      await controller.loadBooks();
      await controller.loadChapter(2); // Go to Genesis 2

      await controller.goToPreviousChapter();

      expect(controller.state.selectedChapter, 1);
      expect(controller.state.selectedBookNumber, 1); // Still Genesis
    });

    test('should navigate to next book when at last chapter', () async {
      await controller.loadBooks();
      await controller.loadChapter(50); // Last chapter of Genesis

      await controller.goToNextChapter();

      expect(controller.state.selectedBookNumber, 2); // Exodus
      expect(controller.state.selectedChapter, 1);
      expect(controller.state.selectedBookName, 'Éx');
    });

    test('should navigate to previous book when at first chapter', () async {
      await controller.loadBooks();
      // Select Exodus
      await controller.selectBook(mockService._mockBooks[1]);

      await controller.goToPreviousChapter();

      expect(controller.state.selectedBookNumber, 1); // Genesis
      expect(controller.state.selectedChapter, 50); // Last chapter
      expect(controller.state.selectedBookName, 'Gn');
    });

    test('should toggle verse selection', () {
      final verseKey = 'Gn|1|1';

      controller.toggleVerseSelection(verseKey);
      expect(controller.state.selectedVerses.contains(verseKey), true);

      controller.toggleVerseSelection(verseKey);
      expect(controller.state.selectedVerses.contains(verseKey), false);
    });

    test('should clear verse selection', () {
      controller.toggleVerseSelection('Gn|1|1');
      controller.toggleVerseSelection('Gn|1|2');

      expect(controller.state.selectedVerses.length, 2);

      controller.clearVerseSelection();
      expect(controller.state.selectedVerses.isEmpty, true);
    });

    test('should toggle bookmarks', () {
      final verseKey = 'Gn|1|1';

      controller.toggleBookmark(verseKey);
      expect(controller.state.bookmarkedVerses.contains(verseKey), true);

      controller.toggleBookmark(verseKey);
      expect(controller.state.bookmarkedVerses.contains(verseKey), false);
    });

    test('should save selected verses to bookmarks', () {
      controller.toggleVerseSelection('Gn|1|1');
      controller.toggleVerseSelection('Gn|1|2');

      controller.saveSelectedVersesToBookmarks();

      expect(controller.state.bookmarkedVerses.length, 2);
      expect(controller.state.selectedVerses.isEmpty, true);
    });

    test('should increase font size', () {
      final initialSize = controller.state.fontSize;

      controller.increaseFontSize();

      expect(controller.state.fontSize, initialSize + 2);
    });

    test('should not increase font size above 30', () {
      controller.setFontSize(30);

      controller.increaseFontSize();

      expect(controller.state.fontSize, 30);
    });

    test('should decrease font size', () {
      final initialSize = controller.state.fontSize;

      controller.decreaseFontSize();

      expect(controller.state.fontSize, initialSize - 2);
    });

    test('should not decrease font size below 12', () {
      controller.setFontSize(12);

      controller.decreaseFontSize();

      expect(controller.state.fontSize, 12);
    });

    test('should search and navigate to Bible reference', () async {
      await controller.loadBooks();

      await controller.search('Juan 3:16');

      expect(controller.state.selectedBookNumber, 43); // John
      expect(controller.state.selectedChapter, 3);
      expect(controller.state.selectedVerse, 16);
      expect(controller.state.isSearching, false);
    });

    test('should perform text search when not a Bible reference', () async {
      await controller.loadBooks();

      await controller.search('love');

      expect(controller.state.isSearching, true);
      expect(controller.state.searchResults.isNotEmpty, true);
    });

    test('should jump to search result', () async {
      await controller.loadBooks();

      final result = {
        'book_number': 43,
        'chapter': 3,
        'verse': 16,
        'text': 'For God so loved',
      };

      await controller.jumpToSearchResult(result);

      expect(controller.state.selectedBookNumber, 43);
      expect(controller.state.selectedChapter, 3);
      expect(controller.state.selectedVerse, 16);
      expect(controller.state.isSearching, false);
    });

    test('should restore position', () async {
      await controller.loadBooks();

      await controller.restorePosition(
        bookName: 'Éx',
        bookNumber: 2,
        chapter: 5,
      );

      expect(controller.state.selectedBookNumber, 2);
      expect(controller.state.selectedChapter, 5);
      expect(controller.state.selectedBookName, 'Éx');
    });

    test('should create verse key correctly', () {
      final key = controller.state.makeVerseKey('Gn', 1, 1);
      expect(key, 'Gn|1|1');
    });
  });
}
