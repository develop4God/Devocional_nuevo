import 'dart:developer' as developer;

import 'package:bible_reader_core/bible_reader_core.dart';
import 'package:devocional_nuevo/extensions/string_extensions.dart';
import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/pages/bible_reader_page.dart';
import 'package:devocional_nuevo/pages/prayers_page.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/services/devocionales_tracking.dart';
import 'package:devocional_nuevo/services/spiritual_stats_service.dart';
import 'package:devocional_nuevo/services/tts/bible_text_formatter.dart';
import 'package:devocional_nuevo/widgets/add_prayer_modal.dart';
import 'package:devocional_nuevo/widgets/add_thanksgiving_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/audio_controller.dart';
import '../controllers/tts_audio_controller.dart';

/// Business logic for DevocionalesPage
/// Handles navigation, data loading, tracking, and user actions
class DevocionalesPageLogic {
  // Dependencies
  final BuildContext context;
  final DevocionalProvider provider;
  final DevocionalesTracking tracking;
  final ScrollController scrollController;
  final TtsAudioController ttsController;
  final FlutterTts flutterTts;
  final AudioController? audioController;
  final String? initialDevocionalId;

  // State
  int _currentDevocionalIndex = 0;
  bool _isTtsModalShowing = false;
  static const String _lastDevocionalIndexKey = 'lastDevocionalIndex';

  DevocionalesPageLogic({
    required this.context,
    required this.provider,
    required this.tracking,
    required this.scrollController,
    required this.ttsController,
    required this.flutterTts,
    required this.audioController,
    this.initialDevocionalId,
  });

  // Getters
  int get currentIndex => _currentDevocionalIndex;
  bool get isTtsModalShowing => _isTtsModalShowing;

  // Setter for current index (to be called from page when state changes)
  void setCurrentIndex(int index) {
    _currentDevocionalIndex = index;
  }

  void setTtsModalShowing(bool showing) {
    _isTtsModalShowing = showing;
  }

  /// Load initial data and set up the first devotional
  Future<void> loadInitialData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final devocionalProvider = Provider.of<DevocionalProvider>(
        context,
        listen: false,
      );

      if (!devocionalProvider.isLoading &&
          devocionalProvider.devocionales.isEmpty) {
        await devocionalProvider.initializeData();
      }

      if (devocionalProvider.devocionales.isNotEmpty) {
        final spiritualStatsService = SpiritualStatsService();
        await spiritualStatsService.recordDailyAppVisit();

        // Get read devotional IDs to filter already completed ones
        final stats = await spiritualStatsService.getStats();
        final readDevocionalIds = stats.readDevocionalIds;

        _currentDevocionalIndex = _findFirstUnreadDevocionalIndex(
          devocionalProvider.devocionales,
          readDevocionalIds,
        );
        developer.log(
          'Devocional cargado al inicio (primer no leído): $_currentDevocionalIndex',
        );

        startTrackingCurrentDevocional();
      } else {
        _currentDevocionalIndex = 0;
        developer.log('No hay devocionales disponibles para cargar el índice.');
      }

