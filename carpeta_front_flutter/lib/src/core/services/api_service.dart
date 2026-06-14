import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'auth_service.dart';

/// Servicio centralizado de comunicación HTTP con el backend.
///
/// Todas las peticiones pasan por aquí para inyectar automáticamente
/// el token JWT de Supabase en los headers.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Headers base con JSON y token de autenticación.
  Future<Map<String, String>> _headers() async {
    final token = AuthService().currentToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────────
  // GET
  // ─────────────────────────────────────────────
  Future<dynamic> get(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );
    return _processResponse(response);
  }

  // ─────────────────────────────────────────────
  // POST
  // ─────────────────────────────────────────────
  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  // ─────────────────────────────────────────────
  // PUT
  // ─────────────────────────────────────────────
  Future<dynamic> put(String url, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  // ─────────────────────────────────────────────
  // PATCH
  // ─────────────────────────────────────────────
  Future<dynamic> patch(String url, Map<String, dynamic> body) async {
    final response = await http.patch(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────
  Future<dynamic> delete(String url) async {
    final response = await http.delete(
      Uri.parse(url),
      headers: await _headers(),
    );
    return _processResponse(response);
  }

  // ─────────────────────────────────────────────
  // Procesar respuestas
  // ─────────────────────────────────────────────
  dynamic _processResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final errorMsg = body is Map ? (body['error'] ?? 'Error desconocido') : 'Error desconocido';
    throw ApiException(response.statusCode, errorMsg.toString());
  }
}

/// Excepción personalizada para errores de la API.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
}
