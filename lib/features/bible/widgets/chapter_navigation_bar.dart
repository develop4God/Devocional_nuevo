import 'package:flutter/material.dart';
import 'package:devocional_nuevo/extensions/string_extensions.dart';

/// Chapter navigation bar widget
/// Pure presentation component with callbacks
class ChapterNavigationBar extends StatelessWidget {
  final String bookName;
  final int chapter;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const ChapterNavigationBar({
    super.key,
    required this.bookName,
    required this.chapter,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous chapter button
              IconButton(
                icon: Icon(Icons.chevron_left, color: colorScheme.primary),
                tooltip: 'bible.previous_chapter'.tr(),
                onPressed: onPrevious,
              ),
              // Current book and chapter display
              Expanded(
                child: Text(
                  '$bookName $chapter',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                ),
              ),
              // Next chapter button
              IconButton(
                icon: Icon(Icons.chevron_right, color: colorScheme.primary),
                tooltip: 'bible.next_chapter'.tr(),
                onPressed: onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
