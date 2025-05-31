// lib/providers/devocional_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/utils/constants.dart';

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
    final normalizedSelectedDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    // Buscar el devocional para la fecha seleccionada
    try {
      return _devocionales.firstWhere(
        (devocional) =>
            devocional.date.year == normalizedSelectedDate.year &&
            devocional.date.month == normalizedSelectedDate.month &&
            devocional.date.day == normalizedSelectedDate.day,
      );
    } catch (e) {
      // Si no se encuentra un devocional para la fecha, retorna un devocional "no disponible"
      print(
          "No se encontró devocional para la fecha $normalizedSelectedDate. Error: $e");
      return _createNoDataDevocional(normalizedSelectedDate);
    }
  }

  // Constructor: Cargar los datos y favoritos al iniciar el provider
  DevocionalProvider() {
    initializeData();
  }

  Future<void> initializeData() async {
    await _loadFavorites();
    await _loadInvitationDialogPreference();
    await _fetchDevocionales();
    notifyListeners();
  }

  // --- Lógica de navegación de fechas ---

  void goToPreviousDay() {
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    notifyListeners();
  }

  void goToNextDay() {
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    notifyListeners();
  }

  void goToToday() {
    _selectedDate = DateTime.now();
    notifyListeners();
  }

  void setSelectedDate(DateTime newDate) {
    _selectedDate = DateTime(
        newDate.year, newDate.month, newDate.day); // Normaliza la fecha
    notifyListeners();
  }

  // --- Lógica de la API ---

  // Método para obtener los devocionales de la API
  Future<void> _fetchDevocionales() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(Constants.apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // --- CAMBIO CLAVE AQUÍ: Acceder a la estructura anidada del JSON ---
        // Se espera que los devocionales estén en responseData['data']['es']['NTV']
        final List<dynamic>? devocionalesJsonList =
            responseData['data']?['es']?['NTV'];

        if (devocionalesJsonList != null) {
          _devocionales = devocionalesJsonList
              .map((json) => Devocional.fromJson(json))
              .toList();
          // Asegúrate de que los devocionales estén ordenados por fecha
          _devocionales.sort((a, b) => a.date.compareTo(b.date));
          print('Devocionales cargados: ${_devocionales.length}');
        } else {
          _errorMessage =
              'No se encontraron devocionales en la estructura esperada (data.es.NTV) o la lista está vacía.';
          print(_errorMessage);
          _devocionales = [
            _createNoDataDevocional(DateTime.now())
          ]; // Devocional de fallback
        }
      } else {
        _errorMessage = 'Error al cargar devocionales: ${response.statusCode}.';
        print(_errorMessage);
        _devocionales = [
          _createNoDataDevocional(DateTime.now())
        ]; // Devocional de fallback
      }
    } catch (e) {
      _errorMessage = 'Error de red o parseo: $e';
      print(_errorMessage);
      _devocionales = [
        _createNoDataDevocional(DateTime.now())
      ]; // Devocional de fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Devocional de fallback para cuando no hay datos
  Devocional _createNoDataDevocional(DateTime date) {
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    return Devocional(
      id: 'no-data-${date.toIso8601String()}',
      versiculo: 'No hay devocional disponible para el día ${formattedDate}.',
      reflexion:
          'Por favor, verifica tu conexión a internet o intenta más tarde. Estamos trabajando para tener el contenido disponible.',
      paraMeditar: [
        {
          'cita': 'Salmos 119:105',
          'texto':
              'Tu palabra es una lámpara a mis pies; es una luz en mi sendero.'
        },
        {
          'cita': 'Mateo 4:4',
          'texto':
              'No solo de pan vivirá el hombre, sino de toda palabra que sale de la boca de Dios.'
        }
      ],
      oracion:
          'Amado Padre, te pedimos que nos guíes y nos reveles tu verdad a través de tu Palabra. Amén.',
      date: date,
      version: 'NTV', // Ajusta según la versión por defecto que uses
      language: 'es', // Ajusta según el idioma por defecto que uses
      tags: ['Sin datos', 'Recordatorio'],
    );
  }

  // --- Lógica de Favoritos ---

  // Guardar favoritos en SharedPreferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    // Convertir la lista de objetos Devocional a una lista de mapas JSON
    final String encodedFavorites =
        json.encode(_favoriteDevocionales.map((dev) => dev.toJson()).toList());
    await prefs.setString('favorites', encodedFavorites);
  }

  // Cargar favoritos de SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedFavorites = prefs.getString('favorites');
    if (encodedFavorites != null) {
      final List<dynamic> decodedList = json.decode(encodedFavorites);
      _favoriteDevocionales =
          decodedList.map((json) => Devocional.fromJson(json)).toList();
    } else {
      _favoriteDevocionales = [];
    }
    // No notificar aquí; initializeData() lo hará al final
  }

  // Verificar si un devocional es favorito
  bool isFavorite(Devocional devocional) {
    // Para verificar si es favorito, se recomienda usar el 'id' del devocional que es único.
    return _favoriteDevocionales.any((fav) => fav.id == devocional.id);
  }

  // Añadir o quitar de favoritos
  void toggleFavorite(Devocional devocional, BuildContext context) {
    // SE AÑADE BuildContext context
    // Asegurarse de no intentar añadir el devocional "no disponible" a favoritos
    if (devocional.id.startsWith('no-data')) {
      // Opcional: mostrar un mensaje al usuario o loguear
      // print('No se puede añadir un devocional no disponible a favoritos.');
      ScaffoldMessenger.of(context).showSnackBar(
        // Mensaje para devocional no disponible
        const SnackBar(
          content: Text('Este devocional no se puede guardar como favorito.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (isFavorite(devocional)) {
      _favoriteDevocionales.removeWhere((fav) => fav.id == devocional.id);
      ScaffoldMessenger.of(context).showSnackBar(
        // Mensaje al remover
        const SnackBar(
          content: Text('Devocional removido de favoritos'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _favoriteDevocionales.add(devocional);
      ScaffoldMessenger.of(context).showSnackBar(
        // Mensaje al guardar
        const SnackBar(
          content: Text('Devocional guardado como favorito'),
          duration: Duration(seconds: 2),
        ),
      );
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
    notifyListeners();
  }
}
