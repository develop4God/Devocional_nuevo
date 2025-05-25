import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' show File, Platform;
import 'package:path_provider/path_provider.dart';
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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DevocionalesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DevocionalesPage extends StatefulWidget {
  const DevocionalesPage({super.key});

  @override
  State<DevocionalesPage> createState() => _DevocionalesPageState();
}

class _DevocionalesPageState extends State<DevocionalesPage> {
  late Future<List<Devocional>> _futureDevocionales;
  List<Devocional> _devocionales = [];
  int _currentIndex = 0;
  Set<int> _seenIndices = {};
  Set<int> _favorites = {};
  bool _showInvitationDialog = true;

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _futureDevocionales = fetchDevocionales();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _seenIndices = (prefs.getStringList('seenIndices') ?? [])
          .map((e) => int.parse(e))
          .toSet();
      _favorites = (prefs.getStringList('favorites') ?? [])
          .map((e) => int.parse(e))
          .toSet();
      _showInvitationDialog = !(prefs.getBool('dontShowInvitation') ?? false);
      _currentIndex = prefs.getInt('currentIndex') ?? 0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'seenIndices',
      _seenIndices.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      'favorites',
      _favorites.map((e) => e.toString()).toList(),
    );
    await prefs.setBool('dontShowInvitation', !_showInvitationDialog);
    await prefs.setInt('currentIndex', _currentIndex);
  }

  Future<List<Devocional>> fetchDevocionales() async {
    final url = Uri.parse(
      'https://raw.githubusercontent.com/develop4God/Devocionales-json/refs/heads/main/DevocionalesNTV_formateado.json',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => Devocional.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar devocionales');
    }
  }

  void _nextDevocional() async {
    if (_devocionales.isEmpty) return;

    if (_showInvitationDialog) {
      _showInvitation();
    } else {
      _goToNext();
    }
  }

  void _goToNext() async {
    int nextIndex = _currentIndex;
    final total = _devocionales.length;

    // Buscamos un índice no repetido (si todos vistos, se permite repetir)
    int attempts = 0;
    do {
      nextIndex = Random().nextInt(total);
      attempts++;
      if (attempts > total) break; // si agotamos opciones, rompemos
    } while (_seenIndices.contains(nextIndex) && _seenIndices.length < total);

    setState(() {
      _currentIndex = nextIndex;
      _seenIndices.add(nextIndex);
    });

    await _saveSettings();
  }

  void _showInvitation() {
    bool dontShowAgain = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            "¡Invitación a fiesta en los cielos y vida eterna!",
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Repite esta oración en voz alta, con fe y creyendo con todo el corazón:\n",
                ),
                Text(
                  "Jesucristo, creo que moriste en la cruz por mi, te pido perdón y me arrepiento de corazón por mis pecados. Te pido seas mi Salvador y el señor de vida. Líbrame de la muerte eterna y escribe mi nombre en el libro de la vida.\nEn el poderoso nombre de Jesús, amén.\n",
                ),
                Text(
                  "Si hiciste esta oración y lo crees:\nSerás salvo tu y tu casa (Hechos 16:31)\nVivirás eternamente (Juan 11:25-26)\nNunca más tendrás sed (Juan 4:14)\nEstarás con Jesucristo en los cielos (Apocalipsis 19:9)\nHay gozo en los cielos cuando un pecador se arrepiente (Lucas 15:10)\nEscrito está y Dios es fiel (Deuteronomio 7:9)\n\nSi hiciste está oración, desde ya tienes salvación y vida nueva.",
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Checkbox(
                  value: dontShowAgain,
                  onChanged: (val) {
                    setState(() {
                      dontShowAgain = val ?? false;
                    });
                  },
                ),
                const Expanded(child: Text('No volver a mostrar')),
              ],
            ),
            TextButton(
              onPressed: () {
                if (dontShowAgain) {
                  setState(() {
                    _showInvitationDialog = false;
                  });
                  _saveSettings();
                }
                Navigator.of(context).pop();
                _goToNext();
              },
              child: const Text("Siguiente devocional"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite() async {
    setState(() {
      if (_favorites.contains(_currentIndex)) {
        _favorites.remove(_currentIndex);
      } else {
        _favorites.add(_currentIndex);
      }
    });
    await _saveSettings();
  }

  Future<void> _shareAsText() async {
    if (_devocionales.isEmpty) return;
    final d = _devocionales[_currentIndex];
    final shareText =
        '''
${d.versiculo}

Análisis:
${d.reflexion}

Para meditar:
${d.paraMeditar.map((m) => "• ${m['cita']}\n${m['texto']}").join('\n')}

Oración:
${d.oracion}
''';

    await Share.share(shareText, subject: 'Devocional');
  }

  Future<void> _shareAsImage() async {
    if (_devocionales.isEmpty) return;

    try {
      final image = await screenshotController.capture();
      if (image == null) return;

      final directory = (await getTemporaryDirectory()).path;
      final imgPath = '$directory/devocional_$_currentIndex.png';
      final imgFile = File(imgPath);
      await imgFile.writeAsBytes(image);

      await Share.shareXFiles([XFile(imgPath)], subject: 'Devocional');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir imagen: $e')),
        );
      }
    }
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
      body: FutureBuilder<List<Devocional>>(
        future: _futureDevocionales,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            _devocionales = snapshot.data ?? [];
            if (_devocionales.isEmpty) {
              return const Center(
                child: Text('No hay devocionales disponibles.'),
              );
            }
            final d = _devocionales[_currentIndex];

            return LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Screenshot(
                      controller: screenshotController,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              d.versiculo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.deepPurple,
                              ),
                              maxLines: 2,
                              minFontSize: 14,
                            ),
                            const SizedBox(height: 8),
                            AutoSizeText(
                              d.reflexion,
                              style: const TextStyle(fontSize: 16),
                              maxLines: 10,
                              minFontSize: 14,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Para meditar:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...d.paraMeditar.map((m) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      m['cita'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.deepPurple,
                                      ),
                                      maxLines: 2,
                                      minFontSize: 14,
                                    ),
                                    const SizedBox(height: 4),
                                    AutoSizeText(
                                      m['texto'] ?? '',
                                      style: const TextStyle(fontSize: 16),
                                      maxLines: 8,
                                      minFontSize: 14,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 12),
                            const Text(
                              'Oración:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 6),
                            AutoSizeText(
                              d.oracion,
                              style: const TextStyle(fontSize: 16),
                              maxLines: 8,
                              minFontSize: 14,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurple,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                tooltip: _favorites.contains(_currentIndex)
                    ? 'Quitar de favoritos'
                    : 'Agregar a favoritos',
                onPressed: _toggleFavorite,
                icon: Icon(
                  _favorites.contains(_currentIndex)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Compartir como texto',
                onPressed: _shareAsText,
                icon: const Icon(Icons.share, color: Colors.white),
              ),
              IconButton(
                tooltip: 'Compartir como imagen',
                onPressed: _shareAsImage,
                icon: const Icon(Icons.image, color: Colors.white),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                ),
                onPressed: _nextDevocional,
                child: const Text(
                  'Nuevo Devocional',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
