import 'dart:ui' as ui;

import 'package:devocional_nuevo/features/bible/controllers/bible_controller.dart';
import 'package:devocional_nuevo/features/bible/widgets/book_selector_dialog.dart';
import 'package:devocional_nuevo/features/bible/widgets/chapter_navigation_bar.dart';
import 'package:devocional_nuevo/features/bible/widgets/verse_action_sheet.dart';
import 'package:devocional_nuevo/features/bible/widgets/verse_list_widget.dart';
import 'package:devocional_nuevo/features/bible/utils/verse_text_formatter.dart';
import 'package:devocional_nuevo/models/bible_version.dart';
import 'package:devocional_nuevo/services/bible_db_service.dart';
import 'package:devocional_nuevo/services/bible_reading_position_service.dart';
import 'package:devocional_nuevo/utils/copyright_utils.dart';
import 'package:devocional_nuevo/widgets/app_bar_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus;
import 'package:shared_preferences/shared_preferences.dart';

/// Bible Reader Page using new architecture
/// Migrated from 1583 lines to ~300 lines using BibleController and reusable widgets
class BibleReaderPage extends StatefulWidget {
  final List<BibleVersion> versions;

  const BibleReaderPage({super.key, required this.versions});

  @override
  State<BibleReaderPage> createState() => _BibleReaderPageState();
}

