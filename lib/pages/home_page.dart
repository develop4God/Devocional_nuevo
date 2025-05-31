// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:devocional_nuevo/pages/devocionales_page.dart'; // Página principal de devocionales
import 'package:devocional_nuevo/pages/favorites_page.dart'; // Página de favoritos

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex =
      0; // Índice de la pestaña seleccionada en la barra de navegación

  // Lista de widgets para las diferentes pestañas
  static const List<Widget> _widgetOptions = <Widget>[
    DevocionalesPage(), // La página principal de devocionales
    FavoritesPage(), // La página de favoritos
    Text(
      'Página de Ajustes (Próximamente)',
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    ), // Un placeholder para la página de ajustes
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(
            _selectedIndex), // Muestra el widget de la pestaña seleccionada
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined), // Icono de libro outlined
            label: 'Devocional', // Etiqueta para devocionales
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline), // Icono de marcador outlined
            label: 'Favoritos', // Etiqueta para favoritos
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined), // Icono de ajustes outlined
            label: 'Ajustes', // Etiqueta para ajustes
          ),
        ],
        currentIndex: _selectedIndex, // Índice actual seleccionado
        selectedItemColor: Theme.of(context)
            .colorScheme
            .primary, // Color principal del tema para el ítem seleccionado
        unselectedItemColor:
            Colors.grey, // Color para los ítems no seleccionados
        onTap: _onItemTapped, // Manejador de tap para cambiar de pestaña
      ),
    );
  }
}
