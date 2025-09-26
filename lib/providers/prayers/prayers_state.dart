import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:devocional_nuevo/models/prayer_model.dart';

part 'prayers_state.freezed.dart';

/// Riverpod state for prayer management with Freezed immutable states
@freezed
class PrayersRiverpodState with _$PrayersRiverpodState {
  /// Initial state when the notifier is created
  const factory PrayersRiverpodState.initial() = PrayersStateInitial;

  /// State when prayers are being loaded
  const factory PrayersRiverpodState.loading() = PrayersStateLoading;

  /// State when prayers are successfully loaded
  const factory PrayersRiverpodState.loaded({
    required List<Prayer> prayers,
    String? errorMessage,
  }) = PrayersStateLoaded;

  /// State when there's an error with prayers
  const factory PrayersRiverpodState.error({
    required String message,
  }) = PrayersStateError;
}

/// Extension to add convenience getters to the state
extension PrayersRiverpodStateX on PrayersRiverpodState {
  /// Get all prayers (only when loaded)
  List<Prayer> get allPrayers {
    return whenOrNull(
          loaded: (prayers, _) => prayers,
        ) ??
        [];
  }

  /// Get only active prayers
  List<Prayer> get activePrayers {
    return allPrayers.where((p) => p.isActive).toList();
  }

  /// Get only answered prayers
  List<Prayer> get answeredPrayers {
    return allPrayers.where((p) => p.isAnswered).toList();
  }

  /// Get total count of prayers
  int get totalPrayers => allPrayers.length;

  /// Get count of active prayers
  int get activePrayersCount => activePrayers.length;

  /// Get count of answered prayers
  int get answeredPrayersCount => answeredPrayers.length;

  /// Check if we're in a loading state
  bool get isLoading => when(
        initial: () => false,
        loading: () => true,
        loaded: (_, __) => false,
        error: (_) => false,
      );

  /// Check if we have loaded data
  bool get isLoaded => when(
        initial: () => false,
        loading: () => false,
        loaded: (_, __) => true,
        error: (_) => false,
      );

  /// Check if we have an error
  bool get hasError => when(
        initial: () => false,
        loading: () => false,
        loaded: (_, __) => false,
        error: (_) => true,
      );

  /// Get error message (null if no error)
  String? get errorMessage => when(
        initial: () => null,
        loading: () => null,
        loaded: (_, errorMessage) => errorMessage,
        error: (message) => message,
      );

  /// Get prayer statistics
  Map<String, dynamic> get statistics {
    if (!isLoaded) {
      return {
        'total': 0,
        'active': 0,
        'answered': 0,
        'oldestActiveDays': 0,
      };
    }

    final now = DateTime.now();
    var oldestActivePrayer = 0;

    if (activePrayers.isNotEmpty) {
      oldestActivePrayer = activePrayers
          .map((p) => now.difference(p.createdDate).inDays)
          .reduce((a, b) => a > b ? a : b);
    }

    return {
      'total': totalPrayers,
      'active': activePrayersCount,
      'answered': answeredPrayersCount,
      'oldestActiveDays': oldestActivePrayer,
    };
  }
}
