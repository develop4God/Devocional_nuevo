// lib/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importaciones para tu proyecto 'devocional_nuevo'
import 'package:devocional_nuevo/pages/devocionales_page.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds: 1500), // Duración de la animación para el fondo/texto
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward(); // Inicia la animación
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Puedes ajustar este tiempo de espera.
    await Future.delayed(const Duration(milliseconds: 2000));

    final devocionalProvider =
        Provider.of<DevocionalProvider>(context, listen: false);
    await devocionalProvider.initializeData();

    await Future.delayed(const Duration(
        milliseconds: 500)); // Espera un poco más antes de la transición

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration:
              const Duration(milliseconds: 600), // Duración de la transición
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DevocionalesPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        // 'StackFit.expand' asegura que el Stack y su contenido cubran toda la pantalla.
        fit: StackFit.expand,
        children: [
          // 1. Capa de la imagen de fondo (cubriendo toda la pantalla)
          // La imagen de fondo aparecerá con la animación de fade.
          FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              'assets/images/splash_background.png', // <<< Tu imagen de fondo principal
              fit: BoxFit
                  .cover, // ¡CRUCIAL! Esto hace que la imagen cubra todo el espacio disponible.
              alignment: Alignment.center, // Centra la imagen si hay recortes.
            ),
          ),

          // 2. Capa del texto "Preparando tu espacio con Dios..." superpuesto.
          // El texto también aparecerá con la animación de fade del _fadeAnimation.
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Centra verticalmente los elementos
                children: [
                  // Aquí no hay Image.asset del logo, si no lo quieres mostrar.
                  // Si tu splash_background.png ya tiene el logo integrado, esto está bien.

                  // Puedes añadir un SizedBox si quieres más espacio encima del texto
                  // const SizedBox(height: 100), // Ejemplo: Ajusta este valor si necesitas mover el texto más abajo

                  Text(
                    'Preparando tu espacio con Dios...',
                    textAlign:
                        TextAlign.center, // Centra el texto si es multilínea
                    style: TextStyle(
                      fontSize: 22, // Tamaño de fuente original
                      fontWeight: FontWeight.bold,
                      color:
                          Color.fromARGB(255, 255, 255, 255), // Color del texto
                      // Sombras para mejorar la visibilidad sobre el fondo
                      shadows: [
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(
                              150, 0, 0, 0), // Sombra negra semi-transparente
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
