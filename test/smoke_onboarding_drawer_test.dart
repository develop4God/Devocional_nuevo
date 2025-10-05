// test/smoke_onboarding_drawer_test.dart
// 🧪 SMOKE TEST - Comprehensive app flow test with service mocks
// Tests: Onboarding → Main App → Drawer interaction
// Validates: No hangs, no black screens, proper loading

import 'package:flutter_test/flutter_test.dart';
import 'package:devocional_nuevo/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data';

// Mock Firebase Core
class MockFirebaseCore extends Mock
    with MockPlatformInterfaceMixin
    implements FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return MockFirebaseApp();
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return MockFirebaseApp();
  }

  @override
  List<FirebaseAppPlatform> get apps => [MockFirebaseApp()];
}

class MockFirebaseApp extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseAppPlatform {
  @override
  String get name => defaultFirebaseAppName;

  @override
  FirebaseOptions get options => const FirebaseOptions(
        apiKey: 'mock-api-key',
        appId: 'mock-app-id',
        messagingSenderId: 'mock-sender-id',
        projectId: 'mock-project-id',
      );

  @override
  bool get isAutomaticDataCollectionEnabled => false;

  @override
  Future<void> delete() async {}

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}
}

// Mock class for Platform Interface
class Mock {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Capture and ignore Google Fonts errors in test environment
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('google_fonts')) {
        // Ignore Google Fonts errors in tests - font will fallback to default
        return;
      }
      originalOnError?.call(details);
    };
  });

  setUp(() async {
    // Disable Google Fonts HTTP fetching in tests
    GoogleFonts.config.allowRuntimeFetching = false;

    // Mock Firebase Core
    FirebasePlatform.instance = MockFirebaseCore();

    // Mock SharedPreferences with onboarding not completed
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': false,
      'onboarding_version': 0,
    });

    // Mock platform channels
    _setupPlatformChannelMocks();
  });

  testWidgets('SMOKE TEST: Complete app flow - onboarding → main → drawer',
      (WidgetTester tester) async {
    print('\n🧪 [SMOKE TEST] Starting comprehensive app flow test\n');

    // Step 0: Start app and wait for Firebase and localization
    print('[DEBUG] 🟢 Starting app (main)');
    app.main();
    await tester.pump(); // Initial frame

    // Step 1: Wait for splash and initial async setup (Firebase, localization, Remote Config)
    print('[DEBUG] ⏳ Waiting for splash and async initialization...');
    await tester.pump(const Duration(seconds: 1));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Step 2: Wait for OnboardingWelcomePage
    print('[DEBUG] ⏳ Waiting for onboarding welcome page...');
    var waitCycles = 0;
    while (find.textContaining('Bienvenido').evaluate().isEmpty &&
        waitCycles < 20) {
      await tester.pump(const Duration(milliseconds: 500));
      waitCycles++;
    }

    if (find.textContaining('Bienvenido').evaluate().isEmpty) {
      print(
          '[DEBUG] ⚠️  Onboarding welcome NOT visible after $waitCycles cycles');
      print('[DEBUG] 🔍 Current widgets on screen:');
      for (var widget in tester.allWidgets.take(10)) {
        print('  - ${widget.runtimeType}');
      }
    } else {
      print('[DEBUG] ✅ Onboarding welcome visible after $waitCycles cycles');
    }
    expect(find.textContaining('Bienvenido'), findsOneWidget);

    // Step 3: Tap "Siguiente" for welcome
    print('[DEBUG] 👉 Tapping Siguiente on welcome');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Siguiente'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Step 4: Wait for theme selection
    print('[DEBUG] ⏳ Waiting for theme selection page...');
    var waitTheme = 0;
    while (find.textContaining('Elige tu Ambiente').evaluate().isEmpty &&
        waitTheme < 15) {
      await tester.pump(const Duration(milliseconds: 500));
      waitTheme++;
    }
    print('[DEBUG] ✅ Theme selection page visible after $waitTheme cycles');
    expect(find.textContaining('Elige tu Ambiente'), findsOneWidget);

    // Step 5: Select a theme and tap "Siguiente"
    print('[DEBUG] 👉 Selecting theme and tapping Siguiente');
    final themeTiles = find.byType(GestureDetector);
    expect(themeTiles, findsWidgets);
    await tester.tap(themeTiles.first);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Siguiente'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Step 6: Wait for backup config page
    print('[DEBUG] ⏳ Waiting for backup configuration page...');
    var waitBackup = 0;
    while (find.textContaining('Sincronización').evaluate().isEmpty &&
        find.textContaining('Configurar luego').evaluate().isEmpty &&
        waitBackup < 15) {
      await tester.pump(const Duration(milliseconds: 500));
      waitBackup++;
    }
    print('[DEBUG] ✅ Backup config page visible after $waitBackup cycles');
    expect(find.textContaining('Configurar luego'), findsOneWidget);

    // Step 7: Tap "Configurar luego"
    print('[DEBUG] 👉 Tapping Configurar luego (skip backup)');
    await tester.tap(find.widgetWithText(TextButton, 'Configurar luego'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Step 8: Wait for completion page
    print('[DEBUG] ⏳ Waiting for onboarding complete page...');
    var waitComplete = 0;
    while (find.textContaining('¡Todo Listo!').evaluate().isEmpty &&
        waitComplete < 15) {
      await tester.pump(const Duration(milliseconds: 500));
      waitComplete++;
    }
    print(
        '[DEBUG] ✅ Onboarding complete page visible after $waitComplete cycles');
    expect(find.textContaining('¡Todo Listo!'), findsWidgets);

    // Step 9: Tap "Comenzar mi espacio con Dios"
    print('[DEBUG] 👉 Tapping start app');
    await tester.tap(
        find.widgetWithText(ElevatedButton, 'Comenzar mi espacio con Dios'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Step 10: Wait for main app with menu icon
    print('[DEBUG] ⏳ Waiting for main app splash and content...');
    var waitMain = 0;
    while (find.byIcon(Icons.menu).evaluate().isEmpty && waitMain < 20) {
      await tester.pump(const Duration(milliseconds: 500));
      waitMain++;
    }
    print('[DEBUG] ✅ Main app visible with menu icon after $waitMain cycles');
    expect(find.byIcon(Icons.menu), findsOneWidget);

    // Step 11: Tap drawer (hamburger icon)
    print('[DEBUG] 👉 Tapping drawer menu icon');
    await tester.tap(find.byIcon(Icons.menu));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Step 12: Wait for drawer content
    print('[DEBUG] ⏳ Waiting for drawer to open...');
    var waitDrawer = 0;
    while (find.text('Tu Biblia, tu estilo').evaluate().isEmpty &&
        waitDrawer < 10) {
      await tester.pump(const Duration(milliseconds: 400));
      waitDrawer++;
    }
    print('[DEBUG] ✅ Drawer opened successfully after $waitDrawer cycles');
    expect(find.text('Tu Biblia, tu estilo'), findsOneWidget);

    print('\n[DEBUG] ✅✅✅ SMOKE TEST COMPLETED SUCCESSFULLY ✅✅✅\n');
    print('[DEBUG] 📊 Summary:');
    print('[DEBUG]   - Onboarding flow: PASSED');
    print('[DEBUG]   - Main app load: PASSED');
    print('[DEBUG]   - Drawer interaction: PASSED');
    print('[DEBUG]   - No hangs or black screens detected\n');
  });
}

// Helper function to setup platform channel mocks
void _setupPlatformChannelMocks() {
  // Mock google_fonts HTTP client
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall methodCall) async {
      return '.';
    },
  );

  // Mock flutter_tts
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('flutter_tts'),
    (call) async {
      switch (call.method) {
        case 'speak':
        case 'stop':
        case 'pause':
        case 'setLanguage':
        case 'setSpeechRate':
        case 'setVolume':
        case 'setPitch':
        case 'awaitSpeakCompletion':
          return null;
        case 'getLanguages':
          return ['es-ES', 'en-US'];
        case 'getVoices':
          return [
            {'name': 'Voice ES', 'locale': 'es-ES'},
            {'name': 'Voice EN', 'locale': 'en-US'},
          ];
        default:
          return null;
      }
    },
  );

  // Mock path_provider
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async {
      switch (call.method) {
        case 'getApplicationDocumentsDirectory':
          return '/mock_documents';
        case 'getTemporaryDirectory':
          return '/mock_temp';
        case 'getApplicationSupportDirectory':
          return '/mock_support';
        default:
          return null;
      }
    },
  );

  // Mock firebase_auth
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_auth'),
    (call) async {
      switch (call.method) {
        case 'Auth#signInAnonymously':
          return {
            'user': {
              'uid': 'mock-anonymous-user-id',
              'email': null,
              'isAnonymous': true,
            }
          };
        case 'Auth#currentUser':
          return {
            'user': {
              'uid': 'mock-anonymous-user-id',
              'email': null,
              'isAnonymous': true,
            }
          };
        default:
          return null;
      }
    },
  );

  // Mock firebase_messaging
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_messaging'),
    (call) async {
      switch (call.method) {
        case 'Messaging#requestPermission':
          return {'authorizationStatus': 1}; // authorized
        case 'Messaging#getToken':
          return 'mock-fcm-token';
        case 'Messaging#subscribeToTopic':
        case 'Messaging#unsubscribeFromTopic':
          return null;
        default:
          return null;
      }
    },
  );

  // Mock firebase_remote_config
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_remote_config'),
    (call) async {
      switch (call.method) {
        case 'RemoteConfig#instance':
          return {};
        case 'RemoteConfig#fetch':
        case 'RemoteConfig#activate':
          return true;
        case 'RemoteConfig#getAll':
          return {
            'onboarding_enabled': {'source': 1, 'value': true},
          };
        case 'RemoteConfig#getBool':
          if (call.arguments['key'] == 'onboarding_enabled') {
            return true;
          }
          return false;
        default:
          return null;
      }
    },
  );

  // Mock google_sign_in
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/google_sign_in'),
    (call) async {
      switch (call.method) {
        case 'init':
        case 'signInSilently':
        case 'signOut':
          return null;
        default:
          return null;
      }
    },
  );

  // Mock url_launcher
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/url_launcher'),
    (call) async {
      return true; // Simulate successful URL launch
    },
  );

  // Mock shared_preferences (additional setup)
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/shared_preferences'),
    (call) async {
      if (call.method == 'getAll') {
        return <String, dynamic>{
          'flutter.onboarding_complete': false,
          'flutter.onboarding_version': 0,
        };
      }
      return null;
    },
  );

  // Mock local_auth (for biometric authentication if used)
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/local_auth'),
    (call) async {
      return false; // Simulate no biometric available
    },
  );
}
