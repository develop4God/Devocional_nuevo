import 'package:flutter/material.dart';
import 'package:devocional_nuevo/extensions/string_extensions.dart';

/// Book selector dialog widget
/// Allows user to search and select a Bible book
class BookSelectorDialog extends StatefulWidget {
  final List<Map<String, dynamic>> books;
  final String? currentSelection;
  final Function(Map<String, dynamic> book) onBookSelected;

  const BookSelectorDialog({
    super.key,
    required this.books,
    this.currentSelection,
    required this.onBookSelected,
  });

  @override
  State<BookSelectorDialog> createState() => _BookSelectorDialogState();

  /// Show the dialog and return selected book
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required List<Map<String, dynamic>> books,
    String? currentSelection,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        Map<String, dynamic>? selectedBook;
        return BookSelectorDialog(
          books: books,
          currentSelection: currentSelection,
          onBookSelected: (book) {
            selectedBook = book;
            Navigator.of(context).pop(selectedBook);
          },
        );
      },
    );
  }
}

class _BookSelectorDialogState extends State<BookSelectorDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _filteredBooks = List.from(widget.books);
    _searchController.addListener(_filterBooks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBooks() {
    setState(() {
      final query = _searchController.text;
      if (query.length < 2) {
        _filteredBooks = List.from(widget.books);
      } else {
        _filteredBooks = widget.books.where((book) {
          final longName = book['long_name'].toString().toLowerCase();
          final shortName = book['short_name'].toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return longName.contains(searchLower) ||
              shortName.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('bible.search_book'.tr()),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'bible.search_book_placeholder'.tr(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = _filteredBooks[index];
                  final isSelected =
                      book['short_name'] == widget.currentSelection;
                  return ListTile(
                    title: Text(book['long_name']),
                    subtitle: Text(book['short_name']),
                    selected: isSelected,
                    selectedTileColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.3),
                    onTap: () {
                      widget.onBookSelected(book);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
