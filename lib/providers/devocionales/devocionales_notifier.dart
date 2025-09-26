import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'devocionales_state.dart';
import 'devocionales_repository.dart';
import 'package:devocional_nuevo/models/devocional_model.dart';

/// Riverpod StateNotifier for devocionales management
/// Replaces the BLoC pattern with cleaner, more maintainable code
class DevocionalesNotifier extends StateNotifier<DevocionalesRiverpodState> {
  final DevocionalesRepository _repository;
  Set<String> _favorites = {};

  DevocionalesNotifier(this._repository)
      : super(const DevocionalesRiverpodState.initial()) {
    // Initialize by loading devocionales
    _initialize();
  }

  /// Initialize the notifier by loading data from repository
  Future<void> _initialize() async {
    await loadDevocionales();
  }

  /// Load all devocionales and set up initial state
  Future<void> loadDevocionales() async {
    state = const DevocionalesRiverpodState.loading();

    try {
      // Load devocionales, version, and favorites concurrently
      final futures = await Future.wait([
        _repository.loadDevocionales(),
        _repository.loadSelectedVersion(),
        _repository.loadFavorites(),
      ]);

      final devocionales = futures[0] as List<Devocional>;
      final selectedVersion = futures[1] as String;
      _favorites = futures[2] as Set<String>;

      debugPrint(
          'Loaded ${devocionales.length} devocionales, version: $selectedVersion');

      state = DevocionalesRiverpodState.loaded(
        devocionales: devocionales,
        selectedVersion: selectedVersion,
      );
    } catch (e) {
      final errorMessage = 'Error loading devocionales: $e';
      debugPrint(errorMessage);
      state = DevocionalesRiverpodState.error(message: errorMessage);
    }
  }

  /// Change the selected Bible version
  Future<void> changeVersion(String version) async {
    final currentState = state;
    if (currentState is! DevocionalesStateLoaded) {
      debugPrint('Cannot change version: state is not loaded');
      return;
    }

    try {
      await _repository.saveSelectedVersion(version);

      state = DevocionalesRiverpodState.loaded(
        devocionales: currentState.devocionales,
        selectedVersion: version,
      );

      debugPrint('Changed version to: $version');
    } catch (e) {
      final errorMessage = 'Error changing version: $e';
      debugPrint(errorMessage);
      state = DevocionalesRiverpodState.error(message: errorMessage);
    }
  }

  /// Toggle favorite status for a devocional
  Future<void> toggleFavorite(String devocionalId) async {
    try {
      _favorites = await _repository.toggleFavorite(devocionalId);
      debugPrint('Toggled favorite for devocional: $devocionalId');

      // Trigger UI update by re-emitting current state
      // This ensures any UI listening for favorite changes gets notified
      final currentState = state;
      if (currentState is DevocionalesStateLoaded) {
        state = DevocionalesRiverpodState.loaded(
          devocionales: currentState.devocionales,
          selectedVersion: currentState.selectedVersion,
        );
      }
    } catch (e) {
      final errorMessage = 'Error toggling favorite: $e';
      debugPrint(errorMessage);
      state = DevocionalesRiverpodState.error(message: errorMessage);
    }
  }

  /// Check if a devocional is marked as favorite
  bool isFavorite(String devocionalId) {
    return _favorites.contains(devocionalId);
  }

  /// Get favorite devocionales for current version
  List<Devocional> getFavoriteDevocionales() {
    final currentState = state;
    if (currentState is! DevocionalesStateLoaded) {
      return [];
    }

    return currentState.devocionales
        .where((d) =>
            _favorites.contains(d.id) &&
            d.version == currentState.selectedVersion)
        .toList();
  }

  /// Refresh devocionales from repository
  Future<void> refreshDevocionales() async {
    debugPrint('Refreshing devocionales...');
    await loadDevocionales();
  }

  /// Get available versions from loaded devocionales
  List<String> getAvailableVersions() {
    final currentState = state;
    if (currentState is! DevocionalesStateLoaded) {
      return ['RVR1960'];
    }

    final versions = currentState.devocionales
        .map((d) => d.version ?? 'RVR1960')
        .toSet()
        .toList()
      ..sort();

    // Ensure RVR1960 is always first if it exists
    if (versions.contains('RVR1960')) {
      versions.remove('RVR1960');
      versions.insert(0, 'RVR1960');
    }

    return versions;
  }

  /// Get devocionales for a specific version
  List<Devocional> getDevocionales({String? version}) {
    final currentState = state;
    if (currentState is! DevocionalesStateLoaded) {
      return [];
    }

    final targetVersion = version ?? currentState.selectedVersion;
    return currentState.devocionales
        .where((d) => (d.version ?? 'RVR1960') == targetVersion)
        .toList();
  }

  /// Get statistics about devocionales
  Map<String, dynamic> getStatistics() {
    final currentState = state;
    if (currentState is! DevocionalesStateLoaded) {
      return {
        'total': 0,
        'currentVersion': 0,
        'favorites': 0,
        'versions': 0,
      };
    }

    final currentVersionDevocionales = getDevocionales();
    final favoriteCount = getFavoriteDevocionales().length;
    final versionCount = getAvailableVersions().length;

    return {
      'total': currentState.devocionales.length,
      'currentVersion': currentVersionDevocionales.length,
      'favorites': favoriteCount,
      'versions': versionCount,
    };
  }

  /// Clear error state
  void clearError() {
    final currentState = state;
    if (currentState is DevocionalesStateError) {
      state = const DevocionalesRiverpodState.initial();
      // Automatically reload after clearing error
      loadDevocionales();
    }
  }
}
