import 'dart:convert';

import 'package:bible_reader_core/bible_reader_core.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/repositories/devotional_image_repository.dart';
import 'package:devocional_nuevo/utils/page_transitions.dart';
import 'package:devocional_nuevo/widgets/discovery_action_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../extensions/string_extensions.dart';
import '../models/devocional_model.dart';
import '../services/devocionales_tracking.dart';
import '../services/spiritual_stats_service.dart';
import 'bible_reader_page.dart';

class DevocionalModernView extends StatefulWidget {
  final List<Devocional> devocionales;
  final int initialIndex;
  final DevotionalImageRepository imageRepository;
  final String? imageUrlOfDay;

  const DevocionalModernView({
    super.key,
    required this.devocionales,
    required this.initialIndex,
    required this.imageRepository,
    this.imageUrlOfDay,
  });

  @override
  State<DevocionalModernView> createState() => _DevocionalModernViewState();
}

class _DevocionalModernViewState extends State<DevocionalModernView> {
  late int _currentDevocionalIndex;
  late Future<String> _imageUrlFuture;
  late FlutterTts _flutterTts;
  bool _isPlaying = false;
  bool _ttsInitialized = false;
  static const String _lastDevocionalIndexKey = 'lastDevocionalIndex';
  final ScrollController _scrollController = ScrollController();
  final DevocionalesTracking _tracking = DevocionalesTracking();

  Future<String> _getImageForToday() async {
    final repo = widget.imageRepository;
    debugPrint(
        '[DEBUG] [ModernView] _getImageForToday: obteniendo lista de imágenes');
    List<String> imageUrls = [];
    try {
      final response = await http.get(Uri.parse(repo.apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> files = json.decode(response.body);
        imageUrls = files
            .where((file) =>
                file['type'] == 'file' &&
                (file['name'].toLowerCase().endsWith('.jpg') ||
                    file['name'].toLowerCase().endsWith('.jpeg') ||
                    file['name'].toLowerCase().endsWith('.avif')))
            .map<String>((file) => file['download_url'] as String)
            .toList();
      }
    } catch (e) {
      debugPrint('[DEBUG] [ModernView] Error obteniendo lista de imágenes: $e');
    }
    return await repo.getImageForToday(imageUrls);
  }

  @override
  void initState() {
    super.initState();
    _currentDevocionalIndex = widget.initialIndex;
    _imageUrlFuture = widget.imageUrlOfDay != null
        ? Future.value(widget.imageUrlOfDay)
        : _getImageForToday();
    _flutterTts = FlutterTts();
    _tracking.initialize(context);
    _startTrackingCurrentDevocional();
    _recordDevotionalRead();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkShowInvitation();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_ttsInitialized) {
      _initializeTts();
      _ttsInitialized = true;
    }
  }

  void _startTrackingCurrentDevocional() {
    if (widget.devocionales.isNotEmpty &&
        _currentDevocionalIndex < widget.devocionales.length) {
      final currentDevocional = widget.devocionales[_currentDevocionalIndex];
      _tracking.clearAutoCompletedExcept(currentDevocional.id);
      _tracking.startDevocionalTracking(
        currentDevocional.id,
        _scrollController,
      );
      // Log de progreso cada vez que inicia tracking
      _logTrackingProgress();
    }
  }

