// lib/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importa DevocionalProvider y DevocionalesPage desde main.dart
// Si en el futuro mueves DevocionalProvider y DevocionalesPage a sus propios archivos,
// deberás actualizar esta importación. Por ejemplo:
// import 'providers/devocional_provider.dart';
// import 'screens/devocionales_page.dart';
import './main.dart'; // Asume que main.dart está en el mismo directorio (lib)

/// SplashScreen: Pantalla de carga inicial de la aplicación.
///
/// Esta pantalla se muestra mientras se cargan los datos necesarios
/// (configuraciones y devocionales) antes de dirigir al usuario
/// a la página principal de devocionales.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia la carga de datos de la aplicación cuando el widget se inicializa.
    _initializeAppData();
  }

  /// Carga los datos iniciales de la aplicación.
  ///
  /// Obtiene la instancia de [DevocionalProvider] y llama a su método
  /// [initializeData] para cargar las configuraciones guardadas y los
  /// devocionales desde la red.
  /// Una vez completada la carga, navega a [DevocionalesPage].
  Future<void> _initializeAppData() async {
    // Accede a DevocionalProvider sin escuchar cambios,
    // ya que solo se necesita para llamar a un método.
    final devocionalProvider =
        Provider.of<DevocionalProvider>(context, listen: false);

    // Carga las configuraciones y los devocionales.
    await devocionalProvider.initializeData();

    // Comprueba si el widget todavía está montado (visible y activo)
    // antes de intentar una navegación para evitar errores.
    if (mounted) {
      // Reemplaza la pantalla actual (SplashScreen) con DevocionalesPage
      // para que el usuario no pueda volver atrás al splash.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DevocionalesPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI del SplashScreen.
    return const Scaffold(
      backgroundColor: Colors.deepPurple, // Color de fondo del splash
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
                color: Colors.white), // Indicador de progreso circular
            SizedBox(height: 20),
            Text(
              'Cargando devocionales...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            // Aquí podrías añadir un logo si lo deseas:
            // Image.asset('assets/logo.png', width: 150, height: 150),
          ],
        ),
      ),
    );
  }
}
