import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'prayers_state.dart';
import 'prayers_repository.dart';
import 'package:devocional_nuevo/models/prayer_model.dart';

/// Riverpod StateNotifier for prayer management
/// Replaces the BLoC pattern with cleaner, more maintainable code
class PrayersNotifier extends StateNotifier<PrayersRiverpodState> {
  final PrayersRepository _repository;

  PrayersNotifier(this._repository)
      : super(const PrayersRiverpodState.initial()) {
    // Initialize by loading prayers
    _initialize();
  }

  /// Initialize the notifier by loading data from repository
  Future<void> _initialize() async {
    await loadPrayers();
  }

  /// Load all prayers from storage
  Future<void> loadPrayers() async {
    state = const PrayersRiverpodState.loading();

    try {
      final prayers = await _repository.loadPrayers();
      _repository.sortPrayers(prayers);

      debugPrint('Loaded ${prayers.length} prayers');

      state = PrayersRiverpodState.loaded(prayers: prayers);
    } catch (e) {
      final errorMessage =
          _repository.getLocalizedErrorMessage('errors.prayer_loading_error');
      debugPrint('Error loading prayers: $e');
      state = PrayersRiverpodState.error(message: errorMessage);
    }
  }

  /// Add a new prayer
  Future<void> addPrayer(String text) async {
    if (text.trim().isEmpty) {
      final currentState = state;
      if (currentState is PrayersStateLoaded) {
        state = PrayersRiverpodState.loaded(
          prayers: currentState.prayers,
          errorMessage:
              _repository.getLocalizedErrorMessage('errors.prayer_empty_text'),
        );
      }
      return;
    }

    try {
      final currentState = state;
      List<Prayer> currentPrayers = [];

      if (currentState is PrayersStateLoaded) {
        currentPrayers = currentState.prayers;
      }

      final newPrayer = await _repository.addPrayer(text);
      final updatedPrayers = [...currentPrayers, newPrayer];
      _repository.sortPrayers(updatedPrayers);

      state = PrayersRiverpodState.loaded(prayers: updatedPrayers);
      debugPrint('Added prayer: ${newPrayer.id}');
    } catch (e) {
      final currentState = state;
      if (currentState is PrayersStateLoaded) {
        state = PrayersRiverpodState.loaded(
          prayers: currentState.prayers,
          errorMessage:
              '${_repository.getLocalizedErrorMessage("errors.prayer_add_error")}: $e',
        );
      }
      debugPrint('Error adding prayer: $e');
    }
  }

  /// Edit an existing prayer
  Future<void> editPrayer(String prayerId, String newText) async {
    if (newText.trim().isEmpty) {
      final currentState = state;
      if (currentState is PrayersStateLoaded) {
        state = PrayersRiverpodState.loaded(
          prayers: currentState.prayers,
          errorMessage:
              _repository.getLocalizedErrorMessage('errors.prayer_empty_text'),
        );
      }
      return;
    }

    try {
      final currentState = state;
      if (currentState is! PrayersStateLoaded) return;

      final updatedPrayer = await _repository.editPrayer(prayerId, newText);
      if (updatedPrayer == null) {
        state = PrayersRiverpodState.loaded(
          prayers: currentState.prayers,
          errorMessage: 'Prayer not found',
        );
        return;
      }

      final updatedPrayers = currentState.prayers.map((p) {
        return p.id == prayerId ? updatedPrayer : p;
      }).toList();

      state = PrayersRiverpodState.loaded(prayers: updatedPrayers);
      debugPrint('Edited prayer: $prayerId');
    } catch (e) {
      final currentState = state;
      if (currentState is PrayersStateLoaded) {
        state = PrayersRiverpodState.loaded(
          prayers: currentState.prayers,
          errorMessage:
              '${_repository.getLocalizedErrorMessage("errors.prayer_edit_error")}: $e',
        );
      }
      debugPrint('Error editing prayer: $e');
    }
  }

  /// Delete a prayer
  Future<void> deletePrayer(String prayerId) async {
    try {
      final currentState = state;
      if (currentState is! PrayersStateLoaded) return;

      final success = await _repository.deletePrayer(prayerId);
      if (!success) {
        state = PrayersRiverpodState.loaded(
          prayers: currentState.prayers,
          errorMessage: 'Prayer not found',
        );
        return;
      }

      final updatedPrayers =
          currentState.prayers.where((p) => p.id != prayerId).toList();

      state = PrayersRiverpodState.loaded(prayers: updatedPrayers);
      debugPrint('Deleted prayer: $prayerId');
    } catch (e) {
      final currentState = state;
      if (currentState is PrayersStateLoaded) {
        state = PrayersRiverpodState.loaded(
          prayers: currentState.prayers,
          errorMessage:
              '${_repository.getLocalizedErrorMessage("errors.prayer_delete_error")}: $e',
        );
      }
      debugPrint('Error deleting prayer: $e');
    }
  }

