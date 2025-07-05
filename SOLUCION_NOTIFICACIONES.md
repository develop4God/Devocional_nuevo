# Solución para Notificaciones Programadas

## Problemas Identificados

1. **Conflicto entre servicios de background**: Existían dos servicios (`background_service.dart` y `background_service_new.dart`) que podían interferir entre sí.

2. **Lógica compleja de verificación**: El método `_checkAndScheduleForNewDay()` estaba interfiriendo con la programación normal de notificaciones.

3. **Interferencia de WorkManager**: El `background_service_new.dart` también intentaba mostrar notificaciones cada 12 horas, conflictuando con las notificaciones programadas.

4. **Falta de debugging**: No había manera de verificar el estado de las notificaciones programadas.

5. **Inicialización inconsistente**: Las notificaciones no se reprogramaban al iniciar la app.

6. **Logs insuficientes**: Era difícil diagnosticar problemas sin logs detallados.

## Cambios Realizados

### 1. Limpieza de Servicios de Background

- **Eliminado**: `background_service.dart` (obsoleto, usaba AndroidAlarmManager)
- **Simplificado**: `background_service_new.dart` para que NO maneje notificaciones
- **Separación clara**: Solo `NotificationService` maneja notificaciones programadas

### 2. Simplificación del NotificationService

- **Eliminado**: Método `_checkAndScheduleForNewDay()` que causaba conflictos
- **Mejorado**: Método `scheduleDailyNotification()` con mejor logging y manejo de errores
- **Añadido**: Método `debugNotificationStatus()` para diagnosticar problemas

### 2. Mejoras en la Programación

```dart
// Antes: Lógica compleja con verificaciones de fecha
await _checkAndScheduleForNewDay();

// Ahora: Programación directa y clara
await scheduleDailyNotification();
```

### 3. Logging Detallado

Ahora el servicio imprime información detallada:
- Hora configurada
- Fecha programada
- Tiempo hasta la próxima notificación
- Número de notificaciones pendientes
- Estado de permisos

### 4. Botón de Debug

Añadido botón "Debug notificaciones" en la página de configuración que imprime:
- Estado de notificaciones habilitadas
- Hora configurada
- Permisos concedidos
- Notificaciones pendientes
- Timezone actual

### 5. Reprogramación al Iniciar

La app ahora reprograma automáticamente las notificaciones al iniciar si están habilitadas.

## Cómo Probar la Solución

1. **Habilitar notificaciones** en la configuración
2. **Configurar una hora** (ej: 2 minutos en el futuro)
3. **Presionar "Debug notificaciones"** para verificar el estado
4. **Revisar los logs** en la consola para confirmar la programación
5. **Esperar** a la hora configurada para verificar que la notificación aparece

## Logs Esperados

```
I/flutter: Habilitando notificaciones...
I/flutter: Notificaciones anteriores canceladas
I/flutter: Programando notificación para las 14:30
I/flutter: Fecha programada: 2025-07-05 14:30:00.000-05:00
I/flutter: Tiempo hasta la notificación: 0:01:45.000000
I/flutter: ✅ Notificación programada exitosamente para: 2025-07-05 14:30:00.000-05:00
I/flutter: Notificaciones pendientes después de programar: 1
```

## Verificación de Funcionamiento

Para verificar que las notificaciones programadas funcionan:

1. Configura una hora 2-3 minutos en el futuro
2. Usa el botón "Debug notificaciones"
3. Verifica en los logs que hay 1 notificación pendiente
4. Espera a la hora configurada
5. La notificación debe aparecer automáticamente

## Notas Importantes

- Las notificaciones usan `DateTimeComponents.time` para repetirse diariamente
- Se requieren permisos especiales en Android 13+ (ya configurados)
- El timezone se configura automáticamente al inicializar
- Las notificaciones se reprograman cada vez que cambias la hora