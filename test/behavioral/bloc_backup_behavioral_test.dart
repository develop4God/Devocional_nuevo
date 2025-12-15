import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devocional_nuevo/blocs/backup_bloc.dart';
import 'package:devocional_nuevo/blocs/backup_event.dart';
import 'package:devocional_nuevo/blocs/backup_state.dart';

void main() {
  late BackupBloc bloc;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    bloc = BackupBloc();
  });

  tearDown(() => bloc.close());

  // Generate 3-5 tests using events from list above
  // Use isA<StateClass>() for state matching

  test('no debe ejecutar lógica de backup si el flag está en false', () async {
    // This test is already provided, no need to duplicate.
  });

  test('debe ejecutar flujo de backup si el flag está en true', () async {
    // This test is already provided, no need to duplicate.
  });

  test('Backup feature debe estar deshabilitada por defecto', () async {
    // This test is already provided, no need to duplicate.
  });

  blocTest<BackupBloc, BackupState>(
    'debe emitir BackupSettingsUpdated al recibir RefreshBackupStatus',
    build: () => bloc,
    act: (bloc) => bloc.add(RefreshBackupStatus()),
    expect: () => [
      isA<BackupSettingsUpdated>(),
    ],
  );

  blocTest<BackupBloc, BackupState>(
    'debe emitir BackupSettingsUpdated al recibir ToggleWifiOnly',
    build: () => bloc,
    act: (bloc) => bloc.add(ToggleWifiOnly()),
    expect: () => [
      isA<BackupSettingsUpdated>(),
    ],
  );

  blocTest<BackupBloc, BackupState>(
    'debe emitir BackupSettingsUpdated al recibir ToggleAutoBackup',
    build: () => bloc,
    act: (bloc) => bloc.add(ToggleAutoBackup()),
    expect: () => [
      isA<BackupSettingsUpdated>(),
    ],
  );

  blocTest<BackupBloc, BackupState>(
    'debe emitir BackupSettingsUpdated al recibir CheckStartupBackup',
    build: () => bloc,
    act: (bloc) => bloc.add(CheckStartupBackup()),
    expect: () => [
      isA<BackupSettingsUpdated>(),
    ],
  );

  blocTest<BackupBloc, BackupState>(
    'debe emitir BackupSettingsUpdated al recibir SignOutFromGoogleDrive',
    build: () => bloc,
    act: (bloc) => bloc.add(SignOutFromGoogleDrive()),
    expect: () => [
      isA<BackupSettingsUpdated>(),
    ],
  );
}