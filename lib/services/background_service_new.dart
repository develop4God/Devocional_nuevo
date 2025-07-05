import 'dart:developer' as developer;
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

// Nombre de la tarea en segundo plano
const String taskName = 'com.develop4god.devocional_nuevo.backgroundTask';

class BackgroundServiceNew {
  static final BackgroundServiceNew _instance = BackgroundServiceNew._internal();
  
  factory BackgroundServiceNew() {
    return _instance;
  }
  
  BackgroundServiceNew._internal();
  
  // Inicializar el servicio de fondo
  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    
    // Registrar la tarea periódica
    await registerPeriodicTask();
    developer.log('BackgroundServiceNew: Workmanager initialized and periodic task registered', name: 'BackgroundServiceNew');
  }
  
  // Registrar una tarea periódica
  Future<void> registerPeriodicTask() async {
    developer.log('BackgroundServiceNew: Registering periodic task', name: 'BackgroundServiceNew');
    await Workmanager().registerPeriodicTask(
      'periodicTask',
      taskName,
      frequency: const Duration(hours: 12),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 15),

    );
    developer.log('BackgroundServiceNew: Periodic task registered', name: 'BackgroundServiceNew');
  }
  
  // Registrar una tarea única
  Future<void> registerOneOffTask() async {
    developer.log('BackgroundServiceNew: Registering one-off task', name: 'BackgroundServiceNew');
    await Workmanager().registerOneOffTask(
      'oneOffTask',
      taskName,
      initialDelay: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 15),
    );
  }
  
  // Cancelar todas las tareas
  Future<void> cancelAllTasks() async {
    developer.log('BackgroundServiceNew: Cancelling all Workmanager tasks', name: 'BackgroundServiceNew');
    await Workmanager().cancelAll();
  }
}

// Esta función debe estar en el ámbito global
@pragma('vm:entry-point')
void callbackDispatcher() {
  developer.log('callbackDispatcher: Task execution started', name: 'BackgroundServiceCallback');
  Workmanager().executeTask((taskName, inputData) async {
    developer.log('callbackDispatcher: Executing task: $taskName', name: 'BackgroundServiceCallback');
    try {
      // Inicializar Firebase para este aislado
      await Firebase.initializeApp(); // ✅ CAMBIO 2: Nueva línea
      // Inicializar DartPluginRegistrant para poder usar plugins en el callback
      WidgetsFlutterBinding.ensureInitialized();
      DartPluginRegistrant.ensureInitialized();
      developer.log('callbackDispatcher: DartPluginRegistrant initialized', name: 'BackgroundServiceCallback');
      
      // Ejecutar la tarea en segundo plano
      await _executeBackgroundTask();
      
      return true;
    } catch (e) {
      developer.log('ERROR in callbackDispatcher: $e', name: 'BackgroundServiceCallback', error: e);
      return false;
    }
  });
}

// Ejecutar la tarea en segundo plano
Future<void> _executeBackgroundTask() async {
  try {
    developer.log('BackgroundServiceNew: Ejecutando tarea en segundo plano', name: 'BackgroundServiceCallback');
    
    // Aquí puedes añadir otras tareas de mantenimiento que NO sean notificaciones
    // Por ejemplo: sincronización de datos, limpieza de caché, etc.
    
    // NOTA: Las notificaciones programadas las maneja NotificationService
    // Este servicio se usa solo para otras tareas de mantenimiento
    
    developer.log('BackgroundServiceNew: Tarea completada', name: 'BackgroundServiceCallback');
  } catch (e) {
    developer.log('Error al ejecutar la tarea en segundo plano: $e', name: 'BackgroundServiceCallback');
  }
}