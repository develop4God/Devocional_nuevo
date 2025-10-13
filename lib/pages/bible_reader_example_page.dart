import 'package:devocional_nuevo/features/bible/controllers/bible_controller.dart';
import 'package:devocional_nuevo/features/bible/widgets/chapter_navigation_bar.dart';
import 'package:devocional_nuevo/features/bible/widgets/verse_list_widget.dart';
import 'package:devocional_nuevo/features/bible/widgets/book_selector_dialog.dart';
import 'package:devocional_nuevo/features/bible/widgets/verse_action_sheet.dart';
import 'package:devocional_nuevo/features/bible/utils/verse_text_formatter.dart';
import 'package:devocional_nuevo/models/bible_version.dart';
import 'package:devocional_nuevo/services/bible_db_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Example of Bible Reader using the new architecture with ListenableBuilder
/// This demonstrates how the page can be reduced to ~250 lines
/// while using reusable widgets and the controller
class BibleReaderExamplePage extends StatefulWidget {
  final BibleVersion version;

  const BibleReaderExamplePage({super.key, required this.version});

  @override
  State<BibleReaderExamplePage> createState() => _BibleReaderExamplePageState();
}

class _BibleReaderExamplePageState extends State<BibleReaderExamplePage> {
  late BibleController _controller;
  late BibleDbService _service;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};
  bool _showFontControls = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _service = BibleDbService();
    await _service.initDb(widget.version.assetPath, widget.version.dbFileName);

    _controller = BibleController(_service);

    // Load saved font size
    final prefs = await SharedPreferences.getInstance();
    final fontSize = prefs.getDouble('bible_font_size') ?? 18.0;
    _controller.setFontSize(fontSize);

    // Load saved bookmarks
    final bookmarks = prefs.getStringList('bible_marked_verses') ?? [];
    _controller.initializeBookmarks(Set.from(bookmarks));

    // Load books
    await _controller.loadBooks();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bible_font_size', _controller.state.fontSize);
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'bible_marked_verses',
      _controller.state.bookmarkedVerses.toList(),
    );
  }

  void _onVerseTap(int verseNumber) {
    final key = _controller.state.makeVerseKey(
      _controller.state.selectedBookName!,
      _controller.state.selectedChapter!,
      verseNumber,
    );
    _controller.toggleVerseSelection(key);

    if (_controller.state.selectedVerses.isNotEmpty) {
      _showActionSheet();
    }
  }

  void _onVerseLongPress(String verseKey) {
    _controller.toggleBookmark(verseKey);
    _saveBookmarks();
  }

  void _showActionSheet() {
    VerseActionSheet.show(
      context,
      selectedVerses: _controller.state.selectedVerses,
      verseReference: VerseTextFormatter.formatReference(
        _controller.state.selectedVerses,
      ),
      onCopy: () {
        final text = VerseTextFormatter.formatSelection(
          _controller.state.verses,
          _controller.state.selectedVerses,
        );
        Clipboard.setData(ClipboardData(text: text));
        Navigator.pop(context);
        _controller.clearVerseSelection();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verses copied')),
        );
      },
      onShare: () {
        final text = VerseTextFormatter.formatSelection(
          _controller.state.verses,
          _controller.state.selectedVerses,
        );
        SharePlus.instance.share(ShareParams(text: text));
        Navigator.pop(context);
        _controller.clearVerseSelection();
      },
      onSave: () {
        _controller.saveSelectedVersesToBookmarks();
        _saveBookmarks();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verses saved')),
        );
      },
    );
  }

  Future<void> _showBookSelector() async {
    final book = await BookSelectorDialog.show(
      context,
      books: _controller.books,
      currentSelection: _controller.state.selectedBookName,
    );

    if (book != null) {
      await _controller.selectBook(book);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Reader Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_size),
            onPressed: () {
              setState(() {
                _showFontControls = !_showFontControls;
              });
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final state = _controller.state;

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Book selector
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _showBookSelector,
                  child: Text(
                    state.selectedBookName ?? 'Select Book',
                  ),
                ),
              ),

              // Font controls
              if (_showFontControls)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.text_decrease),
                        onPressed: () {
                          _controller.decreaseFontSize();
                          _saveFontSize();
                        },
                      ),
                      Text('Font Size: ${state.fontSize.toInt()}'),
                      IconButton(
                        icon: const Icon(Icons.text_increase),
                        onPressed: () {
                          _controller.increaseFontSize();
                          _saveFontSize();
                        },
                      ),
                    ],
                  ),
                ),

              // Verse list
              Expanded(
                child: VerseListWidget(
                  verses: state.verses,
                  fontSize: state.fontSize,
                  selectedVerses: state.selectedVerses,
                  bookmarkedVerses: state.bookmarkedVerses,
                  bookName: state.selectedBookName ?? '',
                  chapter: state.selectedChapter ?? 1,
                  onVerseTap: _onVerseTap,
                  onVerseLongPress: _onVerseLongPress,
                  scrollController: _scrollController,
                  verseKeys: _verseKeys,
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final state = _controller.state;

          if (state.isLoading || state.selectedBookName == null) {
            return const SizedBox.shrink();
          }

          return ChapterNavigationBar(
            bookName: state.selectedBookName!,
            chapter: state.selectedChapter ?? 1,
            onPrevious: () => _controller.goToPreviousChapter(),
            onNext: () => _controller.goToNextChapter(),
          );
        },
      ),
    );
  }
}
