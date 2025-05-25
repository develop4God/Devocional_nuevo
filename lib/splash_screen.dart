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
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(
        milliseconds: 3000)); // Espera 3 segundo para que el logo aparezca

    final devocionalProvider =
        Provider.of<DevocionalProvider>(context, listen: false);
    await devocionalProvider.initializeData();

    await Future.delayed(
        const Duration(milliseconds: 500)); // Espera un poco más

    if (mounted) {
      // <<< CAMBIO CLAVE AQUÍ: Usamos PageRouteBuilder para la transición personalizada
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration:
              const Duration(milliseconds: 600), // Duración de la transición
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DevocionalesPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Animación de deslizamiento de derecha a izquierda
            const begin = Offset(1.0, 0.0); // Comienza desde la derecha
            const end = Offset.zero; // Termina en su posición normal
            const curve = Curves
                .easeOutCubic; // Curva de aceleración/desaceleración suave

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEFEBE9),
              Color(0xFFD7CCC8),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/LogoVectorDevocional V1.0 500x500.png', // <<< ¡CAMBIA ESTA RUTA Y NOMBRE DE ARCHIVO!
                  width: 500,
                  height: 500,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Preparando tu espacio con Dios...',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 186, 119, 156),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
