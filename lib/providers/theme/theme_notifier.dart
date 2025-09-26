import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devocional_nuevo/providers/theme/theme_state.dart';
import 'package:devocional_nuevo/providers/theme/theme_repository.dart';
import 'package:devocional_nuevo/utils/theme_constants.dart';

/// StateNotifier for managing theme state with persistence
class ThemeNotifier extends StateNotifier<ThemeState> {
  final ThemeRepository _repository;

  ThemeNotifier(this._repository) : super(const ThemeState.loading()) {
    _loadInitialTheme();
  }

  /// Load theme preferences and initialize state
  Future<void> _loadInitialTheme() async {
    try {
      final prefs = await _repository.getThemePreferences();
      final themeData = _getThemeData(prefs.themeFamily, prefs.brightness);
      final brightness = prefs.brightness == 'light' ? Brightness.light : Brightness.dark;

      state = ThemeState.loaded(
        themeFamily: prefs.themeFamily,
        brightness: brightness,
        themeData: themeData,
      );
    } catch (e) {
      // Fallback to default theme on error
      final themeData = appThemeFamilies[ThemeRepository.defaultThemeFamily]!['light']!;
      state = ThemeState.loaded(
        themeFamily: ThemeRepository.defaultThemeFamily,
        brightness: Brightness.light,
        themeData: themeData,
      );
    }
  }

  /// Set theme family and persist to storage
  Future<void> setThemeFamily(String familyName) async {
    final currentState = state;
    if (currentState is! ThemeStateLoaded) return;

    // Don't do anything if it's the same theme
    if (currentState.themeFamily == familyName) return;

    // Validate theme family exists
    if (!appThemeFamilies.containsKey(familyName)) return;

    try {
      await _repository.setThemeFamily(familyName);
      final themeData = _getThemeData(familyName, _brightnessToString(currentState.brightness));

      state = ThemeState.loaded(
        themeFamily: familyName,
        brightness: currentState.brightness,
        themeData: themeData,
      );
    } catch (e) {
      // State remains unchanged on error
    }
  }

  /// Set brightness and persist to storage
  Future<void> setBrightness(Brightness brightness) async {
    final currentState = state;
    if (currentState is! ThemeStateLoaded) return;

    // Don't do anything if it's the same brightness
    if (currentState.brightness == brightness) return;

    try {
      final brightnessString = _brightnessToString(brightness);
      await _repository.setBrightness(brightnessString);
      final themeData = _getThemeData(currentState.themeFamily, brightnessString);

      state = ThemeState.loaded(
        themeFamily: currentState.themeFamily,
        brightness: brightness,
        themeData: themeData,
      );
    } catch (e) {
      // State remains unchanged on error
    }
  }

  /// Force reload theme from storage (useful for testing)
  Future<void> reloadTheme() async {
    state = const ThemeState.loading();
    await _loadInitialTheme();
  }

  /// Helper method to get ThemeData from theme constants
  ThemeData _getThemeData(String themeFamily, String brightnessString) {
    return appThemeFamilies[themeFamily]?[brightnessString] ??
        appThemeFamilies[ThemeRepository.defaultThemeFamily]!['light']!;
  }

  /// Helper method to convert Brightness to string
  String _brightnessToString(Brightness brightness) {
    return brightness == Brightness.light ? 'light' : 'dark';
  }

  /// Initialize with default values (useful for testing)
  void initializeDefaults() {
    final themeData = appThemeFamilies[ThemeRepository.defaultThemeFamily]!['light']!;
    state = ThemeState.loaded(
      themeFamily: ThemeRepository.defaultThemeFamily,
      brightness: Brightness.light,
      themeData: themeData,
    );
  }
}