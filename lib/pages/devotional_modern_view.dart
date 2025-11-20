import 'package:devocional_nuevo/widgets/devocionales_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class DevocionalModernView extends StatelessWidget {
  final int currentIndex;
  final int totalDevotionals;
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

  const DevocionalModernView({
    super.key,
    required this.currentIndex,
    required this.totalDevotionals,
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
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...contenido moderno del devocional...
      bottomNavigationBar: DevocionalesBottomNavBar(
        currentIndex: currentIndex,
        isFavorite: isFavorite,
        onPrevious: onPrevious,
        onNext: onNext,
        onFavorite: onFavorite,
        onPrayers: onPrayers,
        onBible: onBible,
        onShare: onShare,
        onProgress: onProgress,
        onSettings: onSettings,
        ttsPlayerWidget: ttsPlayerWidget,
        appBarForegroundColor: appBarForegroundColor,
        appBarBackgroundColor: appBarBackgroundColor,
        totalDevotionals: totalDevotionals,
        currentDevocionalIndex: currentIndex,
      ),
    );
  }
}
