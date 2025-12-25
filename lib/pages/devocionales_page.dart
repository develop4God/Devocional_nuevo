import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:devocional_nuevo/blocs/theme/theme_bloc.dart';
import 'package:devocional_nuevo/blocs/theme/theme_state.dart';
import 'package:devocional_nuevo/extensions/string_extensions.dart';
import 'package:devocional_nuevo/logic/devocionales_page_logic.dart';
import 'package:devocional_nuevo/main.dart';
import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/pages/progress_page.dart';
import 'package:devocional_nuevo/pages/settings_page.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/services/devocionales_tracking.dart';
import 'package:devocional_nuevo/services/update_service.dart';
import 'package:devocional_nuevo/utils/bubble_constants.dart';
import 'package:devocional_nuevo/widgets/app_bar_constants.dart';
import 'package:devocional_nuevo/widgets/devocionales/devocionales_content_view.dart';
import 'package:devocional_nuevo/widgets/devocionales_page_drawer.dart';
import 'package:devocional_nuevo/widgets/floating_font_control_buttons.dart';
import 'package:devocional_nuevo/widgets/tts_miniplayer_modal.dart';
import 'package:devocional_nuevo/widgets/tts_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:lottie/lottie.dart'; // Re-agregado para animación post-splash
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devocional_nuevo/services/service_locator.dart';
import '../controllers/audio_controller.dart';
import '../controllers/tts_audio_controller.dart';
import '../services/analytics_service.dart';
import '../services/spiritual_stats_service.dart';
import '../widgets/voice_selector_dialog.dart';
import '../widgets/animated_fab_with_text.dart';

class DevocionalesPage extends StatefulWidget {
  final String? initialDevocionalId;

  const DevocionalesPage({super.key, this.initialDevocionalId});

  @override
  State<DevocionalesPage> createState() => _DevocionalesPageState();
}

