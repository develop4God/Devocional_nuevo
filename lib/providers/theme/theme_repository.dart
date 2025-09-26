import 'package:shared_preferences/shared_preferences.dart';
import 'package:devocional_nuevo/utils/theme_constants.dart';

/// Repository pattern for theme-related SharedPreferences operations
class ThemeRepository {
  // Keys for storing theme preferences
  static const String _themeFamilyKey = 'theme_family_name';
  static const String _brightnessKey = 'theme_brightness';
  
  // Default values
  static const String defaultThemeFamily = 'Deep Purple';
  static const String defaultBrightness = 'light';

  /// Get the saved theme family from SharedPreferences
  Future<String> getThemeFamily() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeFamily = prefs.getString(_themeFamilyKey);
    
    // Validate saved theme exists in our theme map
    if (savedThemeFamily != null && appThemeFamilies.containsKey(savedThemeFamily)) {
      return savedThemeFamily;
    }
    
    return defaultThemeFamily;
  }

  /// Save theme family to SharedPreferences
  Future<void> setThemeFamily(String themeFamily) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeFamilyKey, themeFamily);
  }

  /// Get the saved brightness setting from SharedPreferences
  Future<String> getBrightness() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_brightnessKey) ?? defaultBrightness;
  }

  /// Save brightness setting to SharedPreferences
  Future<void> setBrightness(String brightness) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_brightnessKey, brightness);
  }

  /// Get complete theme preference as a record for atomic loading
  Future<({String themeFamily, String brightness})> getThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    final savedThemeFamily = prefs.getString(_themeFamilyKey);
    final savedBrightness = prefs.getString(_brightnessKey) ?? defaultBrightness;
    
    // Validate theme family exists
    final themeFamily = (savedThemeFamily != null && appThemeFamilies.containsKey(savedThemeFamily))
        ? savedThemeFamily
        : defaultThemeFamily;
    
    return (themeFamily: themeFamily, brightness: savedBrightness);
  }

  /// Reset theme to defaults (useful for testing)
  Future<void> resetTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeFamilyKey);
    await prefs.remove(_brightnessKey);
  }
}