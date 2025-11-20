// lib/utils/devotional_constants.dart

import 'package:flutter/material.dart';

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

/// Centralized tag-to-color mapping for devotional cards
/// Single source of truth for tag colors across the app
class TagColorMapper {
  // Private constructor to prevent instantiation
  TagColorMapper._();

  /// Map of tag keywords to gradient color pairs [light, dark]
  static const Map<String, List<int>> _tagColorMap = {
    // Love/Amor - Pink to Red
    'love': [0xFFE91E63, 0xFFF44336],
    'amor': [0xFFE91E63, 0xFFF44336],

    // Peace/Paz - Blue to Indigo
    'peace': [0xFF2196F3, 0xFF3F51B5],
    'paz': [0xFF2196F3, 0xFF3F51B5],

    // Faith/Fe - Purple to Deep Purple
    'faith': [0xFF9C27B0, 0xFF673AB7],
    'fe': [0xFF9C27B0, 0xFF673AB7],

    // Hope/Esperanza - Teal to Cyan
    'hope': [0xFF009688, 0xFF00BCD4],
    'esperanza': [0xFF009688, 0xFF00BCD4],

    // Joy/Alegría - Orange to Deep Orange
    'joy': [0xFFFF9800, 0xFFFF5722],
    'alegria': [0xFFFF9800, 0xFFFF5722],
    'alegría': [0xFFFF9800, 0xFFFF5722],
  };

  /// Default gradient colors for tags not in the map
  static const List<int> _defaultColors = [0xFF607D8B, 0xFF455A64]; // Blue Grey

  /// Get gradient colors for a tag
  /// Returns [startColor, endColor] for use in LinearGradient
  static List<Color> getTagGradient(String? tag) {
    if (tag == null || tag.isEmpty) {
      return _defaultColors.map((c) => Color(c)).toList();
    }

    final tagLower = tag.toLowerCase();

    // Find matching color pair
    for (final entry in _tagColorMap.entries) {
      if (tagLower.contains(entry.key)) {
        return entry.value.map((c) => Color(c)).toList();
      }
    }

    // Return default if no match
    return _defaultColors.map((c) => Color(c)).toList();
  }

  /// Get single chip color for a tag
  /// Returns the darker (second) color from the gradient pair
  static Color getTagChipColor(String? tag) {
    final colors = getTagGradient(tag);
    return colors[1]; // Return darker color for chip
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
