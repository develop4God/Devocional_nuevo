import 'package:flutter/material.dart';

/// Interface for theme management that can be implemented by different state management approaches
abstract class ThemeAdapter {
  /// Set the theme family
  Future<void> setThemeFamily(String familyName);

  /// Set the brightness mode
  Future<void> setBrightness(Brightness brightness);

  /// Get current theme family
  String get currentThemeFamily;

  /// Get current brightness
  Brightness get currentBrightness;
}
