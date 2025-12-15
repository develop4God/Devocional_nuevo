import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devocional_nuevo/blocs/backup_bloc.dart';

void main() {
  late BackupBloc bloc;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    bloc = BackupBloc();
  });

  tearDown(() => bloc.close());

  test('Initial state should be BackupInitial', () {
    expect(bloc.state, BackupInitial());
  });

  blocTest<BackupBloc, BackupState>(
    'emits [BackupCreating, BackupCreated] when CreateManualBackup is added',
    build: () => bloc,
    act: (bloc) => bloc.add(CreateManualBackup()),
    expect: () => [
      BackupCreating(),
      BackupCreated(),
    ],
  );

  blocTest<BackupBloc, BackupState>(
    'emits [BackupCreating, BackupRestoring] when RestoreFromBackup is added',
    build: () => bloc,
    act: (bloc) => bloc.add(RestoreFromBackup()),
    expect: () => [
      BackupCreating(),
      BackupRestoring(),
    ],
  );

  blocTest<BackupBloc, BackupState>(
    'emits [BackupLoaded] when RefreshBackupStatus is added',
    build: () => bloc,
    act: (bloc) => bloc.add(RefreshBackupStatus()),
    expect: () => [
      BackupLoaded(),
    ],
  );

  blocTest<BackupBloc, BackupState>(
    'emits [BackupCreating, BackupCreated] when SignInToGoogleDrive is added',
    build: () => bloc,
    act: (bloc) => bloc.add(SignInToGoogleDrive()),
    expect: () => [
      BackupCreating(),
      BackupCreated(),
    ],
  );
}