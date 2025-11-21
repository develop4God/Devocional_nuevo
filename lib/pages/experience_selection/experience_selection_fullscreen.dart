// lib/pages/experience_selection/experience_selection_fullscreen.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/devotional_constants.dart';
import '../devotional_discovery_page.dart';
import '../devocionales_page.dart';

/// Full-screen onboarding experience for first-time users
/// Beautiful Lottie animation with comparative cards
class ExperienceSelectionFullscreen extends StatelessWidget {
  const ExperienceSelectionFullscreen({super.key});

  Future<void> _selectExperience(
      BuildContext context, ExperienceMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        DevotionalConstants.prefExperienceMode, mode.toStorageString());

    if (!context.mounted) return;

    Widget targetPage;
    switch (mode) {
      case ExperienceMode.discovery:
        targetPage = const DevotionalDiscoveryPage();
        break;
      case ExperienceMode.traditional:
        targetPage = const DevocionalesPage();
        break;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // Lottie animation
                SizedBox(
                  height: screenHeight * 0.35,
                  child: Lottie.asset(
                    'assets/lottie/book_animation.json',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  'Choose Your Journey',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Select how you\'d like to explore your devotional time',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Discovery Card (Recommended)
                _buildComparisonCard(
                  context: context,
                  title: 'Discovery Experience',
                  description:
                      'Modern, visual interface with search, favorites, and verse-first reading',
                  features: [
                    'Browse devotionals with beautiful cards',
                    'Search and filter by topics',
                    'Track your reading streak',
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [Colors.purple[900]!, Colors.deepPurple[800]!]
                        : [Colors.purple[600]!, Colors.deepPurple[600]!],
                  ),
                  isRecommended: true,
                  onTap: () =>
                      _selectExperience(context, ExperienceMode.discovery),
                  isDark: isDark,
                ),

                const SizedBox(height: 20),

                // Traditional Card
                _buildComparisonCard(
                  context: context,
                  title: 'Traditional Experience',
                  description:
                      'Classic daily devotional with familiar interface',
                  features: [
                    'Daily devotional card view',
                    'Simple navigation',
                    'Proven and trusted interface',
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [Colors.blue[900]!, Colors.indigo[800]!]
                        : [Colors.blue[600]!, Colors.indigo[600]!],
                  ),
                  isRecommended: false,
                  onTap: () =>
                      _selectExperience(context, ExperienceMode.traditional),
                  isDark: isDark,
                ),

                const SizedBox(height: 32),

                // Settings note
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 16,
                      color: isDark ? Colors.grey[600] : Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'You can change this anytime in Settings',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[600] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonCard({
    required BuildContext context,
    required String title,
    required String description,
    required List<String> features,
    required Gradient gradient,
    required bool isRecommended,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isRecommended
            ? Border.all(color: Colors.purple[400]!, width: 2)
            : Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with gradient
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Stack(
              children: [
                // Recommended badge
                if (isRecommended)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[600],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Recommended',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '🔥',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Title
                Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                // Features
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: isRecommended
                                ? Colors.purple[400]
                                : Colors.blue[400],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 16),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecommended
                          ? Colors.purple[600]
                          : (isDark ? Colors.grey[800] : Colors.grey[200]),
                      foregroundColor: isRecommended
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: isRecommended ? 4 : 0,
                    ),
                    child: Text(
                      'Start',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isRecommended ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
