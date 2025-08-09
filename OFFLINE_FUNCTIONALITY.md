# Funcionalidad Offline - Documentación

## Descripción

Se ha implementado funcionalidad offline completa en el `DevocionalProvider` que permite descargar y almacenar los archivos JSON de devocionales en el dispositivo del usuario para acceso sin conexión a internet.

## Características implementadas

### 1. Descarga automática y manual
- **Descarga automática**: Los datos se guardan automáticamente cuando se descargan desde la API
- **Descarga manual**: Los usuarios pueden descargar contenido desde la UI de configuración
- **Verificación previa**: Se verifica si ya existe contenido local antes de descargar

### 2. Almacenamiento local
- Usa `path_provider` para localizar directorios accesibles del dispositivo
- Los archivos se guardan en `[DocumentsDirectory]/devocionales/`
- Formato: `devocional_[YEAR]_[LANGUAGE].json`

### 3. Carga offline-first
- Prioriza contenido local sobre descargas de red
- Fallback automático a API si no hay contenido local
- Indicador visual de modo offline

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
2. **Carga offline-first**: Se prioriza contenido local si está disponible
3. **Fallback a API**: Si no hay contenido local, se descarga desde la API
4. **Guardado automático**: Los datos descargados se guardan automáticamente
5. **Gestión manual**: Los usuarios pueden descargar/actualizar desde configuración

## Manejo de errores

- Validación de estructura JSON antes de guardar
- Manejo graceful de errores de red y E/O de archivos
- Mensajes de error informativos para el usuario
- Fallback a idioma por defecto si el solicitado no está disponible

## Archivos modificados

1. `lib/providers/devocional_provider.dart` - Lógica principal offline
2. `lib/pages/settings_page.dart` - UI de gestión offline  
3. `test/devocional_provider_offline_test.dart` - Tests unitarios

## Dependencias utilizadas

- `dart:io` - Manejo de archivos del sistema
- `path_provider` - Acceso a directorios del dispositivo (ya incluido)
- `http` - Descargas de red (ya incluido)
- `shared_preferences` - Persistencia de configuración (ya incluido)