class _BibleReaderPageState extends State<BibleReaderPage> {
  late BibleVersion _selectedVersion;
  List<BibleVersion> _availableVersions = [];
  String _deviceLanguage = '';
  BibleController? _controller;
  BibleDbService? _service;
  final BibleReadingPositionService _positionService =
      BibleReadingPositionService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};
  bool _showFontControls = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _detectLanguageAndInitialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _detectLanguageAndInitialize() async {
    setState(() {
      _isInitializing = true;
    });

    // Detect device language
    _deviceLanguage = ui.PlatformDispatcher.instance.locale.languageCode;

    // Filter versions by device language
    _availableVersions = widget.versions
        .where((v) => v.languageCode == _deviceLanguage)
        .toList();

    // If no versions for device language, fall back to Spanish or all
    if (_availableVersions.isEmpty) {
      _availableVersions =
          widget.versions.where((v) => v.languageCode == 'es').toList();
      if (_availableVersions.isEmpty) {
        _availableVersions = widget.versions;
      }
    }

    // Try to restore last reading position
    final lastPosition = await _positionService.getLastPosition();

    if (lastPosition != null &&
        _availableVersions.any((v) =>
            v.name == lastPosition['version'] &&
            v.languageCode == lastPosition['languageCode'])) {
      // Restore last version and position
      _selectedVersion = _availableVersions.firstWhere(
        (v) =>
            v.name == lastPosition['version'] &&
            v.languageCode == lastPosition['languageCode'],
      );
      await _initVersion();
      await _restorePosition(lastPosition);
    } else {
      // Start with first available version
      _selectedVersion = _availableVersions.isNotEmpty
          ? _availableVersions.first
          : widget.versions.first;
      await _initVersion();
    }

    setState(() {
      _isInitializing = false;
    });
  }

  Future<void> _initVersion() async {
    _service = BibleDbService();
    await _service!
        .initDb(_selectedVersion.assetPath, _selectedVersion.dbFileName);

    _controller = BibleController(_service!);

    // Load saved preferences
    final prefs = await SharedPreferences.getInstance();
    final fontSize = prefs.getDouble('bible_font_size') ?? 18.0;
    _controller!.setFontSize(fontSize);

    final bookmarks = prefs.getStringList('bible_marked_verses') ?? [];
    _controller!.initializeBookmarks(Set.from(bookmarks));

    // Load books
    await _controller!.loadBooks();
  }

  Future<void> _restorePosition(Map<String, dynamic> position) async {
    if (_controller == null) return;

    await _controller!.restorePosition(
      bookName: position['bookName'] ?? '',
      bookNumber: position['bookNumber'] ?? 1,
      chapter: position['chapter'] ?? 1,
    );
  }

  Future<void> _switchVersion(BibleVersion version) async {
    if (version.name == _selectedVersion.name) return;

    setState(() {
      _isInitializing = true;
      _selectedVersion = version;
    });

    // Dispose old controller
    _controller?.dispose();

    // Initialize new version
    await _initVersion();

    setState(() {
      _isInitializing = false;
    });
  }

  Future<void> _saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bible_font_size', _controller!.state.fontSize);
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'bible_marked_verses',
      _controller!.state.bookmarkedVerses.toList(),
    );
  }

  Future<void> _saveReadingPosition() async {
    if (_controller == null) return;

    final state = _controller!.state;
    if (state.selectedBookName != null) {
      await _positionService.savePosition(
        bookName: state.selectedBookName!,
        bookNumber: state.selectedBookNumber!,
        chapter: state.selectedChapter ?? 1,
        version: _selectedVersion.name,
        languageCode: _selectedVersion.languageCode,
      );
    }
  }

  void _onVerseTap(int verseNumber) {
    if (_controller == null) return;

    final state = _controller!.state;
    final key = state.makeVerseKey(
      state.selectedBookName!,
      state.selectedChapter!,
      verseNumber,
    );
    _controller!.toggleVerseSelection(key);

    if (state.selectedVerses.isNotEmpty) {
      _showActionSheet();
    }
  }

  void _onVerseLongPress(String verseKey) {
    if (_controller == null) return;
    _controller!.toggleBookmark(verseKey);
    _saveBookmarks();
  }

  void _showActionSheet() {
    if (_controller == null) return;

    VerseActionSheet.show(
      context,
      selectedVerses: _controller!.state.selectedVerses,
      verseReference: VerseTextFormatter.formatReference(
        _controller!.state.selectedVerses,
      ),
      onCopy: () {
        final text = VerseTextFormatter.formatSelection(
          _controller!.state.verses,
          _controller!.state.selectedVerses,
        );
        Clipboard.setData(ClipboardData(text: text));
        Navigator.pop(context);
        _controller!.clearVerseSelection();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('bible.copied'.tr())),
        );
      },
      onShare: () {
        final text = VerseTextFormatter.formatSelection(
          _controller!.state.verses,
          _controller!.state.selectedVerses,
        );
        final copyrightNotice = CopyrightUtils.getCopyrightText(
          _selectedVersion.languageCode,
          _selectedVersion.name,
        );
        SharePlus.instance
            .share(ShareParams(text: '$text\n\n$copyrightNotice'));
        Navigator.pop(context);
        _controller!.clearVerseSelection();
      },
      onSave: () {
        _controller!.saveSelectedVersesToBookmarks();
        _saveBookmarks();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('bible.saved'.tr())),
        );
      },
    );
  }

  Future<void> _showBookSelector() async {
    if (_controller == null) return;

    final book = await BookSelectorDialog.show(
      context,
      books: _controller!.books,
      currentSelection: _controller!.state.selectedBookName,
    );

    if (book != null) {
      await _controller!.selectBook(book);
      _saveReadingPosition();
    }
  }

  void _onSearch(String query) {
    if (_controller == null) return;
    _controller!.search(query);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isInitializing || _controller == null) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: CustomAppBar(
            titleWidget: Text(
              'bible.title'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 16),
              Text('bible.loading'.tr()),
            ],
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _controller!,
      builder: (context, _) {
        final state = _controller!.state;

        // Update verse keys when verses change
        if (_verseKeys.length != state.verses.length) {
          _verseKeys.clear();
          for (final verse in state.verses) {
            final verseNum = verse['verse'] as int;
            _verseKeys[verseNum] = GlobalKey();
          }
        }

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Stack(
              children: [
                CustomAppBar(
                  titleWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'bible.title'.tr(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                      Text(
                        '${_selectedVersion.name} (${_selectedVersion.language})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withValues(alpha: 0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ],
                  ),
                ),
                // Font size toggle
                Positioned(
                  right: _availableVersions.length > 1 ? 48 : 0,
                  top: 0,
                  bottom: 0,
                  child: SafeArea(
                    child: IconButton(
                      icon: Icon(
                        Icons.format_size,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      tooltip: 'bible.adjust_font_size'.tr(),
                      onPressed: () {
                        setState(() {
                          _showFontControls = !_showFontControls;
                        });
                      },
                    ),
                  ),
                ),
                // Version selector
                if (_availableVersions.length > 1)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: SafeArea(
                      child: PopupMenuButton<BibleVersion>(
                        icon: Icon(
                          Icons.menu,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        tooltip: 'bible.select_version'.tr(),
                        onSelected: _switchVersion,
                        itemBuilder: (context) =>
                            _availableVersions.map((version) {
                          return PopupMenuItem<BibleVersion>(
                            value: version,
                            child: Row(
                              children: [
                                if (version.name == _selectedVersion.name)
                                  Icon(Icons.check,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 20)
                                else
                                  const SizedBox(width: 20),
                                const SizedBox(width: 8),
                                Text(version.name),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Search bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'bible.search_placeholder'.tr(),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _controller!.search('');
                                setState(() {});
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _onSearch,
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                // Search results or main content
                if (state.isSearching)
                  Expanded(
                    child: state.searchResults.isEmpty
                        ? Center(child: Text('bible.no_results'.tr()))
                        : ListView.builder(
                            itemCount: state.searchResults.length,
                            itemBuilder: (context, index) {
                              final result = state.searchResults[index];
                              return ListTile(
                                title: Text(
                                  '${result['book_name']} ${result['chapter']}:${result['verse']}',
                                ),
                                subtitle: Text(result['text'] ?? ''),
                                onTap: () {
                                  _controller!.jumpToSearchResult(result);
                                  _saveReadingPosition();
                                },
                              );
                            },
                          ),
                  )
                else ...[
                  // Book and chapter selector
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _showBookSelector,
                            child: Text(
                              state.selectedBookName ??
                                  'bible.select_book'.tr(),
                              style: TextStyle(color: colorScheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<int>(
                          value: state.selectedChapter,
                          items: List.generate(
                            state.maxChapter,
                            (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text('${'bible.chapter'.tr()} ${i + 1}'),
                            ),
                          ),
                          onChanged: (chapter) async {
                            if (chapter != null) {
                              await _controller!.loadChapter(chapter);
                              _saveReadingPosition();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  // Font controls
                  if (_showFontControls)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: colorScheme.surfaceContainerHighest,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.text_decrease),
                            onPressed: () {
                              _controller!.decreaseFontSize();
                              _saveFontSize();
                            },
                          ),
                          Text(
                              '${'bible.font_size'.tr()}: ${state.fontSize.toInt()}'),
                          IconButton(
                            icon: const Icon(Icons.text_increase),
                            onPressed: () {
                              _controller!.increaseFontSize();
                              _saveFontSize();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _showFontControls = false;
                              });
                            },
                            tooltip: 'Cerrar',
                          ),
                        ],
                      ),
                    ),
                  // Verse list
                  Expanded(
                    child: state.verses.isEmpty
                        ? Center(child: Text('bible.no_verses'.tr()))
                        : VerseListWidget(
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
              ],
            ),
          ),
          bottomNavigationBar:
              state.isSearching || state.selectedBookName == null
                  ? null
                  : ChapterNavigationBar(
                      bookName: state.selectedBookName!,
                      chapter: state.selectedChapter ?? 1,
                      onPrevious: () async {
                        await _controller!.goToPreviousChapter();
                        _saveReadingPosition();
                      },
                      onNext: () async {
                        await _controller!.goToNextChapter();
                        _saveReadingPosition();
                      },
                    ),
        );
      },
    );
  }
}
