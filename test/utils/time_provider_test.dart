import 'package:devocional_nuevo/utils/time_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AcceleratedTimeProvider: 7 minutes = 7 days', () async {
    final baseTime = DateTime(2025, 1, 1, 0, 0, 0);
    final accelerated = AcceleratedTimeProvider(
      baseTime: baseTime,
      minutesToDays: 1440, // 1 min = 1 día
    );
    // Tiempo inicial
    expect(accelerated.now(), baseTime);
    // Espera 7 minutos reales
    await Future.delayed(Duration(minutes: 7));
    // Debe haber avanzado ~7 días virtuales
    final elapsed = accelerated.now().difference(baseTime);
    expect(elapsed.inDays, greaterThanOrEqualTo(6)); // Margen por latencia
    expect(elapsed.inDays, lessThanOrEqualTo(8));
  });
}
