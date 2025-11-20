import 'dart:convert';
import 'dart:math';

import 'package:devocional_nuevo/services/devotional_image_normalizer.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DevotionalImageRepository {
  final String apiUrl;
  final String fallbackUrl;
  final DevotionalImageNormalizer normalizer;

  DevotionalImageRepository({
    this.apiUrl =
        'https://api.github.com/repos/develop4God/Devocionales-assets/contents/images',
    this.fallbackUrl =
        'https://raw.githubusercontent.com/develop4God/Devocionales-assets/main/images/devocional_default.jpg',
    DevotionalImageNormalizer? normalizer,
  }) : normalizer = normalizer ?? DevotionalImageNormalizer();

  Future<String> getRandomImageUrl({int width = 600, int height = 400}) async {
    debugPrint('[DEBUG] Iniciando fetch de imágenes desde GitHub');
    try {
      final response = await http.get(Uri.parse(apiUrl));
      debugPrint('[DEBUG] Respuesta status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> files = json.decode(response.body);
        debugPrint('[DEBUG] Archivos recibidos: ${files.length}');
        final List<String> imageUrls = files
            .where((file) =>
                file['type'] == 'file' &&
                (file['name'].toLowerCase().endsWith('.jpg') ||
                    file['name'].toLowerCase().endsWith('.jpeg') ||
                    file['name'].toLowerCase().endsWith('.avif')))
            .map<String>((file) => file['download_url'] as String)
            .toList();
        debugPrint('[DEBUG] Imágenes filtradas: ${imageUrls.length}');
        if (imageUrls.isNotEmpty) {
          final random = Random();
          final selected = imageUrls[random.nextInt(imageUrls.length)];
          debugPrint('[DEBUG] Imagen seleccionada: $selected');
          final normalized =
              normalizer.normalize(selected, width: width, height: height);
          debugPrint('[DEBUG] Imagen normalizada: $normalized');
          return normalized;
        } else {
          debugPrint('[DEBUG] No se encontraron imágenes válidas.');
        }
      } else {
        debugPrint('[DEBUG] Error en la respuesta HTTP: ${response.body}');
      }
    } catch (e) {
      debugPrint('[DEBUG] Error obteniendo imágenes: $e');
    }
    debugPrint('[DEBUG] Usando imagen por defecto.');
    final normalizedFallback =
        normalizer.normalize(fallbackUrl, width: width, height: height);
    debugPrint('[DEBUG] Imagen fallback normalizada: $normalizedFallback');
    return normalizedFallback;
  }
}
