// lib/pages/devocionales_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' show File;
import 'package:path_provider/path_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha, ya no está comentado

// Importa tus propios modelos y providers
import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/pages/favorites_page.dart'; // Importa la página de favoritos

// --- DevocionalesPage (Página principal de devocionales) ---
class DevocionalesPage extends StatefulWidget {
  // Ahora puede recibir un devocional ID para mostrarlo directamente
  final String? initialDevocionalId;

  const DevocionalesPage({super.key, this.initialDevocionalId});

  @override
  State<DevocionalesPage> createState() => _DevocionalesPageState();
}

class _DevocionalesPageState extends State<DevocionalesPage> {
  final ScreenshotController screenshotController = ScreenshotController();
  // Índice para controlar el devocional actual en la lista filtrada
  int _currentDevocionalIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final devocionalProvider =
          Provider.of<DevocionalProvider>(context, listen: false);

      // Solo inicializa si no está cargando y si la lista de devocionales está vacía.
      // La carga inicial y la configuración de preferencias se maneja en initializeData().
      if (!devocionalProvider.isLoading &&
          devocionalProvider.devocionales.isEmpty) {
        devocionalProvider.initializeData();
      }

      // Si se proporcionó un ID de devocional inicial (desde favoritos, por ejemplo)
      // y los devocionales ya están cargados, intenta encontrarlo.
      // Si no están cargados, el listener (Consumer) se encargará cuando lo estén.
      if (widget.initialDevocionalId != null &&
          devocionalProvider.devocionales.isNotEmpty) {
        final index = devocionalProvider.devocionales.indexWhere(
          // << CORREGIDO: devocales -> devocionales
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

  /// Muestra el diálogo de invitación.
  void _showInvitation(BuildContext context) {
    final devocionalProvider =
        Provider.of<DevocionalProvider>(context, listen: false);
    bool doNotShowAgainChecked = false; // Estado inicial del checkbox

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Usa StatefulBuilder para que el estado del checkbox se actualice
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('¡Hola!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                      'Te invitamos a nuestro grupo de WhatsApp para crecer juntos en la fe.'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: doNotShowAgainChecked,
                        onChanged: (bool? newValue) {
                          setState(() {
                            doNotShowAgainChecked = newValue ?? false;
                          });
                        },
                      ),
                      const Text('No mostrar de nuevo'),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ahora no'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (doNotShowAgainChecked) {
                      devocionalProvider.setInvitationDialogVisibility(false);
                    }
                  },
                ),
                TextButton(
                  child: const Text('Unirme'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    if (doNotShowAgainChecked) {
                      devocionalProvider.setInvitationDialogVisibility(false);
                    }
                    // Implementa la lógica para unirse al grupo de WhatsApp
                    // Por ejemplo, usando url_launcher para abrir un enlace
                    // Puedes obtener el enlace de WhatsApp de Constants.whatsappLink si lo añades allí
                    // launchUrl(Uri.parse('https://chat.whatsapp.com/TU_INVITACION'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Abriendo enlace de WhatsApp...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
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
      await Share.shareXFiles([XFile(imagePath.path)],
          text: 'Devocional del día');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: Consumer<DevocionalProvider>(
          builder: (context, devocionalProvider, child) {
            final List<Devocional> devocionales =
                devocionalProvider.devocionales;
            if (devocionales.isEmpty) {
              return const Text('Cargando devocionales...');
            }
            // << CORREGIDO: Usar la fecha del devocional actual
            return Text(DateFormat('EEEE, d MMMM', 'es').format(devocionales
                    .isEmpty
                ? DateTime.now() // Si no hay devocionales, usa la fecha actual
                : devocionales[_currentDevocionalIndex].date));
          },
        ),
        centerTitle: true,
        actions: [
          Consumer<DevocionalProvider>(
            builder: (context, devocionalProvider, child) {
              final List<Devocional> devocionales =
                  devocionalProvider.devocionales;
              return Row(
                children: [
                  // Selector de Idioma
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: devocionalProvider.selectedLanguage,
                      icon: const Icon(Icons.language, color: Colors.white),
                      dropdownColor: Colors.deepPurple[700],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          devocionalProvider.setSelectedLanguage(newValue);
                          // Resetear el índice a 0 al cambiar de idioma
                          setState(() {
                            _currentDevocionalIndex = 0;
                          });
                        }
                      },
                      items: <String>[
                        'es',
                        'en'
                      ] // Añade aquí los idiomas soportados
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value.toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Selector de Versión
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: devocionalProvider.selectedVersion,
                      icon: const Icon(Icons.menu_book, color: Colors.white),
                      dropdownColor: Colors.deepPurple[700],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          devocionalProvider.setSelectedVersion(newValue);
                          // Resetear el índice a 0 al cambiar de versión
                          setState(() {
                            _currentDevocionalIndex = 0;
                          });
                        }
                      },
                      items: <String>[
                        'RVR1960',
                        'NVI'
                      ] // Asegúrate de que estas coincidan con tu JSON
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Botón de calendario (DatePicker)
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: devocionales.isEmpty
                            ? DateTime.now()
                            : devocionales[_currentDevocionalIndex]
                                .date, // << CORREGIDO: usar fecha del devocional actual
                        firstDate:
                            DateTime(2020), // Rango de fechas para el picker
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        // Buscar el devocional para la fecha seleccionada
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
                  // Botón para ir a favoritos
                  IconButton(
                    icon: const Icon(Icons.favorite),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FavoritesPage()),
                      );
                    },
                  ),
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
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 50),
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

          // Asegurarse de que el índice no esté fuera de rango
          if (_currentDevocionalIndex >= devocionales.length) {
            _currentDevocionalIndex = devocionales.length - 1;
            if (_currentDevocionalIndex < 0)
              _currentDevocionalIndex = 0; // Asegurar que no sea negativo
          }

          final Devocional currentDevocional =
              devocionales[_currentDevocionalIndex];
          final bool isFavorite =
              devocionalProvider.isFavorite(currentDevocional);

          return Screenshot(
            controller: screenshotController,
            child: Container(
              color: Theme.of(context)
                  .scaffoldBackgroundColor, // Fondo para la captura
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Versículo
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.deepPurple.shade300),
                      ),
                      child: AutoSizeText(
                        currentDevocional.versiculo,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
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
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                    const SizedBox(height: 10),
                    // << CORREGIDO: Acceso directo a item.cita y item.texto
                    ...currentDevocional.paraMeditar.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '${item.cita}: ', // Ahora item es de tipo ParaMeditar
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              TextSpan(
                                text: item
                                    .texto, // Ahora item es de tipo ParaMeditar
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
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
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
                                    color: Colors.deepPurple),
                          ),
                          const SizedBox(height: 10),
                          if (currentDevocional.version != null)
                            Text('Versión: ${currentDevocional.version}',
                                style: const TextStyle(fontSize: 14)),
                          if (currentDevocional.language != null)
                            Text('Idioma: ${currentDevocional.language}',
                                style: const TextStyle(fontSize: 14)),
                          if (currentDevocional.tags != null &&
                              currentDevocional.tags!.isNotEmpty)
                            Text('Temas: ${currentDevocional.tags!.join(', ')}',
                                style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 20),
                        ],
                      ),

                    // Botones de acción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Botón Favoritos
                        IconButton(
                          tooltip: isFavorite
                              ? 'Quitar de favoritos'
                              : 'Guardar como favorito',
                          onPressed: () => devocionalProvider.toggleFavorite(
                              currentDevocional, context),
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
                        // Botón de compartir en grupo (WhatsApp, etc.)
                        IconButton(
                          tooltip: 'Unirme al grupo',
                          // << CORREGIDO: Cambiado Icons.whatsapp a Icons.group
                          onPressed: () => _showInvitation(context),
                          icon: const Icon(Icons.group, size: 30),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
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
                IconButton(
                  tooltip: 'Devocional anterior',
                  onPressed: _currentDevocionalIndex > 0
                      ? () {
                          setState(() {
                            _currentDevocionalIndex--;
                          });
                        }
                      : null, // Deshabilitar si es el primero
                  icon: Icon(
                    Icons.arrow_back,
                    color: _currentDevocionalIndex > 0
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    size: 30,
                  ),
                ),
                IconButton(
                  tooltip: 'Devocional siguiente',
                  onPressed: _currentDevocionalIndex < devocionales.length - 1
                      ? () {
                          setState(() {
                            _currentDevocionalIndex++;
                          });
                          // Si se llega al último devocional y el diálogo de invitación está activado
                          if (_currentDevocionalIndex ==
                                  devocionales.length - 1 &&
                              devocionalProvider.showInvitationDialog) {
                            _showInvitation(context);
                          }
                        }
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

// << CORREGIDO: Eliminada la clase NavigationService al final del archivo
