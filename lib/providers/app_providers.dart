import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devocional_nuevo/blocs/backup_bloc.dart';
import 'package:devocional_nuevo/blocs/backup_event.dart';
import 'package:devocional_nuevo/blocs/prayer_bloc.dart';
import 'package:devocional_nuevo/controllers/audio_controller.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/providers/localization_provider.dart';
import 'package:devocional_nuevo/services/google_drive_auth_service.dart';
import 'package:devocional_nuevo/services/google_drive_backup_service.dart';
import 'package:devocional_nuevo/services/connectivity_service.dart';
import 'package:devocional_nuevo/services/spiritual_stats_service.dart';

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

/// Provider for BackupBloc
final backupBlocProvider = Provider<BackupBloc>((ref) {
  final devocionalProviderInstance = ref.read(devocionalProvider);
  return BackupBloc(
    backupService: GoogleDriveBackupService(
      authService: GoogleDriveAuthService(),
      connectivityService: ConnectivityService(),
      statsService: SpiritualStatsService(),
    ),
    schedulerService: null, // ✅ El BLoC maneja null correctamente
    devocionalProvider: devocionalProviderInstance,
  );
});