  /// Mark a prayer as answered
  Future<void> markPrayerAsAnswered(String prayerId) async {
    try {
      final currentState = state;
      if (currentState is! PrayersStateLoaded) return;

      final updatedPrayer = await _repository.markPrayerAsAnswered(prayerId);
      if (updatedPrayer == null) {
        state = PrayersRiverpodState.loaded(
          prayers: currentState.prayers,
          errorMessage: 'Prayer not found',
        );
        return;
      }

      final updatedPrayers = currentState.prayers.map((p) {
        return p.id == prayerId ? updatedPrayer : p;
      }).toList();

      _repository.sortPrayers(updatedPrayers);
      state = PrayersRiverpodState.loaded(prayers: updatedPrayers);
      debugPrint('Marked prayer as answered: $prayerId');
    } catch (e) {
      final currentState = state;
      if (currentState is PrayersStateLoaded) {
        state = PrayersRiverpodState.loaded(
          prayers: currentState.prayers,
          errorMessage: 'Error marking prayer as answered: $e',
        );
      }
      debugPrint('Error marking prayer as answered: $e');
    }
  }

  /// Mark a prayer as active (undo answered status)
  Future<void> markPrayerAsActive(String prayerId) async {
    try {
      final currentState = state;
      if (currentState is! PrayersStateLoaded) return;

      final updatedPrayer = await _repository.markPrayerAsActive(prayerId);
      if (updatedPrayer == null) {
        state = PrayersRiverpodState.loaded(
          prayers: currentState.prayers,
          errorMessage: 'Prayer not found',
        );
        return;
      }

      final updatedPrayers = currentState.prayers.map((p) {
        return p.id == prayerId ? updatedPrayer : p;
      }).toList();

      _repository.sortPrayers(updatedPrayers);
      state = PrayersRiverpodState.loaded(prayers: updatedPrayers);
      debugPrint('Marked prayer as active: $prayerId');
    } catch (e) {
      final currentState = state;
      if (currentState is PrayersStateLoaded) {
        state = PrayersRiverpodState.loaded(
          prayers: currentState.prayers,
          errorMessage: 'Error marking prayer as active: $e',
        );
      }
      debugPrint('Error marking prayer as active: $e');
    }
  }

  /// Refresh prayers from repository
  Future<void> refreshPrayers() async {
    debugPrint('Refreshing prayers...');
    await loadPrayers();
  }

  /// Clear error message
  void clearError() {
    final currentState = state;
    if (currentState is PrayersStateLoaded &&
        currentState.errorMessage != null) {
      state = PrayersRiverpodState.loaded(prayers: currentState.prayers);
    } else if (currentState is PrayersStateError) {
      state = const PrayersRiverpodState.initial();
      // Automatically reload after clearing error
      loadPrayers();
    }
  }

  /// Get prayer by ID
  Prayer? getPrayerById(String prayerId) {
    final currentState = state;
    if (currentState is! PrayersStateLoaded) return null;

    try {
      return currentState.prayers.firstWhere((p) => p.id == prayerId);
    } catch (e) {
      return null;
    }
  }

  /// Get filtered prayers by status
  List<Prayer> getPrayersByStatus(PrayerStatus status) {
    final currentState = state;
    if (currentState is! PrayersStateLoaded) return [];

    return currentState.prayers.where((p) => p.status == status).toList();
  }

  /// Get prayers created within a date range
  List<Prayer> getPrayersInDateRange(DateTime startDate, DateTime endDate) {
    final currentState = state;
    if (currentState is! PrayersStateLoaded) return [];

    return currentState.prayers.where((p) {
      return p.createdDate.isAfter(startDate) &&
          p.createdDate.isBefore(endDate);
    }).toList();
  }

  /// Get prayer statistics
  Map<String, dynamic> getStatistics() {
    final currentState = state;
    if (currentState is! PrayersStateLoaded) {
      return {
        'total': 0,
        'active': 0,
        'answered': 0,
        'oldestActiveDays': 0,
      };
    }

    return currentState.statistics;
  }
}
