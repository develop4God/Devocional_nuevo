import 'package:flutter/material.dart';
import 'shimmer_loading.dart';
import '../utils/app_spacing.dart';

/// Skeleton loader for devotional cards
class DevotionalCardSkeleton extends StatelessWidget {
  const DevotionalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[850] : Colors.white;
    final shimmerColor = isDark ? Colors.grey[800] : Colors.grey[300];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section (image placeholder)
          ShimmerLoading(
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.cardRadius),
                ),
              ),
            ),
          ),
          // Content section
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title line 1
                ShimmerLoading(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Title line 2
                ShimmerLoading(
                  child: Container(
                    height: 16,
                    width: double.infinity * 0.8,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Subtitle/metadata
                ShimmerLoading(
                  child: Container(
                    height: 12,
                    width: double.infinity * 0.6,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
