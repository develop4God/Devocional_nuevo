// lib/pages/devocionales_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha
import 'package:flutter_share/flutter_share.dart'; // Para compartir
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/models/devocional_model.dart'; // Asegúrate de que Devocional está importado
import 'package:url_launcher/url_launcher.dart'; // Para abrir enlaces

class DevocionalesPage extends StatefulWidget {
  const DevocionalesPage({super.key});

  @override
  State<DevocionalesPage> createState() => _DevocionalesPageState();
}

class _DevocionalesPageState extends State<DevocionalesPage> {
  // Controlador para el PageView
  final PageController _pageController = PageController();
  // Índice de la página actual
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Escuchar cambios en el índice de la página y actualizar el estado
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentPageIndex = _pageController.page!.round();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Llamar a initializeData solo una vez después de que el widget se haya construido.
      // Se hace de esta forma para evitar llamar a notifyListeners durante la construcción.
      Provider.of<DevocionalProvider>(context, listen: false).initializeData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Función para compartir el devocional
  Future<void> shareDevocional(Devocional devocional) async {
    // Formatear la lista de "Para Meditar" como un string con saltos de línea
    final String paraMeditarText = devocional.paraMeditar.isNotEmpty
        ? devocional.paraMeditar.join('\n')
        : 'N/A';

    final String shareText = "Devocional del día:\n\n"
        "Versículo: ${devocional.versiculo}\n\n"
        "Reflexión: ${devocional.reflexion}\n\n"
        "Para Meditar:\n$paraMeditarText\n\n" // Usamos la cadena formateada
        "Oración: ${devocional.oracion}\n\n"
        "Versión: ${devocional.version ?? 'N/A'}\n"
        "Idioma: ${devocional.language ?? 'N/A'}\n"
        "Fecha: ${DateFormat('dd/MM/yyyy').format(devocional.date)}";

    await FlutterShare.share(
      title: 'Devocional del Día',
      text: shareText,
      chooserTitle: 'Compartir Devocional',
    );
  }

  // Función para mostrar el diálogo de confirmación antes de añadir a favoritos
  void _showFavoriteConfirmationDialog(
      Devocional devocional, DevocionalProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Añadir a favoritos'),
          content: const Text(
              '¿Estás seguro de que quieres guardar este devocional en favoritos?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                provider.toggleFavorite(
                    devocional, context); // Añadir/quitar de favoritos
                Navigator.of(dialogContext).pop(); // Cerrar el diálogo
              },
              child: const Text('Sí, guardar'),
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar el diálogo de invitación a la comunidad (solo si es la primera vez)
  void _showInvitationDialog(DevocionalProvider provider) {
    // Solo mostrar si es la primera vez y el usuario no lo ha deshabilitado
    if (provider.showInvitationDialog) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('¡Bienvenido!'),
            content: const Text(
                'Te invitamos a unirte a nuestra comunidad para crecer en la fe. ¿Te gustaría saber más?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Ocultar el diálogo para futuras sesiones
                  provider.setInvitationDialogVisibility(false);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('No mostrar de nuevo'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Ahora no'),
              ),
              FilledButton(
                onPressed: () async {
                  // Aquí iría el enlace a la comunidad (ej. WhatsApp, Telegram, etc.)
                  const url =
                      'https://example.com/join_community'; // Reemplazar con tu enlace
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo abrir el enlace.'),
                        ),
                      );
                    }
                  }
                  // Opcional: Deshabilitar el diálogo después de hacer clic en "Unirme"
                  provider.setInvitationDialogVisibility(false);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('¡Unirme!'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DevocionalProvider>(
      builder: (context, devocionalProvider, child) {
        // Mostrar el diálogo de invitación después de que la UI se haya cargado
        // y los datos iniciales se hayan procesado.
        if (!devocionalProvider.isLoading &&
            devocionalProvider.errorMessage == null &&
            devocionalProvider.devocionales.isNotEmpty &&
            devocionalProvider.showInvitationDialog) {
          // Usar addPostFrameCallback para asegurar que el diálogo se muestra
          // después de que el frame actual se haya renderizado.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showInvitationDialog(devocionalProvider);
          });
        }

        if (devocionalProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (devocionalProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 48.0),
                const SizedBox(height: 16),
                Text(
                  devocionalProvider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.red[700]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      devocionalProvider.initializeData(), // Reintentar
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }

        if (devocionalProvider.devocionales.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sentiment_dissatisfied,
                    color: Colors.grey[600], size: 48.0),
                const SizedBox(height: 16),
                Text(
                  'No hay devocionales disponibles para la versión y el idioma seleccionados.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Aquí puedes ofrecer opciones para cambiar idioma/versión
                    debugPrint('Abrir selector de idioma/versión');
                    // Puedes navegar a una pantalla de configuración o mostrar un diálogo
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Ajustar configuración'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }

        // Si hay devocionales, ajusta el controlador de página si es necesario
        // Esto previene un error si la lista de devocionales cambia (ej. por filtro)
        // y el índice actual está fuera de rango.
        if (_currentPageIndex >= devocionalProvider.devocionales.length) {
          _currentPageIndex = devocionalProvider.devocionales.length - 1;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _pageController.jumpToPage(_currentPageIndex);
          });
        }

        return Column(
          children: [
            // Controles de Idioma y Versión
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DropdownButton<String>(
                    value: devocionalProvider.selectedLanguage,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        devocionalProvider.setSelectedLanguage(newValue);
                      }
                    },
                    items: <String>[
                      'es',
                      'en'
                    ] // Añade más idiomas si es necesario
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toUpperCase()),
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    value: devocionalProvider.selectedVersion,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        devocionalProvider.setSelectedVersion(newValue);
                      }
                    },
                    items: <String>['RVR1960', 'NVI'] // Añade más versiones
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: devocionalProvider.devocionales.length,
                onPageChanged: (index) {
                  // No se necesita setState aquí porque el listener ya lo hace
                },
                itemBuilder: (context, index) {
                  final devocional = devocionalProvider.devocionales[index];
                  // Determina si es favorito para el icono
                  final bool isFav = devocionalProvider.isFavorite(devocional);

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(devocional.date),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFav ? Colors.red : null,
                                ),
                                onPressed: () =>
                                    _showFavoriteConfirmationDialog(
                                        devocional, devocionalProvider),
                                tooltip: isFav
                                    ? 'Remover de favoritos'
                                    : 'Añadir a favoritos',
                              ),
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () => shareDevocional(devocional),
                                tooltip: 'Compartir',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            devocional.versiculo,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            'Reflexión:',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            devocional.reflexion,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Para Meditar:',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          // CAMBIO CLAVE AQUÍ: Iterar directamente sobre los strings
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: devocional.paraMeditar
                                .map((item) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 4.0),
                                      // Usar el string completo directamente
                                      child: Text(
                                        item, // 'item' es ahora el String completo
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        textAlign: TextAlign.justify,
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Oración:',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            devocional.oracion,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tags: ${devocional.tags?.join(', ') ?? 'N/A'}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Indicadores de página
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  devocionalProvider.devocionales.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPageIndex == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
