import 'package:flutter/material.dart';

class DevocionalesBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final bool isFavorite;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onFavorite;
  final VoidCallback? onPrayers;
  final VoidCallback? onBible;
  final VoidCallback? onShare;
  final VoidCallback? onProgress;
  final VoidCallback? onSettings;
  final Widget? ttsPlayerWidget;
  final Color? appBarForegroundColor;
  final Color? appBarBackgroundColor;
  final int totalDevotionals;
  final int currentDevocionalIndex;

  const DevocionalesBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    required this.isFavorite,
    this.onPrevious,
    this.onNext,
    this.onFavorite,
    this.onPrayers,
    this.onBible,
    this.onShare,
    this.onProgress,
    this.onSettings,
    this.ttsPlayerWidget,
    this.appBarForegroundColor,
    this.appBarBackgroundColor,
    required this.totalDevotionals,
    required this.currentDevocionalIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton.icon(
                    key: const Key('bottom_nav_previous_button'),
                    onPressed: currentDevocionalIndex > 0 ? onPrevious : null,
                    icon: const Icon(Icons.arrow_back_ios, size: 16),
                    label: Text(
                      'Anterior',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentDevocionalIndex > 0
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withAlpha(30),
                      foregroundColor: currentDevocionalIndex > 0
                          ? Colors.white
                          : Theme.of(context).colorScheme.outline,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22)),
                      elevation: currentDevocionalIndex > 0 ? 2 : 0,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                    child: ttsPlayerWidget ??
                        const SizedBox(width: 56, height: 56)),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton.icon(
                    key: const Key('bottom_nav_next_button'),
                    onPressed: currentDevocionalIndex < totalDevotionals - 1
                        ? onNext
                        : null,
                    label: const Icon(Icons.arrow_forward_ios, size: 16),
                    icon: Text(
                      'Siguiente',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentDevocionalIndex <
                              totalDevotionals - 1
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withAlpha(30),
                      foregroundColor:
                          currentDevocionalIndex < totalDevotionals - 1
                              ? Colors.white
                              : Theme.of(context).colorScheme.outline,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22)),
                      elevation:
                          currentDevocionalIndex < totalDevotionals - 1 ? 2 : 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
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
                        ? 'Quitar de favoritos'
                        : 'Guardar como favorito',
                    onPressed: onFavorite,
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.favorite_border,
                      color: isFavorite ? Colors.amber : Colors.white,
                      size: 32,
                    ),
                  ),
                  IconButton(
                    key: const Key('bottom_appbar_prayers_icon'),
                    tooltip: 'Mis oraciones',
                    onPressed: onPrayers,
                    icon: const Icon(Icons.local_fire_department_outlined,
                        color: Colors.white, size: 35),
                  ),
                  IconButton(
                    key: const Key('bottom_appbar_bible_icon'),
                    tooltip: 'Biblia',
                    onPressed: onBible,
                    icon: const Icon(Icons.auto_stories_outlined,
                        color: Colors.white, size: 32),
                  ),
                  IconButton(
                    key: const Key('bottom_appbar_share_icon'),
                    tooltip: 'Compartir devocional',
                    onPressed: onShare,
                    icon: Icon(Icons.share_outlined,
                        color: appBarForegroundColor, size: 30),
                  ),
                  IconButton(
                    key: const Key('bottom_appbar_progress_icon'),
                    tooltip: 'Progreso',
                    onPressed: onProgress,
                    icon: Icon(Icons.emoji_events_outlined,
                        color: appBarForegroundColor, size: 30),
                  ),
                  IconButton(
                    key: const Key('bottom_appbar_settings_icon'),
                    tooltip: 'Ajustes',
                    onPressed: onSettings,
                    icon: Icon(Icons.app_settings_alt_outlined,
                        color: appBarForegroundColor, size: 30),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
