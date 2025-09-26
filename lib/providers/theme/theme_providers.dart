import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devocional_nuevo/providers/theme/theme_state.dart';
import 'package:devocional_nuevo/providers/theme/theme_notifier.dart';
import 'package:devocional_nuevo/providers/theme/theme_repository.dart';
import 'package:devocional_nuevo/utils/theme_constants.dart';

/// Repository provider for dependency injection
final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepository();
});

/// Main theme provider that manages theme state
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier(ref.watch(themeRepositoryProvider));
});

/// Convenience providers for specific theme properties
/// These provide type-safe access to theme properties with fallbacks

/// Get current theme family (falls back to default if loading)
final currentThemeFamilyProvider = Provider<String>((ref) {
  return ref.watch(themeProvider).themeFamilyOrNull ?? ThemeRepository.defaultThemeFamily;
});

/// Get current brightness (falls back to light if loading)  
final currentBrightnessProvider = Provider<Brightness>((ref) {
  return ref.watch(themeProvider).brightnessOrNull ?? Brightness.light;
});

/// Get current ThemeData (falls back to default theme if loading)
final currentThemeDataProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeProvider);
  return themeState.themeDataOrNull ?? 
         appThemeFamilies[ThemeRepository.defaultThemeFamily]!['light']!;
});

/// Get adaptive divider color based on current brightness
final dividerAdaptiveColorProvider = Provider<Color>((ref) {
  return ref.watch(themeProvider).dividerAdaptiveColor;
});

/// Check if theme is currently loading
final themeLoadingProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider).maybeWhen(
    loading: () => true,
    orElse: () => false,
  );
});