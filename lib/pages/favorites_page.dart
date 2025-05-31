// lib/pages/favorites_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha
import 'package:devocional_nuevo/models/devocional_model.dart'; // Asegúrate de importar tu modelo
import 'package:devocional_nuevo/providers/devocional_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text('Mis favoritos guardados'),
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
                    const SizedBox(height: 20),
                    const Text(
                      'Aún no tienes devocionales favoritos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Marca el corazón en un devocional para guardarlo aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
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
              final devocional = favoriteDevocionales[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: InkWell(
                  // Hace que toda la tarjeta sea clickable
                  onTap: () {
                    // Cuando se toca un favorito, navegar a la DevocionalesPage
                    // y establecer esa fecha como la fecha seleccionada.
                    devocionalProvider.setSelectedDate(devocional.date);
                    Navigator.pop(
                        context); // Cierra FavoritesPage y regresa a DevocionalesPage
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('dd MMMM yyyy', 'es')
                              .format(devocional.date),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          devocional.versiculo,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          maxLines: 3, // Muestra solo las primeras 3 líneas
                          overflow: TextOverflow
                              .ellipsis, // Añade puntos suspensivos si se recorta
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            icon: const Icon(
                              Icons
                                  .favorite, // Siempre lleno, ya que estamos en la lista de favoritos
                              color: Colors.red,
                              size: 28,
                            ),
                            tooltip: 'Quitar de favoritos',
                            onPressed: () {
                              // Usamos toggleFavorite que se encarga de añadir/quitar
                              devocionalProvider.toggleFavorite(devocional,
                                  context); // **CAMBIO AQUÍ: Se añade el context**
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        '\"${devocional.versiculo}\" eliminado de favoritos.')),
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
