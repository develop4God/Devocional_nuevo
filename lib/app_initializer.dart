// lib/app_initializer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:devocional_nuevo/pages/devocionales_page.dart'; // Importa tu página principal
import 'package:devocional_nuevo/providers/devocional_provider.dart'; // Importa tu provider

/// Un widget que se encarga de inicializar los datos de la aplicación
/// y luego, una vez listos, navega a la página principal (DevocionalesPage).
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeAppData(); // Inicia la carga de datos al crearse el widget
  }

  Future<void> _initializeAppData() async {
    final devocionalProvider =
        Provider.of<DevocionalProvider>(context, listen: false);
    await devocionalProvider.initializeData(); // Carga los datos del devocional

    // Una vez que los datos están cargados, navega a la página principal.
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DevocionalesPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mientras los datos se cargan, este widget muestra un indicador de carga.
    // En la práctica, el usuario solo verá el SplashScreen hasta que termine
    // la navegación a AppInitializer, por lo que este indicador es un fallback
    // para asegurar que algo se muestra si la carga es muy larga o hay un delay.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
