// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importa los archivos que acabas de separar
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/splash_screen.dart'; // Ya lo tienes, ajusta la ruta si es necesario

void main() {
  // WidgetsFlutterBinding.ensureInitialized(); // Descomentar si necesitas ejecutar código async antes de runApp
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DevocionalProvider(),
      child: MaterialApp(
        title: 'Devocionales',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          colorScheme: ColorScheme.fromSeed(
              seedColor:
                  Colors.deepPurple), // Alternativa moderna a primarySwatch
          appBarTheme: const AppBarTheme(
            elevation: 0, // AppBar sin sombra
            backgroundColor: Colors.deepPurple, // Color explícito para AppBar
            foregroundColor:
                Colors.white, // Color para el texto e íconos del AppBar
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true, // Habilita Material 3 si es tu intención
        ),
        // La aplicación ahora inicia en el SplashScreen importado.
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
