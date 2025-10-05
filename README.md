# Devocionales Cristianos

Aplicación móvil multilingüe para leer devocionales diarios con funcionalidades avanzadas de audio, favoritos, tracking espiritual y sistema inteligente de reseñas.

## ✨ Características Principales

- **📖 Devocionales Diarios**: Contenido espiritual actualizado diariamente
- **🌍 Soporte Multilingüe**: Español, Inglés, Portugués, Francés con localización completa
- **🔊 Audio TTS**: Lectura de devocionales con síntesis de voz personalizable
- **⭐ Favoritos**: Guarda y organiza tus devocionales preferidos
- **📊 Tracking Espiritual**: Estadísticas detalladas de lectura, rachas y progreso
- **🙏 Gestión de Oraciones**: Seguimiento completo de oraciones personales con estados
- **📴 Modo Offline**: Acceso completo sin conexión a internet
- **🔔 Notificaciones Push**: Recordatorios personalizables y notificaciones remotas
- **📱 Compartir**: Comparte contenido inspirador con otros
- **☁️ Respaldo en la Nube**: Sincronización automática con Google Drive
- **🚀 Onboarding Inteligente**: Configuración guiada inicial con BLoC architecture
- **⭐ Sistema de Reseñas Inteligente**: Solicita reseñas en momentos óptimos
- **🎨 Temas Personalizables**: Múltiples temas visuales con soporte claro/oscuro
- **📖 Múltiples Versiones Bíblicas**: RVR1960, NVI, KJV, NIV, ARC, LSG1910, TOB
- **🔍 Búsqueda y Filtrado**: Encuentra devocionales por fecha, favoritos o contenido
- **📈 Estadísticas Detalladas**: Visualiza tu progreso espiritual con métricas completas

## 🆕 Actualizaciones Recientes

### 🚀 Sistema de Onboarding con BLoC Architecture
- **Arquitectura BLoC**: Migración completa del onboarding a patrón BLoC para mejor mantenimiento
- **Configuración Guiada**: Flow paso a paso para selección de tema y configuración de respaldo
- **Persistencia Inteligente**: Guardado automático de progreso con recuperación ante interrupciones
- **Localización Completa**: Soporte total en 4 idiomas con keys actualizadas
- **UI Responsiva**: Diseño adaptativo que funciona en todos los tamaños de pantalla
- **Manejo de Errores**: Sistema robusto de recuperación de errores con diálogos informativos
- **Timeout Protection**: Protección de 30 segundos para conexiones Google Drive
- **Testing Exhaustivo**: 45+ tests cubriendo todos los escenarios posibles

### 🌍 Soporte Multilingüe Mejorado
El sistema solicita reseñas automáticamente cuando los usuarios alcanzan hitos significativos:
- **5° devocional** (validación de engagement temprano)
- **25° devocional** (usuario comprometido)
- **50° devocional** (usuario regular)
- **100° devocional** (usuario dedicado)
- **200° devocional** (super usuario)

### 🌍 Soporte Multilingüe Mejorado
- **Onboarding Localizado**: Todas las pantallas de configuración inicial totalmente traducidas
- **Keys Corregidas**: Sistema de localización mejorado con estructura jerárquica (onboarding.*)
- **Mensajes de Error**: Feedback localizado para conexiones y timeouts
- **4 Idiomas Completos**: Español, English, Português, Français

### ☁️ Sistema de Respaldo Mejorado
- **Google Drive Integration**: Conexión segura con timeout protection
- **Manejo de Cancelación**: Recuperación elegante cuando el usuario cancela la autenticación
- **Estado de Conexión**: Indicadores claros de progreso y estado de conexión
- **Auto-configuración**: Configuración automática óptima tras conexión exitosa
- **Tests de Login Flow**: Cobertura completa de flujos de autenticación y cancelación

### 🎯 Momentos Inteligentes para Reseñas
Diálogos de reseña localizados en todos los idiomas:
- **Español**: "Gracias por tu constancia 🙏"
- **English**: "Thank you for your consistency 🙏"
- **Português**: "Obrigado pela sua constância 🙏"
- **Français**: "Merci pour votre constance 🙏"

