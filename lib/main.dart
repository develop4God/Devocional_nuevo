import 'dart:developer' as developer;

import 'package:devocional_nuevo/controllers/audio_controller.dart';

// Importa tu runner pero solo para helpers, no para el control de la UI
import 'package:devocional_nuevo/game_loop_runner.dart' as runner;
import 'package:devocional_nuevo/pages/settings_page.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/providers/localization_provider.dart';
import 'package:devocional_nuevo/providers/theme_provider.dart';
import 'package:devocional_nuevo/services/notification_service.dart';
import 'package:devocional_nuevo/services/spiritual_stats_service.dart'; // NUEVO
import 'package:devocional_nuevo/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

// Usa el mismo navigatorKey global
final GlobalKey<NavigatorState> navigatorKey = runner.navigatorKey;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log(
      'BackgroundServiceCallback: Manejando mensaje FCM en segundo plano: ${message.messageId}',
      name: 'BackgroundServiceCallback');
  await Firebase.initializeApp();
  tzdata.initializeTimeZones();
  try {
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    developer.log(
        'BackgroundServiceCallback: Zona horaria re-inicializada a: $currentTimeZone',
        name: 'BackgroundServiceCallback');
  } catch (e) {
    developer.log(
        'BackgroundServiceCallback: Error al re-inicializar la zona horaria en segundo plano: $e',
        name: 'BackgroundServiceCallback',
        error: e);
    tz.setLocalLocation(tz.getLocation('UTC'));
    developer.log(
        'BackgroundServiceCallback: Volviendo a la zona horaria UTC en segundo plano.',
        name: 'BackgroundServiceCallback');
  }
  final NotificationService notificationService = NotificationService();
  await notificationService.initialize();
  final String? title = message.notification?.title;
  final String? body = message.notification?.body;
  final String? payload = message.data['payload'] as String?;
  if (title != null && body != null) {
    await notificationService.showImmediateNotification(
      title,
      body,
      payload: payload,
      id: message.messageId.hashCode,
    );
    developer.log(
        'BackgroundServiceCallback: Notificación FCM mostrada en segundo plano: $title',
        name: 'BackgroundServiceCallback');
  } else {
    developer.log(
        'BackgroundServiceCallback: Mensaje FCM de segundo plano sin título o cuerpo de notificación.',
        name: 'BackgroundServiceCallback');
  }
  developer.log(
      'BackgroundServiceCallback: Manejo de mensaje FCM en segundo plano completado.',
      name: 'BackgroundServiceCallback');
}

void main() async {
  developer.log('App: Función main() iniciada.', name: 'MainApp');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Configurar el manejador de mensajes FCM en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  developer.log('App: Manejador de mensajes FCM en segundo plano registrado.',
      name: 'MainApp');

  // Lanzar runApp lo antes posible (sin inicializaciones bloqueantes)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DevocionalProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AudioController()),
        ChangeNotifierProvider(create: (context) => LocalizationProvider()),
      ],
      child: const AppInitializer(),
    ),
  );
}