  @override
  void dispose() {
    _stopSpeaking();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage(Localizations.localeOf(context).languageCode);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  Future<void> _speakDevotional() async {
    debugPrint(
        '[ModernView] TTS: Iniciando lectura para índice $_currentDevocionalIndex');
    if (_isPlaying) {
      await _flutterTts.pause();
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
      debugPrint('[ModernView] TTS: Pausado');
    } else {
      final devocional = widget.devocionales[_currentDevocionalIndex];
      String textToSpeak = '';
      // Versículo principal
      if (devocional.paraMeditar.isNotEmpty) {
        final verse = devocional.paraMeditar.first;
        textToSpeak += '${verse.texto}. ${verse.cita}. ';
      }
      // Título
      textToSpeak += '${devocional.versiculo}. ';
      // Reflexión
      if (devocional.reflexion.isNotEmpty) {
        textToSpeak += '${devocional.reflexion}. ';
      }
      // Oración
      if (devocional.oracion.isNotEmpty) {
        textToSpeak += devocional.oracion;
      }
      debugPrint('[ModernView] TTS: Texto a leer: $textToSpeak');
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
      await _flutterTts.speak(textToSpeak);
      debugPrint('[ModernView] TTS: Comenzó a hablar');
    }
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  Future<void> _goToNextDevocional() async {
    debugPrint('[ModernView] Swipe NEXT iniciado');
    final devocionalProvider =
        Provider.of<DevocionalProvider>(context, listen: false);
    if (_currentDevocionalIndex < widget.devocionales.length - 1) {
      await _stopSpeaking();
      setState(() {
        _currentDevocionalIndex++;
      });
      _scrollToTop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTrackingCurrentDevocional();
      });
      if (devocionalProvider.showInvitationDialog &&
          widget.devocionales[_currentDevocionalIndex].tags != null &&
          widget.devocionales[_currentDevocionalIndex].tags!
              .contains('salvation')) {
        if (mounted) {
          _showInvitation(context);
        }
      }
      await _saveCurrentDevocionalIndex();
      _recordDevotionalRead();
    }
  }

