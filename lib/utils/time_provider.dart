/// Abstracción del reloj para testing
abstract class TimeProvider {
  DateTime now();
}

/// Implementación de producción
class SystemTimeProvider implements TimeProvider {
  @override
  DateTime now() => DateTime.now().toUtc();
}

/// Para tests: tiempo fijo
class FixedTimeProvider implements TimeProvider {
  final DateTime fixedTime;

  FixedTimeProvider(this.fixedTime);

  @override
  DateTime now() => fixedTime;
}

/// Para validación rápida: 1 min = customFactor
class AcceleratedTimeProvider implements TimeProvider {
  final DateTime baseTime;
  final int minutesToDays; // 1 = normal, 1440 = 1min=1día
  late final DateTime _realStart;

  AcceleratedTimeProvider({
    DateTime? baseTime,
    this.minutesToDays = 1440, // Default: 1 minuto = 1 día
  }) : baseTime = baseTime ?? DateTime.now().toUtc() {
    _realStart = DateTime.now();
  }

  @override
  DateTime now() {
    final realElapsed = DateTime.now().difference(_realStart);
    final virtualElapsed = Duration(
      minutes: realElapsed.inMinutes * minutesToDays,
    );
    return baseTime.add(virtualElapsed).toUtc();
  }
}
