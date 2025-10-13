# Bible Reader Architecture - Multi-State-Management Support

## Overview

This architecture enables the Bible Reader feature to work with **both Riverpod and BLoC** state management patterns without code duplication. The core business logic and UI components are state-management agnostic.

## Architecture Layers

### 1. State Model (Pure Dart)
**File:** `lib/features/bible/models/bible_reader_state.dart`

```dart
class BibleReaderState {
  final String? selectedBookName;
  final int? selectedChapter;
  final List<Map<String, dynamic>> verses;
  final Set<String> selectedVerses;
  final double fontSize;
  // ... other immutable fields
  
  BibleReaderState copyWith({...}) => ...;
}
```

- ✅ Immutable data class
- ✅ No Flutter dependencies
- ✅ Works with any state management solution

### 2. Controller (State-Agnostic Business Logic)
**File:** `lib/features/bible/controllers/bible_controller.dart`

```dart
class BibleController extends ChangeNotifier {
  final BibleDbService _service;
  BibleReaderState _state = const BibleReaderState();
  
  BibleReaderState get state => _state;
  
  // Business logic methods
  Future<void> goToNextChapter() async { ... }
  Future<void> search(String query) async { ... }
  void toggleVerseSelection(String key) { ... }
  // ... 20+ other methods
}
```

**Key Principles:**
- ✅ NO imports of `flutter_riverpod` or `flutter_bloc`
- ✅ Only imports: `flutter/foundation.dart`, models, services
- ✅ Uses `ChangeNotifier` (compatible with both frameworks)
- ✅ 100% testable without mocking state management

### 3. Reusable Widgets (Pure Presentation)
**Files:** `lib/features/bible/widgets/`

All widgets receive data via constructor parameters and communicate via callbacks:

```dart
class VerseListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> verses;
  final double fontSize;
  final Set<String> selectedVerses;
  final Function(int verseNumber) onVerseTap;
  
  // NO ref.watch() or BlocBuilder inside
}
```

**Widgets:**
- `verse_list_widget.dart` - Scrollable verse list
- `chapter_navigation_bar.dart` - Previous/Next navigation
- `book_selector_dialog.dart` - Book search & selection
- `verse_action_sheet.dart` - Share/Copy/Save actions

### 4. Utilities (Helpers)
**Files:** `lib/features/bible/utils/`

- `bible_reference_parser.dart` - Parse "Juan 3:16", "Genesis 1", etc.
- `verse_text_formatter.dart` - Clean text, format selections, highlight matches

## Usage Patterns

### Pattern A: Riverpod Implementation

```dart
// 1. Create provider
final bibleControllerProvider = ChangeNotifierProvider<BibleController>((ref) {
  return BibleController(ref.watch(bibleServiceProvider));
});

// 2. Use in widget
class BibleReaderPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(bibleControllerProvider);
    final state = controller.state;
    
    return Scaffold(
      body: VerseListWidget(
        verses: state.verses,
        fontSize: state.fontSize,
        onVerseTap: (v) => controller.toggleVerseSelection(
          state.makeVerseKey(state.selectedBookName!, state.selectedChapter!, v)
        ),
      ),
      bottomNavigationBar: ChapterNavigationBar(
        bookName: state.selectedBookName ?? '',
        chapter: state.selectedChapter ?? 1,
        onPrevious: () => controller.goToPreviousChapter(),
        onNext: () => controller.goToNextChapter(),
      ),
    );
  }
}
```

### Pattern B: BLoC Implementation

```dart
// 1. Create BLoC wrapper
class BibleBloc extends Bloc<BibleEvent, BibleReaderState> {
  final BibleController _controller;
  
  BibleBloc(BibleDbService service) : 
    _controller = BibleController(service),
    super(const BibleReaderState()) {
    
    on<NextChapterPressed>((event, emit) async {
      await _controller.goToNextChapter();
      emit(_controller.state);
    });
    
    on<VerseToggled>((event, emit) {
      _controller.toggleVerseSelection(event.verseKey);
      emit(_controller.state);
    });
  }
}

// 2. Use in widget
class BibleReaderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibleBloc, BibleReaderState>(
      builder: (context, state) {
        return Scaffold(
          body: VerseListWidget(
            verses: state.verses,
            fontSize: state.fontSize,
            onVerseTap: (v) => context.read<BibleBloc>().add(
              VerseToggled(state.makeVerseKey(state.selectedBookName!, state.selectedChapter!, v))
            ),
          ),
          bottomNavigationBar: ChapterNavigationBar(
            bookName: state.selectedBookName ?? '',
            chapter: state.selectedChapter ?? 1,
            onPrevious: () => context.read<BibleBloc>().add(PreviousChapterPressed()),
            onNext: () => context.read<BibleBloc>().add(NextChapterPressed()),
          ),
        );
      },
    );
  }
}
```

