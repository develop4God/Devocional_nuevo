import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devocional_nuevo/models/prayer_model.dart';
import 'package:devocional_nuevo/services/localization_service.dart';

/// Repository for prayer data persistence using both SharedPreferences and file storage
/// Provides clean abstraction for data operations with error handling
class PrayersRepository {
  static const String _prayersKey = 'prayers_data';
  static const String _prayersFileName = 'prayers.json';

  /// Load prayers from storage (tries file first, then SharedPreferences)
  Future<List<Prayer>> loadPrayers() async {
    try {
      // Try to load from file first (more reliable for large data)
      final prayers = await _loadPrayersFromFile();
      if (prayers.isNotEmpty) {
        debugPrint('Loaded ${prayers.length} prayers from file');
        return prayers;
      }

      // Fallback to SharedPreferences
      return await _loadPrayersFromPreferences();
    } catch (e) {
      debugPrint('Error loading prayers: $e');
      return []; // Return empty list on error instead of throwing
    }
  }

  /// Save prayers to storage (both file and SharedPreferences for redundancy)
  Future<void> savePrayers(List<Prayer> prayers) async {
    try {
      // Save to both file and preferences for redundancy
      await Future.wait([
        _savePrayersToFile(prayers),
        _savePrayersToPreferences(prayers),
      ]);

      debugPrint('Saved ${prayers.length} prayers to storage');
    } catch (e) {
      debugPrint('Error saving prayers: $e');
      rethrow; // Re-throw to let the notifier handle the error
    }
  }

  /// Load prayers from file storage
  Future<List<Prayer>> _loadPrayersFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_prayersFileName');

      if (!await file.exists()) {
        return [];
      }

