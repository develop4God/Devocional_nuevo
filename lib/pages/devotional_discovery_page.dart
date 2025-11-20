// lib/pages/devotional_discovery_page.dart

import 'package:bible_reader_core/bible_reader_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../extensions/string_extensions.dart';
import '../models/devocional_model.dart';
import '../providers/devotional_discovery_provider.dart';
import 'bible_reader_page.dart';
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

class _DevotionalDiscoveryPageState extends State<DevotionalDiscoveryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    // Initialize devotionals on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DevotionalDiscoveryProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DevotionalDiscoveryProvider>(
      builder: (context, provider, child) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.grey[50],
          extendBodyBehindAppBar: true,
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
              // Language selector
              IconButton(
                icon: Icon(
                  Icons.language,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                tooltip: 'discovery.select_language'.tr(),
                onPressed: () => _showLanguageSelector(context, provider),
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
              // Hero header with gradient
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
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMMM d').format(DateTime.now()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

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
                    onChanged: (value) {
                      setState(() => _searchTerm = value);
                      provider.filterBySearch(value);
                    },
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

              // Devotional list
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
                          itemCount: provider.filtered.length,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemBuilder: (context, index) {
                            final devocional = provider.filtered[index];
                            return _buildDevocionalCard(
                              context,
                              devocional,
                              provider,
                              colorScheme,
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

  Widget _buildDevocionalCard(
    BuildContext context,
    Devocional devocional,
    DevotionalDiscoveryProvider provider,
    ColorScheme colorScheme,
  ) {
    final isFavorite = provider.isFavorite(devocional.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayDate = _getDisplayDate(devocional);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDevocionalDetail(context, devocional, provider),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image section with gradient overlay
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _getGradientColors(isDark, devocional.tags),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative pattern
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: CustomPaint(painter: _DotPatternPainter()),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date and favorite
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    displayDate,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: isFavorite
                                          ? Colors.amber
                                          : Colors.white,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      provider.toggleFavorite(devocional);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Verse reference (hero element)
                            Text(
                              _extractVerseReference(devocional.versiculo),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Verse text preview
                      Text(
                        _extractVerseText(devocional.versiculo),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tags
                      if (devocional.tags != null &&
                          devocional.tags!.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: devocional.tags!.take(2).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[800]
                                    : colorScheme.primaryContainer
                                        .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : colorScheme.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 16),

                      // Read button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              _navigateToVerse(context, devocional),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? Colors.purple[700]
                                : colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_stories_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'discovery.read_verse_first'.tr(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDisplayDate(Devocional devocional) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final devDate = DateTime(
      devocional.date.year,
      devocional.date.month,
      devocional.date.day,
    );

    if (devDate == today) {
      return 'discovery.today'.tr();
    }

    DateTime displayDate = devDate;
    while (displayDate.isBefore(today)) {
      displayDate = DateTime(
        displayDate.year + 1,
        displayDate.month,
        displayDate.day,
      );
    }

    final tomorrow = today.add(const Duration(days: 1));
    if (displayDate == tomorrow) {
      return 'discovery.tomorrow'.tr();
    }

    final daysUntil = displayDate.difference(today).inDays;
    if (daysUntil <= 7 && daysUntil > 1) {
      return DateFormat('EEEE').format(displayDate);
    }

    return DateFormat('MMM dd').format(displayDate);
  }

  String _extractVerseReference(String versiculo) {
    final parts = versiculo.split(RegExp(r'\s+[A-Z]{2,}[0-9]*:'));
    if (parts.isNotEmpty) {
      return parts[0].trim();
    }

    final quoteIndex = versiculo.indexOf('"');
    if (quoteIndex > 0) {
      return versiculo.substring(0, quoteIndex).trim();
    }

    return versiculo;
  }

  String _extractVerseText(String versiculo) {
    final quoteStart = versiculo.indexOf('"');
    final quoteEnd = versiculo.lastIndexOf('"');
    if (quoteStart != -1 && quoteEnd != -1 && quoteEnd > quoteStart) {
      return versiculo.substring(quoteStart + 1, quoteEnd);
    }
    return versiculo;
  }

  List<Color> _getGradientColors(bool isDark, List<String>? tags) {
    if (tags != null && tags.isNotEmpty) {
      final tag = tags.first.toLowerCase();
      if (tag.contains('love') || tag.contains('amor')) {
        return isDark
            ? [Colors.pink[900]!, Colors.red[800]!]
            : [Colors.pink[400]!, Colors.red[400]!];
      } else if (tag.contains('peace') || tag.contains('paz')) {
        return isDark
            ? [Colors.blue[900]!, Colors.indigo[800]!]
            : [Colors.blue[400]!, Colors.indigo[400]!];
      } else if (tag.contains('faith') || tag.contains('fe')) {
        return isDark
            ? [Colors.purple[900]!, Colors.deepPurple[800]!]
            : [Colors.purple[400]!, Colors.deepPurple[400]!];
      } else if (tag.contains('hope') || tag.contains('esperanza')) {
        return isDark
            ? [Colors.teal[900]!, Colors.cyan[800]!]
            : [Colors.teal[400]!, Colors.cyan[400]!];
      }
    }

    return isDark
        ? [Colors.deepPurple[900]!, Colors.purple[800]!]
        : [Colors.deepPurple[400]!, Colors.purple[400]!];
  }

  void _showLanguageSelector(
    BuildContext context,
    DevotionalDiscoveryProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'discovery.select_language'.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildLanguageOption(
                    context, provider, 'es', 'Español', '🇪🇸'),
                _buildLanguageOption(
                    context, provider, 'en', 'English', '🇺🇸'),
                _buildLanguageOption(
                    context, provider, 'pt', 'Português', '🇧🇷'),
                _buildLanguageOption(
                    context, provider, 'fr', 'Français', '🇫🇷'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    DevotionalDiscoveryProvider provider,
    String code,
    String name,
    String flag,
  ) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      onTap: () {
        Navigator.pop(context);
        provider.changeLanguage(code);
      },
    );
  }

  void _navigateToVerse(BuildContext context, Devocional devocional) async {
    final verseRef = _extractVerseReference(devocional.versiculo);
    final parsed = BibleReferenceParser.parse(verseRef);

    if (parsed != null) {
      // Get all available versions from the registry
      final versions = await BibleVersionRegistry.getAllVersions();

      if (!context.mounted) return;

      // Navigate to Bible reader
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BibleReaderPage(versions: versions),
        ),
      );

      // Handle the result if needed
      debugPrint('Bible reader returned: $result');
    } else {
      // Get all available versions from the registry
      final versions = await BibleVersionRegistry.getAllVersions();

      if (!context.mounted) return;

      // If parsing fails, just open Bible reader
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BibleReaderPage(versions: versions),
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${'discovery.opening_bible'.tr()}: ${devocional.versiculo}',
            ),
          ),
        );
      }
    }
  }

  void _showDevocionalDetail(
    BuildContext context,
    Devocional devocional,
    DevotionalDiscoveryProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _buildDevocionalDetailContent(
            context,
            devocional,
            provider,
            scrollController,
          );
        },
      ),
    );
  }

  Widget _buildDevocionalDetailContent(
    BuildContext context,
    Devocional devocional,
    DevotionalDiscoveryProvider provider,
    ScrollController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFav = provider.isFavorite(devocional.id);

    return Container(
      padding: const EdgeInsets.all(24),
      child: ListView(
        controller: controller,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  devocional.versiculo,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isFav ? Icons.star : Icons.star_border,
                  color: isFav ? Colors.amber : null,
                ),
                onPressed: () {
                  provider.toggleFavorite(devocional);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Read verse button
          ElevatedButton.icon(
            icon: const Icon(Icons.menu_book),
            label: Text('discovery.read_verse_first'.tr()),
            onPressed: () {
              Navigator.pop(context);
              _navigateToVerse(context, devocional);
            },
          ),
          const SizedBox(height: 24),

          // Reflection
          Text(
            'discovery.reflection'.tr(),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            devocional.reflexion,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // Meditation points
          if (devocional.paraMeditar.isNotEmpty) ...[
            Text(
              'discovery.for_meditation'.tr(),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...devocional.paraMeditar.map(
              (punto) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      punto.cita,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.secondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      punto.texto,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Prayer
          Text(
            'discovery.prayer'.tr(),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              devocional.oracion,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for decorative pattern
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotSize = 2.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
