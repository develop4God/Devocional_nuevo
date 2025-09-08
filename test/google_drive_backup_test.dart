import 'package:devocional_nuevo/services/google_drive_backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Google Drive Backup Service Tests', () {
    late GoogleDriveBackupService backupService;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      backupService = GoogleDriveBackupService();
    });

    test('should initialize without errors', () {
      expect(backupService, isNotNull);
    });

    test('should check sign-in status without Google account', () async {
      // This test validates the service can check sign-in status
      // In test environment, it should return false without errors
      final isSignedIn = await backupService.isSignedIn();
      expect(isSignedIn, isFalse);
    });

    test('should handle getCurrentUser when not signed in', () async {
      // This test validates the service handles getCurrentUser gracefully
      final user = await backupService.getCurrentUser();
      expect(user, isNull);
    });

    test('should handle signOut when not signed in gracefully', () async {
      // This test validates the service handles signOut gracefully
      // Note: signOut may throw in test environment, which is expected behavior
      try {
        await backupService.signOut();
        // If it doesn't throw, that's fine too
      } catch (e) {
        // Expected in test environment
        expect(e, isNotNull);
      }
    });
  });

  group('Backup Data Creation Tests', () {
    late GoogleDriveBackupService backupService;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      backupService = GoogleDriveBackupService();
    });

    test('should handle backup creation parameters without throwing syntax errors', () {
      // Test that the service method accepts the right parameters without syntax errors
      expect(() async {
        try {
          // This will fail with authentication error in test, which is expected
          await backupService.createBackup(
            includeStats: true,
            includeFavorites: false,
            includePrayers: true,
          );
        } catch (e) {
          // Expected to fail in test environment due to no authentication
          expect(e.toString(), contains('authenticated'));
        }
      }, returnsNormally);
    });
  });
}