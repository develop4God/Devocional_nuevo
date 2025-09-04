# Devocionales Cristianos

Aplicación móvil multilingüe para leer devocionales diarios con funcionalidades avanzadas de audio, favoritos y tracking espiritual.

## ✨ Características Principales

- **📖 Devocionales Diarios**: Contenido espiritual actualizado
- **🌍 Soporte Multilingüe**: Español, Inglés, Portugués, Francés
- **🔊 Audio TTS**: Lectura de devocionales con síntesis de voz
- **⭐ Favoritos**: Guarda tus devocionales preferidos
- **📊 Tracking Espiritual**: Estadísticas de lectura y progreso
- **🙏 Gestión de Oraciones**: Seguimiento de oraciones personales
- **📴 Modo Offline**: Acceso sin conexión a internet
- **🔔 Notificaciones**: Recordatorios personalizables
- **📱 Compartir**: Comparte contenido inspirador

## 🚀 Estado del Proyecto

### ✅ Testing Coverage - 95%+ en Servicios Críticos
- **80+ Tests Unitarios**: Cobertura completa de funcionalidad
- **Servicios Críticos**: PrayerProvider, TtsService, LocalizationService
- **Providers**: DevocionalProvider, AudioController  
- **Performance**: Todos los tests < 30 segundos
- **CI/CD Ready**: Tests automatizados con mocking robusto

### 🎯 Idiomas y Versiones Bíblicas
- **Español**: RVR1960, NVI
- **Inglés**: KJV, NIV  
- **Portugués**: ARC
- **Francés**: LSG1910

## 🛠️ Tecnologías

- **Flutter 3.32.8**: Framework principal
- **Provider**: Gestión de estado
- **Firebase**: Notificaciones y analytics
- **SharedPreferences**: Persistencia local
- **TTS**: Síntesis de voz multilingüe
- **HTTP**: API de contenido
- **Testing**: Mockito, flutter_test

## Sistema de Notificaciones

La aplicación cuenta con un sistema completo de notificaciones push que incluye:

- **Notificaciones locales programadas**: Recordatorios diarios para leer el devocional
- **Notificaciones remotas**: Recibe mensajes importantes a través de Firebase Cloud Messaging
- **Notificaciones con contenido dinámico**: Muestra el título del devocional del día
- **Notificaciones con imágenes**: Soporte para notificaciones con imágenes grandes
- **Gestión de permisos**: Solicitud y verificación de permisos de notificaciones
- **Tareas en segundo plano**: Actualización de contenido incluso cuando la app está cerrada

### Configuración de Firebase

Para completar la configuración de Firebase Cloud Messaging, consulta el archivo [FIREBASE_SETUP.md](FIREBASE_SETUP.md).

## Requisitos

- Flutter 3.32.8 o superior
- Dart 3.8.1 o superior
- Android SDK 21+ (Android 5.0+)
- iOS 11.0+

## 🧪 Testing

### Ejecutar Tests
```bash
# Todos los tests
flutter test

# Tests específicos
flutter test test/unit/services/
flutter test test/unit/providers/
flutter test test/unit/controllers/

# Con cobertura
flutter test --coverage
```

### Estructura de Tests
```
test/
├── unit/                    # Tests unitarios
│   ├── services/           # Tests de servicios
│   ├── providers/          # Tests de providers
│   ├── controllers/        # Tests de controladores
│   └── models/            # Tests de modelos
├── integration_test/       # Tests de integración
├── mocks.dart             # Generación de mocks
├── test_setup.dart        # Configuración común
└── *.dart                 # Tests específicos
```

### Coverage por Componente
| Componente | Tests | Cobertura |
|------------|-------|-----------|
| PrayerProvider | 15 | 95%+ |
| TtsService | 13 | 95%+ |
| LocalizationService | 4 | 95%+ |
| DevocionalProvider | 15 | 90%+ |
| AudioController | 11 | 75%+ |

## Instalación

1. Clona este repositorio
2. Ejecuta `flutter pub get` para instalar las dependencias
3. Configura Firebase siguiendo las instrucciones en [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
4. Ejecuta `flutter run` para iniciar la aplicación

## Estructura del Proyecto

- `lib/main.dart`: Punto de entrada de la aplicación
- `lib/services/`: Servicios para notificaciones, API, etc.
- `lib/pages/`: Pantallas de la aplicación
- `lib/providers/`: Proveedores de estado (usando Provider)
- `lib/models/`: Modelos de datos
- `lib/widgets/`: Widgets reutilizables

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo LICENSE para más detalles