// Widget raíz que decide si corre Game Loop o la app normal
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool? _isGameLoop;
  bool _appInitialized = false;

  @override
  void initState() {
    super.initState();
    // Ejecutar la detección del Game Loop y la inicialización de la app después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // Inicialización ligera (no bloquea el primer frame)
    await _initServices();
    await _checkGameLoop();
    setState(() {
      _appInitialized = true;
    });
  }

  Future<void> _initServices() async {
    // Mueve aquí la inicialización global que bloqueaba el arranque
    try {
      tzdata.initializeTimeZones();
      await initializeDateFormatting('es', null);
    } catch (e) {
      developer.log(
          'ERROR en AppInitializer: Error al inicializar zona horaria o date formatting: $e',
          name: 'MainApp',
          error: e);
    }

    // Initialize localization service
    try {
      if (mounted) {
        final localizationProvider =
            Provider.of<LocalizationProvider>(context, listen: false);
        await localizationProvider.initialize();
        developer.log('MainApp: Localization service initialized',
            name: 'MainApp');
      }
    } catch (e) {
      developer.log(
          'ERROR en AppInitializer: Error al inicializar servicio de localización: $e',
          name: 'MainApp',
          error: e);
    }

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        await auth.signInAnonymously();
        developer.log(
            'MainApp: Usuario anónimo autenticado: ${auth.currentUser?.uid}',
            name: 'MainApp');
      } else {
        developer.log(
            'MainApp: Usuario ya autenticado: ${auth.currentUser?.uid}',
            name: 'MainApp');
      }
    } catch (e) {
      developer.log(
          'ERROR en AppInitializer: Error al inicializar Firebase Auth o autenticar anónimamente: $e',
          name: 'MainApp',
          error: e);
    }

    try {
      await NotificationService().initialize();
      developer.log(
          'AppInitializer: Servicios de notificación (FCM) registrados correctamente.',
          name: 'MainApp');

      // --- Solicita permiso de notificaciones solo si NO es Test Lab/Game Loop ---
      developer.log('Chequeando acción de intent para TestLab/GameLoop...',
          name: 'DebugFlow');
      final String? action = await runner.getInitialIntentAction();
      developer.log('Acción obtenida: $action', name: 'DebugFlow');
      final bool isTestLab = action == "com.google.intent.action.TEST_LOOP";
      developer.log('isTestLab = $isTestLab', name: 'DebugFlow');
      if (!isTestLab) {
        developer.log('Solicitando permiso de notificaciones...',
            name: 'DebugFlow');
        final settings = await FirebaseMessaging.instance.requestPermission();
        developer.log(
            'Permiso solicitado, estado: ${settings.authorizationStatus}',
            name: 'DebugFlow');
      } else {
        developer.log('NO se solicita permiso de notificaciones por Game Loop',
            name: 'DebugFlow');
      }
    } catch (e) {
      debugPrint('Error al inicializar servicios de notificación: $e');
      developer.log(
          'ERROR en AppInitializer: Error al inicializar servicios de notificación: $e',
          name: 'MainApp',
          error: e);
    }

    // NUEVO: Inicializar sistema de backup automático de estadísticas espirituales
    try {
      final spiritualStatsService = SpiritualStatsService();

      // Verificar integridad de datos al inicio
      await spiritualStatsService.getStats();

      // Habilitar auto-backup si no está configurado (primera vez)
      if (!await spiritualStatsService.isAutoBackupEnabled()) {
        await spiritualStatsService.setAutoBackupEnabled(true);
        developer.log(
            'AppInitializer: Auto-backup de estadísticas espirituales habilitado por defecto.',
            name: 'MainApp');
      }

      // Obtener información de backup para logging
      final backupInfo = await spiritualStatsService.getBackupInfo();
      developer.log(
          'AppInitializer: Sistema de backup inicializado. Auto-backups: ${backupInfo['auto_backups_count']}, Último backup: ${backupInfo['last_auto_backup']}',
          name: 'MainApp');
    } catch (e) {
      developer.log(
          'ERROR en AppInitializer: Error al inicializar sistema de backup de estadísticas: $e',
          name: 'MainApp',
          error: e);
      // No es crítico, la app puede continuar funcionando
    }
  }

  Future<void> _checkGameLoop() async {
    final String? action = await runner.getInitialIntentAction();
    setState(() {
      // Solo activa GameLoop si está en debug mode Y el intent lo pide
      _isGameLoop =
          kDebugMode && (action == "com.google.intent.action.TEST_LOOP");
    });
    // No se llama aquí a runAutomatedGameLoop ni reportTestResultAndExit
  }

  @override
  Widget build(BuildContext context) {
    if (!_appInitialized || _isGameLoop == null) {
      // Muestra el SplashScreen de Flutter mientras inicializas
      return const MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      );
    }
    if (_isGameLoop == true) {
      return const GameLoopWidget();
    }

    // App normal
    return MyApp();
  }
}

// Mantén tu MyApp como antes
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);

    return MaterialApp(
      title: 'Devocionales',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      navigatorKey: navigatorKey,
      locale: localizationProvider.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''),
        Locale('en', ''),
        Locale('pt', ''),
        Locale('fr', ''),
      ],
      home: const SplashScreen(),
      routes: {
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

class GameLoopWidget extends StatefulWidget {
  const GameLoopWidget({super.key});

  @override
  State<GameLoopWidget> createState() => _GameLoopWidgetState();
}

class _GameLoopWidgetState extends State<GameLoopWidget> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_started) {
        _started = true;
        try {
          await runner.runAutomatedGameLoop();
          await runner.reportTestResultAndExit(
              true, "Game loop test completed successfully.");
        } catch (e) {
          await runner.reportTestResultAndExit(
              false, "Game loop test failed: $e");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Devocionales',
      home: runner.testHomeWidget(),
      routes: {
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
