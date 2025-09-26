import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devocional_nuevo/models/devocional_model.dart';
import 'devocionales_repository.dart';
import 'devocionales_notifier.dart';
import 'devocionales_state.dart';

/// Repository provider for devocionales data persistence
final devocionalesRepositoryProvider = Provider<DevocionalesRepository>((ref) {
  return DevocionalesRepository();
});

/// Main StateNotifier provider for devocionales management
final devocionalesProvider =
    StateNotifierProvider<DevocionalesNotifier, DevocionalesRiverpodState>(
        (ref) {
  return DevocionalesNotifier(ref.watch(devocionalesRepositoryProvider));
});

/// Convenience provider to get filtered devocionales for current version
final filteredDevocionalesProvider = Provider<List<Devocional>>((ref) {
  final state = ref.watch(devocionalesProvider);
  return state.filteredDevocionales;
});

/// Convenience provider to get current selected version
final currentVersionProvider = Provider<String>((ref) {
  final state = ref.watch(devocionalesProvider);
  return state.currentVersion;
});

/// Convenience provider to check if devocionales are loading
final devocionalesLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(devocionalesProvider);
  return state.isLoading;
});

/// Convenience provider to check if devocionales are loaded
final devocionalesLoadedProvider = Provider<bool>((ref) {
  final state = ref.watch(devocionalesProvider);
  return state.isLoaded;
});

/// Convenience provider to check if there's an error
final devocionalesHasErrorProvider = Provider<bool>((ref) {
  final state = ref.watch(devocionalesProvider);
  return state.hasError;
});

/// Convenience provider to get error message
final devocionalesErrorMessageProvider = Provider<String?>((ref) {
  final state = ref.watch(devocionalesProvider);
  return state.errorMessage;
});

/// Convenience provider to get available versions
final availableVersionsProvider = Provider<List<String>>((ref) {
  final notifier = ref.watch(devocionalesProvider.notifier);
  return notifier.getAvailableVersions();
});

/// Convenience provider to get favorite devocionales
final favoriteDeVocionalesProvider = Provider<List<Devocional>>((ref) {
  final notifier = ref.watch(devocionalesProvider.notifier);
  return notifier.getFavoriteDevocionales();
});

/// Convenience provider to check if a devocional is favorite
final isFavoriteProvider = Provider.family<bool, String>((ref, devocionalId) {
  final notifier = ref.watch(devocionalesProvider.notifier);
  return notifier.isFavorite(devocionalId);
});

/// Convenience provider to get devocionales statistics
final devocionalesStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.watch(devocionalesProvider.notifier);
  return notifier.getStatistics();
});

/// Convenience provider to get devocionales for specific version
final devocionalesForVersionProvider =
    Provider.family<List<Devocional>, String?>((ref, version) {
  final notifier = ref.watch(devocionalesProvider.notifier);
  return notifier.getDevocionales(version: version);
});

/// Convenience provider to get loaded state data (null if not loaded)
final devocionalesLoadedDataProvider =
    Provider<DevocionalesStateLoaded?>((ref) {
  final state = ref.watch(devocionalesProvider);
  return state.whenOrNull(
    loaded: (devocionales, selectedVersion) => DevocionalesStateLoaded(
      devocionales: devocionales,
      selectedVersion: selectedVersion,
    ),
  );
});
