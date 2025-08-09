# Funcionalidad Offline - Documentación

## Descripción

Se ha implementado funcionalidad offline completa en el `DevocionalProvider` que permite descargar y almacenar los archivos JSON de devocionales en el dispositivo del usuario para acceso sin conexión a internet.

**ACTUALIZACIÓN**: La gestión offline ha sido migrada del Settings al Drawer principal para mejorar la experiencia de usuario y accesibilidad.

## Características implementadas

### 1. Descarga manual y gestión offline
- **Descarga a demanda**: Los devocionales se descargan solo cuando el usuario lo solicita explícitamente
- **Gestión desde Drawer**: Interfaz accesible para descargar y gestionar contenido offline  
- **Verificación previa**: Se verifica si ya existe contenido local antes de descargar

### 2. Almacenamiento local
- Usa `path_provider` para localizar directorios accesibles del dispositivo
- Los archivos se guardan en `[DocumentsDirectory]/devocionales/`
- Formato: `devocional_[YEAR]_[LANGUAGE].json`

### 3. Carga offline-first
- Prioriza contenido local sobre descargas de red
- Fallback automático a API si no hay contenido local
- Indicador visual de modo offline

## Arquitectura de Componentes

### OfflineManagerWidget
Componente reutilizable extraído de la página de configuraciones que maneja toda la lógica de gestión offline:

```dart
OfflineManagerWidget({
  bool showCompactView = false,      // Vista compacta vs completa
  bool showStatusIndicator = true,   // Mostrar indicadores de estado
})
```

#### Características del widget:
- **Vista compacta**: Solo botón de descarga principal
- **Vista completa**: Botones de descarga y actualización + información adicional
- **Estados visuales**: Indicadores de progreso, éxito y error
- **Integración con provider**: Usa Consumer para sincronización de estado

### Integración en Drawer
El componente se integra en `DevocionalesDrawer` mediante:
- **Estado dinámico**: Muestra "Descargar devocionales" o "Devocionales descargados"
- **Iconos adaptativos**: Download → Check verde cuando hay contenido local
- **Diálogo modal**: Abre `OfflineManagerWidget` en modo completo
- **Feedback visual**: Estados de carga y mensajes de éxito/error

## API del DevocionalProvider

### Nuevas propiedades (getters)

```dart
bool get isDownloading          // Estado de descarga en progreso
String? get downloadStatus      // Mensaje de estado de descarga  
bool get isOfflineMode          // Indica si se está usando contenido offline
```

### Nuevos métodos públicos

```dart
// Descarga manual del año actual
Future<bool> downloadCurrentYearDevocionales()

// Descarga de un año específico
Future<bool> downloadDevocionalesForYear(int year)

// Verifica contenido local para el año actual
Future<bool> hasCurrentYearLocalData()

// Fuerza actualización desde API (ignora local)
Future<void> forceRefreshFromAPI()

// Limpia mensajes de estado de descarga
void clearDownloadStatus()
```

### Métodos de utilidad

```dart
// Verifica si existe archivo local para año/idioma específicos
Future<bool> hasLocalFile(int year, String language)

// Elimina todos los archivos locales guardados
Future<void> clearOldLocalFiles()
```

## Integración en la UI

La funcionalidad se ha integrado en la página de configuraciones (`settings_page.dart`) con:

### Sección "Gestión de contenido offline" que incluye:

1. **Indicador de estado**: Muestra si se está usando contenido offline
2. **Estado de descarga**: Progress indicator y mensajes de estado durante descargas
3. **Botones de acción**:
   - "Descargar año actual": Descarga manual de contenido
   - "Actualizar": Fuerza actualización desde servidor
4. **Información de estado**: Indica si hay contenido offline disponible

### Ejemplo de uso en la UI:

```dart
Consumer<DevocionalProvider>(
  builder: (context, provider, child) {
    return Column(
      children: [
        // Mostrar estado offline
        if (provider.isOfflineMode)
          Text('Usando contenido offline'),
          
        // Botón de descarga
        ElevatedButton(
          onPressed: provider.isDownloading ? null : () async {
            final success = await provider.downloadCurrentYearDevocionales();
            // Mostrar resultado al usuario
          },
          child: Text('Descargar contenido'),
        ),
        
        // Mostrar progreso de descarga
        if (provider.downloadStatus != null)
          Text(provider.downloadStatus!),
      ],
    );
  },
)
```

## Flujo de funcionamiento

1. **Inicialización**: Al cargar la app, se verifica si hay contenido local
2. **Carga condicionada**: Si hay contenido local se usa offline, si no se carga desde API (sin guardar automáticamente)
3. **Indicador en Drawer**: Se muestra el estado actual (descargado/no descargado)
4. **Gestión desde Drawer**: Usuario accede a gestión offline desde el drawer principal
5. **Descarga manual**: Las descargas solo ocurren cuando el usuario las solicita explícitamente
6. **Feedback visual**: Estados se sincronizan automáticamente en toda la UI

## Manejo de errores

- Validación de estructura JSON antes de guardar
- Manejo graceful de errores de red y E/O de archivos
- Mensajes de error informativos para el usuario
- Fallback a idioma por defecto si el solicitado no está disponible

## Archivos modificados

1. `lib/providers/devocional_provider.dart` - Lógica principal offline (sin cambios)
2. `lib/widgets/offline_manager_widget.dart` - **NUEVO**: Componente reutilizable  
3. `lib/widgets/devocionales_page_drawer.dart` - **MODIFICADO**: Integración offline
4. `lib/pages/settings_page.dart` - **MODIFICADO**: Sección offline comentada
5. `test/offline_manager_widget_test.dart` - **NUEVO**: Tests del widget
6. `test/drawer_offline_integration_test.dart` - **NUEVO**: Tests de integración

## Mejoras implementadas

### UX/UI
- ✅ Acceso más directo desde drawer principal
- ✅ Estados visuales mejorados (íconos dinámicos)
- ✅ Feedback inmediato de estado
- ✅ Diálogo modal para gestión detallada

### Arquitectura
- ✅ Componente reutilizable extraído
- ✅ Separación de responsabilidades
- ✅ Evita duplicidad de funcionalidad
- ✅ Mejor organización del código

### Testing
- ✅ Tests unitarios para el widget
- ✅ Tests de integración para el drawer
- ✅ Verificación de estado dinámico

## Dependencias utilizadas

- `dart:io` - Manejo de archivos del sistema
- `path_provider` - Acceso a directorios del dispositivo (ya incluido)
- `http` - Descargas de red (ya incluido)
- `shared_preferences` - Persistencia de configuración (ya incluido)