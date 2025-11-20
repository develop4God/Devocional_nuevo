import 'package:flutter/foundation.dart';

class DevotionalImageNormalizer {
  /// Normaliza la URL de la imagen para el tamaño y formato adecuado.
  /// Si el backend soporta parámetros, los agrega; si no, solo documenta el tamaño esperado.
  String normalize(String url, {int width = 600, int height = 400}) {
    debugPrint('[DEBUG] [Normalizer] Recibida URL: $url');
    debugPrint('[DEBUG] [Normalizer] Solicitado tamaño: ${width}x$height');
    if (url.isEmpty) {
      debugPrint('[DEBUG] [Normalizer] URL vacía, devolviendo fallback');
      return url;
    }
    // Ejemplo: si el backend soporta parámetros tipo '?w=600&h=400', los agregamos
    if (url.contains('githubusercontent.com')) {
      debugPrint('[DEBUG] [Normalizer] URL de GitHub detectada');
      // GitHub no soporta redimensionamiento, solo devolvemos la URL original
      debugPrint(
          '[DEBUG] [Normalizer] GitHub no soporta resize, se entrega la URL original');
      return url;
    }
    debugPrint(
        '[DEBUG] [Normalizer] URL no reconocida como GitHub, se entrega la URL original');
    // Si en el futuro se usa un CDN, aquí se puede modificar la URL
    // Por ahora, solo documentamos el tamaño esperado
    return url;
  }
}
