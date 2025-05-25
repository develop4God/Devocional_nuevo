// lib/pages/favorites_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final devocionalProvider = Provider.of<DevocionalProvider>(context);

    // Obtener los devocionales favoritos
    final List<int> favoriteIndices = devocionalProvider.favorites.toList();
    final List<Devocional> favoriteDevocionales = favoriteIndices
        .map((index) => devocionalProvider
            .devocales[index]) // Asumiendo que devocales es la lista completa
        .whereType<
            Devocional>() // Filtrar por si hay nulos (aunque currentDevocional lo maneja)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devocionales Favoritos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: favoriteDevocionales.isEmpty
          ? const Center(
              child: Text(
                'Aún no tienes devocionales favoritos. \n¡Agrega algunos desde la pantalla principal!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: favoriteDevocionales.length,
              itemBuilder: (context, index) {
                final devocional = favoriteDevocionales[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(devocional.versiculo,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(devocional.reflexion,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        // Al quitar de favoritos, usamos el índice original del devocional
                        // en la lista general de devocionales, no el índice en la lista de favoritos.
                        final originalIndex =
                            devocionalProvider.devocales.indexOf(devocional);
                        if (originalIndex != -1) {
                          devocionalProvider.removeFavorite(originalIndex);
                        }
                      },
                    ),
                    onTap: () {
                      // Navegar de vuelta a la página principal y mostrar este devocional
                      final originalIndex =
                          devocionalProvider.devocales.indexOf(devocional);
                      if (originalIndex != -1) {
                        devocionalProvider
                            .setCurrentDevocionalByIndex(originalIndex);
                        Navigator.pop(context); // Cierra la página de favoritos
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
