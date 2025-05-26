// lib/providers/devocional_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/utils/constants.dart'; // Asegúrate de que esta ruta sea correcta

class DevocionalProvider with ChangeNotifier {
  List<Devocional> _devocionales = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime _selectedDate =
      DateTime.now(); // La fecha que se está mostrando actualmente
  List<Devocional> _favoriteDevocionales =
      []; // Lista de devocionales favoritos
  bool _showInvitationDialog = true; // Para el diálogo de invitación

  // Getters
  List<Devocional> get devocionales => _devocionales;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;
  List<Devocional> get favoriteDevocionales => _favoriteDevocionales;
  bool get showInvitationDialog => _showInvitationDialog;

  // Getter para obtener el devocional del día seleccionado
  Devocional? get currentDevocional {
    // Buscar el devocional para la fecha seleccionada
    // Se normaliza _selectedDate para comparar solo día, mes, año
    DateTime normalizedSelectedDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    Devocional? foundDevocional = _devocionales.firstWhere(
      (d) => isSameDay(d.date, normalizedSelectedDate),
      orElse: () => Devocional(
        // Si no se encuentra un devocional, crea uno "vacío" con un mensaje
        id: 'no-data-${normalizedSelectedDate.toIso8601String()}', // ID especial para indicar que no hay datos
        versiculo: 'Devocional no disponible',
        reflexion:
            'Por favor, intente con otra fecha o verifique su conexión a internet.',
        paraMeditar: [],
        oracion:
            'No se encontró un devocional para el día ${normalizedSelectedDate.day}/${normalizedSelectedDate.month}/${normalizedSelectedDate.year}.',
        date: normalizedSelectedDate,
      ),
    );
    return foundDevocional;
  }

  // Constructor para cargar los datos al inicio
  DevocionalProvider() {
    // Aquí se inicializan los datos al crear el Provider.
    // Usamos initializeData para cargar tanto devocionales como favoritos.
    initializeData();
  }

  // Función auxiliar para comprobar si dos fechas son el mismo día (ignorando la hora)
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Función para inicializar datos (llama a _fetchDevocionales y _loadFavorites)
  Future<void> initializeData() async {
    _isLoading = true;
    _errorMessage = null; // Limpiar cualquier error previo
    notifyListeners(); // Inicia el estado de carga

    await _fetchDevocionales();
    await _loadFavorites();
    await _loadInvitationDialogPreference(); // Cargar la preferencia del diálogo

    _isLoading = false;
    notifyListeners(); // Termina el estado de carga (con éxito o con error)
  }

  // Cargar devocionales desde la API
  Future<void> _fetchDevocionales() async {
    try {
      // Asegúrate de que Constants.apiUrl apunte a tu JSON de devocionales
      final response = await http.get(Uri.parse(Constants.apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response
            .bodyBytes)); // Decodificar UTF-8 para caracteres especiales
        _devocionales = data.map((json) => Devocional.fromJson(json)).toList();
        _devocionales
            .sort((a, b) => a.date.compareTo(b.date)); // Ordenar por fecha
      } else {
        _errorMessage = 'Error al cargar devocionales: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
    }
    // No notificar aquí; initializeData() lo hará al final
  }

  // Setear una nueva fecha seleccionada y cargar el devocional para esa fecha
  void setSelectedDate(DateTime newDate) {
    _selectedDate = DateTime(newDate.year, newDate.month,
        newDate.day); // Normalizar a solo día, mes, año
    notifyListeners();
  }

  // Navegar al devocional del día anterior
  void goToPreviousDay() {
    setSelectedDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  // Navegar al devocional del día siguiente
  void goToNextDay() {
    setSelectedDate(_selectedDate.add(const Duration(days: 1)));
  }

  // Este método (nextDevocional) se mantiene principalmente para el flujo del diálogo de invitación
  // que avanza al "siguiente día", aunque la navegación principal ahora es por fecha.
  void nextDevocional() {
    goToNextDay();
  }

  // --- Lógica de Favoritos ---

  // Cargar favoritos desde SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString('favorites');
    if (favoritesJson != null) {
      try {
        final List<dynamic> jsonList = json.decode(favoritesJson);
        _favoriteDevocionales =
            jsonList.map((e) => Devocional.fromJson(e)).toList();
      } catch (e) {
        // En caso de que el JSON de favoritos esté corrupto
        print('Error al cargar favoritos: $e');
        _favoriteDevocionales = []; // Reiniciar la lista de favoritos
      }
      // No notificar aquí; initializeData() lo hará
    }
  }

  // Guardar favoritos en SharedPreferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    // Convertir la lista de objetos Devocional a una lista de mapas JSON y luego a String
    final String jsonString =
        json.encode(_favoriteDevocionales.map((e) => e.toJson()).toList());
    await prefs.setString('favorites', jsonString);
  }

  // Verificar si un devocional es favorito
  bool isFavorite(Devocional devocional) {
    // Compara por ID o por una combinación de atributos si el ID no es único
    // Aquí, asumimos que el 'id' del devocional es único.
    return _favoriteDevocionales.any((fav) => fav.id == devocional.id);
  }

  // Añadir o quitar de favoritos
  void toggleFavorite(Devocional devocional) {
    // Asegurarse de no intentar añadir el devocional "no disponible" a favoritos
    if (devocional.id.startsWith('no-data')) {
      // Opcional: mostrar un mensaje al usuario o loguear
      // print('No se puede añadir un devocional no disponible a favoritos.');
      return;
    }

    if (isFavorite(devocional)) {
      _favoriteDevocionales.removeWhere((fav) => fav.id == devocional.id);
    } else {
      _favoriteDevocionales.add(devocional);
    }
    _saveFavorites(); // Guardar el cambio inmediatamente
    notifyListeners(); // Notificar a los widgets para que se actualicen
  }

  // --- Lógica del Diálogo de Invitación ---

  Future<void> _loadInvitationDialogPreference() async {
    final prefs = await SharedPreferences.getInstance();
    // Leer el valor guardado. Si no existe, se usa true por defecto.
    _showInvitationDialog = prefs.getBool('showInvitationDialog') ?? true;
    // No notificar aquí; initializeData() lo hará
  }

  Future<void> setInvitationDialogVisibility(bool shouldShow) async {
    _showInvitationDialog = shouldShow;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showInvitationDialog', shouldShow);
    notifyListeners(); // Notifica para que la UI se actualice si es necesario
  }
}
