import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';

/// Provider para el Dashboard del administrador.
///
/// Maneja: conteos rápidos, resumen diario, estadísticas históricas,
/// reportes rechazados, tendencias y generación de reportes.
class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Conteos rápidos (tarjetas)
  Map<String, dynamic>? _conteos;

  // Resumen diario
  Map<String, dynamic>? _resumenDiario;

  // Estadísticas históricas
  Map<String, dynamic>? _estadisticasHistoricas;

  // Reportes rechazados
  Map<String, dynamic>? _reportesRechazados;

  // Tendencia mensual
  Map<String, dynamic>? _tendenciaMensual;

  // Reporte generado
  Map<String, dynamic>? _reporteGenerado;

  // UI state
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get conteos => _conteos;
  Map<String, dynamic>? get resumenDiario => _resumenDiario;
  Map<String, dynamic>? get estadisticasHistoricas => _estadisticasHistoricas;
  Map<String, dynamic>? get reportesRechazados => _reportesRechazados;
  Map<String, dynamic>? get tendenciaMensual => _tendenciaMensual;
  Map<String, dynamic>? get reporteGenerado => _reporteGenerado;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ─────────────────────────────────────────────
  // Cargar conteos rápidos (tarjetas del dashboard)
  // ─────────────────────────────────────────────
  Future<void> cargarConteos() async {
    try {
      final result = await _apiService.get(ApiConstants.dashboardConteos);

      if (result is Map<String, dynamic>) {
        _conteos = result;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al cargar conteos: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Cargar resumen del día
  // ─────────────────────────────────────────────
  Future<void> cargarResumenDiario() async {
    _setLoading(true);
    try {
      final result = await _apiService.get(ApiConstants.dashboardResumen);

      if (result is Map<String, dynamic>) {
        _resumenDiario = result;
      }
      _error = null;
    } catch (e) {
      _error = _parseError(e);
    }
    _setLoading(false);
  }

  // ─────────────────────────────────────────────
  // Cargar estadísticas históricas
  // ─────────────────────────────────────────────
  Future<void> cargarEstadisticasHistoricas({
    String? fechaInicio,
    String? fechaFin,
  }) async {
    _setLoading(true);
    try {
      String url = ApiConstants.dashboardEstadisticas;
      final params = <String>[];
      if (fechaInicio != null) params.add('fecha_inicio=$fechaInicio');
      if (fechaFin != null) params.add('fecha_fin=$fechaFin');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final result = await _apiService.get(url);

      if (result is Map<String, dynamic>) {
        _estadisticasHistoricas = result;
      }
      _error = null;
    } catch (e) {
      _error = _parseError(e);
    }
    _setLoading(false);
  }

  // ─────────────────────────────────────────────
  // Cargar reportes rechazados
  // ─────────────────────────────────────────────
  Future<void> cargarReportesRechazados() async {
    _setLoading(true);
    try {
      final result = await _apiService.get(ApiConstants.dashboardRechazados);

      if (result is Map<String, dynamic>) {
        _reportesRechazados = result;
      }
      _error = null;
    } catch (e) {
      _error = _parseError(e);
    }
    _setLoading(false);
  }

  // ─────────────────────────────────────────────
  // Cargar tendencia mensual (últimos 12 meses)
  // ─────────────────────────────────────────────
  Future<void> cargarTendenciaMensual() async {
    try {
      final result = await _apiService.get(ApiConstants.dashboardTendencia);

      if (result is Map<String, dynamic>) {
        _tendenciaMensual = result;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al cargar tendencia mensual: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Generar reporte exportable
  // ─────────────────────────────────────────────
  Future<void> generarReporte({
    String? fechaInicio,
    String? fechaFin,
    String? tipo, // 'todos', 'rechazados', 'resueltos', 'pendientes'
  }) async {
    _setLoading(true);
    try {
      String url = ApiConstants.dashboardGenerarReporte;
      final params = <String>[];
      if (fechaInicio != null) params.add('fecha_inicio=$fechaInicio');
      if (fechaFin != null) params.add('fecha_fin=$fechaFin');
      if (tipo != null) params.add('tipo=$tipo');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final result = await _apiService.get(url);

      if (result is Map<String, dynamic>) {
        _reporteGenerado = result;
      }
      _error = null;
    } catch (e) {
      _error = _parseError(e);
    }
    _setLoading(false);
  }

  // ─────────────────────────────────────────────
  // Cargar todo el dashboard de una vez
  // ─────────────────────────────────────────────
  Future<void> cargarTodo() async {
    _setLoading(true);
    try {
      await Future.wait([
        cargarConteos(),
        cargarResumenDiario(),
        cargarTendenciaMensual(),
      ]);
      _error = null;
    } catch (e) {
      _error = _parseError(e);
    }
    _setLoading(false);
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
