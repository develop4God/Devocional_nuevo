// lib/pages/devotional_discovery_page.dart

import 'dart:async';
import 'dart:convert';

import 'package:devocional_nuevo/widgets/devocionales_page_drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../extensions/string_extensions.dart';
import '../models/devocional_model.dart';
import '../providers/devotional_discovery_provider.dart';
import '../repositories/devotional_image_repository.dart';
import '../services/spiritual_stats_service.dart';
import 'devocional_modern_view.dart';
import 'devotional_discovery/widgets/devotional_card_premium.dart';
import 'devotional_discovery/widgets/favorites_horizontal_section.dart';
import 'favorites_page.dart';

/// Devotional Discovery Page
///
/// This page allows users to:
/// 1. Browse devotionals
/// 2. Select a verse to read first
/// 3. Then view the devotional content
class DevotionalDiscoveryPage extends StatefulWidget {
  const DevotionalDiscoveryPage({super.key});

  @override
  State<DevotionalDiscoveryPage> createState() =>
      _DevotionalDiscoveryPageState();
}

class _DevotionalDiscoveryPageState extends State<DevotionalDiscoveryPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  Timer? _debounceTimer;
  int _currentStreak = 0;
  String? _imageOfDay;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadImageOfDay();
    // Initialize devotionals on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DevotionalDiscoveryProvider>().initialize();
      _loadStreak();
    });
  }

  Future<void> _loadImageOfDay() async {
    final repo = DevotionalImageRepository();
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
      debugPrint('[DEBUG] [Discovery] Error obteniendo lista de imágenes: $e');
    }
    _imageOfDay = await repo.getImageForToday(imageUrls);
    setState(() {});
  }

  Future<void> _loadStreak() async {
    final statsService = SpiritualStatsService();
    final stats = await statsService.getStats();
    if (mounted) {
      setState(() {
        _currentStreak = stats.currentStreak;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchTerm = value);

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Create new timer for 500ms debounce
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      context.read<DevotionalDiscoveryProvider>().filterBySearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Consumer<DevotionalDiscoveryProvider>(
      builder: (context, provider, child) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.grey[50],
          extendBodyBehindAppBar: true,
          drawer: const DevocionalesDrawer(),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'discovery.title'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            actions: [
              // Search icon
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                tooltip: 'discovery.search_hint'.tr(),
                onPressed: () {
                  // Focus search field or scroll to it
                },
              ),
              // Favorites page
              IconButton(
                icon: Icon(
                  Icons.star_border,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritesPage(),
                    ),
                  );
                },
                tooltip: 'discovery.favorites'.tr(),
              ),
            ],
          ),
          body: Column(
            children: [
              // Hero header with gradient and streak badge
              _buildHeroHeader(),

              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'discovery.search_hint'.tr(),
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      suffixIcon: _searchTerm.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _debounceTimer?.cancel();
                                setState(() => _searchTerm = '');
                                provider.filterBySearch('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
              ),

              // Loading indicator
              if (provider.isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),

              // Error message
              if (provider.errorMessage != null && !provider.isLoading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.error),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.initialize(),
                          child: Text('discovery.retry'.tr()),
                        ),
                      ],
                    ),
                  ),
                ),

              // Devotional list with favorites section
              if (!provider.isLoading && provider.errorMessage == null)
                Expanded(
                  child: provider.filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.book_outlined,
                                size: 64,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'discovery.no_devotionals'.tr(),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: provider.filtered.length + 1,
                          // Add 1 for favorites section
                          padding: EdgeInsets.zero,
                          itemExtent: null,
                          // Variable height for favorites section
                          cacheExtent: 1500,
                          itemBuilder: (context, index) {
                            // First item is favorites section
                            if (index == 0) {
                              return FavoritesHorizontalSection(
                                favorites: provider.favorites,
                                onDevocionalTap: (devocional) {
                                  _showDevocionalDetail(
                                      context, devocional, provider);
                                },
                                isDark: isDark,
                              );
                            }

                            // Rest are devotional cards
                            final devocional = provider.filtered[index - 1];
                            return DevotionalCardPremium(
                              devocional: devocional,
                              isFavorite: provider.isFavorite(devocional.id),
                              onTap: () => _showDevocionalDetail(
                                  context, devocional, provider),
                              onFavoriteToggle: () =>
                                  provider.toggleFavorite(devocional),
                              isDark: isDark,
                            );
                          },
                        ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    debugPrint('[DEBUG] _buildHeroHeader: _imageOfDay=$_imageOfDay');

    return Stack(
      children: [
        if (_imageOfDay != null)
          Positioned.fill(
            child: Builder(
              builder: (context) {
                debugPrint('[DEBUG] Mostrando imagen en el hero: $_imageOfDay');
                return Image.network(
                  _imageOfDay!,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stackTrace) {
                    debugPrint('[DEBUG] Error cargando imagen en hero: $error');
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                          child: Icon(Icons.image_not_supported, size: 64)),
                    );
                  },
                );
              },
            ),
          ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.deepPurple[900]!, Colors.purple[800]!]
                  : [colorScheme.primary, colorScheme.secondary],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'discovery.today'.tr(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 2),
                          blurRadius: 6,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 2),
                          blurRadius: 6,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Streak badge in bottom-right
        if (_currentStreak > 0)
          Positioned(
            right: 16,
            bottom: 16,
            child: _buildStreakBadge(isDark),
          ),
      ],
    );
  }

  Widget _buildStreakBadge(bool isDark) {
    final textColor = isDark ? Colors.black87 : Colors.white;
    final backgroundColor = isDark ? Colors.white24 : Colors.black12;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: isDark ? Colors.amber : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '${'discovery.streak'.tr()} $_currentStreak',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showDevocionalDetail(BuildContext context, Devocional devocional,
      DevotionalDiscoveryProvider provider) {
    final imageRepository = DevotionalImageRepository();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => DevocionalModernView(
          devocional: devocional,
          imageRepository: imageRepository,
          imageUrlOfDay: _imageOfDay,
        ),
      ),
    );
  }
}
