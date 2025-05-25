// lib/main.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' show File; // Usado para File
import 'package:path_provider/path_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';

// Importa el SplashScreen desde su nuevo archivo.
import './splash_screen.dart';

// --- Constantes ---
// Es una buena práctica definir URLs y claves de SharedPreferences como constantes.
const String DEVOCIONALES_JSON_URL =
    'https://raw.githubusercontent.com/develop4God/Devocionales-json/refs/heads/main/DevocionalesNTV_formateado.json';
const String PREF_SEEN_INDICES = 'seenIndices';
const String PREF_FAVORITES = 'favorites';
const String PREF_DONT_SHOW_INVITATION = 'dontShowInvitation';
const String PREF_CURRENT_INDEX = 'currentIndex';

// --- Clase Devocional ---
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

// --- DevocionalProvider (Gestión de Estado) ---
/// ChangeNotifier para gestionar el estado de los devocionales.
///
/// Maneja la lista de devocionales, el índice actual, los favoritos,
/// los devocionales vistos, el estado de carga y los mensajes de error.
class DevocionalProvider extends ChangeNotifier {
  List<Devocional> _devocionales = [];
  int _currentIndex = 0;
  Set<int> _seenIndices = {};
  Set<int> _favorites = {};
  bool _showInvitationDialog =
      true; // Controla si el diálogo de invitación debe mostrarse
  bool _isLoading = true; // Indica si los datos se están cargando
  String? _errorMessage; // Mensaje de error si la carga falla

  // Getters para acceder al estado de forma segura.
  List<Devocional> get devocionales =>
      _devocionales; // Corregido: devocales -> devocionales
  int get currentIndex => _currentIndex;
  Devocional? get currentDevocional =>
      _devocionales.isNotEmpty ? _devocionales[_currentIndex] : null;
  Set<int> get seenIndices => _seenIndices;
  Set<int> get favorites => _favorites;
  bool get showInvitationDialog => _showInvitationDialog;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor: La inicialización de datos se maneja externamente (ej. en SplashScreen).
  DevocionalProvider() {
    // La carga se inicia en el SplashScreen, no aquí directamente
    // pero mantenemos los métodos para ser llamados.
  }

  /// Inicializa los datos de la aplicación: carga configuraciones y devocionales.
  Future<void> initializeData() async {
    await _loadSettings();
    await fetchDevocionales();
    // No es necesario notificar listeners aquí si fetchDevocionales ya lo hace al final.
  }

