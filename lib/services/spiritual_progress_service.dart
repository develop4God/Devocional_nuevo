// lib/services/spiritual_progress_service.dart

import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:devocional_nuevo/models/spiritual_progress_stats.dart';

/// Servicio para gestionar las estadísticas de progreso espiritual en Firebase.
/// 
/// Proporciona funcionalidades para:
/// - Registrar actividades espirituales automáticamente
/// - Actualizar estadísticas de progreso
/// - Consultar estadísticas históricas
/// - Calcular rachas y logros
class SpiritualProgressService {
  static final SpiritualProgressService _instance = SpiritualProgressService._internal();
  factory SpiritualProgressService() => _instance;
  SpiritualProgressService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Colecciones de Firestore
  static const String _statsCollection = 'spiritual_progress_stats';
  static const String _activitiesCollection = 'spiritual_activities';

  /// Registra una actividad espiritual y actualiza las estadísticas automáticamente
  Future<void> recordSpiritualActivity({
    required SpiritualActivityType activityType,
    int value = 1,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        developer.log(
          'SpiritualProgressService: Usuario no autenticado, no se puede registrar actividad.',
          name: 'SpiritualProgressService'
        );
        return;
      }

      final now = DateTime.now();
      final activity = SpiritualActivity(
        id: '', // Se asignará automáticamente por Firestore
        userId: user.uid,
        type: activityType,
        date: now,
        metadata: metadata,
        value: value,
      );

      // Guardar la actividad individual
      await _firestore.collection(_activitiesCollection).add(activity.toFirestore());

      // Actualizar las estadísticas agregadas
      await _updateUserStats(user.uid, activityType, value, now);

      developer.log(
        'SpiritualProgressService: Actividad registrada - Tipo: $activityType, Valor: $value',
        name: 'SpiritualProgressService'
      );
    } catch (e) {
      developer.log(
        'Error al registrar actividad espiritual: $e',
        name: 'SpiritualProgressService',
        error: e
      );
    }
  }

  /// Actualiza las estadísticas agregadas del usuario
  Future<void> _updateUserStats(
    String userId,
    SpiritualActivityType activityType,
    int value,
    DateTime activityDate,
  ) async {
    try {
      final userStatsRef = _firestore.collection(_statsCollection).doc(userId);
      final doc = await userStatsRef.get();

      SpiritualProgressStats currentStats;
      if (doc.exists) {
        currentStats = SpiritualProgressStats.fromFirestore(doc);
      } else {
        currentStats = SpiritualProgressStats.createInitial(userId);
      }

      // Actualizar estadísticas según el tipo de actividad
      SpiritualProgressStats updatedStats = _updateStatsForActivity(
        currentStats,
        activityType,
        value,
        activityDate,
      );

      // Guardar estadísticas actualizadas
      await userStatsRef.set(updatedStats.toFirestore(), SetOptions(merge: true));

      developer.log(
        'SpiritualProgressService: Estadísticas actualizadas para usuario $userId',
        name: 'SpiritualProgressService'
      );
    } catch (e) {
      developer.log(
        'Error al actualizar estadísticas del usuario: $e',
        name: 'SpiritualProgressService',
        error: e
      );
    }
  }

  /// Actualiza las estadísticas según el tipo de actividad
  SpiritualProgressStats _updateStatsForActivity(
    SpiritualProgressStats currentStats,
    SpiritualActivityType activityType,
    int value,
    DateTime activityDate,
  ) {
    final now = DateTime.now();
    int newDevotionalsCompleted = currentStats.devotionalsCompleted;
    int newPrayerTimeMinutes = currentStats.prayerTimeMinutes;
    int newVersesMemorized = currentStats.versesMemorized;
    int newCurrentStreak = currentStats.currentStreak;
    int newConsecutiveDays = currentStats.consecutiveDays;

    // Actualizar contador específico según el tipo
    switch (activityType) {
      case SpiritualActivityType.devotionalCompleted:
        newDevotionalsCompleted += value;
        newCurrentStreak = _calculateStreak(currentStats, activityDate);
        break;
      case SpiritualActivityType.prayerTime:
        newPrayerTimeMinutes += value;
        break;
      case SpiritualActivityType.verseMemorized:
        newVersesMemorized += value;
        break;
      default:
        // Para otros tipos de actividades, solo actualizamos la fecha
        break;
    }

    // Actualizar estadísticas mensuales y semanales
    Map<String, dynamic> updatedMonthlyStats = Map.from(currentStats.monthlyStats);
    Map<String, dynamic> updatedWeeklyStats = Map.from(currentStats.weeklyStats);

    _updatePeriodStats(updatedMonthlyStats, activityDate, activityType, value, 'month');
    _updatePeriodStats(updatedWeeklyStats, activityDate, activityType, value, 'week');

    return currentStats.copyWith(
      devotionalsCompleted: newDevotionalsCompleted,
      prayerTimeMinutes: newPrayerTimeMinutes,
      versesMemorized: newVersesMemorized,
      currentStreak: newCurrentStreak,
      consecutiveDays: newConsecutiveDays,
      lastActivityDate: activityDate,
      updatedAt: now,
      monthlyStats: updatedMonthlyStats,
      weeklyStats: updatedWeeklyStats,
    );
  }

  /// Calcula la racha actual de días consecutivos
  int _calculateStreak(SpiritualProgressStats currentStats, DateTime activityDate) {
    final lastActivity = currentStats.lastActivityDate;
    final daysDifference = activityDate.difference(lastActivity).inDays;

    if (daysDifference <= 1) {
      // Mismo día o día siguiente - mantener o incrementar racha
      return daysDifference == 1 ? currentStats.currentStreak + 1 : currentStats.currentStreak;
    } else {
      // Más de un día de diferencia - reiniciar racha
      return 1;
    }
  }

  /// Actualiza estadísticas para períodos específicos (semana/mes)
  void _updatePeriodStats(
    Map<String, dynamic> periodStats,
    DateTime activityDate,
    SpiritualActivityType activityType,
    int value,
    String period,
  ) {
    String key;
    if (period == 'month') {
      key = '${activityDate.year}-${activityDate.month.toString().padLeft(2, '0')}';
    } else {
      // Para semana, usamos el número de la semana del año
      final weekNumber = _getWeekNumber(activityDate);
      key = '${activityDate.year}-W${weekNumber.toString().padLeft(2, '0')}';
    }

    Map<String, dynamic> periodData = Map.from(periodStats[key] ?? {});
    
    // Actualizar contador específico del tipo de actividad
    String activityKey = activityType.toString().split('.').last;
    periodData[activityKey] = (periodData[activityKey] ?? 0) + value;
    
    periodStats[key] = periodData;
  }

  /// Obtiene el número de semana del año para una fecha
  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final firstThursday = startOfYear.add(Duration(days: (4 - startOfYear.weekday) % 7));
    final weekNumber = ((date.difference(firstThursday).inDays) / 7).floor() + 1;
    return weekNumber;
  }

  /// Obtiene las estadísticas del usuario actual
  Future<SpiritualProgressStats?> getUserStats() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        developer.log(
          'SpiritualProgressService: Usuario no autenticado.',
          name: 'SpiritualProgressService'
        );
        return null;
      }

      final doc = await _firestore.collection(_statsCollection).doc(user.uid).get();
      
      if (doc.exists) {
        return SpiritualProgressStats.fromFirestore(doc);
      } else {
        // Crear estadísticas iniciales si no existen
        final initialStats = SpiritualProgressStats.createInitial(user.uid);
        await _firestore.collection(_statsCollection).doc(user.uid).set(initialStats.toFirestore());
        return initialStats;
      }
    } catch (e) {
      developer.log(
        'Error al obtener estadísticas del usuario: $e',
        name: 'SpiritualProgressService',
        error: e
      );
      return null;
    }
  }

  /// Obtiene las actividades espirituales del usuario en un rango de fechas
  Future<List<SpiritualActivity>> getUserActivities({
    DateTime? startDate,
    DateTime? endDate,
    SpiritualActivityType? activityType,
    int limit = 50,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return [];
      }

      Query query = _firestore
          .collection(_activitiesCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .limit(limit);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (activityType != null) {
        query = query.where('type', isEqualTo: activityType.toString());
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => SpiritualActivity.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log(
        'Error al obtener actividades del usuario: $e',
        name: 'SpiritualProgressService',
        error: e
      );
      return [];
    }
  }

  /// Obtiene estadísticas de un mes específico
  Future<Map<String, dynamic>?> getMonthlyStats(int year, int month) async {
    try {
      final stats = await getUserStats();
      if (stats == null) return null;

      final monthKey = '$year-${month.toString().padLeft(2, '0')}';
      return stats.monthlyStats[monthKey] as Map<String, dynamic>?;
    } catch (e) {
      developer.log(
        'Error al obtener estadísticas mensuales: $e',
        name: 'SpiritualProgressService',
        error: e
      );
      return null;
    }
  }

  /// Obtiene estadísticas de una semana específica
  Future<Map<String, dynamic>?> getWeeklyStats(int year, int week) async {
    try {
      final stats = await getUserStats();
      if (stats == null) return null;

      final weekKey = '$year-W${week.toString().padLeft(2, '0')}';
      return stats.weeklyStats[weekKey] as Map<String, dynamic>?;
    } catch (e) {
      developer.log(
        'Error al obtener estadísticas semanales: $e',
        name: 'SpiritualProgressService',
        error: e
      );
      return null;
    }
  }

  /// Stream para escuchar cambios en las estadísticas del usuario
  Stream<SpiritualProgressStats?> watchUserStats() {
    final User? user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection(_statsCollection)
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return SpiritualProgressStats.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Registra la finalización de un devocional con metadatos
  Future<void> recordDevotionalCompletion({
    required String devotionalId,
    required DateTime date,
    Map<String, dynamic> additionalMetadata = const {},
  }) async {
    final metadata = {
      'devotionalId': devotionalId,
      'completedAt': date.toIso8601String(),
      ...additionalMetadata,
    };

    await recordSpiritualActivity(
      activityType: SpiritualActivityType.devotionalCompleted,
      value: 1,
      metadata: metadata,
    );
  }

  /// Registra tiempo de oración
  Future<void> recordPrayerTime({
    required int minutes,
    Map<String, dynamic> additionalMetadata = const {},
  }) async {
    await recordSpiritualActivity(
      activityType: SpiritualActivityType.prayerTime,
      value: minutes,
      metadata: additionalMetadata,
    );
  }

  /// Registra un versículo memorizado
  Future<void> recordVerseMemorized({
    required String verse,
    Map<String, dynamic> additionalMetadata = const {},
  }) async {
    final metadata = {
      'verse': verse,
      'memorizedAt': DateTime.now().toIso8601String(),
      ...additionalMetadata,
    };

    await recordSpiritualActivity(
      activityType: SpiritualActivityType.verseMemorized,
      value: 1,
      metadata: metadata,
    );
  }
}