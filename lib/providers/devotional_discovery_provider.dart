// lib/providers/devotional_discovery_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/devocional_model.dart';
import '../utils/devotional_constants.dart';

/// Provider for devotional discovery feature
/// Uses ChangeNotifier pattern for state management
class DevotionalDiscoveryProvider extends ChangeNotifier {
  List<Devocional> _all = [];
  List<Devocional> _filtered = [];
  List<Devocional> _favorites = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedLanguage = 'es';
  String _selectedVersion = 'RVR1960';
  final bool _isOfflineMode = false;

  // Getters
  List<Devocional> get all => _all;
  List<Devocional> get filtered => _filtered;
  List<Devocional> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedLanguage => _selectedLanguage;
  String get selectedVersion => _selectedVersion;
  bool get isOfflineMode => _isOfflineMode;

  /// Initialize devotional data
  Future<void> initialize() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceLanguage = PlatformDispatcher.instance.locale.languageCode;

      // Get saved language or use device language
      String savedLanguage =
          prefs.getString(DevotionalConstants.prefSelectedLanguage) ??
              deviceLanguage;
      _selectedLanguage = _getSupportedLanguageWithFallback(savedLanguage);

      // Save language if different from saved
      if (_selectedLanguage != savedLanguage) {
        await prefs.setString(
          DevotionalConstants.prefSelectedLanguage,
          _selectedLanguage,
        );
      }

      // Get saved version or use default
      String savedVersion =
          prefs.getString(DevotionalConstants.prefSelectedVersion) ?? '';
      String defaultVersion =
          DevotionalConstants.defaultVersionByLanguage[_selectedLanguage] ??
              'RVR1960';
      _selectedVersion =
          savedVersion.isNotEmpty ? savedVersion : defaultVersion;

      // Load favorites
      await _loadFavorites();

      // Fetch devotionals
      await _fetchDevocionalesForLanguage();
    } catch (e) {
      debugPrint('Error in initialize: $e');
      _errorMessage = 'Error al inicializar los datos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getSupportedLanguageWithFallback(String requestedLanguage) {
    const supportedLanguages = ['es', 'en', 'pt', 'fr', 'zh'];
    if (supportedLanguages.contains(requestedLanguage)) {
      return requestedLanguage;
    }
    return 'es'; // fallback
  }

  /// Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(
        DevotionalConstants.prefFavorites,
      );

      if (favoritesJson != null && favoritesJson.isNotEmpty) {
        final List<dynamic> favoritesData = json.decode(favoritesJson);
        _favorites =
            favoritesData.map((item) => Devocional.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  /// Fetch devotionals from API
  Future<void> _fetchDevocionalesForLanguage() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final int currentYear = DateTime.now().year;
      final String url = DevotionalConstants.getDevocionalesApiUrlMultilingual(
        currentYear,
        _selectedLanguage,
        _selectedVersion,
      );

      debugPrint('🔍 Fetching devotionals from: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to load from API: ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      await _processDevocionalData(data);
    } catch (e) {
      debugPrint('Error fetching devotionals: $e');
      _errorMessage = 'Error al cargar los devocionales: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Process devotional data from JSON
  Future<void> _processDevocionalData(Map<String, dynamic> data) async {
    try {
      List<Devocional> loadedDevocionales = [];

      // Parse new JSON structure: data -> language -> date -> devotionals[]
      if (data['data'] != null) {
        final dataMap = data['data'] as Map<String, dynamic>;

        // Get devotionals for the selected language
        if (dataMap[_selectedLanguage] != null) {
          final languageData =
              dataMap[_selectedLanguage] as Map<String, dynamic>;

          // Iterate through each date
          for (var dateEntry in languageData.entries) {
            final dateDevocionales = dateEntry.value as List<dynamic>;

            // Parse each devotional for this date
            for (var item in dateDevocionales) {
              try {
                final devocional = Devocional.fromJson(
                  item as Map<String, dynamic>,
                );
                loadedDevocionales.add(devocional);
              } catch (e) {
                debugPrint('Error parsing devotional: $e');
              }
            }
          }
        } else {
          debugPrint(
            '⚠️ No devotionals found for language: $_selectedLanguage',
          );
        }
      }

      // Sort by date: Today's devotionals first, then by date (newest first)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      loadedDevocionales.sort((a, b) {
        final aDate = DateTime(a.date.year, a.date.month, a.date.day);
        final bDate = DateTime(b.date.year, b.date.month, b.date.day);

        // Today's devotionals come first
        if (aDate == today && bDate != today) return -1;
        if (bDate == today && aDate != today) return 1;

        // Otherwise sort by date (newest first)
        return b.date.compareTo(a.date);
      });

      _all = loadedDevocionales;
      _filtered = loadedDevocionales;
      _isLoading = false;
      notifyListeners();

      debugPrint(
        '✅ Loaded ${loadedDevocionales.length} devotionals for $_selectedLanguage',
      );
    } catch (e) {
      debugPrint('Error processing devotional data: $e');
      _errorMessage = 'Error al procesar los devocionales: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle favorite status for a devotional
  Future<void> toggleFavorite(Devocional devocional) async {
    try {
      final isFavorite = _favorites.any((d) => d.id == devocional.id);

      if (isFavorite) {
        _favorites.removeWhere((d) => d.id == devocional.id);
      } else {
        _favorites.add(devocional);
      }

      notifyListeners();

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(
        _favorites.map((d) => d.toJson()).toList(),
      );
      await prefs.setString(DevotionalConstants.prefFavorites, favoritesJson);

      debugPrint('✅ Favorite toggled for: ${devocional.id}');
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  /// Check if a devotional is a favorite
  bool isFavorite(String devocionalId) {
    return _favorites.any((d) => d.id == devocionalId);
  }

  /// Change language
  Future<void> changeLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        DevotionalConstants.prefSelectedLanguage,
        languageCode,
      );

      // Get default version for the new language
      final defaultVersion =
          DevotionalConstants.defaultVersionByLanguage[languageCode] ??
              'RVR1960';

      _selectedLanguage = languageCode;
      _selectedVersion = defaultVersion;
      notifyListeners();

      await _fetchDevocionalesForLanguage();
    } catch (e) {
      debugPrint('Error changing language: $e');
    }
  }

  /// Change version
  Future<void> changeVersion(String versionCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        DevotionalConstants.prefSelectedVersion,
        versionCode,
      );

      _selectedVersion = versionCode;
      notifyListeners();

      await _fetchDevocionalesForLanguage();
    } catch (e) {
      debugPrint('Error changing version: $e');
    }
  }

  /// Filter devotionals by search term
  void filterBySearch(String searchTerm) {
    if (searchTerm.isEmpty) {
      _filtered = _all;
      notifyListeners();
      return;
    }

    _filtered = _all.where((d) {
      final term = searchTerm.toLowerCase();

      // Search in reflection, verse, and prayer
      final inReflection = d.reflexion.toLowerCase().contains(term);
      final inVerse = d.versiculo.toLowerCase().contains(term);
      final inPrayer = d.oracion.toLowerCase().contains(term);

      // Search in tags (in the corresponding language)
      final inTags =
          d.tags?.any((tag) => tag.toLowerCase().contains(term)) ?? false;

      return inReflection || inVerse || inPrayer || inTags;
    }).toList();

    notifyListeners();
  }

  /// Get devotional by ID
  Devocional? getDevocionalById(String id) {
    try {
      return _all.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
}
