import 'package:devocional_nuevo/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

/// Bottom sheet that allows users to choose between adding a prayer or thanksgiving
///
/// Displays two options side-by-side with emoji icons.
/// Used in devocionales_page.dart when the floating action button is pressed.
class PrayerThanksgivingChoiceSheet extends StatelessWidget {
  final VoidCallback onPrayerSelected;
  final VoidCallback onThanksgivingSelected;

  const PrayerThanksgivingChoiceSheet({
    super.key,
    required this.onPrayerSelected,
    required this.onThanksgivingSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

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
                    onPrayerSelected();
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
                    onThanksgivingSelected();
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
  }
}
