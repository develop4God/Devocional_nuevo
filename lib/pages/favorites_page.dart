// lib/pages/favorites_page.dart

import 'package:devocional_nuevo/models/devocional_model.dart'; // Asegúrate de importar tu modelo
import 'package:devocional_nuevo/pages/devocionales_page.dart'; // Importar DevocionalesPage
import 'package:devocional_nuevo/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha
import 'package:provider/provider.dart';

import '../providers/devocional_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context)
            .appBarTheme
            .backgroundColor, // Usa el color de fondo del AppBar del tema
        foregroundColor: Colors.white,
        title: Text('favorites.title'.tr()),
        centerTitle: true,
      ),
      body: Consumer<DevocionalProvider>(
        builder: (context, devocionalProvider, child) {
          // Acceder directamente a la lista de devocionales favoritos del provider
          final List<Devocional> favoriteDevocionales =
              devocionalProvider.favoriteDevocionales;

          if (favoriteDevocionales.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'favorites.no_favorites'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'favorites.instructions'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: favoriteDevocionales.length,
            itemBuilder: (context, index) {
              final Devocional devocional = favoriteDevocionales[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  // Al tocar la tarjeta, navega a la página del devocional específico
                  onTap: () {
                    // << CORREGIDO: Pasamos el initialDevocionalId a DevocionalesPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DevocionalesPage(
                          initialDevocionalId: devocional.id,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, d MMMM yyyy', 'es')
                                  .format(devocional.date),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      // Usa el color primario del tema
                                      fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              devocional.versiculo,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.w600),
                              maxLines: 2,
                              overflow: TextOverflow
                                  .ellipsis, // Añade puntos suspensivos si se recorta
                            ),
                          ],
                        ),
                        // Botón para quitar de favoritos (alineado a la derecha)
                        Align(
                          alignment: Alignment.topRight,
                          // Cambiado de bottomRight a topRight para no solapar texto
                          child: IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 28,
                            ),
                            tooltip: 'favorites.remove_tooltip'.tr(),
                            onPressed: () {
                              devocionalProvider.toggleFavorite(
                                  devocional, context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('favorites.removed_message'
                                        .tr()
                                        .replaceAll('{{verse}}',
                                            devocional.versiculo))),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
