import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// Modelo que representa cada devocional
class Devocional {
  final String versiculo;
  final String reflexion;
  final List<dynamic> paraMeditar;
  final String oracion;

  Devocional({
    required this.versiculo,
    required this.reflexion,
    required this.paraMeditar,
    required this.oracion,
  });

  // Método de fábrica para convertir desde JSON
  factory Devocional.fromJson(Map<String, dynamic> json) {
    return Devocional(
      versiculo: json['Versículo'] ?? '',
      reflexion: json['Reflexión'] ?? '',
      paraMeditar: json['para_meditar'] ?? [],
      oracion: json['Oración'] ?? '',
    );
  }
}

// Widget raíz de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Devocionales',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DevocionalesPage(),
    );
  }
}

// Página principal que muestra los devocionales
class DevocionalesPage extends StatefulWidget {
  const DevocionalesPage({super.key});

  @override
  State<DevocionalesPage> createState() => _DevocionalesPageState();
}

class _DevocionalesPageState extends State<DevocionalesPage> {
  late Future<List<Devocional>> _futureDevocionales;

  // Carga el JSON desde GitHub y lo convierte a una lista de objetos
  Future<List<Devocional>> fetchDevocionales() async {
    final url = Uri.parse(
      'https://raw.githubusercontent.com/develop4God/Devocionales-json/refs/heads/main/Prueba.json',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => Devocional.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar devocionales');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureDevocionales = fetchDevocionales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devocionales NTV')),
      body: FutureBuilder<List<Devocional>>(
        future: _futureDevocionales,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final devocionales = snapshot.data!;
            return ListView.builder(
              itemCount: devocionales.length,
              itemBuilder: (context, index) {
                final d = devocionales[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.versiculo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(d.reflexion),
                        const SizedBox(height: 8),
                        ...d.paraMeditar.map(
                          (m) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "• ${m['cita']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(m['texto']),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Oración: ${d.oracion}",
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
