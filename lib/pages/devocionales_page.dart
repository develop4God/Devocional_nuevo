// lib/pages/devocionales_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' show File; // Usado para File
import 'package:path_provider/path_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

// Importa tus propios modelos y providers
import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';

// --- DevocionalesPage (Página principal de devocionales) ---
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
            "¡Oración de fe, para vida eterna!",
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
                  "Si hiciste esta oración y lo crees:\nSerás salvo tu y tu casa (Hch 16:31)\nVivirás eternamente (Jn 11:25-26)\nNunca más tendrás sed (Jn 4:14)\nEstarás con Jesucristo en los cielos (Ap 19:9)\nHay gozo en los cielos cuando un pecador se arrepiente (Luc 15:10)\nEscrito está y Dios es fiel (Dt 7:9)\nDesde ya tienes salvación y vida nueva en Jesucristo.",
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          actions: [
            // Checkbox para "Ya la hice, no mostrar nuevamente"
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
