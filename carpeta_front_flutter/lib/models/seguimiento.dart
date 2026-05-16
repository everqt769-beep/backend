import 'estado.dart';

/// Modelo de Seguimiento (timeline del reporte).
///
/// Mapea la tabla `seguimiento`. Se genera automáticamente
/// cuando se crea, cambia de estado o asigna un reporte.
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
      idSeguimiento: json['id_seguimiento'] ?? '',
      reporteId: json['reporte_id'],
      usuarioId: json['usuario_id'],
      tipoEvento: json['tipo_evento'],
      descripcion: json['descripcion'],
      estadoNuevoId: json['estado_nuevo_id'],
      fecha: json['fecha'] != null ? DateTime.tryParse(json['fecha']) : null,
      estadoNuevo:
          json['estados'] != null ? Estado.fromJson(json['estados']) : null,
      usuario:
          json['usuarios'] is Map<String, dynamic> ? json['usuarios'] : null,
    );
  }

  /// Nombre del usuario que realizó la acción.
  String get nombreUsuario => usuario?['nombre'] ?? 'Sistema';

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
