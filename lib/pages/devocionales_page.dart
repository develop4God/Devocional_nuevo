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
import 'package:devocional_nuevo/pages/favorites_page.dart'; // Importa la página de favoritos
import 'package:devocional_nuevo/pages/settings_page.dart'; // Importa la página de configuración

// --- DevocionalesPage (Página principal de devocionales) ---
class DevocionalesPage extends StatefulWidget {
  final String? initialDevocionalId;

  const DevocionalesPage({super.key, this.initialDevocionalId});

  @override
  State<DevocionalesPage> createState() => _DevocionalesPageState();
}

class _DevocionalesPageState extends State<DevocionalesPage> {
  final ScreenshotController screenshotController = ScreenshotController();
  int _currentDevocionalIndex = 0;

  // --- Método para detectar la dirección del swipe ---
  Offset _dragStart = Offset.zero;

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final dx = details.globalPosition.dx - _dragStart.dx;
    if (dx.abs() > 50) {
      // Considerar un swipe si el desplazamiento es mayor a 50 pixeles
      if (dx < 0) {
        // Deslizar de derecha a izquierda (siguiente)
        _goToNextDevocional();
      } else {
        // Deslizar de izquierda a derecha (anterior)
        _goToPreviousDevocional();
      }
    }
  }

  // Métodos para navegar, reutilizando la lógica del BottomAppBar
  void _goToNextDevocional() {
    final devocionalProvider = Provider.of<DevocionalProvider>(
      context,
      listen: false,
    );
    final List<Devocional> devocionales = devocionalProvider.devocionales;

    if (_currentDevocionalIndex < devocionales.length - 1) {
      setState(() {
        _currentDevocionalIndex++;
      });
      // Mostrar la oración de fe si showInvitationDialog es true al avanzar
      if (devocionalProvider.showInvitationDialog) {
        _showInvitation(context);
      }
    }
  }

  void _goToPreviousDevocional() {
    if (_currentDevocionalIndex > 0) {
      setState(() {
        _currentDevocionalIndex--;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final devocionalProvider = Provider.of<DevocionalProvider>(
        context,
        listen: false,
      );

      if (!devocionalProvider.isLoading &&
          devocionalProvider.devocionales.isEmpty) {
        devocionalProvider.initializeData();
      }

      if (widget.initialDevocionalId != null &&
          devocionalProvider.devocionales.isNotEmpty) {
        final index = devocionalProvider.devocionales.indexWhere(
          (d) => d.id == widget.initialDevocionalId,
        );
        if (index != -1) {
          setState(() {
            _currentDevocionalIndex = index;
          });
        }
      }
    });
  }

  /// Muestra el diálogo de la Oración de Fe.
  void _showInvitation(BuildContext context) {
    final devocionalProvider = Provider.of<DevocionalProvider>(
      context,
      listen: false,
    );
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
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
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
                  child: Text('Ya la hice 🙏,No mostrar nuevamente'),
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  devocionalProvider.setInvitationDialogVisibility(
                    !doNotShowAgainChecked,
                  );
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Entendido",
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Comparte el devocional como texto.
  Future<void> _shareAsText(Devocional devocional) async {
    final text =
        "Devocional del día:\n\nVersículo: ${devocional.versiculo}\n\nReflexión: ${devocional.reflexion}\n\nPara Meditar:\n${devocional.paraMeditar.map((p) => '${p.cita}: ${p.texto}').join('\n')}\n\nOración: ${devocional.oracion}\n\nVersión: ${devocional.version ?? 'N/A'}\nIdioma: ${devocional.language ?? 'N/A'}\nFecha: ${DateFormat('dd/MM/yyyy').format(devocional.date)}";
    await Share.share(text);
  }

  /// Comparte el devocional como imagen (captura de pantalla).
  Future<void> _shareAsImage(Devocional devocional) async {
    final image = await screenshotController.capture();
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File('${directory.path}/devocional.png').create();
      await imagePath.writeAsBytes(image);
      await Share.shareXFiles([
        XFile(imagePath.path),
      ], text: 'Devocional del día');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        // Título fijo en lugar de la fecha
        title: const Text(
          'Devocional Diario',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Consumer<DevocionalProvider>(
            builder: (context, devocionalProvider, child) {
              if (devocionalProvider.devocionales.isEmpty) {
                return const SizedBox.shrink(); // Widget vacío si no hay devocionales
              }
              final List<Devocional> devocionales =
                  devocionalProvider.devocionales;
              return Row(
                children: [
                  // Selector de Idioma - Mantenido
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: devocionalProvider.selectedLanguage,
                      icon: const Icon(Icons.language, color: Colors.white),
                      dropdownColor: Colors.deepPurple[700],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          devocionalProvider.setSelectedLanguage(newValue);
                          setState(() {
                            _currentDevocionalIndex = 0;
                          });
                        }
                      },
                      items: <String>['es', 'en'].map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value.toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  // Selector de Versión - Mantenido
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: devocionalProvider.selectedVersion,
                      icon: const Icon(Icons.menu_book, color: Colors.white),
                      dropdownColor: Colors.deepPurple[700],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          devocionalProvider.setSelectedVersion(newValue);
                          setState(() {
                            _currentDevocionalIndex = 0;
                          });
                        }
                      },
                      items: <String>['RVR1960', 'NVI']
                          .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ),
                  // Botón de Navegación a Favoritos (con ícono Bookmark) - Mantenido
                  IconButton(
                    icon: const Icon(
                      Icons.bookmark,
                    ), // <<-- ÍCONO CAMBIADO A BOOKMARK
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoritesPage(),
                        ),
                      );
                    },
                  ),
                  // Calendario - COMENTADO/QUITADO (para conservar el código)
                  /*
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: devocionales.isEmpty
                            ? DateTime.now()
                            : devocionales[_currentDevocionalIndex].date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        final int index = devocionales.indexWhere(
                          (d) =>
                              d.date.year == picked.year &&
                              d.date.month == picked.month &&
                              d.date.day == picked.day,
                        );
                        if (index != -1) {
                          setState(() {
                            _currentDevocionalIndex = index;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'No hay devocional disponible para esta fecha')),
                          );
                        }
                      }
                    },
                  ),
                  */
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<DevocionalProvider>(
        builder: (context, devocionalProvider, child) {
          final List<Devocional> devocionales = devocionalProvider.devocionales;

          if (devocionalProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (devocionalProvider.errorMessage != null && devocionales.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      devocionalProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => devocionalProvider.initializeData(),
                      child: const Text('Reintentar Carga'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (devocionales.isEmpty) {
            return const Center(
              child: Text(
                'No hay devocionales disponibles para el idioma/versión seleccionados.',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (_currentDevocionalIndex >= devocionales.length) {
            _currentDevocionalIndex = devocionales.length - 1;
            if (_currentDevocionalIndex < 0) _currentDevocionalIndex = 0;
          }

          final Devocional currentDevocional =
              devocionales[_currentDevocionalIndex];
          final bool isFavorite = devocionalProvider.isFavorite(
            currentDevocional,
          );

          return Column(
            // Columna principal del body para elementos fijos y desplazables
            children: [
              // --- Fecha del Devocional (Fija, debajo del AppBar) ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  DateFormat(
                    'EEEE, d MMMM',
                    'es',
                  ).format(currentDevocional.date), // Formato de fecha completo
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              // --- Contenido del Devocional (Desplazable) ---
              Expanded(
                child: GestureDetector(
                  onHorizontalDragStart: _onHorizontalDragStart,
                  onHorizontalDragEnd: _onHorizontalDragEnd,
                  child: Screenshot(
                    controller: screenshotController,
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(
                          16.0,
                        ), // <<-- CORRECCIÓN AQUÍ
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Versículo
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple[100],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.deepPurple.shade300,
                                ),
                              ),
                              child: AutoSizeText(
                                currentDevocional.versiculo,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge!
                                    .copyWith(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple.shade800,
                                    ),
                                maxLines: 5,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Reflexión
                            Text(
                              'Reflexión:',
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              currentDevocional.reflexion,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 20),

                            // Sección "Para Meditar"
                            Text(
                              'Para Meditar:',
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            ...currentDevocional.paraMeditar.map((item) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${item.cita}: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      TextSpan(
                                        text: item.texto,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 20),

                            // Oración
                            Text(
                              'Oración:',
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              currentDevocional.oracion,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 20),

                            // Información de Versión y Tags (si existen)
                            if (currentDevocional.version != null ||
                                currentDevocional.language != null ||
                                currentDevocional.tags != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detalles:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (currentDevocional.version != null)
                                    Text(
                                      'Versión: ${currentDevocional.version}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  if (currentDevocional.language != null)
                                    Text(
                                      'Idioma: ${currentDevocional.language}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  if (currentDevocional.tags != null &&
                                      currentDevocional.tags!.isNotEmpty)
                                    Text(
                                      'Temas: ${currentDevocional.tags!.join(', ')}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // --- Botones de Acción (Fijos en la parte inferior del body) ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botón Favoritos (corazón lleno/vacío)
                    IconButton(
                      tooltip: isFavorite
                          ? 'Quitar de favoritos'
                          : 'Guardar como favorito',
                      onPressed: () => devocionalProvider.toggleFavorite(
                        currentDevocional,
                        context,
                      ),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                    // Botón Compartir como Texto
                    IconButton(
                      tooltip: 'Compartir como texto',
                      onPressed: () => _shareAsText(currentDevocional),
                      icon: const Icon(Icons.share, size: 30),
                    ),
                    // Botón Compartir como Imagen
                    IconButton(
                      tooltip: 'Compartir como imagen (screenshot)',
                      onPressed: () => _shareAsImage(currentDevocional),
                      icon: const Icon(Icons.image, size: 30),
                    ),
                    // Botón de Configuración (Nuevo)
                    IconButton(
                      tooltip: 'Configuración',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings, size: 30),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      // --- BARRAS DE NAVEGACIÓN INFERIOR (DevocionalesPage) ---
      bottomNavigationBar: Consumer<DevocionalProvider>(
        builder: (context, devocionalProvider, child) {
          final List<Devocional> devocionales = devocionalProvider.devocionales;
          return BottomAppBar(
            color: Colors.deepPurple,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Botón Devocional anterior
                IconButton(
                  tooltip: 'Devocional anterior',
                  onPressed: _currentDevocionalIndex > 0
                      ? _goToPreviousDevocional // Usa el método unificado
                      : null, // Deshabilitar si es el primero
                  icon: Icon(
                    Icons.arrow_back,
                    color: _currentDevocionalIndex > 0
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    size: 30,
                  ),
                ),
                // Botón Devocional siguiente
                IconButton(
                  tooltip: 'Siguiente devocional',
                  onPressed: _currentDevocionalIndex < devocionales.length - 1
                      ? _goToNextDevocional // Usa el método unificado
                      : null, // Deshabilitar si es el último
                  icon: Icon(
                    Icons.arrow_forward,
                    color: _currentDevocionalIndex < devocionales.length - 1
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    size: 30,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
