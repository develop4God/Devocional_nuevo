import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'es';
  static const List<String> _supportedLanguages = ['es', 'en', 'pt', 'fr'];

  Map<String, dynamic> _localizedStrings = {};
  String _currentLanguage = _defaultLanguage;

  // Locale mappings for TTS compatibility
  static const Map<String, String> _ttsLocaleMap = {
    'es': 'es-ES',
    'en': 'en-US', 
    'pt': 'pt-BR',
    'fr': 'fr-FR',
  };

  String get currentLanguage => _currentLanguage;
  List<String> get supportedLanguages => _supportedLanguages;

  /// Initialize the localization service and load saved language preference
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Try to get saved language, otherwise detect from device locale
    String savedLanguage = prefs.getString(_languageKey) ?? '';
    
    if (savedLanguage.isEmpty) {
      // Auto-detect from device locale
      savedLanguage = _detectDeviceLanguage();
      await prefs.setString(_languageKey, savedLanguage);
    }

    await setLanguage(savedLanguage);
  }

  /// Detect device language and return supported language or default
  String _detectDeviceLanguage() {
    try {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final languageCode = deviceLocale.languageCode.toLowerCase();
      
      if (_supportedLanguages.contains(languageCode)) {
        return languageCode;
      }
    } catch (e) {
      // Fallback to default if detection fails
    }
    return _defaultLanguage;
  }

  /// Set the current language and load translations
  Future<void> setLanguage(String languageCode) async {
    if (!_supportedLanguages.contains(languageCode)) {
      languageCode = _defaultLanguage;
    }

    _currentLanguage = languageCode;
    await _loadLanguage();
    
    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  /// Load translation file for current language
  Future<void> _loadLanguage() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/translations/$_currentLanguage.json');
      _localizedStrings = json.decode(jsonString);
    } catch (e) {
      // Fallback to default language if loading fails
      if (_currentLanguage != _defaultLanguage) {
        _currentLanguage = _defaultLanguage;
        final String jsonString = await rootBundle.loadString('assets/translations/$_defaultLanguage.json');
        _localizedStrings = json.decode(jsonString);
      }
    }
  }

  /// Get localized string by key path (e.g., "settings.title")
  String translate(String key) {
    final keys = key.split('.');
    dynamic current = _localizedStrings;
    
    for (final k in keys) {
      if (current is Map && current.containsKey(k)) {
        current = current[k];
      } else {
        return key; // Return key if translation not found
      }
    }
    
    return current?.toString() ?? key;
  }

  /// Get the corresponding TTS locale for current language
  String getTtsLocale() {
    return _ttsLocaleMap[_currentLanguage] ?? _ttsLocaleMap[_defaultLanguage]!;
  }

  /// Get Locale object for current language
  Locale getLocale() {
    return Locale(_currentLanguage);
  }

  /// Check if a language is supported
  bool isLanguageSupported(String languageCode) {
    return _supportedLanguages.contains(languageCode);
  }
}

/// String extension to make translation calls easy with .tr()
extension StringTranslation on String {
  String tr() {
    return LocalizationService().translate(this);
  }
}