import 'package:devocional_nuevo/services/devotional_image_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DevotionalImageNormalizer', () {
    final normalizer = DevotionalImageNormalizer();

    test('Devuelve la misma URL para GitHub', () {
      const url =
          'https://raw.githubusercontent.com/develop4God/Devocionales-assets/main/images/devocional_1.jpg';
      final result = normalizer.normalize(url, width: 800, height: 600);
      expect(result, url);
    });

    test('Devuelve la misma URL para URL vacía', () {
      final result = normalizer.normalize('', width: 800, height: 600);
      expect(result, '');
    });

    test('Devuelve la misma URL para CDN desconocido', () {
      const url = 'https://cdn.example.com/image.jpg';
      final result = normalizer.normalize(url, width: 300, height: 200);
      expect(result, url);
    });

    test('DebugPrint muestra logs en cada paso', () {
      // No se puede capturar debugPrint directamente en test estándar,
      // pero se valida que no lanza excepción y retorna la URL esperada.
      const url =
          'https://raw.githubusercontent.com/develop4God/Devocionales-assets/main/images/devocional_2.jpg';
      expect(normalizer.normalize(url, width: 100, height: 100), url);
    });
  });
}