  /// Carga las configuraciones guardadas desde SharedPreferences.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _seenIndices = (prefs.getStringList(PREF_SEEN_INDICES) ?? [])
        .map((e) => int.parse(e))
        .toSet();
    _favorites = (prefs.getStringList(PREF_FAVORITES) ?? [])
        .map((e) => int.parse(e))
        .toSet();
    _showInvitationDialog =
        !(prefs.getBool(PREF_DONT_SHOW_INVITATION) ?? false);
    _currentIndex = prefs.getInt(PREF_CURRENT_INDEX) ?? 0;
    // Notificar listeners después de cargar las configuraciones podría ser útil
    // si alguna UI depende directamente de estos valores antes de que los devocionales carguen.
    // Sin embargo, la carga principal (isLoading) se maneja en fetchDevocionales.
    // notifyListeners(); // Considerar si es necesario aquí.
  }

  /// Guarda las configuraciones actuales en SharedPreferences.
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      PREF_SEEN_INDICES,
      _seenIndices.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      PREF_FAVORITES,
      _favorites.map((e) => e.toString()).toList(),
    );
    await prefs.setBool(PREF_DONT_SHOW_INVITATION, !_showInvitationDialog);
    await prefs.setInt(PREF_CURRENT_INDEX, _currentIndex);
  }

  /// Obtiene los devocionales desde la URL JSON.
  Future<void> fetchDevocionales() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notifica que la carga ha comenzado.

    final url = Uri.parse(DEVOCIONALES_JSON_URL);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _devocionales =
            jsonData.map((item) => Devocional.fromJson(item)).toList();
        // Asegura que el _currentIndex sea válido después de cargar nuevos devocionales.
        if (_currentIndex >= _devocionales.length && _devocionales.isNotEmpty) {
          _currentIndex = 0;
        } else if (_devocionales.isEmpty) {
          _currentIndex = 0; // O manejar un estado de "no hay devocionales"
        }
      } else {
        _errorMessage = 'Error al cargar devocionales: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Verifica tu acceso a internet.';
      // Podrías loggear el error original `e` para depuración.
      // print('Error de conexión: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notifica que la carga ha terminado (con éxito o error).
    }
  }

  /// Selecciona el siguiente devocional.
  ///
  /// Intenta seleccionar un devocional no visto. Si todos han sido vistos,
  /// selecciona uno aleatoriamente.
  void nextDevocional() {
    if (_devocionales.isEmpty) return;

    int nextIndex = _currentIndex;
    final total = _devocionales.length;

    // Si todos los devocionales han sido vistos, o si solo hay uno.
    if (_seenIndices.length >= total && total > 0) {
      // Opcional: podrías limpiar _seenIndices aquí si quieres que el ciclo de "no vistos" comience de nuevo.
      // _seenIndices.clear();
      nextIndex = Random().nextInt(total); // Simplemente elige uno al azar
    } else if (total > 1) {
      // Solo busca uno no visto si hay más de uno.
      int attempts = 0;
      // Bucle para encontrar un índice no visto.
      // Se limita el número de intentos para evitar bucles infinitos en casos extraños.
      do {
        nextIndex = Random().nextInt(total);
        attempts++;
        // Si se han hecho demasiados intentos (más que el total de devocionales),
        // o si encontramos un índice no visto, rompemos el bucle.
        // Esto previene que se quede atascado si _seenIndices está casi lleno.
        if (attempts > total * 2) {
          // Un umbral de intentos un poco mayor que el total
          // Como fallback, simplemente tomamos el siguiente índice secuencialmente
          // o volvemos al inicio si estamos al final.
          nextIndex = (_currentIndex + 1) % total;
          if (_seenIndices.contains(nextIndex) && _seenIndices.length < total) {
            // Si el secuencial también está visto y aún no hemos visto todos,
            // buscamos el primero no visto de forma más exhaustiva (o aceptamos un aleatorio).
            // Esta parte podría refinarse, pero por ahora el aleatorio inicial es el principal.
            // Para simplificar, si el aleatorio falla muchas veces, el fallback a aleatorio es aceptable.
            nextIndex = Random().nextInt(total); // Reintenta un aleatorio final
          }
          break;
        }
      } while (_seenIndices.contains(nextIndex));
    } else {
      // Si solo hay un devocional o ninguno.
      nextIndex = 0; // O _currentIndex, ya que no hay a dónde más ir.
    }

    _currentIndex = nextIndex;
    _seenIndices.add(nextIndex); // Marca el nuevo devocional como visto
    _saveSettings(); // Guarda el estado
    notifyListeners(); // Notifica a los widgets que escuchan
  }

  /// Establece el devocional actual por su índice.
  void setCurrentDevocionalByIndex(int index) {
    if (index >= 0 && index < _devocionales.length) {
      _currentIndex = index;
      _seenIndices
          .add(index); // Marcar como visto también al seleccionar directamente
      _saveSettings();
      notifyListeners();
    }
  }

  /// Alterna el estado de favorito del devocional actual.
  void toggleFavorite() {
    if (_devocionales.isEmpty) return;
    if (_favorites.contains(_currentIndex)) {
      _favorites.remove(_currentIndex);
    } else {
      _favorites.add(_currentIndex);
    }
    _saveSettings();
    notifyListeners();
  }

  /// Remueve un devocional de la lista de favoritos por su índice.
  void removeFavorite(int index) {
    if (_favorites.contains(index)) {
      _favorites.remove(index);
      _saveSettings();
      notifyListeners();
    }
  }

  /// Establece la visibilidad del diálogo de invitación.
  void setInvitationDialogVisibility(bool show) {
    _showInvitationDialog = show;
    _saveSettings();
    notifyListeners();
  }
}

