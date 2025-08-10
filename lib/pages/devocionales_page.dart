import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' show File;
import 'package:path_provider/path_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:devocional_nuevo/widgets/devocionales_page_drawer.dart';
import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/pages/settings_page.dart';
import 'package:devocional_nuevo/services/update_service.dart';
import 'package:devocional_nuevo/pages/progress_page.dart'; // AJUSTE: Import necesario para progreso

class DevocionalesPage extends StatefulWidget {
  final String? initialDevocionalId;

  const DevocionalesPage({super.key, this.initialDevocionalId});

  @override
  State<DevocionalesPage> createState() => _DevocionalesPageState();
}

class _DevocionalesPageState extends State<DevocionalesPage>
    with WidgetsBindingObserver {
  final ScreenshotController screenshotController = ScreenshotController();
  final ScrollController _scrollController = ScrollController();
  int _currentDevocionalIndex = 0;
  static const String _lastDevocionalIndexKey = 'lastDevocionalIndex';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInitialData();

    // Verificar actualizaciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkForUpdate();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Verificar actualizaciones cuando la app vuelve del background
      UpdateService.checkForUpdate();
    }
  }

  Future<void> _loadInitialData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final devocionalProvider =
          Provider.of<DevocionalProvider>(context, listen: false);

      if (!devocionalProvider.isLoading &&
          devocionalProvider.devocionales.isEmpty) {
        await devocionalProvider.initializeData();
        if (!mounted) return;
      }

      if (devocionalProvider.devocionales.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final int? savedIndex = prefs.getInt(_lastDevocionalIndexKey);

        if (mounted) {
          setState(() {
            if (savedIndex != null) {
              _currentDevocionalIndex =
                  (savedIndex + 1) % devocionalProvider.devocionales.length;
              developer.log(
                  'Devocional cargado al inicio (índice siguiente): $_currentDevocionalIndex');
            } else {
              _currentDevocionalIndex = 0;
              developer.log(
                  'No hay índice guardado. Iniciando en el primer devocional (índice 0).');
            }
          });
          
          // Record that a devotional is being read when app starts
          devocionalProvider.recordDevocionalRead();
        }
      } else {
        if (mounted) {
          setState(() {
            _currentDevocionalIndex = 0;
          });
        }
        developer.log('No hay devocionales disponibles para cargar el índice.');
      }

      if (widget.initialDevocionalId != null &&
          devocionalProvider.devocionales.isNotEmpty) {
        final index = devocionalProvider.devocionales.indexWhere(
          (d) => d.id == widget.initialDevocionalId,
        );
        if (index != -1) {
          if (mounted) {
            setState(() {
              _currentDevocionalIndex = index;
            });
          }
        }
      }
    });
  }

  void _goToNextDevocional() {
    if (!mounted) return;

    final devocionalProvider =
        Provider.of<DevocionalProvider>(context, listen: false);
    final List<Devocional> devocionales = devocionalProvider.devocionales;

    if (_currentDevocionalIndex < devocionales.length - 1) {
      // Record that a devotional was read before moving to the next one
      devocionalProvider.recordDevocionalRead();
      
      setState(() {
        _currentDevocionalIndex++;
      });
      _scrollToTop();
      if (devocionalProvider.showInvitationDialog) {
        if (mounted) {
          _showInvitation(context);
        }
      }
      _saveCurrentDevocionalIndex();
    }
  }

  void _goToPreviousDevocional() {
    if (_currentDevocionalIndex > 0) {
      setState(() {
        _currentDevocionalIndex--;
      });
      _scrollToTop();
    }
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _saveCurrentDevocionalIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastDevocionalIndexKey, _currentDevocionalIndex);
    developer.log('Índice de devocional guardado: $_currentDevocionalIndex');
  }

  void _showInvitation(BuildContext context) {
    if (!mounted) return;

    final devocionalProvider =
        Provider.of<DevocionalProvider>(context, listen: false);
    bool doNotShowAgainChecked = !devocionalProvider.showInvitationDialog;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            "¡Oración de fe, para vida eterna!",
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Repite esta oración en voz alta, con fe y creyendo con todo el corazón:\n",
                  textAlign: TextAlign.justify,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurface),
                ),
                Text(
                  "Jesucristo, creo que moriste en la cruz por mi, te pido perdón y me arrepiento de corazón por mis pecados. Te pido seas mi Salvador y el señor de vida. Líbrame de la muerte eterna y escribe mi nombre en el libro de la vida.\nEn el poderoso nombre de Jesús, amén.\n",
                  textAlign: TextAlign.justify,
                  style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface),
                ),
                Text(
                  "Si hiciste esta oración y lo crees:\nSerás salvo tu y tu casa (Hch 16:31)\nVivirás eternamente (Jn 11:25-26)\nNunca más tendrás sed (Jn 4:14)\nEstarás con Cristo en los cielos (Ap 19:9)\nHay gozo en los cielos cuando un pecador se arrepiente (Luc 15:10)\nEscrito está y Dios es fiel (Dt 7:9)\n\nDesde ya tienes salvación y vida nueva en Jesucristo.",
                  textAlign: TextAlign.justify,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurface),
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
                  activeColor: colorScheme.primary,
                ),
                Expanded(
                    child: Text('Ya la hice 🙏\nNo mostrar nuevamente',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurface))),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  devocionalProvider
                      .setInvitationDialogVisibility(!doNotShowAgainChecked);
                  Navigator.of(dialogContext).pop();
                },
                child: Text("Continuar",
                    style: TextStyle(color: colorScheme.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareAsText(Devocional devocional) async {
    final text =
        "Devocional del día:\n\nVersículo: ${devocional.versiculo}\n\nReflexión: ${devocional.reflexion}\n\nPara Meditar:\n${devocional.paraMeditar.map((p) => '${p.cita}: ${p.texto}').join('\n')}\n\nOración: ${devocional.oracion}"; // Líneas de Versión, Idioma, y Fecha eliminadas
    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _shareAsImage(Devocional devocional) async {
    final image = await screenshotController.capture();
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File('${directory.path}/devocional.png').create();
      await imagePath.writeAsBytes(image);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(imagePath.path)],
          text: 'Devocional del día',
          subject: 'Devocional',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const DevocionalesDrawer(), //nuevo drawer
      appBar: AppBar(
        title: Text(
          'Mi espacio íntimo con Dios',
          style: TextStyle(
              color: Theme.of(context).appBarTheme.foregroundColor ??
                  colorScheme.onPrimary),
        ),
        centerTitle: true,
        //comentado para el dropdown de versiones
        /*actions: [
          Consumer<DevocionalProvider>(
            builder: (context, devocionalProvider, child) {
              return Row(
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: devocionalProvider.selectedVersion,
                      icon: Icon(
                        CupertinoIcons.book,
                        color: Theme.of(context).appBarTheme.foregroundColor ??
                            colorScheme.onPrimary,
                      ),
                      dropdownColor: colorScheme.surface,
                      selectedItemBuilder: (BuildContext context) {
                        return <String>[
                          'RVR1960'
                        ].map<Widget>((String itemValue) {
                          return const SizedBox(
                            width: 40.0,
                            child: Text(''),
                          );
                        }).toList();
                      },
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          devocionalProvider.setSelectedVersion(newValue);
                        }
                      },
                      items: const <String>[
                        'RVR1960'
                      ].map<DropdownMenuItem<String>>((String itemValue) {
                        return DropdownMenuItem<String>(
                          value: itemValue,
                          child: Text(
                            itemValue,
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
         ],*/
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
            return Center(
              child: Text(
                'No hay devocionales disponibles para el idioma/versión seleccionados.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurface),
              ),
            );
          }

          if (_currentDevocionalIndex >= devocionales.length ||
              _currentDevocionalIndex < 0) {
            _currentDevocionalIndex = 0;
          }

          final Devocional currentDevocional =
              devocionales[_currentDevocionalIndex];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  DateFormat('EEEE, d MMMM', 'es').format(DateTime.now()),
                  style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
              ),
              Expanded(
                child: Screenshot(
                  controller: screenshotController,
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.primary
                                  .withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: colorScheme.primary
                                      .withAlpha((0.3 * 255).round())),
                            ),
                            child: AutoSizeText(
                              currentDevocional.versiculo,
                              textAlign: TextAlign.center,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 12,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Reflexión:',
                            style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            currentDevocional.reflexion,
                            style: textTheme.bodyMedium?.copyWith(
                                fontSize: 16, color: colorScheme.onSurface),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Para Meditar:',
                            style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary),
                          ),
                          const SizedBox(height: 10),
                          ...currentDevocional.paraMeditar.map((item) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${item.cita}: ',
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: item.texto,
                                      style: textTheme.bodyMedium?.copyWith(
                                          fontSize: 16,
                                          color: colorScheme.onSurface),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 20),
                          Text(
                            'Oración:',
                            style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            currentDevocional.oracion,
                            style: textTheme.bodyMedium?.copyWith(
                                fontSize: 16, color: colorScheme.onSurface),
                          ),
                          const SizedBox(height: 20),
                          if (currentDevocional.version != null ||
                              currentDevocional.language != null ||
                              currentDevocional.tags != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Tex
