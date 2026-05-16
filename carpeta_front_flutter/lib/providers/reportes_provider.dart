import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/reporte.dart';

/// Provider para la gestión de reportes.
///
/// Maneja la lista de reportes, creación, detalle,
/// cambio de estado y filtros.
class ReportesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Reporte> _reportes = [];
  Reporte? _reporteDetalle;
  bool _isLoading = false;
  String? _error;
  String? _filtroEstado;
  String? _filtroArea;

  List<Reporte> get reportes {
    var lista = List<Reporte>.from(_reportes);
    if (_filtroEstado != null && _filtroEstado!.isNotEmpty) {
      lista = lista.where((r) => r.codigoEstado == _filtroEstado).toList();
    }
    if (_filtroArea != null && _filtroArea!.isNotEmpty) {
      lista = lista
          .where((r) =>
              r.categoria?.area?.nombre == _filtroArea)
          .toList();
    }
    return lista;
  }

  Reporte? get reporteDetalle => _reporteDetalle;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get filtroEstado => _filtroEstado;
  String? get filtroArea => _filtroArea;

  /// Total de reportes sin filtro.
  int get totalReportes => _reportes.length;

  /// Reportes con coordenadas para el mapa.
  List<Reporte> get reportesConUbicacion =>
      reportes.where((r) => r.latitud != null && r.longitud != null).toList();

  // ─────────────────────────────────────────────
  // Cargar todos los reportes
  // ─────────────────────────────────────────────
  Future<void> fetchReportes() async {
    _setLoading(true);
    _error = null;
    try {
      final result = await _api.get(ApiConstants.reportes);
      _reportes =
          (result as List).map((json) => Reporte.fromJson(json)).toList();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // Obtener detalle de un reporte
  // ─────────────────────────────────────────────
  Future<void> fetchReporteDetalle(String id) async {
    _setLoading(true);
    _error = null;
    try {
      final result = await _api.get('${ApiConstants.reportes}/$id');
      _reporteDetalle = Reporte.fromJson(result);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // Crear nuevo reporte
  // ─────────────────────────────────────────────
  Future<Reporte?> crearReporte({
    required String categoriaId,
    required String descripcion,
    double? latitud,
    double? longitud,
    String? direccion,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final body = {
        'categoria_id': categoriaId,
        'descripcion': descripcion,
        if (latitud != null) 'latitud': latitud,
        if (longitud != null) 'longitud': longitud,
        if (direccion != null) 'direccion': direccion,
      };
      final result = await _api.post(ApiConstants.reportes, body);
      final nuevoReporte = Reporte.fromJson(result);
      _reportes.insert(0, nuevoReporte);
      _setLoading(false);
      return nuevoReporte;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // Cambiar estado de reporte (funcionario/admin)
  // ─────────────────────────────────────────────
  Future<bool> cambiarEstado({
    required String reporteId,
    required String estadoCodigo,
    String? descripcionSeguimiento,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      await _api.patch(
        '${ApiConstants.reportes}/$reporteId/estado',
        {
          'estado_codigo': estadoCodigo,
          if (descripcionSeguimiento != null)
            'descripcion_seguimiento': descripcionSeguimiento,
        },
      );
      // Refrescar la lista y detalle
      await fetchReportes();
      if (_reporteDetalle?.idReporte == reporteId) {
        await fetchReporteDetalle(reporteId);
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Agregar comentario
  // ─────────────────────────────────────────────
  Future<bool> agregarComentario({
    required String reporteId,
    required String texto,
    String tipo = 'publico',
    String? padreId,
  }) async {
    try {
      await _api.post(ApiConstants.comentarios, {
        'reporte_id': reporteId,
        'texto': texto,
        'tipo': tipo,
        if (padreId != null) 'padre_id': padreId,
      });
      // Refrescar detalle para ver el nuevo comentario
      if (_reporteDetalle?.idReporte == reporteId) {
        await fetchReporteDetalle(reporteId);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Registrar adjunto (metadata en BD)
  // ─────────────────────────────────────────────
  Future<bool> registrarAdjunto({
    required String reporteId,
    required String tipo,
    required String url,
    required String nombreArchivo,
    int? tamanoBytes,
    String? descripcion,
  }) async {
    try {
      await _api.post(ApiConstants.adjuntos, {
        'reporte_id': reporteId,
        'tipo': tipo,
        'url': url,
        'nombre_archivo': nombreArchivo,
        if (tamanoBytes != null) 'tamano_bytes': tamanoBytes,
        if (descripcion != null) 'descripcion': descripcion,
      });
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Filtros
  // ─────────────────────────────────────────────
  void setFiltroEstado(String? estado) {
    _filtroEstado = estado;
    notifyListeners();
  }

  void setFiltroArea(String? area) {
    _filtroArea = area;
    notifyListeners();
  }

  void limpiarFiltros() {
    _filtroEstado = null;
    _filtroArea = null;
    notifyListeners();
  }

  void limpiarDetalle() {
    _reporteDetalle = null;
  }

  // ─────────────────────────────────────────────
  // Estadísticas rápidas
  // ─────────────────────────────────────────────
  Map<String, int> get estadisticas {
    final stats = <String, int>{};
    for (final r in _reportes) {
      final estado = r.codigoEstado;
      stats[estado] = (stats[estado] ?? 0) + 1;
    }
    return stats;
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
