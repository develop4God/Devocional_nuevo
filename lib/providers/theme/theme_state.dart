import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_state.freezed.dart';

@freezed
class ThemeState with _$ThemeState {
  const factory ThemeState.loading() = ThemeStateLoading;

  const factory ThemeState.loaded({
    required String themeFamily,
    required Brightness brightness,
    required ThemeData themeData,
  }) = ThemeStateLoaded;
}

// Extension methods for easier access
extension ThemeStateX on ThemeState {
  String? get themeFamilyOrNull => maybeWhen(
        loaded: (themeFamily, _, __) => themeFamily,
        orElse: () => null,
      );

  Brightness? get brightnessOrNull => maybeWhen(
        loaded: (_, brightness, __) => brightness,
        orElse: () => null,
      );

  ThemeData? get themeDataOrNull => maybeWhen(
        loaded: (_, __, themeData) => themeData,
        orElse: () => null,
      );

  Color get dividerAdaptiveColor {
    final brightness = brightnessOrNull ?? Brightness.light;
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}
