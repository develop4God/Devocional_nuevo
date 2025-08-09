// lib/models/spiritual_progress_stats.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos para las estadísticas de progreso espiritual del usuario.
/// 
/// Rastrea diversas actividades espirituales como devocionales completados,
/// tiempo de oración, versículos memorizados, etc.
class SpiritualProgressStats {
  final String userId;
  final int devotionalsCompleted;
  final int prayerTimeMinutes;
  final int versesMemorized;
  final int consecutiveDays;
  final int currentStreak;
  final DateTime lastActivityDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> monthlyStats;
  final Map<String, dynamic> weeklyStats;

  SpiritualProgressStats({
    required this.userId,
    this.devotionalsCompleted = 0,
    this.prayerTimeMinutes = 0,
    this.versesMemorized = 0,
    this.consecutiveDays = 0,
    this.currentStreak = 0,
    required this.lastActivityDate,
    required this.createdAt,
    required this.updatedAt,
    this.monthlyStats = const {},
    this.weeklyStats = const {},
  });

  /// Constructor factory para crear una instancia desde Firestore
  factory SpiritualProgressStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SpiritualProgressStats(
      userId: doc.id,
      devotionalsCompleted: data['devotionalsCompleted'] ?? 0,
      prayerTimeMinutes: data['prayerTimeMinutes'] ?? 0,
      versesMemorized: data['versesMemorized'] ?? 0,
      consecutiveDays: data['consecutiveDays'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      lastActivityDate: (data['lastActivityDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      monthlyStats: Map<String, dynamic>.from(data['monthlyStats'] ?? {}),
      weeklyStats: Map<String, dynamic>.from(data['weeklyStats'] ?? {}),
    );
  }

  /// Constructor factory para crear una instancia desde JSON
  factory SpiritualProgressStats.fromJson(Map<String, dynamic> json) {
    return SpiritualProgressStats(
      userId: json['userId'] ?? '',
      devotionalsCompleted: json['devotionalsCompleted'] ?? 0,
      prayerTimeMinutes: json['prayerTimeMinutes'] ?? 0,
      versesMemorized: json['versesMemorized'] ?? 0,
      consecutiveDays: json['consecutiveDays'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      lastActivityDate: DateTime.parse(json['lastActivityDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      monthlyStats: Map<String, dynamic>.from(json['monthlyStats'] ?? {}),
      weeklyStats: Map<String, dynamic>.from(json['weeklyStats'] ?? {}),
    );
  }

  /// Convierte la instancia a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'devotionalsCompleted': devotionalsCompleted,
      'prayerTimeMinutes': prayerTimeMinutes,
      'versesMemorized': versesMemorized,
      'consecutiveDays': consecutiveDays,
      'currentStreak': currentStreak,
      'lastActivityDate': Timestamp.fromDate(lastActivityDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'monthlyStats': monthlyStats,
      'weeklyStats': weeklyStats,
    };
  }

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'devotionalsCompleted': devotionalsCompleted,
      'prayerTimeMinutes': prayerTimeMinutes,
      'versesMemorized': versesMemorized,
      'consecutiveDays': consecutiveDays,
      'currentStreak': currentStreak,
      'lastActivityDate': lastActivityDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'monthlyStats': monthlyStats,
      'weeklyStats': weeklyStats,
    };
  }

  /// Crea una copia actualizada de las estadísticas
  SpiritualProgressStats copyWith({
    String? userId,
    int? devotionalsCompleted,
    int? prayerTimeMinutes,
    int? versesMemorized,
    int? consecutiveDays,
    int? currentStreak,
    DateTime? lastActivityDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? monthlyStats,
    Map<String, dynamic>? weeklyStats,
  }) {
    return SpiritualProgressStats(
      userId: userId ?? this.userId,
      devotionalsCompleted: devotionalsCompleted ?? this.devotionalsCompleted,
      prayerTimeMinutes: prayerTimeMinutes ?? this.prayerTimeMinutes,
      versesMemorized: versesMemorized ?? this.versesMemorized,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      currentStreak: currentStreak ?? this.currentStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      monthlyStats: monthlyStats ?? this.monthlyStats,
      weeklyStats: weeklyStats ?? this.weeklyStats,
    );
  }

  /// Crea estadísticas iniciales para un nuevo usuario
  factory SpiritualProgressStats.createInitial(String userId) {
    final now = DateTime.now();
    return SpiritualProgressStats(
      userId: userId,
      devotionalsCompleted: 0,
      prayerTimeMinutes: 0,
      versesMemorized: 0,
      consecutiveDays: 0,
      currentStreak: 0,
      lastActivityDate: now,
      createdAt: now,
      updatedAt: now,
      monthlyStats: {},
      weeklyStats: {},
    );
  }

  @override
  String toString() {
    return 'SpiritualProgressStats(userId: $userId, devotionalsCompleted: $devotionalsCompleted, prayerTimeMinutes: $prayerTimeMinutes, versesMemorized: $versesMemorized, currentStreak: $currentStreak)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpiritualProgressStats &&
        other.userId == userId &&
        other.devotionalsCompleted == devotionalsCompleted &&
        other.prayerTimeMinutes == prayerTimeMinutes &&
        other.versesMemorized == versesMemorized &&
        other.currentStreak == currentStreak;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        devotionalsCompleted.hashCode ^
        prayerTimeMinutes.hashCode ^
        versesMemorized.hashCode ^
        currentStreak.hashCode;
  }
}

/// Enumeración para tipos de actividades espirituales
enum SpiritualActivityType {
  devotionalCompleted,
  prayerTime,
  verseMemorized,
  bibleReading,
  worship,
  service,
}

/// Modelo para registrar actividades individuales
class SpiritualActivity {
  final String id;
  final String userId;
  final SpiritualActivityType type;
  final DateTime date;
  final Map<String, dynamic> metadata;
  final int value; // Minutos para oración, 1 para devocional completado, etc.

  SpiritualActivity({
    required this.id,
    required this.userId,
    required this.type,
    required this.date,
    this.metadata = const {},
    this.value = 1,
  });

  factory SpiritualActivity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SpiritualActivity(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: SpiritualActivityType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => SpiritualActivityType.devotionalCompleted,
      ),
      date: (data['date'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      value: data['value'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString(),
      'date': Timestamp.fromDate(date),
      'metadata': metadata,
      'value': value,
    };
  }
}