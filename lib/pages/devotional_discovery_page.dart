// lib/pages/devotional_discovery_page.dart

import 'dart:async';
import 'dart:convert';

import 'package:devocional_nuevo/pages/bible_reader_page.dart';
import 'package:devocional_nuevo/pages/prayers_page.dart';
import 'package:devocional_nuevo/widgets/devocionales_page_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../blocs/theme/theme_bloc.dart';
import '../blocs/theme/theme_state.dart';
import '../extensions/string_extensions.dart';
import '../models/devocional_model.dart';
import '../providers/devocional_provider.dart';
import '../repositories/devotional_image_repository.dart';
import '../services/spiritual_stats_service.dart';
import '../utils/page_transitions.dart';
import '../widgets/app_bar_constants.dart';
import '../widgets/devotional_card_skeleton.dart';
import '../widgets/discovery_bottom_nav_bar.dart';
import 'devotional_discovery/widgets/devotional_card_premium.dart';
import 'devotional_discovery/widgets/favorites_horizontal_section.dart';
import 'devotional_modern_view.dart';

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
  // UI state
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  int _currentStreak = 0;
  String? _imageOfDay;

  // Local search state (view-specific, not provider)
  String _searchTerm = '';
  List<Devocional> _searchResults = [];
  String? _currentLanguage;
  String? _currentBibleVersion;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadImageOfDay();
    // Initialize devotionals on first load using DevocionalProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DevocionalProvider>();
      // Store current language and bible version for change detection
      _currentLanguage = provider.selectedLanguage;
      _currentBibleVersion = provider.selectedVersion;
      // Initialize search results with all devotionals
      _searchResults = provider.devocionales;
      setState(() {});
      _loadStreak();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for language or bible version changes
    final provider = context.watch<DevocionalProvider>();

    // Check if language changed
    if (_currentLanguage != null &&
        _currentLanguage != provider.selectedLanguage) {
      debugPrint(
          '[DEBUG] [Discovery] Language changed from $_currentLanguage to ${provider.selectedLanguage}, reloading...');
      _currentLanguage = provider.selectedLanguage;
      // Reload devotionals
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchResults = provider.devocionales;
          setState(() {});
        }
      });
    }

    // Check if bible version changed
    if (_currentBibleVersion != null &&
        _currentBibleVersion != provider.selectedVersion) {
      debugPrint(
          '[DEBUG] [Discovery] Bible version changed from $_currentBibleVersion to ${provider.selectedVersion}, reloading...');
      _currentBibleVersion = provider.selectedVersion;
      // Reload devotionals
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchResults = provider.devocionales;
          setState(() {});
        }
      });
    }
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
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Perform local search on devotionals (view-specific logic)
  void _performLocalSearch(String term) {
    final provider = context.read<DevocionalProvider>();
    _searchTerm = term.toLowerCase();

    if (_searchTerm.isEmpty) {
      _searchResults = provider.devocionales;
    } else {
      _searchResults = provider.devocionales.where((d) {
        final paraMeditarText = d.paraMeditar.join(' ').toLowerCase();
        return d.versiculo.toLowerCase().contains(_searchTerm) ||
            d.reflexion.toLowerCase().contains(_searchTerm) ||
            paraMeditarText.contains(_searchTerm);
      }).toList();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Requerido por AutomaticKeepAliveClientMixin
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final themeState = context.watch<ThemeBloc>().state as ThemeLoaded;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: themeState.systemUiOverlayStyle,
      child: Consumer<DevocionalProvider>(
        builder: (context, provider, child) {
          final bool isDark = Theme.of(context).brightness == Brightness.dark;
          return Scaffold(
            drawer: const DevocionalesDrawer(),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Stack(
                children: [
                  CustomAppBar(
                    titleText: 'devotionals.my_intimate_space_with_god'.tr(),
                  ),
                ],
              ),
            ),
            body: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildHeroHeader(),
                if (provider.isLoading) ...[
                  for (int i = 0; i < 3; i++) DevotionalCardSkeleton()
                ],
                if (provider.errorMessage != null && !provider.isLoading)
                  Center(
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
                          onPressed: () {
                            provider.initializeData();
                            _performLocalSearch('');
                          },
                          child: Text('discovery.retry'.tr()),
                        ),
                      ],
                    ),
                  ),
                if (!provider.isLoading && provider.errorMessage == null)
                  _searchResults.isEmpty
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
                      : FavoritesHorizontalSection(
                          favorites: provider.favoriteDevocionales,
                          onDevocionalTap: (devocional) {
                            _showDevocionalDetail(
                                context, devocional, provider);
                          },
                          isDark: isDark,
                        ),
                if (!provider.isLoading &&
                    provider.errorMessage == null &&
                    _searchResults.isNotEmpty)
                  ..._searchResults.map((devocional) => Hero(
                        tag: 'devotional_${devocional.id}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: DevotionalCardPremium(
                            devocional: devocional,
                            isFavorite: provider.isFavorite(devocional),
                            onTap: () => _showDevocionalDetail(
                                context, devocional, provider),
                            onFavoriteToggle: () =>
                                provider.toggleFavorite(devocional, context),
                            isDark: isDark,
                          ),
                        ),
                      ))
              ],
            ),
            bottomNavigationBar: Builder(
              builder: (context) {
                final Color appBarForegroundColor =
                    Theme.of(context).appBarTheme.foregroundColor ??
                        Theme.of(context).colorScheme.onPrimary;
                final Color? appBarBackgroundColor =
                    Theme.of(context).appBarTheme.backgroundColor;
                return DiscoveryBottomNavBar(
                  onPrayers: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(
                      context,
                      PageTransitions.fadeSlide(const PrayersPage()),
                    );
                  },
                  onBible: () {
                    Navigator.push(
                      context,
                      PageTransitions.fadeSlide(BibleReaderPage(versions: [])),
                    );
                  },
                  onProgress: () {
                    // Navegación a la página de estadísticas si existe
                  },
                  onSettings: () {
                    // Navegación a la página de configuración si existe
                  },
                  ttsPlayerWidget: const SizedBox(),
                  appBarForegroundColor: appBarForegroundColor,
                  appBarBackgroundColor: appBarBackgroundColor,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      height: 280, // Aumenta el alto del hero
      child: FutureBuilder<String>(
        future: _getImageOfDayFuture(),
        builder: (context, snapshot) {
          final imageUrl = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            debugPrint('[DEBUG] [Hero] Esperando imagen del día...');
            return Container(
              width: double.infinity,
              height: 340,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Colors.deepPurple[900]!, Colors.purple[800]!]
                      : [colorScheme.primary, colorScheme.secondary],
                ),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          if (imageUrl != null && imageUrl.isNotEmpty) {
            debugPrint('[DEBUG] [Hero] Imagen del día lista: $imageUrl');
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, error, stackTrace) {
                      debugPrint(
                          '[DEBUG] [Hero] Error cargando imagen: $error');
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [Colors.deepPurple[900]!, Colors.purple[800]!]
                                : [colorScheme.primary, colorScheme.secondary],
                          ),
                        ),
                        child: const Center(
                            child: Icon(Icons.image_not_supported, size: 64)),
                      );
                    },
                  ),
                ),
                _buildHeroContent(colorScheme, isDark),
                if (_currentStreak > 0)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    // Ajusta la posición vertical para que esté más arriba
                    child: _buildStreakBadge(isDark),
                  ),
              ],
            );
          }
          debugPrint('[DEBUG] [Hero] No hay imagen, fallback al gradiente');
          return Stack(
            children: [
              Container(
                width: double.infinity,
                height: 340,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [Colors.deepPurple[900]!, Colors.purple[800]!]
                        : [colorScheme.primary, colorScheme.secondary],
                  ),
                ),
              ),
              _buildHeroContent(colorScheme, isDark),
              if (_currentStreak > 0)
                Positioned(
                  right: 16,
                  top: 32,
                  // Ajusta la posición vertical para que esté más arriba
                  child: _buildStreakBadge(isDark),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<String> _getImageOfDayFuture() async {
    if (_imageOfDay != null && _imageOfDay!.isNotEmpty) {
      return _imageOfDay!;
    }
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
      debugPrint('[DEBUG] [Hero] Error obteniendo lista de imágenes: $e');
    }
    final url = await repo.getImageForToday(imageUrls);
    _imageOfDay = url;
    return url;
  }

  DateFormat _getLocalizedDateFormat(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    switch (locale) {
      case 'es':
        return DateFormat("EEEE, d 'de' MMMM", 'es');
      case 'en':
        return DateFormat('EEEE, MMMM d', 'en');
      case 'fr':
        return DateFormat('EEEE d MMMM', 'fr');
      case 'pt':
        return DateFormat("EEEE, d 'de' MMMM", 'pt');
      case 'ja':
        return DateFormat('y年M月d日 EEEE', 'ja');
      default:
        return DateFormat('EEEE, MMMM d', 'en');
    }
  }

  Widget _buildHeroContent(ColorScheme colorScheme, bool isDark) {
    final dateFormat = _getLocalizedDateFormat(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.primary.withValues(alpha: 0.6),
                  colorScheme.secondary.withValues(alpha: 0.6)
                ]
              : [
                  colorScheme.primary.withValues(alpha: 0.6),
                  colorScheme.secondary.withValues(alpha: 0.6)
                ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                dateFormat.format(DateTime.now()),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 6), // Subir la llama
            child: SizedBox(
              width: 28,
              height: 28,
              child: Lottie.asset(
                'assets/lottie/fire.json',
                repeat: true,
                animate: true,
              ),
            ),
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
      DevocionalProvider provider) {
    final imageRepository = DevotionalImageRepository();
    HapticFeedback.mediumImpact();
    final index = provider.devocionales.indexOf(devocional);
    if (index < 0 && provider.devocionales.isNotEmpty) {
      // Devocional no encontrado, navega al primero válido
      Navigator.push(
        context,
        PageTransitions.fadeSlide(
          Hero(
            tag: 'devotional_${provider.devocionales.first.id}',
            child: DevocionalModernView(
              devocionales: provider.devocionales,
              initialIndex: 0,
              imageRepository: imageRepository,
              imageUrlOfDay: _imageOfDay,
            ),
          ),
        ),
      );
    } else if (index >= 0) {
      Navigator.push(
        context,
        PageTransitions.fadeSlide(
          Hero(
            tag: 'devotional_${devocional.id}',
            child: DevocionalModernView(
              devocionales: provider.devocionales,
              initialIndex: index,
              imageRepository: imageRepository,
              imageUrlOfDay: _imageOfDay,
            ),
          ),
        ),
      );
    }
  }
}
