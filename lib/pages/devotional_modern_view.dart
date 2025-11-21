import 'dart:convert';

import 'package:devocional_nuevo/repositories/devotional_image_repository.dart';
import 'package:devocional_nuevo/widgets/discovery_action_bar.dart';
import 'package:devocional_nuevo/utils/page_transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:bible_reader_core/bible_reader_core.dart';

import '../models/devocional_model.dart';
import 'bible_reader_page.dart';

class DevocionalModernView extends StatefulWidget {
  final Devocional devocional;
  final DevotionalImageRepository imageRepository;
  final String? imageUrlOfDay;

  const DevocionalModernView({
    super.key,
    required this.devocional,
    required this.imageRepository,
    this.imageUrlOfDay,
  });

  @override
  State<DevocionalModernView> createState() => _DevocionalModernViewState();
}

class _DevocionalModernViewState extends State<DevocionalModernView> {
  late Future<String> _imageUrlFuture;
  bool _isComplete = false;
  late FlutterTts _flutterTts;
  bool _isPlaying = false;

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
    debugPrint(
        '[DEBUG] [ModernView] initState: solicitando imagen fija para el día');
    if (widget.imageUrlOfDay != null) {
      _imageUrlFuture = Future.value(widget.imageUrlOfDay);
    } else {
      _imageUrlFuture = _getImageForToday();
    }

    // Initialize TTS
    _flutterTts = FlutterTts();
    _initializeTts();
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
    if (_isPlaying) {
      await _flutterTts.pause();
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    } else {
      // Build text to speak: verse + title + body
      String textToSpeak = '';

      // Add verse if available
      if (widget.devocional.paraMeditar.isNotEmpty) {
        final verse = widget.devocional.paraMeditar.first;
        textToSpeak += '${verse.texto}. ${verse.cita}. ';
      }

      // Add title
      textToSpeak += '${widget.devocional.versiculo}. ';

      // Add reflection
      if (widget.devocional.reflexion.isNotEmpty) {
        textToSpeak += '${widget.devocional.reflexion}. ';
      }

      // Add prayer
      if (widget.devocional.oracion.isNotEmpty) {
        textToSpeak += widget.devocional.oracion;
      }

      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }

      await _flutterTts.speak(textToSpeak);
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FutureBuilder<String>(
        future: _imageUrlFuture,
        builder: (context, snapshot) {
          debugPrint(
              '[DEBUG] [ModernView] FutureBuilder: snapshot.connectionState=${snapshot.connectionState}');
          final imageUrl = snapshot.data ??
              'https://raw.githubusercontent.com/develop4God/Devocionales-assets/main/images/devocional_default.jpg';
          debugPrint('[DEBUG] [ModernView] URL final para mostrar: $imageUrl');
          return CustomScrollView(
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
                          debugPrint('[DEBUG] Error cargando imagen: $error');
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 64),
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
                    widget.devocional.versiculo,
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
                      if (widget.devocional.tags != null &&
                          widget.devocional.tags!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: widget.devocional.tags!
                                .take(2)
                                .map((tag) => Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius: BorderRadius.circular(16),
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
                          widget.devocional.reflexion, colorScheme),
                      const SizedBox(height: 24),
                      if (widget.devocional.paraMeditar.isNotEmpty) ...[
                        Text(
                          'Para meditar',
                          style: textTheme.headlineSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...widget.devocional.paraMeditar.map((item) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: _buildPremiumVerse(item, colorScheme),
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
                              widget.devocional.oracion, colorScheme),
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
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: DiscoveryActionBar(
        devocional: widget.devocional,
        isComplete: _isComplete,
        onMarkComplete: () {
          setState(() {
            _isComplete = !_isComplete;
          });
        },
        isPlaying: _isPlaying,
        onPlayPause: _speakDevotional,
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
                fontSize: i == 0 ? 20.0 : 18.5, // First paragraph larger
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
