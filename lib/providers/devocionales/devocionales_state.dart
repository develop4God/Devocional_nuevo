import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:devocional_nuevo/models/devocional_model.dart';

part 'devocionales_state.freezed.dart';

/// Riverpod state for devocionales management with Freezed immutable states
@freezed
class DevocionalesRiverpodState with _$DevocionalesRiverpodState {
  /// Initial state when the notifier is created
  const factory DevocionalesRiverpodState.initial() = DevocionalesStateInitial;

  /// State when devocionales are being loaded
  const factory DevocionalesRiverpodState.loading() = DevocionalesStateLoading;

  /// State when devocionales are successfully loaded
  const factory DevocionalesRiverpodState.loaded({
    required List<Devocional> devocionales,
    required String selectedVersion,
  }) = DevocionalesStateLoaded;

  /// State when there's an error loading devocionales
  const factory DevocionalesRiverpodState.error({
    required String message,
  }) = DevocionalesStateError;
}

/// Extension to add convenience getters to the state
extension DevocionalesRiverpodStateX on DevocionalesRiverpodState {
  /// Get filtered devocionales for the current version (only when loaded)
  List<Devocional> get filteredDevocionales {
    return whenOrNull(
          loaded: (devocionales, selectedVersion) => devocionales
              .where((d) => (d.version ?? 'RVR1960') == selectedVersion)
              .toList(),
        ) ??
        [];
  }

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
  String? get errorMessage => whenOrNull(
        error: (message) => message,
      );

  /// Get current selected version (default to 'RVR1960' if not loaded)
  String get currentVersion => when(
        initial: () => 'RVR1960',
        loading: () => 'RVR1960',
        loaded: (_, selectedVersion) => selectedVersion,
        error: (_) => 'RVR1960',
      );
}
