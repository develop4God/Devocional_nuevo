import 'package:devocional_nuevo/blocs/backup_bloc.dart';
import 'package:devocional_nuevo/blocs/onboarding/onboarding_bloc.dart';
import 'package:devocional_nuevo/blocs/onboarding/onboarding_event.dart';
import 'package:devocional_nuevo/blocs/onboarding/onboarding_models.dart';
import 'package:devocional_nuevo/blocs/onboarding/onboarding_state.dart';
import 'package:devocional_nuevo/pages/onboarding/onboarding_backup_configuration_page.dart';
import 'package:devocional_nuevo/pages/onboarding/onboarding_complete_page.dart';
import 'package:devocional_nuevo/pages/onboarding/onboarding_theme_selection_page.dart';
import 'package:devocional_nuevo/pages/onboarding/onboarding_welcome_page.dart';
import 'package:devocional_nuevo/providers/theme/theme_adapter.dart';
import 'package:devocional_nuevo/providers/theme/riverpod_theme_adapter.dart';
import 'package:devocional_nuevo/providers/theme_provider.dart';
import 'package:devocional_nuevo/services/onboarding_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingFlow({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final PageController _pageController = PageController();
  late OnboardingBloc _onboardingBloc;

  @override
  void initState() {
    super.initState();

    // Initialize OnboardingBloc with required dependencies
    // Use try-catch to handle missing providers gracefully
    ThemeAdapter? themeAdapter;
    BackupBloc? backupBloc;

    try {
      backupBloc = context.read<BackupBloc?>();
    } catch (e) {
      debugPrint('⚠️ BackupBloc not found in context, continuing without it');
    }

    // Use RiverpodThemeAdapter instead of ThemeProvider
    themeAdapter = RiverpodThemeAdapter(ref);

    _onboardingBloc = OnboardingBloc(
      onboardingService: OnboardingService.instance,
      themeProvider: _createThemeProviderAdapter(themeAdapter),
      backupBloc: backupBloc,
    );

    // Initialize onboarding flow
    _onboardingBloc.add(const InitializeOnboarding());
  }

  /// Create a ThemeProvider-like adapter from RiverpodThemeAdapter
  /// This is a temporary bridge until OnboardingBloc is fully migrated
  ThemeProvider _createThemeProviderAdapter(ThemeAdapter adapter) {
    return _RiverpodThemeProviderBridge(adapter);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _onboardingBloc.close();
    super.dispose();
  }

  void _handleStepNavigation(int targetStep) {
    _onboardingBloc.add(ProgressToStep(targetStep));
  }

  void _handleBack() {
    _onboardingBloc.add(const GoToPreviousStep());
  }

  void _handleComplete() {
    _onboardingBloc.add(const CompleteOnboarding());
  }

  void _animateToPage(int pageIndex) {
    // Only animate if PageController is attached and the widget is mounted
    if (_pageController.hasClients && mounted) {
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showErrorDialog(BuildContext context, OnboardingError error) {
    if (!mounted) return; // Safety check before showing dialog
    if (!context.mounted) return; // Context safety check

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        title: const Text('Onboarding Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.message),
            if (error.errorContext?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                'Details: ${error.errorContext}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (mounted && context.mounted) {
                _onboardingBloc.add(const InitializeOnboarding());
              }
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (mounted) {
                widget.onComplete(); // Skip onboarding on persistent errors
              }
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: BlocProvider<OnboardingBloc>(
        create: (context) => _onboardingBloc,
        child: BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (!mounted) return; // Safety check for async state updates

            if (state is OnboardingStepActive) {
              // Animate to the current step page
              _animateToPage(state.currentStepIndex);
            } else if (state is OnboardingCompleted) {
              // Onboarding completed, call the completion callback
              widget.onComplete();
            } else if (state is OnboardingError) {
              // Show detailed error dialog instead of just snackbar
              _showErrorDialog(context, state);
            }
          },
          builder: (context, state) {
            if (state is OnboardingLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is OnboardingCompleted) {
              // This should not be reached due to the listener, but provide fallback
              return const Scaffold(
                body: Center(
                  child: Text('Onboarding completed!'),
                ),
              );
            }

            if (state is OnboardingError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading onboarding',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          _onboardingBloc.add(const InitializeOnboarding());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is OnboardingStepActive) {
              return Scaffold(
                body: Column(
                  children: [
                    // Progress indicator
                    if (state.currentStepIndex <
                        OnboardingSteps.defaultSteps.length - 1)
                      Container(
                        padding: const EdgeInsets.fromLTRB(
                            32, 24, 32, 16), // Added top padding for status bar
                        margin: const EdgeInsets.only(
                            top:
                                8), // Additional margin to separate from status bar
                        child: Row(
                          children: List.generate(
                              OnboardingSteps.defaultSteps.length - 1, (index) {
                            return Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                    right: index <
                                            OnboardingSteps
                                                    .defaultSteps.length -
                                                2
                                        ? 8
                                        : 0),
                                height:
                                    6, // Increased height for better visibility
                                decoration: BoxDecoration(
                                  color: index <= state.currentStepIndex
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: index <= state.currentStepIndex
                                      ? [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                    // Pages
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          OnboardingWelcomePage(
                            onNext: () => _handleStepNavigation(1),
                          ),
                          OnboardingThemeSelectionPage(
                            onNext: () => _handleStepNavigation(2),
                            onBack: _handleBack,
                          ),
                          OnboardingBackupConfigurationPage(
                            onNext: () => _handleStepNavigation(3),
                            onBack: _handleBack,
                            onSkip: () => _handleStepNavigation(3),
                          ),
                          OnboardingCompletePage(onStartApp: _handleComplete),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Default fallback for initial state
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ), // Closes Directionality widget child
    ); // Closes Directionality widget
  }
}

/// Bridge class to adapt Riverpod ThemeAdapter to the old ThemeProvider interface
/// This is a temporary solution until OnboardingBloc is fully migrated to Riverpod
class _RiverpodThemeProviderBridge extends ThemeProvider {
  final ThemeAdapter _adapter;

  _RiverpodThemeProviderBridge(this._adapter);

  @override
  Future<void> setThemeFamily(String familyName) async {
    await _adapter.setThemeFamily(familyName);
    // Notify listeners that theme changed (for any observers)
    notifyListeners();
  }

  @override
  Future<void> setBrightness(Brightness brightness) async {
    await _adapter.setBrightness(brightness);
    // Notify listeners that brightness changed (for any observers)
    notifyListeners();
  }

  @override
  String get currentThemeFamily => _adapter.currentThemeFamily;

  @override
  Brightness get currentBrightness => _adapter.currentBrightness;

  @override
  void initializeDefaults() {
    // Not needed for Riverpod implementation
    // The Riverpod providers handle initialization
  }
}