### Pattern C: Plain Flutter (ListenableBuilder)

```dart
// See lib/pages/bible_reader_example_page.dart for complete example

class BibleReaderPage extends StatefulWidget {
  @override
  State<BibleReaderPage> createState() => _BibleReaderPageState();
}

class _BibleReaderPageState extends State<BibleReaderPage> {
  late BibleController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = BibleController(BibleDbService());
  }
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;
        
        return Scaffold(
          body: VerseListWidget(
            verses: state.verses,
            fontSize: state.fontSize,
            onVerseTap: (v) => _controller.toggleVerseSelection(
              state.makeVerseKey(state.selectedBookName!, state.selectedChapter!, v)
            ),
          ),
        );
      },
    );
  }
}
```

## Testing

### Controller Tests (19 tests)
**File:** `test/unit/features/bible/controllers/bible_controller_test.dart`

Tests cover:
- Navigation (next/previous chapter, cross-book)
- Search (Bible references, text search)
- Verse selection and bookmarking
- Font size controls
- State transitions

All tests pass without any Flutter or state management mocking.

### Parser Tests (14 tests)
**File:** `test/unit/utils/bible_reference_parser_test.dart`

Tests cover:
- Spanish: "Juan 3:16", "1 Corintios 13:4"
- English: "John 3:16", "Genesis 1:1"
- Abbreviations: "Gn 9:4", "S.Juan 3:16"
- Edge cases: whitespace, case-insensitivity

## File Structure

```
lib/
├── features/bible/
│   ├── models/
│   │   └── bible_reader_state.dart      # Immutable state (72 lines)
│   ├── controllers/
│   │   └── bible_controller.dart        # Business logic (286 lines)
│   ├── widgets/
│   │   ├── verse_list_widget.dart       # Verse display (~115 lines)
│   │   ├── chapter_navigation_bar.dart  # Navigation (~70 lines)
│   │   ├── book_selector_dialog.dart    # Book selection (~140 lines)
│   │   └── verse_action_sheet.dart      # Actions (~160 lines)
│   └── utils/
│       ├── bible_reference_parser.dart  # Parse refs (~65 lines)
│       └── verse_text_formatter.dart    # Format text (~110 lines)
└── pages/
    ├── bible_reader_page.dart           # Original (1594 lines) - unchanged
    └── bible_reader_example_page.dart   # Example with new arch (268 lines)

test/
└── unit/features/bible/
    └── controllers/
        └── bible_controller_test.dart   # 19 tests
```

## Benefits

✅ **Code Reusability:** Same components work in both apps (habitus_faith & Devocional_nuevo)  
✅ **Testability:** 100% business logic coverage without mocking frameworks  
✅ **Maintainability:** Single source of truth for Bible reader logic  
✅ **Flexibility:** Easy to switch state management solutions  
✅ **Type Safety:** Immutable state with compile-time guarantees  

## Migration Path

The original `bible_reader_page.dart` remains untouched to avoid breaking changes. Migration can be done gradually:

1. **Phase 1:** Use `BibleController` for new features
2. **Phase 2:** Replace custom methods with controller calls
3. **Phase 3:** Replace ListView.builder with `VerseListWidget`
4. **Phase 4:** Replace dialogs with extracted components
5. **Phase 5:** Remove redundant state variables

**Target:** Reduce from 1594 lines to ~250-300 lines

## Related Documentation

- **Architecture:** `ARCHITECTURE.md` - Overall app architecture
- **Bible Features:** `BIBLE_FEATURE.md` - Bible feature documentation
- **Implementation:** `BIBLE_IMPROVEMENTS_SUMMARY.md` - Recent improvements

## License

Same license as the parent project.
