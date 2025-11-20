import 'dart:convert';
import 'dart:math';

import 'package:devocional_nuevo/services/devotional_image_normalizer.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DevotionalImageRepository {
  final String apiUrl;
  final DevotionalImageNormalizer normalizer;

  DevotionalImageRepository({
    this.apiUrl =
        'https://api.github.com/repos/develop4God/Devocionales-assets/contents/images',
    DevotionalImageNormalizer? normalizer,
  }) : normalizer = normalizer ?? DevotionalImageNormalizer();

  Future<String> getRandomImageUrl({int width = 600, int height = 400}) async {
    debugPrint('[DEBUG] Iniciando fetch de imágenes desde GitHub');
    List<String> imageUrls = [];
    try {
      final response = await http.get(Uri.parse(apiUrl));
      debugPrint('[DEBUG] Respuesta status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> files = json.decode(response.body);
        debugPrint('[DEBUG] Archivos recibidos: ${files.length}');
        imageUrls = files
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
          debugPrint('[DEBUG] No se encontraron imágenes válidas en GitHub.');
        }
      } else {
        debugPrint('[DEBUG] Error en la respuesta HTTP: ${response.body}');
      }
    } catch (e) {
      debugPrint('[DEBUG] Error obteniendo imágenes: $e');
    }
    // Fallback: usar la primera imagen válida si existe
    if (imageUrls.isNotEmpty) {
      debugPrint('[DEBUG] Usando fallback: primera imagen válida de la lista');
      final normalizedFallback =
          normalizer.normalize(imageUrls.first, width: width, height: height);
      debugPrint('[DEBUG] Imagen fallback normalizada: $normalizedFallback');
      return normalizedFallback;
    }
    // Si no hay ninguna imagen válida, usar un placeholder genérico
    debugPrint('[DEBUG] No hay imágenes válidas, usando placeholder genérico');
    return 'https://via.placeholder.com/${width}x${height}?text=Devocional';
  }

  Future<String> getImageForToday(List<String> imageUrls) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey =
        'devocional_image_${DateTime.now().toIso8601String().substring(0, 10)}';
    final savedUrl = prefs.getString(todayKey);
    debugPrint('[DEBUG] [ImageRepo] Imagen en cache para hoy: $savedUrl');
    if (savedUrl != null) {
      if (imageUrls.contains(savedUrl)) {
        debugPrint('[DEBUG] [ImageRepo] Imagen en cache es válida: $savedUrl');
        return savedUrl;
      } else {
        debugPrint(
            '[DEBUG] [ImageRepo] Imagen en cache no es válida, seleccionando nueva.');
      }
    }
    if (imageUrls.isNotEmpty) {
      final random = Random();
      final selected = imageUrls[random.nextInt(imageUrls.length)];
      await prefs.setString(todayKey, selected);
      debugPrint(
          '[DEBUG] [ImageRepo] Imagen del día asignada y guardada: $selected');
      return selected;
    }
    debugPrint(
        '[DEBUG] [ImageRepo] No hay imágenes válidas, usando placeholder genérico');
    return 'https://via.placeholder.com/600x400?text=Devocional';
  }
}
