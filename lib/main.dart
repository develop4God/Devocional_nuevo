import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:auto_size_text/auto_size_text.dart';

void main() {
  runApp(const MyApp());
}

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

  factory Devocional.fromJson(Map<String, dynamic> json) {
    return Devocional(
      versiculo: json['Versículo'] ?? '',
      reflexion: json['Reflexión'] ?? '',
      paraMeditar: json['para_meditar'] ?? [],
      oracion: json['Oración'] ?? '',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Devocionales',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const DevocionalesPage(),
    );
  }
}

class DevocionalesPage extends StatefulWidget {
  const DevocionalesPage({super.key});

  @override
  State<DevocionalesPage> createState() => _DevocionalesPageState();
}

class _DevocionalesPageState extends State<DevocionalesPage> {
  late Future<Devocional> _futureDevocional;

  Future<Devocional> fetchDevocional() async {
    final url = Uri.parse(
      'https://raw.githubusercontent.com/develop4God/Devocionales-json/refs/heads/main/DevocionalesNTV_formateado.json',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final random = Random();
      final randomItem = jsonData[random.nextInt(jsonData.length)];
      return Devocional.fromJson(randomItem);
    } else {
      throw Exception('Error al cargar devocionales');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureDevocional = fetchDevocional();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text(
          'Mi relación íntima con Dios',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<Devocional>(
        future: _futureDevocional,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final d = snapshot.data!;
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          d.versiculo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        const AutoSizeText(
                          'Análisis:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AutoSizeText(
                          d.reflexion,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        const AutoSizeText(
                          'Para meditar:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...d.paraMeditar.map(
                          (m) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                "• ${m['cita']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              AutoSizeText(
                                m['texto'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const AutoSizeText(
                          'Oración',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AutoSizeText(
                          d.oracion,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                          ),
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
