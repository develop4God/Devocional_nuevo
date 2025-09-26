import 'package:devocional_nuevo/pages/onboarding/onboarding_backup_configuration_page.dart';
import 'package:devocional_nuevo/pages/onboarding/onboarding_complete_page.dart';
import 'package:devocional_nuevo/pages/onboarding/onboarding_theme_selection_page.dart';
import 'package:devocional_nuevo/pages/onboarding/onboarding_welcome_page.dart';
import 'package:devocional_nuevo/providers/onboarding/onboarding_providers.dart';
import 'package:devocional_nuevo/providers/onboarding/onboarding_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingFlow({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    
    // Initialize onboarding flow using Riverpod
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProvider.notifier).initialize();
    });
  }

  void _handleStepNavigation(int stepIndex) {
    ref.read(onboardingProvider.notifier).progressToStep(stepIndex);
    _animateToPage(stepIndex);
  }

  void _handleBack() {
    ref.read(onboardingProvider.notifier).goBack();
    final currentStep = ref.read(currentOnboardingStepProvider);
    if (currentStep > 0) {
      _animateToPage(currentStep - 1);
    }
  }

  void _handleComplete() {
    ref.read(onboardingProvider.notifier).complete();
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

  void _showErrorDialog(BuildContext context, OnboardingErrorState errorState) {
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
            Text(errorState.message),
            if (errorState.errorContext?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                'Details: ${errorState.errorContext}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Retry initialization
              ref.read(onboardingProvider.notifier).initialize();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Skip onboarding and complete it (fallback)
              widget.onComplete();
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr, // Force LTR for consistency
      child: Scaffold(
        body: Consumer(
          builder: (context, ref, child) {
            final onboardingState = ref.watch(onboardingProvider);

            // Listen for state changes and handle completion
            ref.listen<OnboardingRiverpodState>(onboardingProvider, (previous, next) {
              next.when(
                initial: () {},
                loading: () {},
                stepActive: (currentStepIndex, currentStep, userSelections, stepConfiguration, canProgress, canGoBack, progress) {
                  // Update page controller if needed
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_pageController.hasClients && _pageController.page?.round() != currentStepIndex) {
                      _animateToPage(currentStepIndex);
                    }
                  });
                },
                configuring: (configurationType, configurationData) {},
                completed: (appliedConfigurations, completionTimestamp) {
                  // Onboarding completed, call the completion callback
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onComplete();
                  });
                },
                error: (message, category, errorContext) {
                  // Show detailed error dialog instead of just snackbar
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showErrorDialog(context, OnboardingErrorState(
                      message: message,
                      category: category,
                      errorContext: errorContext,
                    ));
                  });
                },
              );
            });

            return onboardingState.when(
              initial: () => const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              loading: () => const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              stepActive: (currentStepIndex, currentStep, userSelections, stepConfiguration, canProgress, canGoBack, progress) {
                return Scaffold(
                  body: Column(
                    children: [
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
              },
              configuring: (configurationType, configurationData) => const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              completed: (appliedConfigurations, completionTimestamp) => const Scaffold(
                body: Center(
                  child: Text('Onboarding completed!'),
                ),
              ),
              error: (message, category, errorContext) => Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $message',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(onboardingProvider.notifier).initialize(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ), // Closes Directionality widget child
    ); // Closes Directionality widget
  }
}