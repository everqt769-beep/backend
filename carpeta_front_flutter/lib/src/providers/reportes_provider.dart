import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/models/seguimiento.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/analisis_ia.dart';
import '../models/asignacion.dart';
import '../models/reporte.dart';
import '../models/reporte_historial.dart';
import '../models/usuario_simple.dart';

class ReportesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Reporte> _reportes = [];
  Reporte? _reporteDetalle;
  List<Asignacion> _asignaciones = [];
  List<UsuarioSimple> _funcionarios = [];
  List<ReporteHistorial> _historial = [];
  AnalisisIA? _analisisIA;

  final String _selectListQuery =
    '*,usuarios(nombre),categorias(*,area:areas(*)),estados(*),analisis_ia(*)';

  bool _isLoading = false;
  String? _error;
  String? _filtroEstado;
  String? _filtroArea;

  Reporte? get reporteDetalle => _reporteDetalle;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get filtroEstado => _filtroEstado;
  String? get filtroArea => _filtroArea;
  List<Asignacion> get asignaciones => _asignaciones;
  List<UsuarioSimple> get funcionarios => _funcionarios;
  List<ReporteHistorial> get historial => _historial;
  AnalisisIA? get analisisIA => _analisisIA;

  List<Reporte> get reportes {
    var lista = List<Reporte>.from(_reportes);

    if (_filtroEstado != null && _filtroEstado!.isNotEmpty) {
      lista = lista.where((r) => r.codigoEstado == _filtroEstado).toList();
    }

    if (_filtroArea != null && _filtroArea!.isNotEmpty) {
      lista = lista.where((r) {
        final nombreArea = r.categoria?.area?.nombre;
        return nombreArea == _filtroArea;
      }).toList();
    }

    return lista;
  }

  int get totalReportes => _reportes.length;

  Future<void> fetchReportes() async {
  _setLoading(true);
  _error = null;

  try {
    _log('GET reportes');
    final result = await _api.get(
      '${ApiConstants.reportes}?select=$_selectListQuery',
    );
    final lista = _asList(result);

    _log('reportes recibidos: ${lista.length}');
    _reportes = lista
        .whereType<Map<String, dynamic>>()
        .map(Reporte.fromJson)
        .toList();
  } catch (e, st) {
    _error = e.toString();
    _log('ERROR fetchReportes: $e');
    _log(st.toString());
  } finally {
    _setLoading(false);
  }
}

  Future<void> fetchMisReportes() async {
  _setLoading(true);
  _error = null;

  try {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuario no autenticado.');
    }

    _log('GET mis reportes userId=$userId');
    final result = await _api.get(
      '${ApiConstants.reportes}?usuario_id=eq.$userId&select=$_selectListQuery',
    );

    final lista = _asList(result);
    _log('mis reportes recibidos: ${lista.length}');

    _reportes = lista
        .whereType<Map<String, dynamic>>()
        .map(Reporte.fromJson)
        .toList();
  } catch (e, st) {
    _error = e.toString();
    _log('ERROR fetchMisReportes: $e');
    _log(st.toString());
  } finally {
    _setLoading(false);
  }
}

  Future<void> fetchReporteDetalle(String id) async {
    _setLoading(true);
    _error = null;

    try {
      _log('GET detalle reporte id=$id');
      final result = await _api.get('${ApiConstants.reportes}/$id');

      final data = _asMap(result);
      if (data == null) {
        throw Exception('La respuesta del detalle no es un objeto válido.');
      }

      _log('detalle keys: ${data.keys.join(', ')}');
      _reporteDetalle = Reporte.fromJson(data);

      await fetchSeguimientoReporte(id);

      _log(
        'detalle cargado => id=${_reporteDetalle?.idReporte}, '
        'adjuntos=${_reporteDetalle?.adjuntos.length}, '
        'comentarios=${_reporteDetalle?.comentarios.length}, '
        'seguimientos=${_reporteDetalle?.seguimientos.length}',
      );
    } catch (e, st) {
      _error = e.toString();
      _reporteDetalle = null;
      _log('ERROR fetchReporteDetalle: $e');
      _log(st.toString());
    } finally {
      _setLoading(false);
    }
  }

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
      final body = <String, dynamic>{
        'categoria_id': categoriaId,
        'descripcion': descripcion,
        if (latitud != null) 'latitud': latitud,
        if (longitud != null) 'longitud': longitud,
        if (direccion != null) 'direccion': direccion,
      };

      _log('POST crear reporte: $body');
      final result = await _api.post(ApiConstants.reportes, body);

      final data = _firstObject(result);
      if (data == null) {
        throw Exception('No se pudo leer el reporte creado.');
      }

      final nuevoReporte = Reporte.fromJson(data);
      _reportes.insert(0, nuevoReporte);

      _log('reporte creado id=${nuevoReporte.idReporte}');
      return nuevoReporte;
    } catch (e, st) {
      _error = e.toString();
      _log('ERROR crearReporte: $e');
      _log(st.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cambiarEstado({
    required String reporteId,
    required String estadoCodigo,
    String? descripcionSeguimiento,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final body = <String, dynamic>{
        'estado_codigo': estadoCodigo,
        if (descripcionSeguimiento != null)
          'descripcion_seguimiento': descripcionSeguimiento,
      };

      _log('PATCH cambiar estado reporteId=$reporteId body=$body');
      await _api.patch('${ApiConstants.reportes}/$reporteId/estado', body);

      await fetchReportes();

      if (_reporteDetalle?.idReporte == reporteId) {
        await fetchReporteDetalle(reporteId);
      }

      return true;
    } catch (e, st) {
      _error = e.toString();
      _log('ERROR cambiarEstado: $e');
      _log(st.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

 Future<void> fetchSeguimientoReporte(String reporteId) async {
  try {
    _log('GET seguimiento reporteId=$reporteId');

    final result = await _api.get(
      '${ApiConstants.seguimiento}/reporte/$reporteId',
    );

    final lista = _asList(result);

    final seguimientos = lista
        .whereType<Map<String, dynamic>>()
        .map((json) => Seguimiento.fromJson(json))
        .toList();

    _log('seguimientos recibidos: ${seguimientos.length}');

    if (_reporteDetalle != null && _reporteDetalle!.idReporte == reporteId) {
      _reporteDetalle = Reporte(
        idReporte: _reporteDetalle!.idReporte,
        usuarioId: _reporteDetalle!.usuarioId,
        categoriaId: _reporteDetalle!.categoriaId,
        descripcion: _reporteDetalle!.descripcion,
        latitud: _reporteDetalle!.latitud,
        longitud: _reporteDetalle!.longitud,
        direccion: _reporteDetalle!.direccion,
        estadoId: _reporteDetalle!.estadoId,
        fechaCreacion: _reporteDetalle!.fechaCreacion,
        usuario: _reporteDetalle!.usuario,
        categoria: _reporteDetalle!.categoria,
        estado: _reporteDetalle!.estado,
        adjuntos: _reporteDetalle!.adjuntos,
        comentarios: _reporteDetalle!.comentarios,
        seguimientos: seguimientos,
        analisisIa: _reporteDetalle!.analisisIa,
      );
      notifyListeners();
    }
  } catch (e, st) {
    _log('ERROR fetchSeguimientoReporte: $e');
    _log(st.toString());
  }
}

  Future<AnalisisIA?> analizarReporte(String reporteId) async {
    _setLoading(true);
    _error = null;

    try {
      final url = '${ApiConstants.reportes}/$reporteId/analizar';
      _log('POST analizar reporte id=$reporteId');

      final result = await _api.post(url, {});
      final data = _asMap(result);

      if (data == null) {
        throw Exception('La respuesta del análisis no es válida.');
      }

      _log('respuesta analizar keys: ${data.keys.join(', ')}');

      final analisisRaw = data['analisis_ia'] ?? data['analisisIa'] ?? data;
      _analisisIA = AnalisisIA.fromJson(_asMap(analisisRaw) ?? {});

      await fetchReporteDetalle(reporteId);
      return _analisisIA;
    } catch (e, st) {
      _error = e.toString();
      _log('ERROR analizarReporte: $e');
      _log(st.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchHistorialAnalisis() async {
    _setLoading(true);
    _error = null;

    try {
      _log('GET historial análisis');
      final result = await _api.get(ApiConstants.reportesHistorial);
      final lista = _asList(result);

      _historial = lista
          .whereType<Map<String, dynamic>>()
          .map(ReporteHistorial.fromJson)
          .toList();

      _log('historial recibido: ${_historial.length}');
    } catch (e, st) {
      _error = e.toString();
      _log('ERROR fetchHistorialAnalisis: $e');
      _log(st.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAsignaciones() async {
    _setLoading(true);
    _error = null;

    try {
      _log('GET asignaciones');
      final result = await _api.get(ApiConstants.asignaciones);
      final lista = _asList(result);

      _asignaciones = lista
          .whereType<Map<String, dynamic>>()
          .map(Asignacion.fromJson)
          .toList();

      _log('asignaciones recibidas: ${_asignaciones.length}');
    } catch (e, st) {
      _error = e.toString();
      _log('ERROR fetchAsignaciones: $e');
      _log(st.toString());
    } finally {
      _setLoading(false);
    }
  }

  List<Reporte> get reportesConUbicacion =>
      reportes.where((r) => r.latitud != null && r.longitud != null).toList();

  Future<void> fetchFuncionarios() async {
    _setLoading(true);
    _error = null;

    try {
      _log('GET usuarios');
      final result = await _api.get(ApiConstants.usuarios);
      final lista = _asList(result);

      final usuarios = lista
          .whereType<Map<String, dynamic>>()
          .map(UsuarioSimple.fromJson)
          .toList();

      _funcionarios = usuarios.where((u) {
        final rol = u.rol?.toLowerCase() ?? '';
        return rol.contains('funcionario') || rol.contains('admin');
      }).toList();

      _log('funcionarios filtrados: ${_funcionarios.length}');
    } catch (e, st) {
      _error = e.toString();
      _funcionarios = [];
      _log('ERROR fetchFuncionarios: $e');
      _log(st.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> crearAsignacion({
    required String reporteId,
    required String funcionarioId,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final body = {'reporte_id': reporteId, 'funcionario_id': funcionarioId};

      _log('POST asignación: $body');
      await _api.post(ApiConstants.asignaciones, body);

      await fetchReporteDetalle(reporteId);
      await fetchReportes();

      return true;
    } catch (e, st) {
      _error = e.toString();
      _log('ERROR crearAsignacion: $e');
      _log(st.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> agregarComentario({
    required String reporteId,
    required String texto,
    String tipo = 'publico',
    String? padreId,
  }) async {
    _error = null;

    try {
      final body = <String, dynamic>{
        'reporte_id': reporteId,
        'texto': texto,
        'tipo': tipo,
        if (padreId != null) 'padre_id': padreId,
      };

      _log('POST comentario: $body');
      await _api.post(ApiConstants.comentarios, body);

      if (_reporteDetalle?.idReporte == reporteId) {
        await fetchReporteDetalle(reporteId);
      }

      return true;
    } catch (e, st) {
      _error = e.toString();
      _log('ERROR agregarComentario: $e');
      _log(st.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> registrarAdjunto({
    required String reporteId,
    required String tipo,
    required String url,
    required String nombreArchivo,
    int? tamanoBytes,
    String? descripcion,
  }) async {
    _error = null;

    try {
      final body = <String, dynamic>{
        'reporte_id': reporteId,
        'tipo': tipo,
        'url': url,
        'nombre_archivo': nombreArchivo,
        if (tamanoBytes != null) 'tamano_bytes': tamanoBytes,
        if (descripcion != null) 'descripcion': descripcion,
      };

      _log('POST adjunto: $body');
      await _api.post(ApiConstants.adjuntos, body);

      if (_reporteDetalle?.idReporte == reporteId) {
        await fetchReporteDetalle(reporteId);
      }

      return true;
    } catch (e, st) {
      _error = e.toString();
      _log('ERROR registrarAdjunto: $e');
      _log(st.toString());
      notifyListeners();
      return false;
    }
  }

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
    notifyListeners();
  }

  Map<String, int> get estadisticas {
    final stats = <String, int>{};
    for (final r in _reportes) {
      stats[r.codigoEstado] = (stats[r.codigoEstado] ?? 0) + 1;
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

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[REPORTES_PROVIDER] $message');
    }
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List) return value;
    if (value is Map<String, dynamic>) {
      final data = value['data'];
      if (data is List) return data;

      final results = value['results'];
      if (results is List) return results;

      final items = value['items'];
      if (items is List) return items;

      return [value];
    }
    return [];
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      final data = value['data'];
      if (data is Map<String, dynamic>) return data;
      return value;
    }
    return null;
  }

  Map<String, dynamic>? _firstObject(dynamic value) {
    if (value is Map<String, dynamic>) {
      final data = value['data'];
      if (data is Map<String, dynamic>) return data;
      return value;
    }

    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map<String, dynamic>) return first;
    }

    return null;
  }
}
