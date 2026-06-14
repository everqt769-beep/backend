// lib/src/models/seguimiento.dart

import 'estado.dart';

/// Modelo de Seguimiento (timeline del reporte).
/// Mapea la tabla `seguimiento`.
class Seguimiento {
  final String idSeguimiento;
  final String? reporteId;
  final String? usuarioId;
  final String? tipoEvento;
  final String? descripcion;
  final String? estadoNuevoId;
  final DateTime? fecha;
  final Estado? estadoNuevo;
  final Map<String, dynamic>? usuario;

  Seguimiento({
    required this.idSeguimiento,
    this.reporteId,
    this.usuarioId,
    this.tipoEvento,
    this.descripcion,
    this.estadoNuevoId,
    this.fecha,
    this.estadoNuevo,
    this.usuario,
  });

  factory Seguimiento.fromJson(Map<String, dynamic> json) {
    return Seguimiento(
      idSeguimiento: json['id_seguimiento']?.toString() ?? '',
      reporteId: json['reporte_id']?.toString(),
      usuarioId: json['usuario_id']?.toString(),
      tipoEvento: json['tipo_evento']?.toString(),
      descripcion: json['descripcion']?.toString(),
      estadoNuevoId: json['estado_nuevo_id']?.toString(),
      fecha: json['fecha'] != null
          ? DateTime.tryParse(json['fecha'].toString())
          : null,
      estadoNuevo: json['estados'] is Map<String, dynamic>
          ? Estado.fromJson(Map<String, dynamic>.from(json['estados']))
          : null,
      usuario: json['usuarios'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['usuarios'])
          : null,
    );
  }

  /// Convierte el objeto Seguimiento a Map para serializar a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_seguimiento': idSeguimiento,
      'reporte_id': reporteId,
      'usuario_id': usuarioId,
      'tipo_evento': tipoEvento,
      'descripcion': descripcion,
      'estado_nuevo_id': estadoNuevoId,
      'fecha': fecha?.toIso8601String(),
      'estados': estadoNuevo?.toJson(),
      'usuarios': usuario,
    };
  }

  /// Nombre del usuario que realizó la acción.
  String get nombreUsuario => usuario?['nombre']?.toString() ?? 'Sistema';

  /// Ícono representativo del evento.
  String get icono {
    switch (tipoEvento) {
      case 'creacion':
        return '📝';
      case 'cambio_estado':
        return '🔄';
      case 'asignacion':
        return '👤';
      default:
        return '📌';
    }
  }
}
