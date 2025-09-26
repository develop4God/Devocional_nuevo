import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devocional_nuevo/providers/theme/theme_adapter.dart';
import 'package:devocional_nuevo/providers/theme/theme_providers.dart';

/// Riverpod implementation of ThemeAdapter
class RiverpodThemeAdapter implements ThemeAdapter {
  final Ref _ref;

  RiverpodThemeAdapter(this._ref);

  @override
  Future<void> setThemeFamily(String familyName) async {
    await _ref.read(themeProvider.notifier).setThemeFamily(familyName);
  }

  @override
  Future<void> setBrightness(Brightness brightness) async {
    await _ref.read(themeProvider.notifier).setBrightness(brightness);
  }

  @override
  String get currentThemeFamily {
    return _ref.read(currentThemeFamilyProvider);
  }

  @override
  Brightness get currentBrightness {
    return _ref.read(currentBrightnessProvider);
  }
}

/// Legacy ThemeProvider implementation of ThemeAdapter 
/// (for migration purposes - to be removed after full migration)
class LegacyThemeAdapter implements ThemeAdapter {
  // This can be used if we need backward compatibility during migration
  // We'll implement this if needed, but for now we'll use Riverpod approach
  
  @override
  Future<void> setThemeFamily(String familyName) async {
    // Implementation would wrap old ThemeProvider
    throw UnimplementedError('Use RiverpodThemeAdapter instead');
  }

  @override
  Future<void> setBrightness(Brightness brightness) async {
    throw UnimplementedError('Use RiverpodThemeAdapter instead');
  }

  @override
  String get currentThemeFamily {
    throw UnimplementedError('Use RiverpodThemeAdapter instead');
  }

  @override
  Brightness get currentBrightness {
    throw UnimplementedError('Use RiverpodThemeAdapter instead');
  }
}

/// Provider for theme adapter
final themeAdapterProvider = Provider<ThemeAdapter>((ref) {
  return RiverpodThemeAdapter(ref);
});