import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/auth_service.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/usuario.dart';

/// Provider de autenticación.
///
/// Gestiona el estado global de la sesión: login, registro,
/// datos de perfil y rol del usuario.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  Usuario? _usuario;
  bool _isLoading = false;
  String? _error;

  Usuario? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authService.isAuthenticated;
  String get rol => _usuario?.rol ?? 'ciudadano';

  /// Inicializar: verificar sesión existente y cargar perfil.
  Future<void> init() async {
    if (_authService.isAuthenticated) {
      await _loadPerfil();
    }

    // Escuchar cambios de autenticación
    _authService.authStateChanges.listen((event) {
      if (event.event == AuthChangeEvent.signedIn) {
        _loadPerfil();
      } else if (event.event == AuthChangeEvent.signedOut) {
        _usuario = null;
        notifyListeners();
      }
    });
  }

  /// Login con email y contraseña.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.signIn(email: email, password: password);
      await _loadPerfil();
      _setLoading(false);
      return true;
    } catch (e) {
      _error = _parseError(e);
      _setLoading(false);
      return false;
    }
  }

  /// Registro de nuevo ciudadano.
  Future<bool> register(String nombre, String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.signUp(
        email: email,
        password: password,
        nombre: nombre,
      );
      await _loadPerfil();
      _setLoading(false);
      return true;
    } catch (e) {
      _error = _parseError(e);
      _setLoading(false);
      return false;
    }
  }

  /// Cerrar sesión.
  Future<void> logout() async {
    await _authService.signOut();
    _usuario = null;
    _error = null;
    notifyListeners();
  }

  /// Recuperar contraseña.
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = _parseError(e);
      _setLoading(false);
      return false;
    }
  }

  /// Actualizar perfil (teléfono, etc.).
  Future<bool> updatePerfil(Map<String, dynamic> datos) async {
    _setLoading(true);
    try {
      final result =
          await _apiService.put('${ApiConstants.usuarios}/perfil', datos);
      _usuario = Usuario.fromJson(result);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = _parseError(e);
      _setLoading(false);
      return false;
    }
  }

  /// Cargar perfil del usuario autenticado desde el backend.
  Future<void> _loadPerfil() async {
    try {
      final result =
          await _apiService.get('${ApiConstants.usuarios}/perfil');
      _usuario = Usuario.fromJson(result);
      notifyListeners();
    } catch (e) {
      // Si falla al obtener perfil, no bloquear la app
      debugPrint('Error cargando perfil: $e');
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    if (e is AuthException) return e.message;
    if (e is ApiException) return e.message;
    return 'Ocurrió un error inesperado';
  }

  /// Limpiar error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