### ⏰ Sistema de Enfriamiento Inteligente
- **90 días de enfriamiento global**: Previene sobre-solicitud
- **30 días "recordar después"**: Respeta la elección del usuario
- **Preferencias permanentes**: "Ya califiqué" y "No preguntar más"

### 📱 Integración Nativa con Respaldos
- **Primario**: API nativa de Android/iOS
- **Respaldo**: Redirección directa a Play Store/App Store
- **Fallback final**: Lanzador de URL para casos extremos

## 🚀 Estado del Proyecto

### ✅ Testing Coverage - 95%+ en Servicios Críticos
- **135+ Tests Unitarios**: Cobertura completa de funcionalidad incluyendo OnboardingBloc
- **45+ Tests del Sistema de Onboarding**: Cobertura exhaustiva del nuevo BLoC architecture
- **36 Tests del Sistema de Reseñas**: Cobertura exhaustiva del feature de reseñas
- **Smoke Test Comprehensivo**: Test de flujo completo onboarding → main → drawer *(NUEVO)*
- **Login Flow Tests**: Tests específicos para flujos de autenticación y manejo de cancelación
- **Servicios Críticos**: PrayerProvider, TtsService, LocalizationService, InAppReviewService, OnboardingBloc
- **Providers**: DevocionalProvider, AudioController, ThemeBloc
- **Performance**: Todos los tests < 30 segundos
- **CI/CD Ready**: Tests automatizados con mocking robusto

### 🎯 Idiomas y Versiones Bíblicas
- **Español**: RVR1960, NVI
- **Inglés**: KJV, NIV  
- **Portugués**: ARC, NVI
- **Francés**: LSG1910, TOB

## 🛠️ Tecnologías

- **Flutter 3.32.8**: Framework principal multiplataforma
- **Dart 3.8.1**: Lenguaje de programación
- **BLoC Pattern**: Gestión de estado para lógica compleja (Onboarding, Theme, Prayer, Backup)
- **Provider**: Gestión de estado para casos simples (DevocionalProvider, LocalizationProvider)
- **Firebase Core**: Plataforma backend
- **Firebase Messaging**: Notificaciones push remotas
- **Firebase Auth**: Autenticación anónima de usuarios
- **Firebase Remote Config**: Configuración remota de features
- **Google Drive API**: Respaldo y sincronización en la nube
- **SharedPreferences**: Persistencia local de datos
- **flutter_tts**: Síntesis de voz multilingüe
- **HTTP**: Comunicación con API REST
- **Mockito & Mocktail**: Framework de mocking para tests
- **bloc_test**: Testing utilities para BLoC
- **in_app_review**: Sistema nativo de reseñas de tienda
- **google_fonts**: Tipografías personalizadas
- **share_plus**: Compartir contenido
- **url_launcher**: Abrir URLs externas

## 🏗️ Arquitectura

### Arquitectura Limpia
- **Separación de responsabilidades**: Límites claros entre capas
- **Patrón BLoC**: Para gestión de estado compleja (devocionales, oraciones)
- **Patrón Provider**: Para gestión de estado simple (tema, localización)
- **Capa de Servicios**: Servicios dedicados para funcionalidad central
- **Widgets Reutilizables**: Componentes UI en carpeta dedicada

