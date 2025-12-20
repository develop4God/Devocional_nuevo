import 'package:flutter/material.dart';

/// Centralized shadow definitions with dark mode support
class AppShadows {
  AppShadows._(); // Prevent instantiation

  /// Card shadow - adapts to theme brightness
  static List<BoxShadow> card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      // Subtle elevation in dark mode
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];
    } else {
      // More prominent shadow in light mode
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
    }
  }

  /// Button shadow - subtle depth
  static List<BoxShadow> button(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Floating element shadow (FAB, etc.)
  static List<BoxShadow> floating(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
        blurRadius: 32,
        offset: const Offset(0, 16),
      ),
    ];
  }
}
