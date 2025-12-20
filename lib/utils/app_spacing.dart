import 'package:flutter/material.dart';

/// Centralized spacing constants following 8pt grid system
class AppSpacing {
  AppSpacing._(); // Prevent instantiation

  // Base unit (8pt grid system)
  static const double unit = 8.0;

  // Common spacing values
  static const double xs = unit * 0.5; // 4px
  static const double sm = unit; // 8px
  static const double md = unit * 2; // 16px
  static const double lg = unit * 3; // 24px
  static const double xl = unit * 4; // 32px
  static const double xxl = unit * 6; // 48px

  // Card-specific
  static const double cardPadding = md; // 16px
  static const double cardMargin = md; // 16px
  static const double cardRadius = lg; // 24px

  // Screen padding
  static const double screenHorizontal = md; // 16px
  static const double screenVertical = md; // 16px
  static const EdgeInsets screenPadding = EdgeInsets.all(md);

  // Component spacing
  static const double iconTextGap = sm; // 8px
  static const double sectionGap = lg; // 24px
  static const double listItemGap = md; // 16px
}
