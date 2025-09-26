import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:devocional_nuevo/models/devocional_model.dart';

/// Repository for devocionales data persistence using SharedPreferences
/// Provides clean abstraction for data operations with error handling
class DevocionalesRepository {
  static const String _devocionalesKey = 'devocionales_data';
  static const String _selectedVersionKey = 'selected_version';
  static const String _favoritesKey = 'favorite_devocionales';

  /// Load all devocionales from storage
  Future<List<Devocional>> loadDevocionales() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final devocionalesJson = prefs.getString(_devocionalesKey);

      if (devocionalesJson == null || devocionalesJson.isEmpty) {
        debugPrint('No devocionales found in storage, returning empty list');
        return [];
      }

      final List<dynamic> decodedList = json.decode(devocionalesJson);
      final devocionales = decodedList
          .map((item) => Devocional.fromJson(item as Map<String, dynamic>))
          .toList();

      debugPrint('Loaded ${devocionales.length} devocionales from storage');
      return devocionales;
    } catch (e) {
      debugPrint('Error loading devocionales: $e');
      return []; // Return empty list on error instead of throwing
    }
  }

  /// Save devocionales to storage
  Future<void> saveDevocionales(List<Devocional> devocionales) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final devocionalesJson = json.encode(
        devocionales.map((d) => d.toJson()).toList(),
      );

      await prefs.setString(_devocionalesKey, devocionalesJson);
      debugPrint('Saved ${devocionales.length} devocionales to storage');
    } catch (e) {
      debugPrint('Error saving devocionales: $e');
      rethrow; // Re-throw to let the notifier handle the error
    }
  }

  /// Load selected version from storage
  Future<String> loadSelectedVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final version = prefs.getString(_selectedVersionKey) ?? 'RVR1960';
      debugPrint('Loaded selected version: $version');
      return version;
    } catch (e) {
      debugPrint('Error loading selected version: $e');
      return 'RVR1960'; // Return default on error
    }
  }

  /// Save selected version to storage
  Future<void> saveSelectedVersion(String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedVersionKey, version);
      debugPrint('Saved selected version: $version');
    } catch (e) {
      debugPrint('Error saving selected version: $e');
      rethrow; // Re-throw to let the notifier handle the error
    }
  }

  /// Load favorites from storage
  Future<Set<String>> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = prefs.getStringList(_favoritesKey) ?? [];
      final favorites = favoritesList.toSet();
      debugPrint('Loaded ${favorites.length} favorite devocionales');
      return favorites;
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      return <String>{}; // Return empty set on error
    }
  }

  /// Save favorites to storage
  Future<void> saveFavorites(Set<String> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, favorites.toList());
      debugPrint('Saved ${favorites.length} favorite devocionales');
    } catch (e) {
      debugPrint('Error saving favorites: $e');
      rethrow; // Re-throw to let the notifier handle the error
    }
  }

  /// Toggle favorite status for a devocional
  Future<Set<String>> toggleFavorite(String devocionalId) async {
    final favorites = await loadFavorites();

    if (favorites.contains(devocionalId)) {
      favorites.remove(devocionalId);
      debugPrint('Removed $devocionalId from favorites');
    } else {
      favorites.add(devocionalId);
      debugPrint('Added $devocionalId to favorites');
    }

    await saveFavorites(favorites);
    return favorites;
  }

  /// Check if a devocional is marked as favorite
  Future<bool> isFavorite(String devocionalId) async {
    final favorites = await loadFavorites();
    return favorites.contains(devocionalId);
  }

  /// Get all available versions from devocionales
  Future<List<String>> getAvailableVersions() async {
    try {
      final devocionales = await loadDevocionales();
      final versions = devocionales
          .map((d) => d.version ?? 'RVR1960')
          .toSet()
          .toList()
        ..sort();

      // Ensure RVR1960 is always first if it exists
      if (versions.contains('RVR1960')) {
        versions.remove('RVR1960');
        versions.insert(0, 'RVR1960');
      }

      debugPrint('Available versions: $versions');
      return versions;
    } catch (e) {
      debugPrint('Error getting available versions: $e');
      return ['RVR1960']; // Return default version on error
    }
  }
}
