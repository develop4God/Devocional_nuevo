import 'package:devocional_nuevo/services/update_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:mockito/mockito.dart';

class MockInAppUpdate extends Mock implements InAppUpdate {}

void main() {
  group('UpdateService', () {
    late MockInAppUpdate mockInAppUpdate;

    setUp(() {
      mockInAppUpdate = MockInAppUpdate();
    });

    test('User checks for update and update is available (flexible)',
        () async {
      // Given
      final updateInfo = AppUpdateInfo(
        updateAvailability: UpdateAvailability.updateAvailable,
        immediateUpdateAllowed: false,
        flexibleUpdateAllowed: true,
        availableVersionCode: 2,
        updatePriority: 1,
        clientVersionStalenessDays: 0,
      );
      when(mockInAppUpdate.checkForUpdate())
          .thenAnswer((_) async => updateInfo);
      // When
      await UpdateService.checkForUpdate();

      // Then
      verify(mockInAppUpdate.checkForUpdate()).called(1);
    });

    test('User checks for update and no update is available', () async {
      // Given
      final updateInfo = AppUpdateInfo(
        updateAvailability: UpdateAvailability.updateNotAvailable,
        immediateUpdateAllowed: false,
        flexibleUpdateAllowed: false,
        availableVersionCode: 1,
        updatePriority: 0,
        clientVersionStalenessDays: 0,
      );
      when(mockInAppUpdate.checkForUpdate())
          .thenAnswer((_) async => updateInfo);

      // When
      await UpdateService.checkForUpdate();

      // Then
      verify(mockInAppUpdate.checkForUpdate()).called(1);
    });

    test('User initiates flexible update and update completes successfully',
        () async {
      // Given
      when(mockInAppUpdate.startFlexibleUpdate()).thenAnswer((_) async {});
      when(mockInAppUpdate.completeFlexibleUpdate()).thenAnswer((_) async {});

      // When
      await UpdateService.performFlexibleUpdate();

      // Then
      verify(mockInAppUpdate.startFlexibleUpdate()).called(1);
      verify(mockInAppUpdate.completeFlexibleUpdate()).called(1);
    });

    test('User checks for update info and receives update details', () async {
      // Given
      final updateInfo = AppUpdateInfo(
        updateAvailability: UpdateAvailability.updateAvailable,
        immediateUpdateAllowed: false,
        flexibleUpdateAllowed: true,
        availableVersionCode: 2,
        updatePriority: 1,
        clientVersionStalenessDays: 0,
      );
      when(mockInAppUpdate.checkForUpdate())
          .thenAnswer((_) async => updateInfo);

      // When
      final result = await UpdateService.getUpdateInfo();

      // Then
      expect(result['updateAvailable'], true);
      verify(mockInAppUpdate.checkForUpdate()).called(1);
    });
  });
}