  Future<void> _goToPreviousDevocional() async {
    debugPrint('[ModernView] Swipe PREV iniciado');
    final devocionalProvider =
        Provider.of<DevocionalProvider>(context, listen: false);
    if (_currentDevocionalIndex > 0) {
      await _stopSpeaking();
      setState(() {
        _currentDevocionalIndex--;
      });
      _scrollToTop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTrackingCurrentDevocional();
      });
      if (devocionalProvider.showInvitationDialog &&
          widget.devocionales[_currentDevocionalIndex].tags != null &&
          widget.devocionales[_currentDevocionalIndex].tags!
              .contains('salvation')) {
        if (mounted) {
          _showInvitation(context);
        }
      }
      await _saveCurrentDevocionalIndex();
      _recordDevotionalRead();
    }
  }

  Future<void> _saveCurrentDevocionalIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastDevocionalIndexKey, _currentDevocionalIndex);
  }

  Future<void> _recordDevotionalRead() async {
    final spiritualStatsService = SpiritualStatsService();
    await spiritualStatsService.recordDailyAppVisit();
  }

  void _checkShowInvitation() {
    final currentDevocional = widget.devocionales[_currentDevocionalIndex];
    if (currentDevocional.tags != null &&
        currentDevocional.tags!.contains('salvation')) {
      setState(() {
        // _showInvitationDialog = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInvitation(context);
      });
    } else {
      setState(() {
        // _showInvitationDialog = false;
      });
    }
  }

  void _showInvitation(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    bool doNotShowAgainChecked = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          key: const Key('salvation_prayer_dialog'),
          backgroundColor: colorScheme.surface,
          title: Text(
            "devotionals.salvation_prayer_title".tr(),
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "devotionals.salvation_prayer_intro".tr(),
                  textAlign: TextAlign.justify,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  "devotionals.salvation_prayer".tr(),
                  textAlign: TextAlign.justify,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  "devotionals.salvation_promise".tr(),
                  textAlign: TextAlign.justify,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
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
                  child: Text(
                    'prayer.already_prayed'.tr(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                key: const Key('salvation_prayer_continue_button'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: Text(
                  "devotionals.continue".tr(),
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  void _logTrackingProgress() {
    final devocionalProvider =
        Provider.of<DevocionalProvider>(context, listen: false);
    final seconds = devocionalProvider.currentReadingSeconds;
    final scroll = devocionalProvider.currentScrollPercentage;
    debugPrint('⏱️ Segundos de lectura: $seconds');
    debugPrint(
        '📜 Porcentaje de scroll: ${(scroll * 100).toStringAsFixed(1)}%');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final devocionalActual = widget.devocionales[_currentDevocionalIndex];
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < -200) {
              // Swipe izquierda: siguiente
              _goToNextDevocional();
            } else if (details.primaryVelocity! > 200) {
              // Swipe derecha: anterior
              _goToPreviousDevocional();
            }
          }
        },
        child: FutureBuilder<String>(
          future: _imageUrlFuture,
          builder: (context, snapshot) {
            debugPrint(
                '[DEBUG] [ModernView] FutureBuilder: snapshot.connectionState=${snapshot.connectionState}');
            final imageUrl = snapshot.data ??
                'https://raw.githubusercontent.com/develop4God/Devocionales-assets/main/images/devocional_default.jpg';
            debugPrint(
                '[DEBUG] [ModernView] URL final para mostrar: $imageUrl');
            return Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 260,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, error, stackTrace) {
                                debugPrint(
                                    '[DEBUG] Error cargando imagen: $error');
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported,
                                        size: 64),
                                  ),
                                );
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.5),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          devocionalActual.versiculo,
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        centerTitle: true,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Chips de tags (máximo 2)
                            if (devocionalActual.tags != null &&
                                devocionalActual.tags!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  children: devocionalActual.tags!
                                      .take(2)
                                      .map((tag) => Container(
                                            margin:
                                                const EdgeInsets.only(right: 8),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              tag,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            Text(
                              'Reflexión',
                              style: textTheme.headlineSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildEnhancedBody(
                                devocionalActual.reflexion, colorScheme),
                            const SizedBox(height: 24),
                            if (devocionalActual.paraMeditar.isNotEmpty) ...[
                              Text(
                                'Para meditar',
                                style: textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...devocionalActual.paraMeditar
                                  .map((item) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: _buildPremiumVerse(
                                                item, colorScheme),
                                          ),
                                        ),
                                      )),
                              const SizedBox(height: 24),
                            ],
                            Text(
                              'Oración',
                              style: textTheme.headlineSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: _buildEnhancedBody(
                                    devocionalActual.oracion, colorScheme),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Center(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Volver'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: DiscoveryActionBar(
        devocional: devocionalActual,
        isComplete: false,
        onMarkComplete: () {},
        isPlaying: _isPlaying,
        onPlayPause: _speakDevotional,
        onNext: _goToNextDevocional,
        onPrevious: _goToPreviousDevocional,
      ),
    );
  }

  /// Builds premium verse with SelectableText.rich and Bible navigation
  Widget _buildPremiumVerse(ParaMeditar item, ColorScheme colorScheme) {
    return SelectableText.rich(
      TextSpan(
        children: [
          // Verse text with Playfair Display
          TextSpan(
            text: '${item.texto}\n\n',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              height: 1.3,
              color: colorScheme.onSurface,
            ),
          ),
          // Bible reference (tappable)
          TextSpan(
            text: item.cita,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _navigateToBible(item.cita),
          ),
        ],
      ),
    );
  }

  /// Navigates to Bible reader with parsed reference
  Future<void> _navigateToBible(String reference) async {
    final parsed = BibleReferenceParser.parse(reference);
    if (parsed != null) {
      try {
        // Load Bible versions
        final versions = await BibleVersionRegistry.getAllVersions();

        if (!mounted) return;

        // Navigate to BibleReaderPage
        Navigator.push(
          context,
          PageTransitions.fadeSlide(
            BibleReaderPage(
              versions: versions,
            ),
          ),
        );

        // TODO: In future, BibleReaderPage should accept initialBook/chapter/verse
        // For now, user will need to navigate manually once in the Bible reader
      } catch (e) {
        debugPrint('[DevotionalModernView] Error loading Bible versions: $e');
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar la Biblia: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Show error if reference couldn't be parsed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo interpretar la referencia: $reference'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Builds enhanced body text with Lora font and first paragraph emphasis
  Widget _buildEnhancedBody(String text, ColorScheme colorScheme) {
    // Split text into paragraphs
    final paragraphs = text.split('\n\n');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.grey.shade200 : Colors.grey.shade800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < paragraphs.length; i++) ...[
          if (paragraphs[i].trim().isNotEmpty)
            Text(
              paragraphs[i].trim(),
              style: GoogleFonts.lora(
                fontSize: i == 0 ? 20.0 : 18.5,
                // First paragraph larger
                height: 1.88,
                letterSpacing: 0.15,
                fontWeight: i == 0 ? FontWeight.w500 : FontWeight.w400,
                color: textColor,
              ),
            ),
          if (i < paragraphs.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}
