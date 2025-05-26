// lib/models/devocional_model.dart

import 'package:flutter/material.dart';

/// Modelo de datos para un devocional.
///
/// Contiene el ID, versículo, reflexión, puntos para meditar, una oración y la fecha.
class Devocional {
  final String id;
  final String versiculo;
  final String reflexion;
  final List<Map<String, String>> paraMeditar;
  final String oracion;
  final DateTime date;

  Devocional({
    required this.id,
    required this.versiculo,
    required this.reflexion,
    required this.paraMeditar,
    required this.oracion,
    required this.date,
  });

  /// Constructor factory para crear una instancia de [Devocional] desde un JSON.
  ///
  /// Proporciona valores por defecto si algún campo es nulo en el JSON.
  factory Devocional.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    final String? dateString = json['date']
        as String?; // <--- CUIDADO AQUÍ: Lee como String? (puede ser nulo)

    if (dateString != null && dateString.isNotEmpty) {
      // <--- Verifica si la cadena de fecha no es nula ni vacía
      try {
        // Intenta primero con el formato ISO 8601 (yyyy-MM-dd) que es común
        parsedDate = DateTime.parse(dateString);
      } catch (e) {
        // Si falla, intenta con el formato "dd-MM-yyyy" que quizás estés usando
        try {
          List<String> parts =
              dateString.split('-'); // Ahora dateString ya no es nulo
          if (parts.length == 3) {
            parsedDate = DateTime(
                int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          } else {
            print(
                'Advertencia: Formato de fecha desconocido para "$dateString". Usando fecha actual.');
            parsedDate = DateTime.now(); // Fallback
          }
        } catch (innerE) {
          print('Error final al parsear fecha: $innerE. Usando fecha actual.');
          parsedDate = DateTime.now(); // Fallback final
        }
      }
    } else {
      // Si dateString es null o vacío, usa la fecha actual como fallback
      print(
          'Advertencia: El campo "date" es nulo o vacío en el JSON. Usando fecha actual.');
      parsedDate = DateTime.now();
    }

    return Devocional(
      id: json['id'] as String? ??
          UniqueKey()
              .hashCode
              .toString(), // Usa UniqueKey si el ID puede ser nulo en JSON
      versiculo: json['versiculo'] ?? '',
      reflexion: json['reflexion'] ?? '',
      paraMeditar: (json['para_meditar'] as List<dynamic>?)
              ?.map((item) => {
                    'cita': item['cita'] as String? ?? '',
                    'texto': item['texto'] as String? ?? '',
                  })
              .toList() ??
          [],
      oracion: json['oracion'] ?? '',
      date: parsedDate,
    );
  }

  // Método toJson para serializar a JSON (útil para guardar favoritos)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'versiculo': versiculo,
      'reflexion': reflexion,
      'para_meditar': paraMeditar,
      'oracion': oracion,
      'date': date
          .toIso8601String()
          .substring(0, 10), // Guardar solo la fecha en formato YYYY-MM-DD
    };
  }
}
