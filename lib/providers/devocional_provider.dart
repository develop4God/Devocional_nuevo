// lib/providers/devocional_provider.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Importa tus propios modelos y constantes
import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/utils/constants.dart';

// --- DevocionalProvider (Gestión de Estado) ---
/// ChangeNotifier para gestionar el estado de los devocionales.
///
/// Maneja la lista de devocionales, el índice actual, los favoritos,
/// los devocionales vistos, el estado de carga y los mensajes de error.
class DevocionalProvider extends ChangeNotifier {
  List<Devocional> _devocionales = [];
  int _currentIndex = 0;
  Set<int> _seenIndices = {};
  Set<int> _favorites = {};
  bool _showInvitationDialog =
      true; // Controla si el diálogo de invitación debe mostrarse
  bool _isLoading = true; // Indica si los datos se están cargando
  String? _errorMessage; // Mensaje de error si la carga falla

  // Getters para acceder al estado de forma segura.
  List<Devocional> get devocionales => _devocionales;
  int get currentIndex => _currentIndex;
  Devocional? get currentDevocional =>
      _devocionales.isNotEmpty ? _devocionales[_currentIndex] : null;
  Set<int> get seenIndices => _seenIndices;
  Set<int> get favorites => _favorites;
  bool get showInvitationDialog => _showInvitationDialog;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor: La inicialización de datos se maneja externamente (ej. en SplashScreen).
  DevocionalProvider() {
    // La carga se inicia en el SplashScreen, no aquí directamente
    // pero mantenemos los métodos para ser llamados.
  }

  /// Inicializa los datos de la aplicación: carga configuraciones y devocionales.
  Future<void> initializeData() async {
    await _loadSettings();
    await fetchDevocionales();
    // No es necesario notificar listeners aquí si fetchDevocionales ya lo hace al final.
  }

  /// Carga las configuraciones guardadas desde SharedPreferences.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _seenIndices = (prefs.getStringList(PREF_SEEN_INDICES) ?? [])
        .map((e) => int.parse(e))
        .toSet();
    _favorites = (prefs.getStringList(PREF_FAVORITES) ?? [])
        .map((e) => int.parse(e))
        .toSet();
    _showInvitationDialog =
        !(prefs.getBool(PREF_DONT_SHOW_INVITATION) ?? false);
    _currentIndex = prefs.getInt(PREF_CURRENT_INDEX) ?? 0;
  }

  /// Guarda las configuraciones actuales en SharedPreferences.
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      PREF_SEEN_INDICES,
      _seenIndices.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      PREF_FAVORITES,
      _favorites.map((e) => e.toString()).toList(),
    );
    await prefs.setBool(PREF_DONT_SHOW_INVITATION, !_showInvitationDialog);
    await prefs.setInt(PREF_CURRENT_INDEX, _currentIndex);
  }

  /// Obtiene los devocionales desde la URL JSON.
  Future<void> fetchDevocionales() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notifica que la carga ha comenzado.

    final url = Uri.parse(DEVOCIONALES_JSON_URL);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _devocionales =
            jsonData.map((item) => Devocional.fromJson(item)).toList();
        // Asegura que el _currentIndex sea válido después de cargar nuevos devocionales.
        if (_currentIndex >= _devocionales.length && _devocionales.isNotEmpty) {
          _currentIndex = 0;
        } else if (_devocionales.isEmpty) {
          _currentIndex = 0; // O manejar un estado de "no hay devocionales"
        }
      } else {
        _errorMessage = 'Error al cargar devocionales: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Verifica tu acceso a internet.';
      // Podrías loggear el error original `e` para depuración.
      // print('Error de conexión: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notifica que la carga ha terminado (con éxito o error).
    }
  }

  /// Selecciona el siguiente devocional.
  ///
  /// Intenta seleccionar un devocional no visto. Si todos han sido vistos,
  /// selecciona uno aleatoriamente.
  void nextDevocional() {
    if (_devocionales.isEmpty) return;

    int nextIndex = _currentIndex;
    final total = _devocionales.length;

    // Si todos los devocionales han sido vistos, o si solo hay uno.
    if (_seenIndices.length >= total && total > 0) {
      // Opcional: podrías limpiar _seenIndices aquí si quieres que el ciclo de "no vistos" comience de nuevo.
      // _seenIndices.clear();
      nextIndex = Random().nextInt(total); // Simplemente elige uno al azar
    } else if (total > 1) {
      // Solo busca uno no visto si hay más de uno.
      int attempts = 0;
      // Bucle para encontrar un índice no visto.
      // Se limita el número de intentos para evitar bucles infinitos en casos extraños.
      do {
        nextIndex = Random().nextInt(total);
        attempts++;
        // Si se han hecho demasiados intentos (más que el total de devocionales),
        // o si encontramos un índice no visto, rompemos el bucle.
        // Esto previene que se quede atascado si _seenIndices está casi lleno.
        if (attempts > total * 2) {
          // Un umbral de intentos un poco mayor que el total
          // Como fallback, simplemente tomamos el siguiente índice secuencialmente
          // o volvemos al inicio si estamos al final.
          nextIndex = (_currentIndex + 1) % total;
          if (_seenIndices.contains(nextIndex) && _seenIndices.length < total) {
            // Si el secuencial también está visto y aún no hemos visto todos,
            // buscamos el primero no visto de forma más exhaustiva (o aceptamos un aleatorio).
            // Esta parte podría refinarse, pero por ahora el aleatorio inicial es el principal.
            nextIndex = Random().nextInt(total); // Reintenta un aleatorio final
          }
          break;
        }
      } while (_seenIndices.contains(nextIndex));
    } else {
      // Si solo hay un devocional o ninguno.
      nextIndex = 0; // O _currentIndex, ya que no hay a dónde más ir.
    }

    _currentIndex = nextIndex;
    _seenIndices.add(nextIndex); // Marca el nuevo devocional como visto
    _saveSettings(); // Guarda el estado
    notifyListeners(); // Notifica a los widgets que escuchan
  }

  /// Establece el devocional actual por su índice.
  void setCurrentDevocionalByIndex(int index) {
    if (index >= 0 && index < _devocionales.length) {
      _currentIndex = index;
      _seenIndices
          .add(index); // Marcar como visto también al seleccionar directamente
      _saveSettings();
      notifyListeners();
    }
  }

  /// Alterna el estado de favorito del devocional actual.
  void toggleFavorite() {
    if (_devocionales.isEmpty) return;
    if (_favorites.contains(_currentIndex)) {
      _favorites.remove(_currentIndex);
    } else {
      _favorites.add(_currentIndex);
    }
    _saveSettings();
    notifyListeners();
  }

  /// Remueve un devocional de la lista de favoritos por su índice.
  void removeFavorite(int index) {
    if (_favorites.contains(index)) {
      _favorites.remove(index);
      _saveSettings();
      notifyListeners();
    }
  }

  /// Establece la visibilidad del diálogo de invitación.
  void setInvitationDialogVisibility(bool show) {
    _showInvitationDialog = show;
    _saveSettings();
    notifyListeners();
  }
}
