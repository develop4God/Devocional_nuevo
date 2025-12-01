import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:your_app/services/update_service.dart'; // Replace with your app's import

@GenerateMocks([InAppUpdate])
import 'update_service_test.mocks.dart'; // Replace with your app's import

void main() {
  group('UpdateService', () {
    late MockInAppUpdate mockInAppUpdate;

    setUp(() {
      mockInAppUpdate = MockInAppUpdate();
    });

    group('checkForUpdate', () {
      test('should perform immediate update when available and allowed',
          () async {
        when(mockInAppUpdate.checkForUpdate())
            .thenAnswer((_) async => AppUpdateInfo(
                  updateAvailability: UpdateAvailability.updateAvailable,
                  immediateUpdateAllowed: true,
                  flexibleUpdateAllowed: false,
                  availableVersionCode: 2,
                  updatePriority: 1,
                  clientVersionStalenessDays: 0,
                ));
        when(mockInAppUpdate.performImmediateUpdate()).thenAnswer((_) async {});

        await UpdateService.checkForUpdate();

        verify(mockInAppUpdate.performImmediateUpdate()).called(1);
      });

      test('should perform flexible update when available and allowed',
          () async {
        when(mockInAppUpdate.checkForUpdate()).thenAnswer((_) async =>
            AppUpdateInfo(
                updateAvailability: UpdateAvailability.updateAvailable,
                immediateUpdateAllowed: false,
                flexibleUpdateAllowed: true,
                availableVersionCode: 2,
                updatePriority: 1,
                clientVersionStalenessDays: 0));
        when(mockInAppUpdate.startFlexibleUpdate()).thenAnswer((_) async {});
        when(mockInAppUpdate.completeFlexibleUpdate()).thenAnswer((_) async {});

        await UpdateService.checkForUpdate();

        verify(mockInAppUpdate.startFlexibleUpdate()).called(1);
        verify(mockInAppUpdate.completeFlexibleUpdate()).called(1);
      });

      test('should not perform update when no update is available', () async {
        when(mockInAppUpdate.checkForUpdate()).thenAnswer((_) async =>
            AppUpdateInfo(
                updateAvailability: UpdateAvailability.updateNotAvailable,
                immediateUpdateAllowed: false,
                flexibleUpdateAllowed: false,
                availableVersionCode: 1,
                updatePriority: 0,
                clientVersionStalenessDays: 0));

        await UpdateService.checkForUpdate();

        verifyNever(mockInAppUpdate.performImmediateUpdate());
        verifyNever(mockInAppUpdate.startFlexibleUpdate());
        verifyNever(mockInAppUpdate.completeFlexibleUpdate());
      });

      test('should handle errors during update check', () async {
        when(mockInAppUpdate.checkForUpdate())
            .thenThrow(Exception('Simulated error'));

        await UpdateService.checkForUpdate();

        // No specific verification needed as the error is handled internally
      });
    });

    group('performImmediateUpdate', () {
      test('should call performImmediateUpdate', () async {
        when(mockInAppUpdate.performImmediateUpdate()).thenAnswer((_) async {});

        await UpdateService.performImmediateUpdate();

        verify(mockInAppUpdate.performImmediateUpdate()).called(1);
      });

      test('should handle errors during immediate update', () async {
        when(mockInAppUpdate.performImmediateUpdate())
            .thenThrow(Exception('Simulated error'));

        await UpdateService.performImmediateUpdate();

        // No specific verification needed as the error is handled internally
      });
    });

    group('performFlexibleUpdate', () {
      test('should start and complete flexible update', () async {
        when(mockInAppUpdate.startFlexibleUpdate()).thenAnswer((_) async {});
        when(mockInAppUpdate.completeFlexibleUpdate()).thenAnswer((_) async {});

        await UpdateService.performFlexibleUpdate();

        verify(mockInAppUpdate.startFlexibleUpdate()).called(1);
        verify(mockInAppUpdate.completeFlexibleUpdate()).called(1);
      });

      test('should handle errors during flexible update', () async {
        when(mockInAppUpdate.startFlexibleUpdate())
            .thenThrow(Exception('Simulated error'));

        await UpdateService.performFlexibleUpdate();

        // No specific verification needed as the error is handled internally
      });
    });

    group('performFlexibleUpdateWithCallback', () {
      test('should call onStatusChange during flexible update', () async {
        final statusChanges = <String>[];
        void onStatusChange(String status) {
          statusChanges.add(status);
        }

        when(mockInAppUpdate.startFlexibleUpdate()).thenAnswer((_) async {});
        when(mockInAppUpdate.completeFlexibleUpdate()).thenAnswer((_) async {});

        await UpdateService.performFlexibleUpdateWithCallback(
            onStatusChange: onStatusChange);

        expect(statusChanges.isNotEmpty, true);
        expect(statusChanges[0], 'Iniciando actualización...');
      });

      test('should handle errors during flexible update with callback',
          () async {
        final statusChanges = <String>[];
        void onStatusChange(String status) {
          statusChanges.add(status);
        }

        when(mockInAppUpdate.startFlexibleUpdate())
            .thenThrow(Exception('Simulated error'));

        await UpdateService.performFlexibleUpdateWithCallback(
            onStatusChange: onStatusChange);

        expect(statusChanges.contains('Error en actualización'), true);
      });
    });

    group('completeFlexibleUpdateIfAvailable', () {
      test('should complete flexible update if available', () async {
        when(mockInAppUpdate.completeFlexibleUpdate()).thenAnswer((_) async {});

        final result = await UpdateService.completeFlexibleUpdateIfAvailable();

        expect(result, true);
        verify(mockInAppUpdate.completeFlexibleUpdate()).called(1);
      });

      test('should return false if no update is available to complete',
          () async {
        when(mockInAppUpdate.completeFlexibleUpdate())
            .thenThrow(Exception('No update available'));

        final result = await UpdateService.completeFlexibleUpdateIfAvailable();

        expect(result, false);
        verify(mockInAppUpdate.completeFlexibleUpdate()).called(1);
      });
    });

    group('getUpdateInfo', () {
      test('should return update info successfully', () async {
        final mockInfo = AppUpdateInfo(
          updateAvailability: UpdateAvailability.updateAvailable,
          immediateUpdateAllowed: true,
          flexibleUpdateAllowed: false,
          availableVersionCode: 2,
          updatePriority: 1,
          clientVersionStalenessDays: 0,
        );
        when(mockInAppUpdate.checkForUpdate()).thenAnswer((_) async => mockInfo);

        final result = await UpdateService.getUpdateInfo();

        expect(result['updateAvailable'], true);
        expect(result['immediateUpdateAllowed'], true);
        expect(result['flexibleUpdateAllowed'], false);
        expect(result['availableVersionCode'], 2);
        expect(result['updatePriority'], 1);
        expect(result['clientVersionStalenessDays'], 0);
      });

      test('should handle errors when getting update info', () async {
        when(mockInAppUpdate.checkForUpdate())
            .thenThrow(Exception('Simulated error'));

        final result = await UpdateService.getUpdateInfo();

        expect(result['updateAvailable'], false);
        expect(result['error'], isNotNull);
      });
    });
  });
}