// --- MyApp (Widget principal de la aplicación) ---
void main() {
  // Asegura que los bindings de Flutter estén inicializados antes de runApp.
  // WidgetsFlutterBinding.ensureInitialized(); // Necesario si realizas operaciones async antes de runApp
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DevocionalProvider(),
      child: MaterialApp(
        title: 'Devocionales',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          colorScheme: ColorScheme.fromSeed(
              seedColor:
                  Colors.deepPurple), // Alternativa moderna a primarySwatch
          appBarTheme: const AppBarTheme(
            elevation: 0, // AppBar sin sombra
            backgroundColor: Colors.deepPurple, // Color explícito para AppBar
            foregroundColor:
                Colors.white, // Color para el texto e íconos del AppBar
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true, // Habilita Material 3 si es tu intención
        ),
        // La aplicación ahora inicia en el SplashScreen importado.
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// --- DevocionalesPage (Página principal de devocionales) ---
// Esta página sigue aquí por ahora, pero podría moverse a su propio archivo.
class DevocionalesPage extends StatefulWidget {
  const DevocionalesPage({super.key});

  @override
  State<DevocionalesPage> createState() => _DevocionalesPageState();
}

class _DevocionalesPageState extends State<DevocionalesPage> {
  final ScreenshotController screenshotController = ScreenshotController();

  /// Muestra el diálogo de invitación.
  void _showInvitation(BuildContext context) {
    final devocionalProvider =
        Provider.of<DevocionalProvider>(context, listen: false);
    // Estado local para el checkbox dentro del diálogo.
    // Se inicializa con el valor opuesto a `showInvitationDialog`
    // porque la variable representa "No volver a mostrar".
    bool doNotShowAgainChecked = !devocionalProvider.showInvitationDialog;

    showDialog(
      context: context,
      barrierDismissible: false, // El usuario debe interactuar con el diálogo
      builder: (context) => StatefulBuilder(
        // StatefulBuilder permite que el estado del Checkbox se maneje localmente en el diálogo.
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            "¡Invitación a fiesta en los cielos y vida eterna!",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize
                  .min, // Para que el Column no ocupe más de lo necesario
              children: const [
                Text(
                  "Repite esta oración en voz alta, con fe y creyendo con todo el corazón:\n",
                  textAlign: TextAlign.justify,
                ),
                Text(
                  "Jesucristo, creo que moriste en la cruz por mi, te pido perdón y me arrepiento de corazón por mis pecados. Te pido seas mi Salvador y el señor de vida. Líbrame de la muerte eterna y escribe mi nombre en el libro de la vida.\nEn el poderoso nombre de Jesús, amén.\n",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
                Text(
                  "Si hiciste esta oración y lo crees:\nSerás salvo tu y tu casa (Hechos 16:31)\nVivirás eternamente (Juan 11:25-26)\nNunca más tendrás sed (Juan 4:14)\nEstarás con Jesucristo en los cielos (Apocalipsis 19:9)\nHay gozo en los cielos cuando un pecador se arrepiente (Lucas 15:10)\nEscrito está y Dios es fiel (Deuteronomio 7:9)\n\nSi hiciste está oración, desde ya tienes salvación y vida nueva.",
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          actions: [
            // Checkbox para "No volver a mostrar"
            Row(
              children: [
                Checkbox(
                  value: doNotShowAgainChecked,
                  onChanged: (val) {
                    setDialogState(() {
                      // Usa setDialogState para actualizar el UI del diálogo
                      doNotShowAgainChecked = val ?? false;
                    });
                  },
                ),
                const Expanded(child: Text('No volver a mostrar')),
              ],
            ),
            // Botones de acción del diálogo
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  // Actualiza la preferencia de mostrar el diálogo en el provider.
                  // Si "No volver a mostrar" está marcado (true), entonces `showInvitationDialog` debe ser false.
                  devocionalProvider
                      .setInvitationDialogVisibility(!doNotShowAgainChecked);
                  Navigator.of(context).pop(); // Cierra el diálogo
                  devocionalProvider
                      .nextDevocional(); // Carga el siguiente devocional
                },
                child: const Text("Siguiente devocional",
                    style: TextStyle(color: Colors.deepPurple)),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  // Simplemente cierra el diálogo sin cambiar la preferencia permanentemente.
                  // La preferencia `showInvitationDialog` no se modifica aquí,
                  // por lo que el diálogo podría aparecer la próxima vez si no se marcó el checkbox.
                  Navigator.of(context).pop();
                },
                child:
                    const Text("Cancelar", style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Comparte el devocional actual como texto.
  Future<void> _shareAsText(Devocional d) async {
    // Construye el texto a compartir.
    final shareText = '''
${d.versiculo}

Reflexión:
${d.reflexion}

Para meditar:
${d.paraMeditar.map((m) => "• ${m['cita']}\n${m['texto']}").join('\n\n')}

Oración:
${d.oracion}

Compartido desde: Mi Relación Íntima con Dios App
'''; // Puedes añadir una firma o enlace a tu app.

    await Share.share(shareText, subject: 'Devocional: ${d.versiculo}');
  }

  /// Captura el contenido del devocional como una imagen y lo comparte.
  Future<void> _shareAsImage(Devocional d) async {
    try {
      // Captura el widget envuelto por ScreenshotController.
      final imageBytes = await screenshotController.capture();
      if (imageBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo capturar la imagen.')),
          );
        }
        return;
      }

      // Guarda la imagen en un directorio temporal.
      final directory = (await getTemporaryDirectory()).path;
      // Usa un nombre de archivo que sea menos propenso a colisiones o caracteres inválidos.
      final imgPath =
          '$directory/devocional_share_${DateTime.now().millisecondsSinceEpoch}.png';
      final imgFile = File(imgPath);
      await imgFile.writeAsBytes(imageBytes);

      // Comparte el archivo de imagen.
      await Share.shareXFiles([XFile(imgPath)],
          subject: 'Devocional: ${d.versiculo}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir imagen: $e')),
        );
      }
      // print('Error al compartir imagen: $e'); // Para depuración
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // El color de fondo y foreground se hereda de ThemeData > appBarTheme
        centerTitle: true,
        title: const Text(
          'Mi relación íntima con Dios',
          style: TextStyle(
            // color: Colors.white, // Ya no es necesario si se define en appBarTheme
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
                Icons.favorite /*color: Colors.white*/), // Color heredado
            tooltip: 'Ver favoritos',
            onPressed: () {
              // TODO: Implementar navegación a FavoritesPage
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const FavoritesPage()),
              // );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Página de Favoritos (Pendiente)')),
              );
            },
          ),
        ],
      ),
      body: Consumer<DevocionalProvider>(
        builder: (context, devocionalProvider, child) {
          // Estado de carga
          if (devocionalProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // Estado de error
          else if (devocionalProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(devocionalProvider.errorMessage!,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => devocionalProvider.fetchDevocionales(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          // Estado sin devocionales o devocional actual nulo
          else if (devocionalProvider.devocionales.isEmpty ||
              devocionalProvider.currentDevocional == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No hay devocionales disponibles en este momento. Intenta más tarde.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Si todo está bien, muestra el devocional actual.
          final d = devocionalProvider.currentDevocional!;

          // El LayoutBuilder y ConstrainedBox aseguran que el SingleChildScrollView
          // tenga un contexto de tamaño para que la captura de pantalla funcione correctamente
          // incluso si el contenido es más corto que la pantalla.
          // IntrinsicHeight puede ser costoso, pero es útil para asegurar que
          // el widget Screenshot capture todo el contenido vertical.
          return LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  // Ayuda a Screenshot a determinar la altura completa
                  child: Screenshot(
                    controller: screenshotController,
                    // Es importante dar un color de fondo al widget que se va a capturar,
                    // de lo contrario, el fondo podría ser transparente en la imagen.
                    child: Container(
                      color: Theme.of(context)
                          .scaffoldBackgroundColor, // O Colors.white
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Versículo
                            Center(
                              // Centrar el versículo
                              child: AutoSizeText(
                                d.versiculo,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.deepPurple.shade700,
                                ),
                                textAlign: TextAlign.center,
                                maxLines:
                                    3, // Permitir más líneas para versículos largos
                                minFontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Reflexión
                            Text(
                              'Reflexión:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.deepPurple.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AutoSizeText(
                              d.reflexion,
                              style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.4), // Mejor interlineado
                              textAlign: TextAlign.justify,
                              // maxLines: 15, // Considerar quitar maxLines para AutoSizeText si no es crucial
                              minFontSize: 14,
                            ),
                            const SizedBox(height: 20),

                            // Para meditar
                            if (d.paraMeditar.isNotEmpty) ...[
                              Text(
                                'Para meditar:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.deepPurple.shade600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...d.paraMeditar.map((m) {
                                final cita = m['cita'] as String? ?? '';
                                final texto = m['texto'] as String? ?? '';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AutoSizeText(
                                        cita,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.deepPurple.shade700,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 2,
                                        minFontSize: 14,
                                      ),
                                      const SizedBox(height: 6),
                                      AutoSizeText(
                                        texto,
                                        style: const TextStyle(
                                            fontSize: 16, height: 1.4),
                                        textAlign: TextAlign.justify,
                                        // maxLines: 10,
                                        minFontSize: 14,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const SizedBox(
                                  height: 4), // Reducido espacio si había mucho
                            ],

                            // Oración
                            Text(
                              'Oración:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.deepPurple.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AutoSizeText(
                              d.oracion,
                              style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                  fontStyle: FontStyle.italic),
                              textAlign: TextAlign.justify,
                              // maxLines: 10,
                              minFontSize: 14,
                            ),
                            const SizedBox(
                                height: 24), // Espacio al final del contenido
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      // Barra de navegación inferior
      bottomNavigationBar: Consumer<DevocionalProvider>(
        builder: (context, devocionalProvider, child) {
          final d = devocionalProvider.currentDevocional;
          // No mostrar la barra si no hay devocional cargado
          if (d == null ||
              devocionalProvider.isLoading ||
              devocionalProvider.devocionales.isEmpty) {
            return const SizedBox.shrink();
          }

          bool isFavorite = devocionalProvider.favorites
              .contains(devocionalProvider.currentIndex);

          return BottomAppBar(
            color: Colors.deepPurple, // Color de fondo
            child: IconTheme(
              // Aplicar color blanco a todos los iconos dentro
              data: const IconThemeData(color: Colors.white),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Botón de Favorito
                    IconButton(
                      tooltip: isFavorite
                          ? 'Quitar de favoritos'
                          : 'Agregar a favoritos',
                      onPressed: devocionalProvider.toggleFavorite,
                      icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border),
                    ),
                    // Botón de Compartir Texto
                    IconButton(
                      tooltip: 'Compartir como texto',
                      onPressed: () => _shareAsText(d),
                      icon: const Icon(Icons.share),
                    ),
                    // Botón de Compartir Imagen
                    IconButton(
                      tooltip: 'Compartir como imagen (screenshot)',
                      onPressed: () => _shareAsImage(d),
                      icon: const Icon(Icons.image), // Icono más representativo
                    ),
                    // Botón de Siguiente Devocional
                    IconButton(
                      tooltip: 'Siguiente devocional',
                      onPressed: () {
                        if (devocionalProvider.showInvitationDialog) {
                          _showInvitation(context);
                        } else {
                          devocionalProvider.nextDevocional();
                        }
                      },
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
