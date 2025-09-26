import 'package:devocional_nuevo/extensions/string_extensions.dart';
import 'package:devocional_nuevo/providers/theme/theme_providers.dart';
import 'package:devocional_nuevo/utils/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingThemeSelectionPage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OnboardingThemeSelectionPage({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<OnboardingThemeSelectionPage> createState() =>
      _OnboardingThemeSelectionPageState();
}

class _OnboardingThemeSelectionPageState
    extends ConsumerState<OnboardingThemeSelectionPage> {
  String? selectedTheme;

  @override
  void initState() {
    super.initState();
    // Get current theme as default selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentThemeFamily = ref.read(currentThemeFamilyProvider);
      setState(() {
        selectedTheme = currentThemeFamily;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: TextButton(
                        onPressed: widget.onBack,
                        child: Text(
                          'onboarding.onboarding_back'.tr(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      // Title and subtitle section - more flexible height
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 80,
                          maxHeight: 140, // Flexible height constraint
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            Text(
                              'onboarding.onboarding_theme_title'.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 12),

                            // Subtitle
                            Text(
                              'onboarding.onboarding_theme_subtitle'.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    )
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Theme selection grid - takes remaining space
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: themeDisplayNames.length,
                          itemBuilder: (context, index) {
                            final themeKey = themeDisplayNames.keys.elementAt(
                              index,
                            );
                            final displayName = themeDisplayNames[themeKey]!;
                            final themeData =
                                appThemeFamilies[themeKey]!['light']!;
                            final isSelected = selectedTheme == themeKey;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedTheme = themeKey;
                                });
                                // Apply theme immediately for live preview
                                ref
                                    .read(themeProvider.notifier)
                                    .setThemeFamily(themeKey);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? themeData.colorScheme.primary
                                        : Colors.grey.withValues(alpha: 0.3),
                                    width: isSelected ? 3 : 1,
                                  ),
                                  color: themeData.colorScheme.surface,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: themeData.colorScheme.primary
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize:
                                      MainAxisSize.min, // Prevent overflow
                                  children: [
                                    // Color circle - smaller
                                    Container(
                                      width: 50, // Reduced size
                                      height: 50, // Reduced size
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: themeData.colorScheme.primary,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2, // Reduced border
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Theme name - constrained
                                    Flexible(
                                      child: Text(
                                        displayName,
                                        style: TextStyle(
                                          fontSize: 12, // Smaller font
                                          fontWeight: FontWeight.w600,
                                          color:
                                              themeData.colorScheme.onSurface,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Selected indicator
                                    if (isSelected)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4), // Reduced padding
                                        child: Icon(
                                          Icons.check_circle,
                                          color: themeData.colorScheme.primary,
                                          size: 16, // Smaller icon
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Next button
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedTheme != null ? widget.onNext : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'onboarding.onboarding_next'.tr(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
