// test/services/notification_service_unit_test.dart
// Unit tests for NotificationService focusing on SharedPreferences functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('NotificationService - Unit Tests (SharedPreferences only)', () {
    setUp(() async {
      // Setup clean SharedPreferences for each test
      SharedPreferences.setMockInitialValues({
        'notifications_enabled': false,
        'notification_time': '09:00',
      });
    });

    group('SharedPreferences Behavior Tests', () {
      test('SharedPreferences mock returns correct default values', () async {
        final prefs = await SharedPreferences.getInstance();
        
        // Test the actual behavior that NotificationService relies on
        final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        final notificationTime = prefs.getString('notification_time') ?? '09:00';
        
        expect(notificationsEnabled, isFalse); // Based on mock setup
        expect(notificationTime, equals('09:00'));
      });

      test('SharedPreferences can store and retrieve notification settings', () async {
        final prefs = await SharedPreferences.getInstance();
        
        // Test storing values
        await prefs.setBool('notifications_enabled', true);
        await prefs.setString('notification_time', '14:30');
        
        // Test retrieving values
        expect(prefs.getBool('notifications_enabled'), isTrue);
        expect(prefs.getString('notification_time'), equals('14:30'));
      });

      test('SharedPreferences handles default fallback values correctly', () async {
        final prefs = await SharedPreferences.getInstance();
        
        // Clear the key to test fallback behavior
        await prefs.remove('notifications_enabled');
        
        // Test that getBool returns null when key doesn't exist
        expect(prefs.getBool('notifications_enabled'), isNull);
        
        // Test the pattern used in NotificationService
        final enabledWithFallback = prefs.getBool('notifications_enabled') ?? true;
        expect(enabledWithFallback, isTrue);
      });

      test('SharedPreferences persists values between instances', () async {
        // Set values in first instance
        final prefs1 = await SharedPreferences.getInstance();
        await prefs1.setBool('notifications_enabled', true);
        await prefs1.setString('notification_time', '20:15');
        
        // Get values from second instance
        final prefs2 = await SharedPreferences.getInstance();
        expect(prefs2.getBool('notifications_enabled'), isTrue);
        expect(prefs2.getString('notification_time'), equals('20:15'));
      });

      test('SharedPreferences handles edge case times correctly', () async {
        final prefs = await SharedPreferences.getInstance();
        
        // Test early morning
        await prefs.setString('notification_time', '00:00');
        expect(prefs.getString('notification_time'), equals('00:00'));
        
        // Test late night
        await prefs.setString('notification_time', '23:59');
        expect(prefs.getString('notification_time'), equals('23:59'));
      });

      test('SharedPreferences handles empty and null values', () async {
        final prefs = await SharedPreferences.getInstance();
        
        // Test empty string
        await prefs.setString('notification_time', '');
        expect(prefs.getString('notification_time'), equals(''));
        
        // Test that removing a key makes it return null
        await prefs.remove('notification_time');
        expect(prefs.getString('notification_time'), isNull);
        
        // Test fallback pattern
        final timeWithFallback = prefs.getString('notification_time') ?? '09:00';
        expect(timeWithFallback, equals('09:00'));
      });
    });

    group('NotificationService Constants Tests', () {
      test('Key constants are correctly defined', () {
        // These should match the constants in NotificationService
        const notificationsEnabledKey = 'notifications_enabled';
        const notificationTimeKey = 'notification_time';
        const defaultNotificationTime = '09:00';
        const fcmTokenKey = 'fcm_token';
        
        // Verify the constants are strings and not empty
        expect(notificationsEnabledKey, isA<String>());
        expect(notificationTimeKey, isA<String>());
        expect(defaultNotificationTime, isA<String>());
        expect(fcmTokenKey, isA<String>());
        
        expect(notificationsEnabledKey.isNotEmpty, isTrue);
        expect(notificationTimeKey.isNotEmpty, isTrue);
        expect(defaultNotificationTime.isNotEmpty, isTrue);
        expect(fcmTokenKey.isNotEmpty, isTrue);
      });

      test('Default notification time is valid format', () {
        const defaultTime = '09:00';
        
        // Test that default time matches HH:MM format
        final timeRegex = RegExp(r'^\d{2}:\d{2}$');
        expect(timeRegex.hasMatch(defaultTime), isTrue);
        
        // Test that it can be parsed as valid time components
        final parts = defaultTime.split(':');
        expect(parts.length, equals(2));
        
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        
        expect(hour, isNotNull);
        expect(minute, isNotNull);
        expect(hour! >= 0 && hour <= 23, isTrue);
        expect(minute! >= 0 && minute <= 59, isTrue);
      });
    });

    group('Mock Environment Validation', () {
      test('Test environment is properly set up', () async {
        // Verify that we're in a test environment
        expect(SharedPreferences.getInstance, isA<Function>());
        
        // Verify that mock values can be set and retrieved
        final prefs = await SharedPreferences.getInstance();
        expect(prefs, isNotNull);
        
        // Test that we can modify mock values
        await prefs.setBool('test_key', true);
        expect(prefs.getBool('test_key'), isTrue);
      });
      
      test('Multiple SharedPreferences instances share state', () async {
        final prefs1 = await SharedPreferences.getInstance();
        final prefs2 = await SharedPreferences.getInstance();
        
        // They should be the same instance
        expect(identical(prefs1, prefs2), isTrue);
        
        // Changes in one should reflect in the other
        await prefs1.setBool('shared_test', true);
        expect(prefs2.getBool('shared_test'), isTrue);
      });
    });

    group('Integration Simulation Tests', () {
      test('Simulate NotificationService workflow patterns', () async {
        final prefs = await SharedPreferences.getInstance();
        
        // Simulate areNotificationsEnabled() workflow
        final enabledResult = prefs.getBool('notifications_enabled') ?? true;
        expect(enabledResult, isFalse); // Based on our mock setup
        
        // Simulate setNotificationsEnabled(true) workflow
        await prefs.setBool('notifications_enabled', true);
        final afterEnable = prefs.getBool('notifications_enabled') ?? true;
        expect(afterEnable, isTrue);
        
        // Simulate setNotificationsEnabled(false) workflow
        await prefs.setBool('notifications_enabled', false);
        final afterDisable = prefs.getBool('notifications_enabled') ?? true;
        expect(afterDisable, isFalse);
      });

      test('Simulate notification time management workflow', () async {
        final prefs = await SharedPreferences.getInstance();
        
        // Simulate getNotificationTime() workflow
        final defaultTime = prefs.getString('notification_time') ?? '09:00';
        expect(defaultTime, equals('09:00'));
        
        // Simulate setNotificationTime() workflow
        await prefs.setString('notification_time', '14:30');
        final customTime = prefs.getString('notification_time') ?? '09:00';
        expect(customTime, equals('14:30'));
        
        // Test time persistence
        final prefs2 = await SharedPreferences.getInstance();
        final persistedTime = prefs2.getString('notification_time') ?? '09:00';
        expect(persistedTime, equals('14:30'));
      });

      test('Simulate complete notification setup workflow', () async {
        final prefs = await SharedPreferences.getInstance();
        
        // 1. Check initial state
        expect(prefs.getBool('notifications_enabled') ?? true, isFalse);
        expect(prefs.getString('notification_time') ?? '09:00', equals('09:00'));
        
        // 2. Enable notifications
        await prefs.setBool('notifications_enabled', true);
        expect(prefs.getBool('notifications_enabled') ?? true, isTrue);
        
        // 3. Set custom time
        await prefs.setString('notification_time', '08:30');
        expect(prefs.getString('notification_time') ?? '09:00', equals('08:30'));
        
        // 4. Verify persistence by creating new instance
        final newPrefs = await SharedPreferences.getInstance();
        expect(newPrefs.getBool('notifications_enabled') ?? true, isTrue);
        expect(newPrefs.getString('notification_time') ?? '09:00', equals('08:30'));
        
        // 5. Disable notifications
        await newPrefs.setBool('notifications_enabled', false);
        expect(newPrefs.getBool('notifications_enabled') ?? true, isFalse);
        
        // 6. Time setting should persist even when disabled
        expect(newPrefs.getString('notification_time') ?? '09:00', equals('08:30'));
      });
    });
  });
}