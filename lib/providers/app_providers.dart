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

// Note: BackupBloc migrated to BackupNotifier in backup/backup_providers.dart
// Note: OnboardingBloc migrated to OnboardingNotifier in onboarding/onboarding_providers.dart
// Note: ThemeProvider migrated to ThemeNotifier in theme/theme_providers.dart
// Note: PrayerBloc to be migrated to PrayerNotifier in future iteration