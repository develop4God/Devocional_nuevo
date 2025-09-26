import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devocional_nuevo/models/prayer_model.dart';
import 'prayers_repository.dart';
import 'prayers_notifier.dart';
import 'prayers_state.dart';

/// Repository provider for prayers data persistence
final prayersRepositoryProvider = Provider<PrayersRepository>((ref) {
  return PrayersRepository();
});

/// Main StateNotifier provider for prayers management
final prayersProvider =
    StateNotifierProvider<PrayersNotifier, PrayersRiverpodState>((ref) {
  return PrayersNotifier(ref.watch(prayersRepositoryProvider));
});

/// Convenience provider to get all prayers
final allPrayersProvider = Provider<List<Prayer>>((ref) {
  final state = ref.watch(prayersProvider);
  return state.allPrayers;
});

/// Convenience provider to get active prayers
final activePrayersProvider = Provider<List<Prayer>>((ref) {
  final state = ref.watch(prayersProvider);
  return state.activePrayers;
});

/// Convenience provider to get answered prayers
final answeredPrayersProvider = Provider<List<Prayer>>((ref) {
  final state = ref.watch(prayersProvider);
  return state.answeredPrayers;
});

/// Convenience provider to get total prayers count
final totalPrayersCountProvider = Provider<int>((ref) {
  final state = ref.watch(prayersProvider);
  return state.totalPrayers;
});

/// Convenience provider to get active prayers count
final activePrayersCountProvider = Provider<int>((ref) {
  final state = ref.watch(prayersProvider);
  return state.activePrayersCount;
});

/// Convenience provider to get answered prayers count
final answeredPrayersCountProvider = Provider<int>((ref) {
  final state = ref.watch(prayersProvider);
  return state.answeredPrayersCount;
});

/// Convenience provider to check if prayers are loading
final prayersLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(prayersProvider);
  return state.isLoading;
});

/// Convenience provider to check if prayers are loaded
final prayersLoadedProvider = Provider<bool>((ref) {
  final state = ref.watch(prayersProvider);
  return state.isLoaded;
});

/// Convenience provider to check if there's an error
final prayersHasErrorProvider = Provider<bool>((ref) {
  final state = ref.watch(prayersProvider);
  return state.hasError;
});

/// Convenience provider to get error message
final prayersErrorMessageProvider = Provider<String?>((ref) {
  final state = ref.watch(prayersProvider);
  return state.errorMessage;
});

/// Convenience provider to get prayers statistics
final prayersStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(prayersProvider);
  return state.statistics;
});

/// Convenience provider to get prayer by ID
final prayerByIdProvider = Provider.family<Prayer?, String>((ref, prayerId) {
  final notifier = ref.watch(prayersProvider.notifier);
  return notifier.getPrayerById(prayerId);
});

/// Convenience provider to get prayers by status
final prayersByStatusProvider =
    Provider.family<List<Prayer>, PrayerStatus>((ref, status) {
  final notifier = ref.watch(prayersProvider.notifier);
  return notifier.getPrayersByStatus(status);
});

/// Convenience provider to get prayers in date range
final prayersInDateRangeProvider =
    Provider.family<List<Prayer>, DateRange>((ref, dateRange) {
  final notifier = ref.watch(prayersProvider.notifier);
  return notifier.getPrayersInDateRange(dateRange.startDate, dateRange.endDate);
});

/// Convenience provider to get loaded state data (null if not loaded)
final prayersLoadedDataProvider = Provider<PrayersStateLoaded?>((ref) {
  final state = ref.watch(prayersProvider);
  return state.whenOrNull(
    loaded: (prayers, errorMessage) => PrayersStateLoaded(
      prayers: prayers,
      errorMessage: errorMessage,
    ),
  );
});

/// Helper class for date range queries
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  const DateRange(this.startDate, this.endDate);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}