### Estructura de Carpetas
```
lib/
├── blocs/                    # Gestión de estado BLoC
│   ├── onboarding/           # BLoC de onboarding (4 archivos)
│   ├── prayer_bloc.dart      # Gestión de oraciones
│   ├── theme/                # BLoC de temas
│   ├── backup_bloc.dart      # Gestión de respaldos
│   └── backup_event.dart
├── controllers/              # Controladores de aplicación
│   └── audio_controller.dart # Control de audio TTS
├── extensions/               # Extensiones de Dart
│   ├── string_extensions.dart  # Extensiones para strings (tr())
│   └── datetime_extensions.dart
├── models/                   # Modelos de datos
│   ├── devocional_model.dart
│   ├── prayer_model.dart
│   ├── spiritual_stats_model.dart
│   └── theme_preference.dart
├── pages/                    # Pantallas de la aplicación
│   ├── devocionales_page.dart
│   ├── favorites_page.dart
│   ├── prayers_page.dart
│   ├── settings_page.dart
│   ├── onboarding/           # 4 páginas de onboarding
│   └── statistics_page.dart
├── providers/                # Proveedores de estado
│   ├── devocional_provider.dart
│   └── localization_provider.dart
├── services/                 # Servicios centrales
│   ├── tts/                  # Servicios específicos de TTS
│   │   ├── tts_service.dart
│   │   ├── voice_settings_service.dart
│   │   └── bible_text_formatter.dart
│   ├── onboarding_service.dart
│   ├── google_drive_auth_service.dart
│   ├── google_drive_backup_service.dart
│   ├── spiritual_stats_service.dart
│   ├── notification_service.dart
│   ├── in_app_review_service.dart
│   ├── localization_service.dart
│   ├── connectivity_service.dart
│   └── compression_service.dart
├── utils/                    # Utilidades y constantes
│   └── bubble_constants.dart # Constantes de la aplicación
├── widgets/                  # Componentes UI reutilizables
│   ├── devocionales_page_drawer.dart
│   ├── theme_selector.dart
│   ├── donate/               # Widgets de donaciones
│   └── onboarding/           # Widgets de onboarding
└── main.dart                 # Punto de entrada de la aplicación
```

## Sistema de Notificaciones

La aplicación cuenta con un sistema completo de notificaciones push que incluye:

- **Notificaciones locales programadas**: Recordatorios diarios para leer el devocional
- **Notificaciones remotas**: Recibe mensajes importantes a través de Firebase Cloud Messaging
- **Notificaciones con contenido dinámico**: Muestra el título del devocional del día
- **Notificaciones con imágenes**: Soporte para notificaciones con imágenes grandes
- **Gestión de permisos**: Solicitud y verificación de permisos de notificaciones
- **Tareas en segundo plano**: Actualización de contenido incluso cuando la app está cerrada

## 📱 Funcionalidades de la App

### Flujo Inicial de la Aplicación

1. **SplashScreen Animado**
   - Pantalla de bienvenida con animaciones y partículas luminosas
   - Inicialización de servicios en segundo plano (Firebase, localización, Remote Config)
   - Transición suave al onboarding o pantalla principal

2. **Sistema de Onboarding** (Primera vez o actualizaciones)
   - **Bienvenida**: Presentación de la aplicación
   - **Selección de Tema**: Elige entre múltiples temas visuales
   - **Configuración de Respaldo**: Opcional - Conectar con Google Drive
   - **Pantalla de Completado**: Confirmación y entrada a la aplicación

3. **Pantalla Principal - Devocionales**
   - Visualización del devocional del día
   - Navegación entre devocionales (anterior/siguiente)
   - Reproducción de audio TTS
   - Opciones para marcar como favorito
   - Compartir devocional

### Drawer de Navegación

El menú lateral (drawer) proporciona acceso a:

- **Versión Bíblica**: Selector de versión según idioma
- **Idioma**: Cambio entre es, en, pt, fr
- **Tema Visual**: Selector de temas con preview
- **Favoritos**: Acceso a devocionales guardados
- **Oraciones**: Gestión de lista de oraciones
- **Estadísticas**: Progreso espiritual y métricas
- **Notificaciones**: Configuración de recordatorios
- **Respaldo**: Sincronización con Google Drive
- **Donaciones**: Soporte al proyecto
- **Compartir App**: Compartir con otros usuarios

### Gestión de Oraciones

- Crear nuevas oraciones con título y descripción
- Marcar oraciones como respondidas
- Ver historial de oraciones activas y respondidas
- Estadísticas de oraciones

### Sistema de Estadísticas Espirituales

- **Tracking de Lectura**: Total de devocionales leídos
- **Rachas**: Días consecutivos de lectura
- **Favoritos**: Contador de devocionales favoritos
- **Progreso Visual**: Gráficos y métricas de avance
- **Historial**: Fechas de última actividad y logros

### Audio y TTS

