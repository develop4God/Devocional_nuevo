// lib/models/devocional_model.dart

/// Modelo de datos para un devocional.
///
/// Contiene el versículo, reflexión, puntos para meditar y una oración.
class Devocional {
  final String versiculo;
  final String reflexion;
  final List<dynamic>
      paraMeditar; // Podría ser List<Map<String, String>> para más tipado
  final String oracion;

  Devocional({
    required this.versiculo,
    required this.reflexion,
    required this.paraMeditar,
    required this.oracion,
  });

  /// Constructor factory para crear una instancia de [Devocional] desde un JSON.
  ///
  /// Proporciona valores por defecto si algún campo es nulo en el JSON.
  factory Devocional.fromJson(Map<String, dynamic> json) {
    return Devocional(
      versiculo: json['Versículo'] ?? '',
      reflexion: json['Reflexión'] ?? '',
      paraMeditar: json['para_meditar'] ?? [],
      oracion: json['Oración'] ?? '',
    );
  }
}