      if (initialDevocionalId != null &&
          devocionalProvider.devocionales.isNotEmpty) {
        final index = devocionalProvider.devocionales.indexWhere(
          (d) => d.id == initialDevocionalId,
        );
        if (index != -1) {
          _currentDevocionalIndex = index;
          startTrackingCurrentDevocional();
        }
      }
    });
  }

  /// Find the first unread devotional index starting from the beginning
  int _findFirstUnreadDevocionalIndex(
    List<Devocional> devocionales,
    List<String> readDevocionalIds,
  ) {
    if (devocionales.isEmpty) return 0;

    // Start from index 0 and find the first unread devotional
    for (int i = 0; i < devocionales.length; i++) {
      if (!readDevocionalIds.contains(devocionales[i].id)) {
        developer.log(
          'Primer devocional no leído encontrado en índice: $i (ID: ${devocionales[i].id})',
        );
        return i;
      }
    }

    // If all devotionals are read, start from the beginning
    developer.log(
      'Todos los devocionales han sido leídos, iniciando desde el principio',
    );
    return 0;
  }

  /// Start tracking the current devotional
  void startTrackingCurrentDevocional() {
    final devocionalProvider = Provider.of<DevocionalProvider>(
      context,
      listen: false,
    );
    if (devocionalProvider.devocionales.isNotEmpty &&
        _currentDevocionalIndex < devocionalProvider.devocionales.length) {
      final currentDevocional =
          devocionalProvider.devocionales[_currentDevocionalIndex];
      tracking.clearAutoCompletedExcept(currentDevocional.id);
      tracking.startDevocionalTracking(
        currentDevocional.id,
        scrollController,
      );
    }
  }

  /// Navigate to the next devotional
  Future<void> goToNextDevocional() async {
    final devocionalProvider = Provider.of<DevocionalProvider>(
      context,
      listen: false,
    );

    final List<Devocional> devocionales = devocionalProvider.devocionales;

    if (_currentDevocionalIndex < devocionales.length - 1) {
      if (audioController != null && audioController!.isActive) {
        debugPrint(
          'DevocionalesPage: Stopping AudioController before navigation',
        );
        await audioController!.stop();
        await Future.delayed(const Duration(milliseconds: 100));
      } else {
        await stopSpeaking();
      }

      _currentDevocionalIndex++;

      scrollToTop();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        startTrackingCurrentDevocional();
      });

      HapticFeedback.mediumImpact();

      if (devocionalProvider.showInvitationDialog) {
        showInvitation();
      }

      await saveCurrentDevocionalIndex();
    }
  }

  /// Navigate to the previous devotional
  Future<void> goToPreviousDevocional() async {
    if (_currentDevocionalIndex > 0) {
      if (audioController != null && audioController!.isActive) {
        debugPrint(
          'DevocionalesPage: Stopping AudioController before navigation',
        );
        await audioController!.stop();
        await Future.delayed(const Duration(milliseconds: 100));
      } else {
        await stopSpeaking();
      }

      _currentDevocionalIndex--;

      scrollToTop();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        startTrackingCurrentDevocional();
      });

      HapticFeedback.mediumImpact();
    }
  }

  /// Scroll to the top of the page
  void scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  /// Save the current devotional index to persistent storage
  Future<void> saveCurrentDevocionalIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastDevocionalIndexKey, _currentDevocionalIndex);
    developer.log('Índice de devocional guardado: $_currentDevocionalIndex');
  }

  /// Stop TTS speaking
  Future<void> stopSpeaking() async {
    await flutterTts.stop();
  }

  /// Show salvation invitation dialog
  void showInvitation() {
    final devocionalProvider = Provider.of<DevocionalProvider>(
      context,
      listen: false,
    );

    bool doNotShowAgainChecked = !devocionalProvider.showInvitationDialog;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

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
                  devocionalProvider.setInvitationDialogVisibility(
                    !doNotShowAgainChecked,
                  );
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

  /// Get the current devotional from the list
  Devocional? getCurrentDevocional(List<Devocional> devocionales) {
    if (devocionales.isNotEmpty &&
        _currentDevocionalIndex >= 0 &&
        _currentDevocionalIndex < devocionales.length) {
      return devocionales[_currentDevocionalIndex];
    }
    return null;
  }

  /// Get localized date format for the current locale
  DateFormat getLocalizedDateFormat() {
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

  /// Share devotional as text
  Future<void> shareAsText(Devocional devocional) async {
    final meditationsText =
        devocional.paraMeditar.map((p) => '${p.cita}: ${p.texto}').join('\n');

    final devotionalText = "devotionals.share_text_format".tr({
      'verse': devocional.versiculo,
      'reflection': devocional.reflexion,
      'meditations': meditationsText,
      'prayer': devocional.oracion,
    });

    await SharePlus.instance.share(ShareParams(text: devotionalText));
  }

  /// Navigate to prayers page
  void goToPrayers() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PrayersPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  /// Navigate to bible page
  Future<void> goToBible() async {
    final devocionalProvider = Provider.of<DevocionalProvider>(
      context,
      listen: false,
    );
    final appLanguage = devocionalProvider.selectedLanguage;

    debugPrint('🟦 [Bible] Using app language instead of device: $appLanguage');

    List<BibleVersion> versions =
        await BibleVersionRegistry.getVersionsForLanguage(appLanguage);

    debugPrint(
      '🟩 [Bible] Versions for app language ($appLanguage): ${versions.map((v) => '${v.name} (${v.languageCode}) - downloaded: ${v.isDownloaded}').join(', ')}',
    );

    if (versions.isEmpty) {
      versions = await BibleVersionRegistry.getVersionsForLanguage('es');
    }

    if (versions.isEmpty) {
      versions = await BibleVersionRegistry.getAllVersions();
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BibleReaderPage(versions: versions),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  /// Show modal to choose between adding prayer or thanksgiving
  void showAddPrayerOrThanksgivingChoice() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'devotionals.choose_option'.tr(),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        showAddPrayerModal();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text('🙏', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(
                              'prayer.prayer'.tr(),
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        showAddThanksgivingModal();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text('☺️', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(
                              'thanksgiving.thanksgiving'.tr(),
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// Show modal to add a prayer
  void showAddPrayerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddPrayerModal(),
    );
  }

  /// Show modal to add a thanksgiving
  void showAddThanksgivingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddThanksgivingModal(),
    );
  }

  /// Expand bible version abbreviation to full name
  String expandBibleVersion(String version, String language) {
    final expansions = BibleTextFormatter.getBibleVersionExpansions(language);
    return expansions[version] ?? version;
  }

  /// Build TTS text for a devotional
  String buildTtsTextForDevocional(Devocional devocional, String language) {
    final verseLabel = 'devotionals.verse'.tr().replaceAll(':', '');
    final reflectionLabel = 'devotionals.reflection'.tr().replaceAll(':', '');
    final meditateLabel = 'devotionals.to_meditate'.tr().replaceAll(':', '');
    final prayerLabel = 'devotionals.prayer'.tr().replaceAll(':', '');

    final StringBuffer ttsBuffer = StringBuffer();
    ttsBuffer.write('$verseLabel: ');
    ttsBuffer.write(
      BibleTextFormatter.normalizeTtsText(
        devocional.versiculo,
        language,
        devocional.version,
      ),
    );
    ttsBuffer.write('\n$reflectionLabel: ');
    ttsBuffer.write(
      BibleTextFormatter.normalizeTtsText(
        devocional.reflexion,
        language,
        devocional.version,
      ),
    );
    if (devocional.paraMeditar.isNotEmpty) {
      ttsBuffer.write('\n$meditateLabel: ');
      ttsBuffer.write(
        devocional.paraMeditar.map((m) {
          return '${BibleTextFormatter.normalizeTtsText(m.cita, language, devocional.version)}: ${m.texto}';
        }).join('\n'),
      );
    }
    ttsBuffer.write('\n$prayerLabel: ');
    ttsBuffer.write(
      BibleTextFormatter.normalizeTtsText(
        devocional.oracion,
        language,
        devocional.version,
      ),
    );
    return ttsBuffer.toString();
  }

  /// Handle TTS state changes
  void handleTtsStateChange(VoidCallback showModalCallback) {
    try {
      final s = ttsController.state.value;

      // Show modal when playback starts
      if (s == TtsPlayerState.playing && !_isTtsModalShowing) {
        // Check if modal is not already showing to avoid duplicates
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isTtsModalShowing) return;
          showModalCallback();
        });
      }

      if (s == TtsPlayerState.completed || s == TtsPlayerState.idle) {
        // Mark modal as not showing when audio stops
        _isTtsModalShowing = false;
      }
    } catch (e) {
      debugPrint('[DevocionalesPage] Error en _handleTtsStateChange: $e');
    }
  }
}
