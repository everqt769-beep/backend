import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/api_constants.dart';

/// Servicio de autenticación integrado con Supabase Auth.
///
/// Gestiona login, registro, logout y el token JWT
/// que se envía al backend en cada petición.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Cliente de Supabase (se inicializa en main.dart).
  SupabaseClient get _client => Supabase.instance.client;

  /// Usuario actual autenticado.
  User? get currentUser => _client.auth.currentUser;

  /// Token JWT actual para enviar al backend.
  String? get currentToken => _client.auth.currentSession?.accessToken;

  /// Stream de cambios de autenticación.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// ¿Hay sesión activa?
  bool get isAuthenticated => currentUser != null;

  // ─────────────────────────────────────────────
  // Login con email y contraseña
  // ─────────────────────────────────────────────
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // ─────────────────────────────────────────────
  // Registro con email, contraseña y nombre
  // ─────────────────────────────────────────────
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String nombre,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'nombre': nombre},
    );
    return response;
  }

  // ─────────────────────────────────────────────
  // Cerrar sesión
  // ─────────────────────────────────────────────
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ─────────────────────────────────────────────
  // Recuperar contraseña
  // ─────────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // ─────────────────────────────────────────────
  // Refrescar sesión
  // ─────────────────────────────────────────────
  Future<AuthResponse> refreshSession() async {
    final response = await _client.auth.refreshSession();
    return response;
  }
}
