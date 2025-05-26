// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importación necesaria para initializeDateFormatting
import 'package:flutter_localizations/flutter_localizations.dart'; // Importación para delegados de localización

// Importa los archivos que acabas de separar
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/splash_screen.dart'; // Asegúrate de que esta ruta sea correcta

void main() async {
  // <--- CAMBIO: main() ahora es async
  WidgetsFlutterBinding.ensureInitialized(); // <--- CAMBIO: Asegura que los bindings de Flutter estén listos

  // <--- CAMBIO: Inicializa los datos de localización para español
  // Esto debe hacerse ANTES de que cualquier widget que use DateFormat sea construido.
  await initializeDateFormatting('es', null);

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        // <--- CAMBIO: Añade los delegados y locales soportados para la internacionalización
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // Soporte para inglés
          Locale('es', ''), // Soporte para español
        ],

        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
