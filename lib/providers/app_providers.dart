import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devocional_nuevo/blocs/prayer_bloc.dart';
import 'package:devocional_nuevo/controllers/audio_controller.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/providers/localization_provider.dart';

/// Provider for LocalizationProvider
final localizationProvider = ChangeNotifierProvider<LocalizationProvider>((ref) {
  return LocalizationProvider();
});

/// Provider for DevocionalProvider
final devocionalProvider = ChangeNotifierProvider<DevocionalProvider>((ref) {
  return DevocionalProvider();
});

/// Provider for AudioController
final audioControllerProvider = ChangeNotifierProvider<AudioController>((ref) {
  return AudioController();
});

/// Provider for PrayerBloc
final prayerBlocProvider = Provider<PrayerBloc>((ref) {
  return PrayerBloc();
});

// Note: BackupBloc replaced with BackupNotifier in backup/backup_providers.dart