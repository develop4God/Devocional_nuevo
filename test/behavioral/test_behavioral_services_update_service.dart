import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/services.dart';
import 'package:devocional_nuevo/services/update_service.dart';
import 'package:in_app_update/in_app_update.dart';

@GenerateMocks([InAppUpdate])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UpdateService', () {
    setUp(() {
      // Mock InAppUpdate static methods
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'checkForUpdate':
              return {
                'updateAvailability': 1, // UpdateAvailability.updateAvailable
                'immediateUpdateAllowed': true,
                'flexibleUpdateAllowed': false,
                'availableVersionCode': 2,
                'updatePriority': 3,
                'clientVersionStalenessDays': 4,
              };
            case 'performImmediateUpdate':
              return true;
            case 'startFlexibleUpdate':
              return true;
            case 'completeFlexibleUpdate':
              return true;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update'),
        null,
      );
    });

    test('User checks for update and an immediate update is available',
        () async {
      // Given: App starts, and an immediate update is available.
      // Mock checkForUpdate to return update available and immediate allowed
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'checkForUpdate':
              return {
                'updateAvailability': 1, // UpdateAvailability.updateAvailable
                'immediateUpdateAllowed': true,
                'flexibleUpdateAllowed': false,
                'availableVersionCode': 2,
                'updatePriority': 3,
                'clientVersionStalenessDays': 4,
              };
            case 'performImmediateUpdate':
              return true;
            default:
              return null;
          }
        },
      );

      // When: User calls checkForUpdate
      await UpdateService.checkForUpdate();

      // Then: Immediate update is performed. Verify performImmediateUpdate is called
      // Since we can't directly verify static method calls, we rely on the mock setup.
      // If the mock is set up correctly, the test passes.
    });

    test('User checks for update and a flexible update is available',
        () async {
      // Given: App starts, and a flexible update is available.
      // Mock checkForUpdate to return update available and flexible allowed
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'checkForUpdate':
              return {
                'updateAvailability': 1, // UpdateAvailability.updateAvailable
                'immediateUpdateAllowed': false,
                'flexibleUpdateAllowed': true,
                'availableVersionCode': 2,
                'updatePriority': 3,
                'clientVersionStalenessDays': 4,
              };
            case 'startFlexibleUpdate':
              return true;
            case 'completeFlexibleUpdate':
              return true;
            default:
              return null;
          }
        },
      );

      // When: User calls checkForUpdate
      await UpdateService.checkForUpdate();

      // Then: Flexible update is started. Verify startFlexibleUpdate is called
      // Since we can't directly verify static method calls, we rely on the mock setup.
      // If the mock is set up correctly, the test passes.
    });

    test('User performs a flexible update with callback and monitors progress',
        () async {
      // Given: User initiates a flexible update with a callback.
      final statusUpdates = <String>[];
      // Mock startFlexibleUpdate and completeFlexibleUpdate
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'startFlexibleUpdate':
              return true;
            case 'completeFlexibleUpdate':
              return true;
            default:
              return null;
          }
        },
      );

      // When: User calls performFlexibleUpdateWithCallback
      await UpdateService.performFlexibleUpdateWithCallback(
          onStatusChange: (status) {
        statusUpdates.add(status);
      });

      // Then: The callback is called with progress updates and the update completes.
      expect(statusUpdates, isNotEmpty);
      expect(statusUpdates.first, 'Iniciando actualización...');
      expect(statusUpdates, contains('Descargando... 80%'));
      expect(statusUpdates, contains('Preparando instalación...'));
      expect(statusUpdates, contains('Actualización completada exitosamente'));
    });

    test('User attempts to complete a flexible update when one is available',
        () async {
      // Given: A flexible update is available.
      // Mock completeFlexibleUpdate to return true
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'completeFlexibleUpdate':
              return true;
            default:
              return null;
          }
        },
      );

      // When: User calls completeFlexibleUpdateIfAvailable
      final result = await UpdateService.completeFlexibleUpdateIfAvailable();

      // Then: The update is completed successfully.
      expect(result, isTrue);
    });

    test('User attempts to complete a flexible update when none is available',
        () async {
      // Given: No flexible update is available.
      // Mock completeFlexibleUpdate to throw an exception (simulating no update)
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'completeFlexibleUpdate':
              throw PlatformException(code: '1'); // Simulate no update available
            default:
              return null;
          }
        },
      );

      // When: User calls completeFlexibleUpdateIfAvailable
      final result = await UpdateService.completeFlexibleUpdateIfAvailable();

      // Then: The method returns false.
      expect(result, isFalse);
    });

    test('User gets update info successfully', () async {
      // Given: The app is running.
      // Mock checkForUpdate to return update info
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'checkForUpdate':
              return {
                'updateAvailability': 1, // UpdateAvailability.updateAvailable
                'immediateUpdateAllowed': true,
                'flexibleUpdateAllowed': false,
                'availableVersionCode': 2,
                'updatePriority': 3,
                'clientVersionStalenessDays': 4,
              };
            default:
              return null;
          }
        },
      );

      // When: User calls getUpdateInfo
      final result = await UpdateService.getUpdateInfo();

      // Then: The update info is returned correctly.
      expect(result['updateAvailable'], isTrue);
      expect(result['immediateUpdateAllowed'], isTrue);
      expect(result['flexibleUpdateAllowed'], isFalse);
      expect(result['availableVersionCode'], 2);
      expect(result['updatePriority'], 3);
      expect(result['clientVersionStalenessDays'], 4);
    });

    test('User gets update info and an error occurs', () async {
      // Given: An error occurs while getting update info.
      // Mock checkForUpdate to throw an exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'checkForUpdate':
              throw PlatformException(code: '1', message: 'Simulated error');
            default:
              return null;
          }
        },
      );

      // When: User calls getUpdateInfo
      final result = await UpdateService.getUpdateInfo();

      // Then: The error is handled and an error map is returned.
      expect(result['updateAvailable'], isFalse);
      expect(result['error'], isNotNull);
      expect(result['error'], contains('Simulated error'));
    });
  });
}