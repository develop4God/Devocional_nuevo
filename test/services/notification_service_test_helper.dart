// test/services/notification_service_test_helper.dart


import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:shared_preferences/shared_preferences.dart';

class NotificationServiceTestHelper {

  static bool _initialized = false;

  

  static Future<void> setupFirebaseForTesting() async {

    if (_initialized) return;

    

    TestWidgetsFlutterBinding.ensureInitialized();

    _setupPlatformChannelMocks();

    

    try {

      await Firebase.initializeApp(

        options: const FirebaseOptions(

          apiKey: 'fake-api-key-for-testing',

          appId: 'fake-app-id-for-testing',

          messagingSenderId: 'fake-sender-id-for-testing',

          projectId: 'fake-project-id-for-testing',

          storageBucket: 'fake-storage-bucket',

          authDomain: 'fake-auth-domain',

        ),

      );

    } catch (e) {

      // Firebase ya inicializado

    }

    

    _initialized = true;

  }

  static Future<void> setupSharedPreferencesForTesting() async {

    SharedPreferences.setMockInitialValues({

      'notifications_enabled': false,

      'notification_time': '09:00',

      'fcm_token': null,

    });

  }

  static void _setupPlatformChannelMocks() {
    // Flutter Local Notifications
    const MethodChannel('dexterous.com/flutter/local_notifications')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'initialize':
        case 'getNotificationAppLaunchDetails':
        case 'requestPermissions':
        case 'show':
        case 'zonedSchedule':
        case 'cancelAll':
        case 'cancel':
          return true;
        default:
          return null;
      }
    });

    // Firebase Messaging
    const MethodChannel('plugins.flutter.io/firebase_messaging')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Messaging#requestPermission':
          return {'authorizationStatus': 1};
        case 'Messaging#getToken':
          return 'mock_fcm_token_123456789';
        case 'Messaging#setAutoInitEnabled':
        case 'Messaging#getInitialMessage':
        case 'Messaging#subscribeToTopic':
        case 'Messaging#unsubscribeFromTopic':
          return null;
        default:
          return null;
      }
    });

    // Firebase Auth
    const MethodChannel('plugins.flutter.io/firebase_auth')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Auth#currentUser':
          return null; // No user by default for simple tests
        case 'Auth#authStateChanges':
          return null;
        case 'Auth#signInAnonymously':
        case 'Auth#signOut':
          return null;
        default:
          return null;
      }
    });

    // Firebase Firestore
    const MethodChannel('plugins.flutter.io/cloud_firestore')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'DocumentReference#set':
        case 'DocumentReference#update':
          return null;
        case 'DocumentReference#get':
          return {
            'data': {
              'notificationsEnabled': true,
              'notificationTime': '09:00',
              'lastUpdated': DateTime.now().millisecondsSinceEpoch,
            },
            'exists': true,
          };
        case 'Query#snapshots':
        case 'DocumentReference#snapshots':
          return null;
        default:
          return null;
      }
    });

    // Permission Handler
    const MethodChannel('flutter.baseflow.com/permissions/methods')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'requestPermissions':
          return {0: 1, 1: 1, 2: 1}; // All permissions granted
        case 'checkPermissionStatus':
          return 1; // Granted
        default:
          return 1;
      }
    });

    // Timezone
    const MethodChannel('plugins.flutter.io/timezone')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return 'America/New_York';
    });

    // Flutter Timezone
    const MethodChannel('flutter_timezone')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return 'America/New_York';
    });
  }

  static Future<void> cleanup() async {

    try {

      final prefs = await SharedPreferences.getInstance();

      await prefs.clear();

    } catch (e) {

      // Ignorar errores de cleanup

    }

  }

  static Map<String, dynamic> createTestUserData({

    bool notificationsEnabled = true,

    String notificationTime = '09:00',

    String userTimezone = 'America/New_York',

  }) {

    return {

      'notificationsEnabled': notificationsEnabled,

      'notificationTime': notificationTime,

      'userTimezone': userTimezone,

      'lastUpdated': DateTime.now().toIso8601String(),

    };

  }

}
