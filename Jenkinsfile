pipeline {
    agent any

    environment {
        // Variables de entorno limpias - SIN modificar PATH aquí
        FLUTTER_HOME = "/opt/flutter"
        ANDROID_SDK_ROOT = "/home/jenkins/Android/Sdk"
        ANDROID_HOME = "/home/jenkins/Android/Sdk"
        JAVA_HOME = "/usr/lib/jvm/java-11-openjdk-amd64"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                echo '🔄 Obteniendo código fuente...'
                checkout scm
            }
        }

        stage('Verificar Entorno') {
            steps {
                echo '🔍 Verificando entorno (basado en micro-jobs exitosos)...'
                // Usar withEnv como en la solución que funcionó
                withEnv([
                    "PATH+FLUTTER=${FLUTTER_HOME}/bin",
                    "PATH+CMDLINE=${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin",
                    "PATH+PLATFORM_TOOLS=${ANDROID_SDK_ROOT}/platform-tools",
                    "PATH+BUILD_TOOLS=${ANDROID_SDK_ROOT}/build-tools/34.0.0",
                    "PATH+JAVA=${JAVA_HOME}/bin"
                ]) {
                    sh '''
                        echo "=== VERIFICACIÓN DE HERRAMIENTAS CRÍTICAS ==="
                        echo "PATH actual: $PATH"
                        
                        echo "📱 Verificando Android SDK..."
                        which sdkmanager
                        sdkmanager --version
                        
                        echo "🛠️ Verificando componentes Android..."
                        ls -la "$ANDROID_SDK_ROOT/platforms/" || echo "❌ Platforms no encontrado"
                        ls -la "$ANDROID_SDK_ROOT/build-tools/" || echo "❌ Build-tools no encontrado"
                        ls -la "$ANDROID_SDK_ROOT/platform-tools/" || echo "❌ Platform-tools no encontrado"
                        
                        echo "🚀 Verificando Flutter..."
                        which flutter
                        flutter --version
                        
                        echo "☕ Verificando Java..."
                        which java
                        java --version
                        
                        echo "✅ Verificación de entorno completada"
                    '''
                }
            }
        }

        stage('Configurar Flutter') {
            steps {
                echo '⚙️ Configurando Flutter para Android...'
                withEnv([
                    "PATH+FLUTTER=${FLUTTER_HOME}/bin",
                    "PATH+CMDLINE=${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin",
                    "PATH+PLATFORM_TOOLS=${ANDROID_SDK_ROOT}/platform-tools",
                    "PATH+BUILD_TOOLS=${ANDROID_SDK_ROOT}/build-tools/34.0.0",
                    "PATH+JAVA=${JAVA_HOME}/bin"
                ]) {
                    sh '''
                        echo "=== CONFIGURACIÓN DE FLUTTER ==="
                        # Configurar Flutter para usar nuestro Android SDK
                        flutter config --android-sdk "$ANDROID_SDK_ROOT"
                        
                        # Verificar configuración
                        echo "📋 Verificando configuración aplicada..."
                        flutter config
                        
                        # Flutter doctor específico para Android
                        echo "🏥 Ejecutando Flutter Doctor para Android..."
                        flutter doctor --android-licenses || echo "Licencias ya aceptadas"
                        flutter doctor -v
                    '''
                }
            }
        }

        stage('Limpiar y Obtener Dependencias') {
            steps {
                echo '🧹 Limpiando proyecto y obteniendo dependencias...'
                withEnv([
                    "PATH+FLUTTER=${FLUTTER_HOME}/bin"
                ]) {
                    sh '''
                        echo "=== LIMPIEZA Y DEPENDENCIAS ==="
                        # Limpiar builds anteriores
                        flutter clean
                        
                        # Verificar que existe pubspec.yaml
                        if [ ! -f "pubspec.yaml" ]; then
                            echo "❌ Error: pubspec.yaml no encontrado. ¿Es un proyecto Flutter válido?"
                            exit 1
                        fi
                        
                        # Obtener dependencias
                        flutter pub get
                        
                        echo "✅ Dependencias obtenidas exitosamente"
                    '''
                }
            }
        }

        stage('Ejecutar Tests') {
            steps {
                echo '🧪 Ejecutando tests...'
                withEnv([
                    "PATH+FLUTTER=${FLUTTER_HOME}/bin"
                ]) {
                    script {
                        // Los tests que fallan no rompen el pipeline
                        def testResult = sh(script: 'flutter test', returnStatus: true)
                        if (testResult != 0) {
                            unstable('Tests fallaron pero continuamos el build')
                        }
                    }
                }
            }
        }

        stage('Build APK Debug') {
            steps {
                echo '🔨 Construyendo APK Debug...'
                withEnv([
                    "PATH+FLUTTER=${FLUTTER_HOME}/bin",
                    "PATH+CMDLINE=${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin",
                    "PATH+PLATFORM_TOOLS=${ANDROID_SDK_ROOT}/platform-tools",
                    "PATH+BUILD_TOOLS=${ANDROID_SDK_ROOT}/build-tools/34.0.0",
                    "PATH+JAVA=${JAVA_HOME}/bin"
                ]) {
                    sh '''
                        echo "=== BUILD APK DEBUG ==="
                        flutter build apk --debug
                        
                        # Verificar que el APK se creó
                        APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
                        if [ -f "$APK_PATH" ]; then
                            echo "✅ APK Debug creado exitosamente"
                            ls -lh "$APK_PATH"
                        else
                            echo "❌ Error: APK Debug no encontrado"
                            exit 1
                        fi
                    '''
                }
            }
        }

        stage('Build App Bundle Release') {
            steps {
                echo '📦 Construyendo App Bundle Release...'
                withEnv([
                    "PATH+FLUTTER=${FLUTTER_HOME}/bin",
                    "PATH+CMDLINE=${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin",
                    "PATH+PLATFORM_TOOLS=${ANDROID_SDK_ROOT}/platform-tools",
                    "PATH+BUILD_TOOLS=${ANDROID_SDK_ROOT}/build-tools/34.0.0",
                    "PATH+JAVA=${JAVA_HOME}/bin"
                ]) {
                    sh '''
                        echo "=== BUILD APP BUNDLE RELEASE ==="
                        flutter build appbundle --release
                        
                        # Verificar que el AAB se creó
                        AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
                        if [ -f "$AAB_PATH" ]; then
                            echo "✅ App Bundle Release creado exitosamente"
                            ls -lh "$AAB_PATH"
                        else
                            echo "❌ Error: App Bundle Release no encontrado"
                            exit 1
                        fi
                    '''
                }
            }
        }

        stage('Análisis Final') {
            steps {
                echo '📊 Realizando análisis final...'
                sh '''
                    echo "=== ANÁLISIS FINAL ==="
                    echo "📁 Estructura de builds generados:"
                    find build/app/outputs -name "*.apk" -o -name "*.aab" | while read file; do
                        echo "  📱 $(basename "$file"): $(du -h "$file" | cut -f1)"
                    done
                    
                    echo "✅ Análisis completado"
                '''
            }
        }
    }

    post {
        always {
            echo '🏁 Pipeline finalizado.'

            script {
                // Archivar artefactos si existen
                try {
                    archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/*.apk,build/app/outputs/bundle/release/*.aab', 
                                   fingerprint: true, 
                                   allowEmptyArchive: true
                    echo '📁 Artefactos archivados exitosamente'
                } catch (Exception e) {
                    echo "⚠️ No se pudieron archivar algunos artefactos: ${e.getMessage()}"
                }
            }
        }

        success {
            echo '''
            🎉 ¡PIPELINE EXITOSO! 
            
            ✅ Builds generados correctamente:
            • APK Debug para testing
            • App Bundle Release para Play Store
            
            🚀 Artefactos disponibles en la sección de artifacts
            
            🙌 ¡Gloria a Dios por esta victoria!
            '''
        }

        failure {
            echo '''
            ❌ Pipeline falló. Revisa los logs para identificar el problema.
            
            🔍 Pasos de debugging recomendados:
            1. Verificar que el repositorio tenga un proyecto Flutter válido
            2. Revisar los logs de la etapa que falló
            3. Confirmar que las dependencias en pubspec.yaml son correctas
            4. Verificar permisos de archivos si es necesario
            
            💡 Recuerda: Los micro-jobs demuestran que el entorno funciona correctamente
            '''
        }

        unstable {
            echo '''
            ⚠️ Pipeline completado con warnings (probablemente tests fallidos).
            
            ✅ Los builds se generaron correctamente
            🧪 Revisa los tests que fallaron si es necesario
            '''
        }
    }
}
