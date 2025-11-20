// lib/utils/devotional_constants.dart

/// Experience mode enum for type-safe experience selection
enum ExperienceMode {
  discovery,
  traditional;

  /// Convert enum to string for storage
  String toStorageString() => name;

  /// Create enum from storage string
  static ExperienceMode fromStorageString(String? value) {
    switch (value) {
      case 'discovery':
        return ExperienceMode.discovery;
      case 'traditional':
        return ExperienceMode.traditional;
      default:
        return ExperienceMode.traditional; // Default fallback
    }
  }
}

/// Global constants for devotionals discovery feature
class DevotionalConstants {
  /// URL GENERATION FUNCTIONS

  // Original method - DO NOT MODIFY (Backward Compatibility)
  static String getDevocionalesApiUrl(int year) {
    return 'https://raw.githubusercontent.com/develop4God/Devocionales-json/refs/heads/main/Devocional_year_$year.json';
  }

  // New method for multilingual support
  static String getDevocionalesApiUrlMultilingual(
    int year,
    String languageCode,
    String versionCode,
  ) {
    // Backward compatibility for Spanish RVR1960
    if (languageCode == 'es' && versionCode == 'RVR1960') {
      return getDevocionalesApiUrl(year); // Use original method
    }

    // New format for other languages/versions
    return 'https://raw.githubusercontent.com/develop4God/Devocionales-json/refs/heads/main/Devocional_year_${year}_${languageCode}_$versionCode.json';
  }

  /// LANGUAGE AND VERSION MAPS

  // Supported languages and their readable names
  static const Map<String, String> supportedLanguages = {
    'es': 'Español',
    'en': 'English',
    'pt': 'Português',
    'fr': 'Français',
    'zh': 'Chinese (Coming Soon)',
  };

  // Available Bible versions by language
  static const Map<String, List<String>> bibleVersionsByLanguage = {
    'es': ['RVR1960', 'NVI'],
    'en': ['KJV', 'NIV'],
    'pt': ['ARC', 'NVI'],
    'fr': ['LSG1910', 'TOB'],
    'zh': [], // Coming soon
  };

  // Default Bible version by language
  static const Map<String, String> defaultVersionByLanguage = {
    'es': 'RVR1960',
    'en': 'KJV',
    'pt': 'ARC',
    'fr': 'LSG1910',
    'zh': 'RVR1960', // Fallback until Chinese content is available
  };

  /// PREFERENCES (SharedPreferences KEYS)
  static const String prefFavorites = 'discovery_favorites';
  static const String prefSelectedLanguage = 'discovery_selectedLanguage';
  static const String prefSelectedVersion = 'discovery_selectedVersion';
  static const String prefExperienceMode = 'discovery_experienceMode';
}
