// lib/pages/devocionales_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' show File;
import 'package:path_provider/path_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha

// Importa tus propios modelos y providers
import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/pages/favorites_page.dart'; // <-- Importa la nueva página de favoritos

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
    bool doNotShowAgainChecked = !devocionalProvider.showInvitationDialog;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            "¡Oración de fe, para vida eterna!",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  "Si hiciste esta oración y lo crees:\nSerás salvo tu y tu casa (Hch 16:31)\nVivirás eternamente (Jn 11:25-26)\nNunca más tendrás sed (Jn 4:14)\nEstarás con Cristo en los cielos (Ap 19:9)\nHay gozo en los cielos cuando un pecador se arrepiente (Luc 15:10)\nEscrito está y Dios es fiel (Dt 7:9)\n\nDesde ya tienes salvación y vida nueva en Jesucristo.",
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Checkbox(
                  value: doNotShowAgainChecked,
                  onChanged: (val) {
                    setDialogState(() {
                      doNotShowAgainChecked = val ?? false;
                    });
                  },
                ),
                const Expanded(
                    child: Text('Ya la hice 🙏,No mostrar nuevamente')),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  devocionalProvider
                      .setInvitationDialogVisibility(!doNotShowAgainChecked);
                  Navigator.of(context).pop();
                  devocionalProvider.goToNextDay(); // Usar goToNextDay
                },
                child: const Text("Siguiente devocional",
                    style: TextStyle(color: Colors.deepPurple)),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
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
    final shareText = '''
${d.versiculo}

Reflexión:
${d.reflexion}

Para meditar:
${d.paraMeditar.map((m) => "• ${m['cita']}\n${m['texto']}").join('\n\n')}

Oración:
${d.oracion}

Compartido desde: Mi Relación Íntima con Dios App
''';
    await Share.share(shareText, subject: 'Devocional: ${d.versiculo}');
  }

  /// Captura el contenido del devocional como una imagen y lo comparte.
  Future<void> _shareAsImage(Devocional d) async {
    try {
      final imageBytes = await screenshotController.capture();
      if (imageBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo capturar la imagen.')),
          );
        }
        return;
      }

      final directory = (await getTemporaryDirectory()).path;
      final imgPath =
          '$directory/devocional_share_${DateTime.now().millisecondsSinceEpoch}.png';
      final imgFile = File(imgPath);
      await imgFile.writeAsBytes(imageBytes);

      await Share.shareXFiles([XFile(imgPath)],
          subject: 'Devocional: ${d.versiculo}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir imagen: $e')),
        );
      }
    }
  }

  // Función para mostrar el selector de fecha (DatePicker)
  Future<void> _selectDate(
      BuildContext context, DevocionalProvider provider) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2000), // Fecha mínima
      lastDate: DateTime.now().add(const Duration(
          days: 365 * 10)), // Fecha máxima (ej. 10 años en el futuro)
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != provider.selectedDate) {
      provider.setSelectedDate(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Mi relación íntima con Dios',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark), // CAMBIO AQUÍ: Icono de marcador
            tooltip:
                'Ver favoritos guardados', // CAMBIO AQUÍ: Tooltip actualizado
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const FavoritesPage()), // <-- NAVEGAR A FAVORITESPAGE
              );
            },
          ),
        ],
      ),
      body: Consumer<DevocionalProvider>(
        builder: (context, devocionalProvider, child) {
          if (devocionalProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (devocionalProvider.errorMessage != null) {
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
                      onPressed: () => devocionalProvider
                          .initializeData(), // Reintentar cargar todo
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final d = devocionalProvider.currentDevocional;

          // Nuevo: Verificar si el devocional actual es el "no disponible" (placeholder)
          if (d == null || d.id.startsWith('no-data')) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No hay devocional disponible para esta fecha.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _selectDate(context, devocionalProvider),
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Elegir otra fecha'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        devocionalProvider.setSelectedDate(DateTime.now());
                      },
                      icon: const Icon(Icons.today),
                      label: const Text('Ir al día de hoy'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.deepPurple),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Screenshot(
                    controller: screenshotController,
                    child: Container(
                      color: Theme.of(context)
                          .scaffoldBackgroundColor, // Asegura que el fondo sea capturado
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back_ios),
                                    onPressed:
                                        devocionalProvider.goToPreviousDay,
                                  ),
                                  GestureDetector(
                                    onTap: () => _selectDate(
                                        context, devocionalProvider),
                                    child: Text(
                                      // CAMBIO AQUÍ: Eliminar 'Geißler' del formato
                                      DateFormat('dd MMMM',
                                              'es') // Antes era 'dd MMMM Geißler'
                                          .format(
                                              devocionalProvider.selectedDate),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios),
                                    onPressed: devocionalProvider.goToNextDay,
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: AutoSizeText(
                                d.versiculo,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.deepPurple.shade700,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                minFontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
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
                              style: const TextStyle(fontSize: 16, height: 1.4),
                              textAlign: TextAlign.justify,
                              minFontSize: 14,
                            ),
                            const SizedBox(height: 20),
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
                                final cita = m['cita'] ?? '';
                                final texto = m['texto'] ?? '';
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
                                        minFontSize: 14,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 4),
                            ],
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
                              minFontSize: 14,
                            ),
                            const SizedBox(height: 24),
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
      bottomNavigationBar: Consumer<DevocionalProvider>(
        builder: (context, devocionalProvider, child) {
          final d = devocionalProvider.currentDevocional;
          // No mostrar la barra si no hay un devocional válido cargado (o es el placeholder)
          if (d == null ||
              devocionalProvider.isLoading ||
              d.id.startsWith('no-data')) {
            return const SizedBox
                .shrink(); // O un contenedor vacío para ocultarlo
          }

          bool isFavorite = devocionalProvider.isFavorite(d);

          return BottomAppBar(
            color: Colors.deepPurple,
            child: IconTheme(
              data: const IconThemeData(color: Colors.white),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      tooltip: isFavorite
                          ? 'Quitar de favoritos'
                          : 'Agregar a favoritos',
                      onPressed: () => devocionalProvider.toggleFavorite(
                          d, context), // **Pasa el context aquí** [cite: 1]
                      icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border),
                    ),
                    IconButton(
                      tooltip: 'Compartir como texto',
                      onPressed: () => _shareAsText(d),
                      icon: const Icon(Icons.share),
                    ),
                    IconButton(
                      tooltip: 'Compartir como imagen (screenshot)',
                      onPressed: () => _shareAsImage(d),
                      icon: const Icon(Icons.image),
                    ),
                    IconButton(
                      tooltip: 'Siguiente devocional',
                      onPressed: () {
                        if (devocionalProvider.showInvitationDialog) {
                          _showInvitation(context);
                        } else {
                          devocionalProvider.goToNextDay(); // Usar goToNextDay
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
// Este código define la página principal de devocionales, donde se muestra el devocional del día, se permite navegar entre días, compartir el devocional y agregarlo a favoritos.