class _DevocionalesPageState extends State<DevocionalesPage>
    with WidgetsBindingObserver, RouteAware {
  final ScreenshotController screenshotController = ScreenshotController();
  final ScrollController _scrollController = ScrollController();
  final DevocionalesTracking _tracking = DevocionalesTracking();
  final FlutterTts _flutterTts = FlutterTts();
  late final TtsAudioController _ttsAudioController;
  late final DevocionalesPageLogic _logic;
  AudioController? _audioController;
  bool _routeSubscribed = false;
  int _currentStreak = 0;
  late Future<int> _streakFuture;

  // Font control variables
  bool _showFontControls = false;
  double _fontSize = 16.0;

  static bool _postSplashAnimationShown =
      false; // Controla mostrar solo una vez
  bool _showPostSplashAnimation = false; // Estado local

  // Lista de animaciones Lottie disponibles
  final List<String> _lottieAssets = [
    'assets/lottie/bird_love.json',
    'assets/lottie/confetti.json',
    'assets/lottie/happy_bird.json',
    'assets/lottie/dog_walking.json',
    'assets/lottie/book_animation.json',
    'assets/lottie/plant.json',
  ];
  String? _selectedLottieAsset;

  @override
  void initState() {
    super.initState();
    _ttsAudioController = TtsAudioController(flutterTts: _flutterTts);
    // Listener para cerrar miniplayer automáticamente cuando el TTS complete
    _ttsAudioController.state.addListener(_handleTtsStateChange);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioController = Provider.of<AudioController>(context, listen: false);
      _tracking.initialize(context);
      _precacheLottieAnimations();
      // Initialize logic after context is available
      final provider = Provider.of<DevocionalProvider>(context, listen: false);
      _logic = DevocionalesPageLogic(
        context: context,
        provider: provider,
        tracking: _tracking,
        scrollController: _scrollController,
        ttsController: _ttsAudioController,
        flutterTts: _flutterTts,
        audioController: _audioController,
        initialDevocionalId: widget.initialDevocionalId,
      );
    });
    _loadFontSize();
    _loadInitialData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkForUpdate();
    });
    _pickRandomLottie();
    _streakFuture = _loadStreak();
    if (!_postSplashAnimationShown) {
      _showPostSplashAnimation = true;
      _postSplashAnimationShown = true;
      Future.delayed(const Duration(seconds: 7), () {
        if (mounted) setState(() => _showPostSplashAnimation = false);
      });
    }
  }

  Future<void> _precacheLottieAnimations() async {
    try {
      // Precache the fire.json animation to ensure it loads on first app start
      await Future.wait([
        rootBundle.load('assets/lottie/fire.json'),
        // Precache other frequently used animations
        ..._lottieAssets.map((asset) => rootBundle.load(asset)),
      ]);
      debugPrint('✅ Lottie animations precached successfully');
    } catch (e) {
      debugPrint('⚠️ Error precaching Lottie animations: $e');
    }
  }

  Future<int> _loadStreak() async {
    final stats = await SpiritualStatsService().getStats();
    if (mounted) {
      setState(() {
        _currentStreak = stats.currentStreak;
      });
    }
    return stats.currentStreak;
  }

  void _pickRandomLottie() {
    final random = Random();
    setState(() {
      _selectedLottieAsset =
          _lottieAssets[random.nextInt(_lottieAssets.length)];
    });
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('devocional_font_size') ?? 16.0;
    });
  }

  void _toggleFontControls() {
    setState(() {
      _showFontControls = !_showFontControls;
    });
  }

  Future<void> _increaseFontSize() async {
    if (_fontSize < 28.0) {
      setState(() {
        _fontSize += 1;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('devocional_font_size', _fontSize);
    }
  }

  Future<void> _decreaseFontSize() async {
    if (_fontSize > 12.0) {
      setState(() {
        _fontSize -= 1;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('devocional_font_size', _fontSize);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_routeSubscribed) {
      final route = ModalRoute.of(context);
      if (route is PageRoute) {
        routeObserver.subscribe(this, route);
        debugPrint(
          '🔄 [DEBUG] Global RouteObserver subscribed for DevocionalesPage',
        );
        _routeSubscribed = true;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _tracking.pauseTracking();
      debugPrint('🔄 App paused - tracking and criteria timer paused');
    } else if (state == AppLifecycleState.resumed) {
      _tracking.resumeTracking();
      debugPrint('🔄 App resumed - tracking and criteria timer resumed');
      UpdateService.checkForUpdate();
    }
  }

  @override
  void didPush() {
    _tracking.resumeTracking();
    debugPrint('📄 DevocionalesPage pushed → tracking resumed');
  }

  @override
  void didPopNext() {
    _tracking.resumeTracking();
    debugPrint('📄 DevocionalesPage popped next → tracking resumed');
  }

  @override
  void didPushNext() {
    _tracking.pauseTracking();
    debugPrint('📄 DevocionalesPage didPushNext → tracking PAUSED');
    if (_audioController != null && _audioController!.isActive) {
      debugPrint('🎵 [DEBUG] Navigation away - stopping audio (force)');
      _audioController!.forceStop();
    }
  }

  @override
  void dispose() {
    // Remover listener agregado en initState
    try {
      _ttsAudioController.state.removeListener(_handleTtsStateChange);
    } catch (_) {}
    _ttsAudioController.dispose();
    _tracking.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // Delegate to logic class
    await _logic.loadInitialData();
    // Update local state with the current index from logic
    if (mounted) {
      setState(() {});
    }
  }


  void _goToNextDevocional() async {
    if (!mounted) return;
    await _logic.goToNextDevocional();
    if (mounted) {
      setState(() {});
    }
  }

  void _goToPreviousDevocional() async {
    await _logic.goToPreviousDevocional();
    if (mounted) {
      setState(() {});
    }
  }



  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final themeState = context.watch<ThemeBloc>().state as ThemeLoaded;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: themeState.systemUiOverlayStyle,
      child: Scaffold(
        drawer: const DevocionalesDrawer(),
        appBar: CustomAppBar(
          titleWidget: AutoSizeText(
            'devotionals.my_intimate_space_with_god'.tr(),
            maxLines: 1,
            minFontSize: 10,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          actions: [
            IconButton(
              icon:
                  const Icon(Icons.text_increase_outlined, color: Colors.white),
              tooltip: 'bible.adjust_font_size'.tr(),
              onPressed: _toggleFontControls,
            ),
          ],
        ),
        floatingActionButton: AnimatedFabWithText(
          onPressed: () => _logic.showAddPrayerOrThanksgivingChoice(),
          text: 'prayer.add_prayer_thanksgiving_hint'.tr(),
          fabColor: colorScheme.primary, // Color del círculo con el +
          backgroundColor: colorScheme.secondary, // Color del fondo del texto
          textColor: colorScheme.onPrimaryContainer, // Color del texto
          iconColor: colorScheme.onPrimary, // Color del icono +
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: Stack(
          children: [
            Consumer<DevocionalProvider>(
              builder: (context, devocionalProvider, child) {
                final List<Devocional> devocionales =
                    devocionalProvider.devocionales;

                if (devocionales.isEmpty) {
                  return Center(
                    child: Text(
                      'devotionals.no_devotionals_available'.tr(),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );
                }

                if (_logic.currentIndex >= devocionales.length ||
                    _logic.currentIndex < 0) {
                  _logic.setCurrentIndex(0);
                }

                final Devocional currentDevocional =
                    devocionales[_logic.currentIndex];

                return Column(
                  children: [
                    Expanded(
                      child: Screenshot(
                        controller: screenshotController,
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16.0),
                            child: DevocionalesContentView(
                              devocional: currentDevocional,
                              fontSize: _fontSize,
                              logic: _logic,
                              currentStreak: _currentStreak,
                              streakFuture: _streakFuture,
                              onStreakBadgeTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProgressPage()),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (_showFontControls)
              FloatingFontControlButtons(
                currentFontSize: _fontSize,
                onIncrease: _increaseFontSize,
                onDecrease: _decreaseFontSize,
                onClose: () => setState(() => _showFontControls = false),
              ),
            if (_showPostSplashAnimation)
              Positioned(
                top: MediaQuery.of(context).padding.top + kToolbarHeight,
                right: 0,
                child: IgnorePointer(
                  child: Lottie.asset(
                    _selectedLottieAsset ?? 'assets/lottie/happy_bird.json',
                    width: 200,
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: Consumer<DevocionalProvider>(
          builder: (context, devocionalProvider, child) {
            final List<Devocional> devocionales =
                devocionalProvider.devocionales;
            final Devocional? currentDevocional = _logic.getCurrentDevocional(
              devocionales,
            );
            final bool isFavorite = currentDevocional != null
                ? devocionalProvider.isFavorite(currentDevocional)
                : false;

            final Color? appBarBackgroundColor = Theme.of(
              context,
            ).appBarTheme.backgroundColor;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      Consumer<AudioController>(
                        builder: (context, audioController, _) {
                          final progress = audioController.progress;
                          // Eliminados chunkIndex y totalChunks
                          return LinearProgressIndicator(
                            value: progress,
                            minHeight: 6, // Changed from 4
                            backgroundColor: Colors.grey[300],
                            color: colorScheme.primary,
                            // If supported, add borderRadius
                          );
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 45,
                              child: OutlinedButton.icon(
                                key: const Key('bottom_nav_previous_button'),
                                onPressed: _logic.currentIndex > 0
                                    ? _goToPreviousDevocional
                                    : null,
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                label: Text(
                                  'devotionals.previous'.tr(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: colorScheme.primary,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  foregroundColor: colorScheme.primary,
                                  overlayColor: colorScheme.primary.withAlpha(
                                      (0.1 * 255).round()), // Added feedback
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: currentDevocional != null
                                  ? Builder(
                                      builder: (context) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Original TtsPlayerWidget (unchanged)
                                            TtsPlayerWidget(
                                              key: const Key(
                                                'bottom_nav_tts_player',
                                              ),
                                              devocional: currentDevocional,
                                              audioController:
                                                  _ttsAudioController,
                                              onCompleted: () {
                                                final provider = Provider.of<
                                                        DevocionalProvider>(
                                                    context,
                                                    listen: false);
                                                if (provider
                                                    .showInvitationDialog) {
                                                  _logic.showInvitation();
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                  : const SizedBox(width: 56, height: 56),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 45,
                              child: OutlinedButton(
                                key: const Key('bottom_nav_next_button'),
                                onPressed: _logic.currentIndex <
                                        devocionales.length - 1
                                    ? _goToNextDevocional
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: colorScheme.primary,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  foregroundColor: colorScheme.primary,
                                  overlayColor: colorScheme.primary.withAlpha(
                                      (0.1 * 255).round()), // Added feedback
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'devotionals.next'.tr(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: BottomAppBar(
                    height: 60,
                    color: appBarBackgroundColor,
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            key: const Key('bottom_appbar_favorite_icon'),
                            tooltip: isFavorite
                                ? 'devotionals.remove_from_favorites_short'.tr()
                                : 'devotionals.save_as_favorite'.tr(),
                            onPressed: currentDevocional != null
                                ? () => devocionalProvider.toggleFavorite(
                                      currentDevocional,
                                      context,
                                    )
                                : null,
                            icon: Icon(
                              isFavorite ? Icons.star : Icons.favorite_border,
                              color: isFavorite ? Colors.amber : Colors.white,
                              size: 32,
                            ),
                          ),
                          IconButton(
                            key: const Key('bottom_appbar_prayers_icon'),
                            tooltip: 'tooltips.my_prayers'.tr(),
                            onPressed: () async {
                              HapticFeedback
                                  .mediumImpact(); // Added haptic feedback
                              await BubbleUtils.markAsShown(
                                BubbleUtils.getIconBubbleId(
                                  Icons.local_fire_department_outlined,
                                  'new',
                                ),
                              );
                              _logic.goToPrayers();
                            },
                            icon: const Icon(
                              Icons.local_fire_department_outlined,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                          IconButton(
                            key: const Key('bottom_appbar_bible_icon'),
                            tooltip: 'tooltips.bible'.tr(),
                            onPressed: () async {
                              await BubbleUtils.markAsShown(
                                BubbleUtils.getIconBubbleId(
                                  Icons.auto_stories_outlined,
                                  'new',
                                ),
                              );
                              _logic.goToBible();
                            },
                            icon: Icon(
                              Icons.auto_stories_outlined,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          IconButton(
                            key: const Key('bottom_appbar_share_icon'),
                            tooltip: 'devotionals.share_devotional'.tr(),
                            onPressed: currentDevocional != null
                                ? () => _logic.shareAsText(currentDevocional)
                                : null,
                            icon: Icon(
                              Icons.share_outlined,
                              color: colorScheme.onPrimary,
                              size: 30,
                            ),
                          ),
                          IconButton(
                            key: const Key('bottom_appbar_progress_icon'),
                            tooltip: 'tooltips.progress'.tr(),
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      const ProgressPage(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return FadeTransition(
                                        opacity: animation, child: child);
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 250),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.emoji_events_outlined,
                              color: colorScheme.onPrimary,
                              size: 30,
                            ),
                          ),
                          IconButton(
                            key: const Key('bottom_appbar_settings_icon'),
                            tooltip: 'tooltips.settings'.tr(),
                            onPressed: () async {
                              await BubbleUtils.markAsShown(
                                BubbleUtils.getIconBubbleId(
                                  Icons.app_settings_alt_outlined,
                                  'new',
                                ),
                              );
                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      const SettingsPage(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return FadeTransition(
                                        opacity: animation, child: child);
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 250),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.app_settings_alt_outlined,
                              color: colorScheme.onPrimary,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleTtsStateChange() {
    _logic.handleTtsStateChange(_showTtsModal);
  }

  void _showTtsModal() {
    // Prevent showing multiple modals
    if (!mounted || _logic.isTtsModalShowing) return;

    _logic.setTtsModalShowing(true);

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return ValueListenableBuilder<TtsPlayerState>(
          valueListenable: _ttsAudioController.state,
          builder: (context, state, _) {
            // Auto-close modal when not playing/paused
            if (state == TtsPlayerState.idle ||
                state == TtsPlayerState.completed) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.canPop(ctx)) {
                  Navigator.of(ctx).pop();
                }
              });
            }

            return ValueListenableBuilder<Duration>(
              valueListenable: _ttsAudioController.currentPosition,
              builder: (context, currentPos, __) {
                return ValueListenableBuilder<Duration>(
                  valueListenable: _ttsAudioController.totalDuration,
                  builder: (context, totalDur, ___) {
                    return ValueListenableBuilder<double>(
                      valueListenable: _ttsAudioController.playbackRate,
                      builder: (context, rate, ____) {
                        return TtsMiniplayerModal(
                          positionListenable:
                              _ttsAudioController.currentPosition,
                          totalDurationListenable:
                              _ttsAudioController.totalDuration,
                          stateListenable: _ttsAudioController.state,
                          playbackRateListenable:
                              _ttsAudioController.playbackRate,
                          playbackRates: _ttsAudioController.supportedRates,
                          onStop: () {
                            _ttsAudioController.stop();
                            _logic.setTtsModalShowing(false);
                            if (Navigator.canPop(ctx)) {
                              Navigator.of(ctx).pop();
                            }
                          },
                          onSeek: (d) => _ttsAudioController.seek(d),
                          onTogglePlay: () {
                            if (state == TtsPlayerState.playing) {
                              _ttsAudioController.pause();
                            } else {
                              // Track TTS play button press with Firebase Analytics
                              try {
                                getService<AnalyticsService>().logTtsPlay();
                              } catch (e) {
                                debugPrint(
                                    '❌ Error logging TTS play analytics: $e');
                                // Fail silently - analytics should not block functionality
                              }
                              _ttsAudioController.play();
                            }
                          },
                          onCycleRate: () async {
                            // CRITICAL: Pause before changing speed to avoid playback issues
                            if (state == TtsPlayerState.playing) {
                              await _ttsAudioController.pause();
                            }
                            try {
                              await _ttsAudioController.cyclePlaybackRate();
                            } catch (e) {
                              debugPrint(
                                '[DevocionalesPage] cyclePlaybackRate failed: $e',
                              );
                            }
                          },
                          onVoiceSelector: () async {
                            // Capture context-dependent values BEFORE async gap
                            final languageCode =
                                Localizations.localeOf(context).languageCode;
                            final currentDevocional =
                                Provider.of<DevocionalProvider>(context,
                                        listen: false)
                                    .devocionales[_logic.currentIndex];
                            final sampleText = _logic.buildTtsTextForDevocional(
                              currentDevocional,
                              languageCode,
                            );

                            // CRITICAL: Pause before opening voice selector to avoid playback issues
                            if (state == TtsPlayerState.playing) {
                              await _ttsAudioController.pause();
                            }

                            // Safe to use ctx here: ctx is from the outer builder scope (line 1514),
                            // not the widget context. Builder-provided contexts remain valid across
                            // async gaps within their scope, unlike widget contexts.
                            await showModalBottomSheet(
                              // ignore: use_build_context_synchronously
                              context: ctx,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(28),
                                ),
                              ),
                              builder: (voiceCtx) => FractionallySizedBox(
                                heightFactor: 0.8,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(voiceCtx)
                                        .viewInsets
                                        .bottom,
                                  ),
                                  child: VoiceSelectorDialog(
                                    language: languageCode,
                                    sampleText: sampleText,
                                    onVoiceSelected: (name, locale) async {},
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      _logic.setTtsModalShowing(false);
    });
  }
}
