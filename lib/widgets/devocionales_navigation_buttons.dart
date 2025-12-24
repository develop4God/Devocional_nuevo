import 'package:devocional_nuevo/controllers/tts_audio_controller.dart';
import 'package:devocional_nuevo/extensions/string_extensions.dart';
import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/widgets/tts_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Navigation buttons row for devotionals page
///
/// Shows previous/next buttons with a TTS player in the center.
class DevocionalesNavigationButtons extends StatelessWidget {
  final int currentDevocionalIndex;
  final int devocionalesLength;
  final Devocional? currentDevocional;
  final TtsAudioController audioController;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final void Function(BuildContext) onShowInvitation;

  const DevocionalesNavigationButtons({
    super.key,
    required this.currentDevocionalIndex,
    required this.devocionalesLength,
    required this.currentDevocional,
    required this.audioController,
    required this.onPrevious,
    required this.onNext,
    required this.onShowInvitation,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 45,
            child: OutlinedButton.icon(
              key: const Key('bottom_nav_previous_button'),
              onPressed: currentDevocionalIndex > 0 ? onPrevious : null,
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
                overlayColor:
                    colorScheme.primary.withAlpha((0.1 * 255).round()),
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
                          TtsPlayerWidget(
                            key: const Key('bottom_nav_tts_player'),
                            devocional: currentDevocional!,
                            audioController: audioController,
                            onCompleted: () {
                              final provider = Provider.of<DevocionalProvider>(
                                context,
                                listen: false,
                              );
                              if (provider.showInvitationDialog) {
                                onShowInvitation(context);
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
              onPressed: currentDevocionalIndex < devocionalesLength - 1
                  ? onNext
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
                overlayColor:
                    colorScheme.primary.withAlpha((0.1 * 255).round()),
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
    );
  }
}
