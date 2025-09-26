import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devocional_nuevo/controllers/audio_controller.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/providers/localization_provider.dart';

/// Provider for LocalizationProvider - Legacy ChangeNotifier (to be migrated)
final localizationProvider = ChangeNotifierProvider<LocalizationProvider>((ref) {
  return LocalizationProvider();
});

/// Provider for DevocionalProvider - Legacy ChangeNotifier (to be migrated)  
final devocionalProvider = ChangeNotifierProvider<DevocionalProvider>((ref) {
  return DevocionalProvider();
});

/// Provider for AudioController - Legacy ChangeNotifier (to be migrated)
final audioControllerProvider = ChangeNotifierProvider<AudioController>((ref) {
  return AudioController();
});

// ✅ MIGRATED TO RIVERPOD:
// - BackupBloc → BackupNotifier in backup/backup_providers.dart
// - OnboardingBloc → OnboardingNotifier in onboarding/onboarding_providers.dart
// - ThemeProvider → ThemeNotifier in theme/theme_providers.dart
// - DevocionalesBloc → DevocionalesNotifier in devocionales/devocionales_providers.dart
// - PrayerBloc → PrayersNotifier in prayers/prayers_providers.dart

// 🔄 PENDING MIGRATION (Future iterations):
// - LocalizationProvider → To be migrated to StateNotifier
// - DevocionalProvider → To be migrated to StateNotifier
// - AudioController → To be migrated to StateNotifier