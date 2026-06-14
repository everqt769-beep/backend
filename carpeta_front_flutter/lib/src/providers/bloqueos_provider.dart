import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/bloqueo.dart';
import '../models/configuracion_bloqueo.dart';

/// Provider para la gestión de bloqueos de usuarios.
///
/// Maneja: verificación de bloqueo, lista de bloqueados,
/// bloqueo/desbloqueo manual, configuración y estadísticas.
class BloqueosProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Estado de bloqueo del usuario actual
  bool _estaBloqueado = false;
  Map<String, dynamic>? _datosBloqueo;

  // Lista de usuarios bloqueados (admin)
  List<Bloqueo> _usuariosBloqueados = [];
  List<Bloqueo> _historialUsuario = [];

  // Configuración
  ConfiguracionBloqueo? _configuracion;

  // Estadísticas
  Map<String, dynamic>? _estadisticas;

  // UI state
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get estaBloqueado => _estaBloqueado;
  Map<String, dynamic>? get datosBloqueo => _datosBloqueo;
  List<Bloqueo> get usuariosBloqueados => _usuariosBloqueados;
  List<Bloqueo> get historialUsuario => _historialUsuario;
  ConfiguracionBloqueo? get configuracion => _configuracion;
  Map<String, dynamic>? get estadisticas => _estadisticas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ─────────────────────────────────────────────
  // Verificar bloqueo del usuario actual
  // ─────────────────────────────────────────────
  Future<bool> verificarBloqueoActual() async {
    try {
      final result = await _apiService.get(ApiConstants.bloqueosVerificar);

      if (result is Map<String, dynamic>) {
        _estaBloqueado = result['bloqueado'] == true;
        _datosBloqueo = _estaBloqueado ? result : null;
        notifyListeners();
        return _estaBloqueado;
      }

      _estaBloqueado = false;
      _datosBloqueo = null;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error al verificar bloqueo: $e');
      _estaBloqueado = false;
      _datosBloqueo = null;
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Cargar usuarios bloqueados (admin)
  // ─────────────────────────────────────────────
  Future<void> cargarUsuariosBloqueados() async {
    _setLoading(true);
    try {
      final result = await _apiService.get(ApiConstants.bloqueosUsuarios);

      if (result is List) {
        _usuariosBloqueados = result
            .map((json) => Bloqueo.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      _error = null;
    } catch (e) {
      _error = _parseError(e);
    }
    _setLoading(false);
  }

  // ─────────────────────────────────────────────
  // Cargar historial de un usuario (admin)
  // ─────────────────────────────────────────────
  Future<void> cargarHistorial(String usuarioId) async {
    _setLoading(true);
    try {
      final result = await _apiService.get(
        '${ApiConstants.bloqueosHistorial}/$usuarioId',
      );

      if (result is List) {
        _historialUsuario = result
            .map((json) => Bloqueo.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      _error = null;
    } catch (e) {
      _error = _parseError(e);
    }
    _setLoading(false);
  }

  // ─────────────────────────────────────────────
  // Bloquear un usuario (admin)
  // ─────────────────────────────────────────────
  Future<bool> bloquearUsuario({
    required String usuarioId,
    required String motivo,
    int? duracionHoras,
    String? reporteId,
    String? notasAdmin,
  }) async {
    _setLoading(true);
    try {
      await _apiService.post(
        '${ApiConstants.bloqueosBloquear}/$usuarioId',
        {
          'motivo': motivo,
          if (duracionHoras != null) 'duracion_horas': duracionHoras,
          if (reporteId != null) 'reporte_id': reporteId,
          if (notasAdmin != null) 'notas_admin': notasAdmin,
        },
      );
      _error = null;
      _setLoading(false);
      // Recargar lista
      await cargarUsuariosBloqueados();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _setLoading(false);
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Desbloquear un usuario (admin)
  // ─────────────────────────────────────────────
  Future<bool> desbloquearUsuario(String usuarioId, {String? notasAdmin}) async {
    _setLoading(true);
    try {
      await _apiService.post(
        '${ApiConstants.bloqueosDesbloquear}/$usuarioId',
        {
          if (notasAdmin != null) 'notas_admin': notasAdmin,
        },
      );
      _error = null;
      _setLoading(false);
      // Recargar lista
      await cargarUsuariosBloqueados();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _setLoading(false);
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Configuración del sistema de bloqueos
  // ─────────────────────────────────────────────
  Future<void> cargarConfiguracion() async {
    _setLoading(true);
    try {
      final result = await _apiService.get(ApiConstants.bloqueosConfig);

      if (result is Map<String, dynamic>) {
        _configuracion = ConfiguracionBloqueo.fromJson(result);
      }
      _error = null;
    } catch (e) {
      _error = _parseError(e);
    }
    _setLoading(false);
  }

  Future<bool> actualizarConfiguracion(ConfiguracionBloqueo config) async {
    _setLoading(true);
    try {
      final result = await _apiService.put(
        ApiConstants.bloqueosConfig,
        config.toJson(),
      );

      if (result is Map<String, dynamic>) {
        _configuracion = ConfiguracionBloqueo.fromJson(result);
      }
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = _parseError(e);
      _setLoading(false);
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Estadísticas de bloqueos
  // ─────────────────────────────────────────────
  Future<void> cargarEstadisticas() async {
    try {
      final result = await _apiService.get(ApiConstants.bloqueosEstadisticas);

      if (result is Map<String, dynamic>) {
        _estadisticas = result;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al cargar estadísticas de bloqueos: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    if (e is ApiException) return e.message;
    return 'Ocurrió un error inesperado';
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
