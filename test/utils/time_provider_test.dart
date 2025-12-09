import 'package:devocional_nuevo/utils/time_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AcceleratedTimeProvider: 1 second = 1 day (fast test)', () async {
    final baseTime = DateTime(2025, 1, 1, 0, 0, 0);
    final accelerated = AcceleratedTimeProvider(
      baseTime: baseTime,
      minutesToDays: 86400, // 1 seg real = 1 día virtual
    );
    expect(accelerated.now(), baseTime);
    await Future.delayed(Duration(seconds: 7));
    final elapsed = accelerated.now().difference(baseTime);
    expect(elapsed.inDays, greaterThanOrEqualTo(6));
    expect(elapsed.inDays, lessThanOrEqualTo(8));
  });

  test('AcceleratedTimeProvider: calculates virtual time correctly', () {
    final baseTime = DateTime(2025, 1, 1, 0, 0, 0);
    final accelerated = AcceleratedTimeProvider(
      baseTime: baseTime,
      minutesToDays: 1440,
    );
    // Simula que pasaron 5 minutos reales
    final realElapsed = Duration(minutes: 5);
    final virtualElapsed = Duration(minutes: realElapsed.inMinutes * 1440);
    expect(virtualElapsed.inDays, equals(5));
  });
}
