import 'dart:convert';

import 'package:devocional_nuevo/repositories/devotional_image_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/devocional_model.dart';

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
                      Text(
                        'Reflexión',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.devocional.reflexion,
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (widget.devocional.paraMeditar.isNotEmpty) ...[
                        Text(
                          'Para meditar',
                          style: textTheme.headlineSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...widget.devocional.paraMeditar.map((item) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    '${item.cita}: ${item.texto}',
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize: 16,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
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
                          child: Text(
                            widget.devocional.oracion,
                            style: textTheme.bodyLarge?.copyWith(
                              fontSize: 18,
                              color: colorScheme.onSurface,
                            ),
                          ),
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
    );
  }
}