      final jsonString = await file.readAsString();
      if (jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> decodedList = json.decode(jsonString);
      final prayers = decodedList
          .map((item) => Prayer.fromJson(item as Map<String, dynamic>))
          .toList();

      return prayers;
    } catch (e) {
      debugPrint('Error loading prayers from file: $e');
      return [];
    }
  }

  /// Save prayers to file storage
  Future<void> _savePrayersToFile(List<Prayer> prayers) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_prayersFileName');

      final jsonString = json.encode(
        prayers.map((p) => p.toJson()).toList(),
      );

      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error saving prayers to file: $e');
      rethrow;
    }
  }

  /// Load prayers from SharedPreferences (fallback)
  Future<List<Prayer>> _loadPrayersFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prayersJson = prefs.getString(_prayersKey);

      if (prayersJson == null || prayersJson.isEmpty) {
        debugPrint('No prayers found in preferences, returning empty list');
        return [];
      }

      final List<dynamic> decodedList = json.decode(prayersJson);
      final prayers = decodedList
          .map((item) => Prayer.fromJson(item as Map<String, dynamic>))
          .toList();

      debugPrint('Loaded ${prayers.length} prayers from preferences');
      return prayers;
    } catch (e) {
      debugPrint('Error loading prayers from preferences: $e');
      return [];
    }
  }

  /// Save prayers to SharedPreferences (backup)
  Future<void> _savePrayersToPreferences(List<Prayer> prayers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prayersJson = json.encode(
        prayers.map((p) => p.toJson()).toList(),
      );

      await prefs.setString(_prayersKey, prayersJson);
    } catch (e) {
      debugPrint('Error saving prayers to preferences: $e');
      rethrow;
    }
  }

  /// Sort prayers by creation date (newest first) and status (active first)
  void sortPrayers(List<Prayer> prayers) {
    prayers.sort((a, b) {
      // Active prayers come first
      if (a.isActive && !b.isActive) return -1;
      if (!a.isActive && b.isActive) return 1;

      // Within the same status, sort by date (newest first)
      return b.createdDate.compareTo(a.createdDate);
    });
  }

  /// Add a new prayer
  Future<Prayer> addPrayer(String text) async {
    if (text.trim().isEmpty) {
      throw ArgumentError('Prayer text cannot be empty');
    }

    final prayers = await loadPrayers();

    final newPrayer = Prayer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      createdDate: DateTime.now(),
      status: PrayerStatus.active,
    );

    prayers.add(newPrayer);
    sortPrayers(prayers);
    await savePrayers(prayers);

    debugPrint('Added new prayer: ${newPrayer.id}');
    return newPrayer;
  }

  /// Edit an existing prayer
  Future<Prayer?> editPrayer(String prayerId, String newText) async {
    if (newText.trim().isEmpty) {
      throw ArgumentError('Prayer text cannot be empty');
    }

    final prayers = await loadPrayers();
    final prayerIndex = prayers.indexWhere((p) => p.id == prayerId);

    if (prayerIndex == -1) {
      debugPrint('Prayer not found: $prayerId');
      return null;
    }

    final updatedPrayer = prayers[prayerIndex].copyWith(
      text: newText.trim(),
    );

    prayers[prayerIndex] = updatedPrayer;
    await savePrayers(prayers);

    debugPrint('Updated prayer: $prayerId');
    return updatedPrayer;
  }

  /// Delete a prayer
  Future<bool> deletePrayer(String prayerId) async {
    final prayers = await loadPrayers();
    final initialLength = prayers.length;

    prayers.removeWhere((p) => p.id == prayerId);

    if (prayers.length == initialLength) {
      debugPrint('Prayer not found for deletion: $prayerId');
      return false;
    }

    await savePrayers(prayers);
    debugPrint('Deleted prayer: $prayerId');
    return true;
  }

  /// Mark a prayer as answered
  Future<Prayer?> markPrayerAsAnswered(String prayerId) async {
    final prayers = await loadPrayers();
    final prayerIndex = prayers.indexWhere((p) => p.id == prayerId);

    if (prayerIndex == -1) {
      debugPrint('Prayer not found: $prayerId');
      return null;
    }

    final updatedPrayer = prayers[prayerIndex].copyWith(
      status: PrayerStatus.answered,
      answeredDate: DateTime.now(),
    );

    prayers[prayerIndex] = updatedPrayer;
    sortPrayers(prayers);
    await savePrayers(prayers);

    debugPrint('Marked prayer as answered: $prayerId');
    return updatedPrayer;
  }

  /// Mark a prayer as active (undo answered status)
  Future<Prayer?> markPrayerAsActive(String prayerId) async {
    final prayers = await loadPrayers();
    final prayerIndex = prayers.indexWhere((p) => p.id == prayerId);

    if (prayerIndex == -1) {
      debugPrint('Prayer not found: $prayerId');
      return null;
    }

    final updatedPrayer = prayers[prayerIndex].copyWith(
      status: PrayerStatus.active,
      clearAnsweredDate: true,
    );

    prayers[prayerIndex] = updatedPrayer;
    sortPrayers(prayers);
    await savePrayers(prayers);

    debugPrint('Marked prayer as active: $prayerId');
    return updatedPrayer;
  }

  /// Get prayer statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final prayers = await loadPrayers();
    final now = DateTime.now();

    final activePrayers = prayers.where((p) => p.isActive).toList();
    final answeredPrayers = prayers.where((p) => p.isAnswered).toList();

    var oldestActivePrayer = 0;
    if (activePrayers.isNotEmpty) {
      oldestActivePrayer = activePrayers
          .map((p) => now.difference(p.createdDate).inDays)
          .reduce((a, b) => a > b ? a : b);
    }

    return {
      'total': prayers.length,
      'active': activePrayers.length,
      'answered': answeredPrayers.length,
      'oldestActiveDays': oldestActivePrayer,
    };
  }

  /// Get localized error message
  String getLocalizedErrorMessage(String key) {
    try {
      return LocalizationService.instance.translate(key);
    } catch (e) {
      // Fallback to English if localization fails
      switch (key) {
        case 'errors.prayer_loading_error':
          return 'Error loading prayers';
        case 'errors.prayer_empty_text':
          return 'Prayer text cannot be empty';
        case 'errors.prayer_add_error':
          return 'Error adding prayer';
        case 'errors.prayer_edit_error':
          return 'Error editing prayer';
        case 'errors.prayer_delete_error':
          return 'Error deleting prayer';
        default:
          return 'An error occurred';
      }
    }
  }
}
