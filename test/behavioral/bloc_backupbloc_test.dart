import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devocional_nuevo/blocs/backup_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGoogleDriveBackupService extends Mock implements GoogleDriveBackupService {}

void main() {
  late BackupBloc backupBloc;
  late MockGoogleDriveBackupService mockGoogleDriveBackupService;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    mockGoogleDriveBackupService = MockGoogleDriveBackupService();
    backupBloc = BackupBloc(googleDriveBackupService: mockGoogleDriveBackupService);
  });

  tearDown(() {
    backupBloc.close();
  });

  test('initial state is correct', () {
    expect(backupBloc.state, isA<BackupInitial>());
  });

  blocTest<BackupBloc, BackupState>(
    'user scenario: Backup initiated successfully',
    build: () {
      when(() => mockGoogleDriveBackupService.backupData()).thenAnswer((_) async => true);
      return backupBloc;
    },
    act: (bloc) => bloc.add(BackupInitiated()),
    expect: () => [
      isA<BackupLoading>(),
      isA<BackupSuccess>(),
    ],
    verify: (bloc) {
      verify(() => mockGoogleDriveBackupService.backupData()).called(1);
    },
  );

  blocTest<BackupBloc, BackupState>(
    'user scenario: Restore initiated successfully',
    build: () {
      when(() => mockGoogleDriveBackupService.restoreData()).thenAnswer((_) async => true);
      return backupBloc;
    },
    act: (bloc) => bloc.add(RestoreInitiated()),
    expect: () => [
      isA<BackupLoading>(),
      isA<RestoreSuccess>(),
    ],
    verify: (bloc) {
      verify(() => mockGoogleDriveBackupService.restoreData()).called(1);
    },
  );

  blocTest<BackupBloc, BackupState>(
    'user scenario: Backup fails',
    build: () {
      when(() => mockGoogleDriveBackupService.backupData()).thenThrow(Exception('Backup failed'));
      return backupBloc;
    },
    act: (bloc) => bloc.add(BackupInitiated()),
    expect: () => [
      isA<BackupLoading>(),
      isA<BackupFailure>(),
    ],
    verify: (bloc) {
      final state = bloc.state;
      expect(state, isA<BackupFailure>());
      expect((state as BackupFailure).error, 'Exception: Backup failed');
      verify(() => mockGoogleDriveBackupService.backupData()).called(1);
    },
  );

  blocTest<BackupBloc, BackupState>(
    'user scenario: Restore fails',
    build: () {
      when(() => mockGoogleDriveBackupService.restoreData()).thenThrow(Exception('Restore failed'));
      return backupBloc;
    },
    act: (bloc) => bloc.add(RestoreInitiated()),
    expect: () => [
      isA<BackupLoading>(),
      isA<RestoreFailure>(),
    ],
    verify: (bloc) {
      final state = bloc.state;
      expect(state, isA<RestoreFailure>());
      expect((state as RestoreFailure).error, 'Exception: Restore failed');
      verify(() => mockGoogleDriveBackupService.restoreData()).called(1);
    },
  );

  blocTest<BackupBloc, BackupState>(
    'user scenario: Backup already in progress',
    build: () => backupBloc,
    act: (bloc) {
      bloc.emit(BackupLoading());
      bloc.add(BackupInitiated());
    },
    expect: () => [],
  );

  blocTest<BackupBloc, BackupState>(
    'user scenario: Restore already in progress',
    build: () => backupBloc,
    act: (bloc) {
      bloc.emit(BackupLoading());
      bloc.add(RestoreInitiated());
    },
    expect: () => [],
  );
}