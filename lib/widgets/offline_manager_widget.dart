import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/services/localization_service.dart';

class OfflineManagerWidget extends StatelessWidget {
  final bool showCompactView;
  final bool showStatusIndicator;

  const OfflineManagerWidget({
    super.key,
    this.showCompactView = false,
    this.showStatusIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<DevocionalProvider>(
      builder: (context, devocionalProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado actual - solo mostrar si no es vista compacta
            if (!showCompactView && devocionalProvider.isOfflineMode)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.offline_bolt,
                        color: colorScheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'offline_manager.using_offline_content'.tr(),
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (!showCompactView && devocionalProvider.isOfflineMode)
              const SizedBox(height: 10),

            // Mostrar estado de descarga si hay uno
            if (showStatusIndicator &&
                devocionalProvider.downloadStatus != null)
              Container(
                padding: EdgeInsets.all(showCompactView ? 8 : 12),
                decoration: BoxDecoration(
                  color: devocionalProvider.isDownloading
                      ? colorScheme.secondaryContainer
                      : colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (devocionalProvider.isDownloading)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      )
                    else
                      Icon(
                        devocionalProvider.downloadStatus!.contains('Error')
                            ? Icons.error
                            : Icons.check_circle,
                        color:
                            devocionalProvider.downloadStatus!.contains('Error')
                                ? colorScheme.error
                                : colorScheme.primary,
                        size: 16,
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        devocionalProvider.downloadStatus!,
                        style: (showCompactView
                                ? textTheme.bodySmall
                                : textTheme.bodySmall)
                            ?.copyWith(
                          color: devocionalProvider.isDownloading
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (!devocionalProvider.isDownloading)
                      IconButton(
                        icon: Icon(Icons.close, size: 16),
                        onPressed: () =>
                            devocionalProvider.clearDownloadStatus(),
                        padding: EdgeInsets.zero,
                        constraints:
                            BoxConstraints(minWidth: 24, minHeight: 24),
                      ),
                  ],
                ),
              ),

            if (showStatusIndicator &&
                devocionalProvider.downloadStatus != null &&
                !showCompactView)
              const SizedBox(height: 15),

            // Botones de acción - layout diferente para vista compacta
            if (showCompactView)
              // Vista compacta: solo botón principal
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: devocionalProvider.isDownloading
                      ? null
                      : () =>
                          _downloadDevocionales(context, devocionalProvider),
                  icon: Icon(Icons.download),
                  label: Text('offline_manager.download_current_year'.tr()),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              )
            else
              // Vista completa: ambos botones
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: devocionalProvider.isDownloading
                          ? null
                          : () => _downloadDevocionales(
                              context, devocionalProvider),
                      icon: Icon(Icons.download),
                      label: Text('offline_manager.download_current_year'.tr()),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: devocionalProvider.isDownloading
                          ? null
                          : () => _refreshFromAPI(context, devocionalProvider),
                      icon: Icon(Icons.refresh),
                      label: Text('offline_manager.update'.tr()),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

            if (!showCompactView) const SizedBox(height: 10),

            // Información adicional - solo en vista completa
            if (!showCompactView)
              FutureBuilder<bool>(
                future: devocionalProvider.hasCurrentYearLocalData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data!
                          ? 'offline_manager.offline_available'.tr()
                          : 'offline_manager.no_offline_content'.tr(),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        );
      },
    );
  }

  Future<void> _downloadDevocionales(
      BuildContext context, DevocionalProvider provider) async {
    final colorScheme = Theme.of(context).colorScheme;
    final success = await provider.downloadCurrentYearDevocionales();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'offline_manager.download_success'.tr()
                : 'offline_manager.download_error'.tr(),
          ),
          backgroundColor: success ? colorScheme.primary : colorScheme.error,
        ),
      );
    }
  }

  Future<void> _refreshFromAPI(
      BuildContext context, DevocionalProvider provider) async {
    final colorScheme = Theme.of(context).colorScheme;
    await provider.forceRefreshFromAPI();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('offline_manager.content_updated'.tr()),
          backgroundColor: colorScheme.primary,
        ),
      );
    }
  }
}
