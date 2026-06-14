
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
/// También verifica si el usuario está bloqueado.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  Usuario? _usuario;
  bool _isLoading = false;
  String? _error;

  // Estado de bloqueo
  bool _estaBloqueado = false;
  Map<String, dynamic>? _datosBloqueo;

  Usuario? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authService.isAuthenticated;
  String get rol => _usuario?.rol ?? 'ciudadano';

  // Getters de bloqueo
  bool get estaBloqueado => _estaBloqueado;
  Map<String, dynamic>? get datosBloqueo => _datosBloqueo;

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
        _estaBloqueado = false;
        _datosBloqueo = null;
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
  Future<void> signUp({
    required String email,
    required String password,
    required String nombre,
  }) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'nombre': nombre},
    );

    if (response.user == null) {
      throw Exception('No se pudo registrar el usuario');
    }
  }

  /// Cerrar sesión.
  Future<void> logout() async {
    await _authService.signOut();
    _usuario = null;
    _estaBloqueado = false;
    _datosBloqueo = null;
    _error = null;
    notifyListeners();
  }

  
  /// Actualizar perfil (teléfono, etc.).
  Future<bool> updatePerfil(Map<String, dynamic> datos) async {
    _setLoading(true);
    try {
      final result = await _apiService.put(
        '${ApiConstants.usuarios}/perfil',
        datos,
      );
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
      final result = await _apiService.get('${ApiConstants.usuarios}/perfil');

      if (result == null) {
        debugPrint('Perfil no encontrado (null)');
        _usuario = null;
        notifyListeners();
        return;
      }

      if (result is! Map<String, dynamic>) {
        debugPrint('Respuesta inválida: $result');
        return;
      }

      _usuario = Usuario.fromJson(result);

      // Verificar si el usuario (ciudadano) está bloqueado
      if (_usuario?.rol == 'ciudadano') {
        await _verificarBloqueo();
      } else {
        _estaBloqueado = false;
        _datosBloqueo = null;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando perfil: $e');
    }
  }

  /// Verificar si el usuario actual está bloqueado.
  Future<void> _verificarBloqueo() async {
    try {
      final result = await _apiService.get(ApiConstants.bloqueosVerificar);

      if (result is Map<String, dynamic>) {
        _estaBloqueado = result['bloqueado'] == true;
        _datosBloqueo = _estaBloqueado ? result : null;
      } else {
        _estaBloqueado = false;
        _datosBloqueo = null;
      }
    } catch (e) {
      debugPrint('Error verificando bloqueo: $e');
      _estaBloqueado = false;
      _datosBloqueo = null;
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
