import 'package:flutter/material.dart';
import 'package:devocional_nuevo/services/localization_service.dart';

class LocalizationProvider extends ChangeNotifier {
  final LocalizationService _localizationService = LocalizationService();

  String get currentLanguage => _localizationService.currentLanguage;
  List<String> get supportedLanguages => _localizationService.supportedLanguages;
  Locale get locale => _localizationService.getLocale();

  /// Initialize the localization provider
  Future<void> initialize() async {
    await _localizationService.initialize();
    notifyListeners();
  }

  /// Change the app language
  Future<void> setLanguage(String languageCode) async {
    if (_localizationService.currentLanguage != languageCode) {
      await _localizationService.setLanguage(languageCode);
      notifyListeners();
    }
  }

  /// Get localized string
  String translate(String key) {
    return _localizationService.translate(key);
  }

  /// Get TTS locale for current language
  String getTtsLocale() {
    return _localizationService.getTtsLocale();
  }
}