- **Reproducción de Audio**: Lectura automática del devocional
- **Configuración de Voz**: Velocidad, tono, volumen
- **Múltiples Idiomas**: Voces nativas para cada idioma
- **Controles de Reproducción**: Play, pause, stop
- **Formateo Especial**: Manejo de textos bíblicos

### Respaldo en la Nube

- **Autenticación Google**: Login seguro con Google Drive
- **Respaldo Automático**: Sincronización periódica de datos
- **Restauración**: Recuperación de datos en nuevo dispositivo
- **Configuración Manual**: Backup on-demand
- **Estado de Conexión**: Indicadores visuales de sincronización

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

# Tests del sistema de reseñas
flutter test test/in_app_review_service_test.dart

# Tests específicos por categoría
flutter test test/unit/services/
flutter test test/unit/providers/
flutter test test/unit/controllers/

# Con cobertura
flutter test --coverage
```

### Estructura de Tests
```
test/
├── unit/                    # Tests unitarios organizados
│   ├── controllers/         # Tests de controladores
│   ├── extensions/          # Tests de extensiones
│   ├── providers/           # Tests de proveedores
│   ├── services/            # Tests de servicios
│   └── utils/               # Tests de utilidades
├── integration/             # Tests de integración
├── mocks/                   # Mocks para testing
└── *.dart                   # Tests principales y configuración
```

### Cobertura de Tests del Sistema de Reseñas
- ✅ **17 Tests de Funcionalidad Central**: Detección de hitos, validación, preferencias
- ✅ **8 Tests de Usuarios Existentes**: Lógica para usuarios con 5+ devocionales
- ✅ **8 Tests de Integración**: Ciclo de vida de contexto, seguridad async
- ✅ **2 Tests de Modo Debug**: Comportamiento en desarrollo
- ✅ **1 Test de Widget**: Integración UI con gestión apropiada de contexto

### Smoke Test Completo
- ✅ **Configuración de Mocks**: Firebase, SharedPreferences, Platform Channels
- ✅ **Flujo de Onboarding**: Welcome → Theme Selection → Backup Config → Complete
- ✅ **Carga de App Principal**: Validación de SplashScreen y DevocionalesPage
- ✅ **Interacción de Drawer**: Apertura y verificación de contenido
- ⚠️  **Nota**: Requiere configuración de Google Fonts en assets para ejecutarse completamente

## Instalación

1. Clona este repositorio
2. Ejecuta `flutter pub get` para instalar las dependencias
3. Ejecuta `flutter run` para iniciar la aplicación

## 📚 Documentación

### Documentación del Proyecto
- [DEVOCIONAL_NUEVO_LIB_STRUCTURE.md](./DEVOCIONAL_NUEVO_LIB_STRUCTURE.md) - Estructura detallada del código fuente
- [DEVOCIONAL_NUEVO_TEST_STRUCTURE.md](./DEVOCIONAL_NUEVO_TEST_STRUCTURE.md) - Estructura detallada de tests
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Documentación de arquitectura
- [TECHNICAL_SERVICES.md](./TECHNICAL_SERVICES.md) - Documentación de servicios
- [TEST_COVERAGE_REPORT.md](./TEST_COVERAGE_REPORT.md) - Reporte de cobertura de tests

### Características Técnicas
- **44+ archivos Dart** en 11 directorios con arquitectura organizada
- **40+ archivos de test** con cobertura exhaustiva
- **4 idiomas** completamente soportados (es, en, pt, fr)
- **8 versiones bíblicas** disponibles
- **Funcionalidad offline** completa con caché local
- **Sistema de audio** con configuraciones personalizables de voz
- **Tracking de progreso** y estadísticas espirituales detalladas
- **Sistema de reseñas inteligente** con timing óptimo y localizado
- **Arquitectura BLoC** para gestión de estado compleja
- **Responsive UI** con adaptación a diferentes tamaños de pantalla
- **Manejo robusto de errores** con recuperación automática
- **Testing automatizado** con mocks completos de servicios

## 🔧 Desarrollo

### Análisis de Código
```bash
dart analyze
```

### Formateo de Código
```bash
dart format .
```

### Generar Documentación
```bash
dart doc
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo LICENSE para más detalles
