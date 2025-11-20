// lib/pages/devotional_discovery/widgets/devotional_card_premium.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/devocional_model.dart';

/// Premium devotional card with full background image (Glorify/YouVersion style)
class DevotionalCardPremium extends StatelessWidget {
  final Devocional devocional;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isDark;

  const DevotionalCardPremium({
    super.key,
    required this.devocional,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final displayDate = _getDisplayDate();
    final verseReference = _extractVerseReference(devocional.versiculo);
    final verseText = _extractVerseText(devocional.versiculo);

    return Semantics(
      label:
          'Devotional card for $verseReference. $verseText. Posted $displayDate. ${isFavorite ? "In favorites" : "Not in favorites"}',
      button: true,
      child: Container(
        height: 320,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  _buildBackgroundImage(),

                  // Dark gradient overlay (bottom to top)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.9),
                        ],
                        stops: const [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Date badge only
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Date badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                displayDate,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Bottom content
                        // Theme tag chip
                        if (devocional.tags != null &&
                            devocional.tags!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getTagColor(devocional.tags!.first),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              devocional.tags!.first,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Verse reference (large and bold)
                        Text(
                          verseReference,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Verse preview text
                        Text(
                          _extractVerseText(devocional.versiculo),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 12),

                        // Reading time badge
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '5 min read',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Floating heart button (FAB style) - top-right
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Semantics(
                      label: isFavorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                      button: true,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey(isFavorite),
                                color: isFavorite
                                    ? Colors.red[500]
                                    : Colors.grey[700],
                                size: 24,
                              ),
                            ),
                            onPressed: onFavoriteToggle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ), // Close Semantics
    );
  }

  Widget _buildBackgroundImage() {
    // Use CachedNetworkImage with shimmer placeholder
    // For now, we'll use a fallback gradient since we don't have image URLs
    // In production, you'd fetch image URLs from your API or use Unsplash
    final imageUrl = _getImageUrl();

    if (imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: _getGradientColors()[0],
          highlightColor: _getGradientColors()[1].withValues(alpha: 0.5),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getGradientColors(),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getGradientColors(),
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white70,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  'Tap to retry',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Fallback gradient with subtle shimmer effect
    return Shimmer.fromColors(
      baseColor: _getGradientColors()[0],
      highlightColor: _getGradientColors()[1].withValues(alpha: 0.3),
      period: const Duration(milliseconds: 2000),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(),
          ),
        ),
      ),
    );
  }

  String? _getImageUrl() {
    // TODO: In production, fetch image URLs from your devotional data
    // For now, returning null to use gradient fallback
    // You could add an "imageUrl" field to your Devocional model
    return null;
  }

  List<Color> _getGradientColors() {
    if (devocional.tags != null && devocional.tags!.isNotEmpty) {
      final tag = devocional.tags!.first.toLowerCase();
      if (tag.contains('love') || tag.contains('amor')) {
        return isDark
            ? [Colors.pink[900]!, Colors.red[800]!]
            : [Colors.pink[600]!, Colors.red[600]!];
      } else if (tag.contains('peace') || tag.contains('paz')) {
        return isDark
            ? [Colors.blue[900]!, Colors.indigo[800]!]
            : [Colors.blue[600]!, Colors.indigo[600]!];
      } else if (tag.contains('faith') || tag.contains('fe')) {
        return isDark
            ? [Colors.purple[900]!, Colors.deepPurple[800]!]
            : [Colors.purple[600]!, Colors.deepPurple[600]!];
      } else if (tag.contains('hope') || tag.contains('esperanza')) {
        return isDark
            ? [Colors.teal[900]!, Colors.cyan[800]!]
            : [Colors.teal[600]!, Colors.cyan[600]!];
      }
    }

    return isDark
        ? [Colors.deepPurple[900]!, Colors.purple[800]!]
        : [Colors.deepPurple[600]!, Colors.purple[600]!];
  }

  Color _getTagColor(String tag) {
    final tagLower = tag.toLowerCase();
    if (tagLower.contains('love') || tagLower.contains('amor')) {
      return Colors.red[600]!;
    } else if (tagLower.contains('peace') || tagLower.contains('paz')) {
      return Colors.blue[600]!;
    } else if (tagLower.contains('faith') || tagLower.contains('fe')) {
      return Colors.purple[600]!;
    } else if (tagLower.contains('hope') || tagLower.contains('esperanza')) {
      return Colors.teal[600]!;
    }
    return Colors.deepPurple[600]!;
  }

  String _getDisplayDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final devDate = DateTime(
      devocional.date.year,
      devocional.date.month,
      devocional.date.day,
    );

    if (devDate == today) {
      return 'Today';
    }

    DateTime displayDate = devDate;
    while (displayDate.isBefore(today)) {
      displayDate = DateTime(
        displayDate.year + 1,
        displayDate.month,
        displayDate.day,
      );
    }

    final tomorrow = today.add(const Duration(days: 1));
    if (displayDate == tomorrow) {
      return 'Tomorrow';
    }

    final daysUntil = displayDate.difference(today).inDays;
    if (daysUntil <= 7 && daysUntil > 1) {
      return DateFormat('EEEE').format(displayDate);
    }

    return DateFormat('MMM dd').format(displayDate);
  }

  String _extractVerseReference(String versiculo) {
    final parts = versiculo.split(RegExp(r'\s+[A-Z]{2,}[0-9]*:'));
    if (parts.isNotEmpty) {
      return parts[0].trim();
    }

    final quoteIndex = versiculo.indexOf('"');
    if (quoteIndex > 0) {
      return versiculo.substring(0, quoteIndex).trim();
    }

    return versiculo;
  }

  String _extractVerseText(String versiculo) {
    final quoteStart = versiculo.indexOf('"');
    final quoteEnd = versiculo.lastIndexOf('"');
    if (quoteStart != -1 && quoteEnd != -1 && quoteEnd > quoteStart) {
      return versiculo.substring(quoteStart + 1, quoteEnd);
    }
    return versiculo;
  }
}
