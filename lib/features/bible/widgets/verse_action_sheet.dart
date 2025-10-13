import 'package:flutter/material.dart';
import 'package:devocional_nuevo/extensions/string_extensions.dart';

/// Verse action sheet widget
/// Shows actions for selected verses (copy, share, save, image)
class VerseActionSheet extends StatelessWidget {
  final Set<String> selectedVerses;
  final String verseReference;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback? onImage;

  const VerseActionSheet({
    super.key,
    required this.selectedVerses,
    required this.verseReference,
    required this.onCopy,
    required this.onShare,
    required this.onSave,
    this.onImage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Selection info
          Text(
            verseReference,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'bible.verses_selected'
                .tr({'count': selectedVerses.length.toString()}),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 24),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context: context,
                icon: Icons.copy,
                label: 'bible.copy'.tr(),
                onTap: onCopy,
              ),
              _buildActionButton(
                context: context,
                icon: Icons.bookmark_add_outlined,
                label: 'bible.save'.tr(),
                onTap: onSave,
              ),
              _buildActionButton(
                context: context,
                icon: Icons.share,
                label: 'bible.share'.tr(),
                onTap: onShare,
              ),
              if (onImage != null)
                _buildActionButton(
                  context: context,
                  icon: Icons.image_outlined,
                  label: 'Imagen',
                  onTap: onImage!,
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: colorScheme.onSurface,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Show the action sheet
  static Future<void> show(
    BuildContext context, {
    required Set<String> selectedVerses,
    required String verseReference,
    required VoidCallback onCopy,
    required VoidCallback onShare,
    required VoidCallback onSave,
    VoidCallback? onImage,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return VerseActionSheet(
          selectedVerses: selectedVerses,
          verseReference: verseReference,
          onCopy: onCopy,
          onShare: onShare,
          onSave: onSave,
          onImage: onImage,
        );
      },
    );
  }
}
