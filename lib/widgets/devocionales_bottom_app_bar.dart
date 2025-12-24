import 'package:devocional_nuevo/extensions/string_extensions.dart';
import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/pages/progress_page.dart';
import 'package:devocional_nuevo/pages/settings_page.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/utils/bubble_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom navigation bar for the devotionals page
///
/// Displays icons for favorite, prayers, bible, share, progress, and settings.
class DevocionalesBottomAppBar extends StatelessWidget {
  final Color appBarBackgroundColor;
  final bool isFavorite;
  final Devocional? currentDevocional;
  final DevocionalProvider devocionalProvider;
  final VoidCallback onPrayersPressed;
  final VoidCallback onBiblePressed;
  final Future<void> Function(Devocional) onSharePressed;

  const DevocionalesBottomAppBar({
    super.key,
    required this.appBarBackgroundColor,
    required this.isFavorite,
    required this.currentDevocional,
    required this.devocionalProvider,
    required this.onPrayersPressed,
    required this.onBiblePressed,
    required this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: BottomAppBar(
        height: 60,
        color: appBarBackgroundColor,
        padding: EdgeInsets.zero,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                key: const Key('bottom_appbar_favorite_icon'),
                tooltip: isFavorite
                    ? 'devotionals.remove_from_favorites_short'.tr()
                    : 'devotionals.save_as_favorite'.tr(),
                onPressed: currentDevocional != null
                    ? () => devocionalProvider.toggleFavorite(
                          currentDevocional!,
                          context,
                        )
                    : null,
                icon: Icon(
                  isFavorite ? Icons.star : Icons.favorite_border,
                  color: isFavorite ? Colors.amber : Colors.white,
                  size: 32,
                ),
              ),
              IconButton(
                key: const Key('bottom_appbar_prayers_icon'),
                tooltip: 'tooltips.my_prayers'.tr(),
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  await BubbleUtils.markAsShown(
                    BubbleUtils.getIconBubbleId(
                      Icons.local_fire_department_outlined,
                      'new',
                    ),
                  );
                  onPrayersPressed();
                },
                icon: const Icon(
                  Icons.local_fire_department_outlined,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              IconButton(
                key: const Key('bottom_appbar_bible_icon'),
                tooltip: 'tooltips.bible'.tr(),
                onPressed: () async {
                  await BubbleUtils.markAsShown(
                    BubbleUtils.getIconBubbleId(
                      Icons.auto_stories_outlined,
                      'new',
                    ),
                  );
                  onBiblePressed();
                },
                icon: const Icon(
                  Icons.auto_stories_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              IconButton(
                key: const Key('bottom_appbar_share_icon'),
                tooltip: 'devotionals.share_devotional'.tr(),
                onPressed: currentDevocional != null
                    ? () => onSharePressed(currentDevocional!)
                    : null,
                icon: Icon(
                  Icons.share_outlined,
                  color: colorScheme.onPrimary,
                  size: 30,
                ),
              ),
              IconButton(
                key: const Key('bottom_appbar_progress_icon'),
                tooltip: 'tooltips.progress'.tr(),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ProgressPage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 250),
                    ),
                  );
                },
                icon: Icon(
                  Icons.emoji_events_outlined,
                  color: colorScheme.onPrimary,
                  size: 30,
                ),
              ),
              IconButton(
                key: const Key('bottom_appbar_settings_icon'),
                tooltip: 'tooltips.settings'.tr(),
                onPressed: () async {
                  await BubbleUtils.markAsShown(
                    BubbleUtils.getIconBubbleId(
                      Icons.app_settings_alt_outlined,
                      'new',
                    ),
                  );
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const SettingsPage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 250),
                    ),
                  );
                },
                icon: Icon(
                  Icons.app_settings_alt_outlined,
                  color: colorScheme.onPrimary,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
