// lib/utils/constants.dart

import 'package:flutter/material.dart'; // ¡Importante! Necesario para GlobalKey y NavigatorState

// --- Constantes ---
// Es una buena práctica definir URLs y claves de SharedPreferences como constantes dentro de una clase.
class Constants {
  static const String apiUrl =
      'https://raw.githubusercontent.com/develop4God/Devocionales-json/refs/heads/main/Devocionales_20250608_162909_es_RVR1960.json';

  // Las siguientes constantes no son necesarias en el nuevo modelo basado en fechas y objetos
  // pero las mantengo aquí si las usas en otras partes de tu código por ahora.
  // En el nuevo DevocionalProvider, 'seenIndices' y 'currentIndex' ya no se usan.
  // Y 'favorites' se gestiona directamente con la lista de Devocional objetos.
  static const String PREF_SEEN_INDICES =
      'seenIndices'; // Esto ya no se usa en el nuevo Provider
  static const String PREF_FAVORITES =
      'favorites'; // Esto ya no se usa directamente en el nuevo Provider (usa 'favorites' clave)
  static const String PREF_DONT_SHOW_INVITATION = 'dontShowInvitation';
  static const String PREF_CURRENT_INDEX =
      'currentIndex'; // Esto ya no se usa en el nuevo Provider
}

// Clase de utilidad para obtener el contexto del Navigator.
// Asegúrate de que NavigationService.navigatorKey se asigne a tu MaterialApp en main.dart.
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
