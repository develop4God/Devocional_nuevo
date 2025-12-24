import 'package:devocional_nuevo/extensions/string_extensions.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:flutter/material.dart';

/// Dialog that displays salvation prayer invitation to users
///
/// Shows a salvation prayer with an option to not show again.
/// Used in devocionales_page.dart when displaying devotional content.
class SalvationInvitationDialog extends StatefulWidget {
  final DevocionalProvider devocionalProvider;

  const SalvationInvitationDialog({
    super.key,
    required this.devocionalProvider,
  });

  @override
  State<SalvationInvitationDialog> createState() =>
      _SalvationInvitationDialogState();
}

class _SalvationInvitationDialogState extends State<SalvationInvitationDialog> {
  bool _doNotShowAgainChecked = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AlertDialog(
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
              value: _doNotShowAgainChecked,
              onChanged: (val) {
                setState(() {
                  _doNotShowAgainChecked = val ?? false;
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
              widget.devocionalProvider.setInvitationDialogVisibility(
                !_doNotShowAgainChecked,
              );
              Navigator.of(context).pop();
            },
            child: Text(
              "devotionals.continue".tr(),
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}
