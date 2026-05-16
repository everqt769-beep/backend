import 'estado.dart';
import 'reporte.dart';

/// Modelo de Asignación de reporte a funcionario.
///
/// Mapea la tabla `asignaciones`. Al crear una asignación,
/// el backend cambia automáticamente el estado del reporte a 'asignado'.
class Asignacion {
  final String idAsignacion;
  final String? reporteId;
  final String? funcionarioId;
  final DateTime? fechaAsignacion;
  final String? estadoId;
  final Estado? estado;
  final Reporte? reporte;

  Asignacion({
    required this.idAsignacion,
    this.reporteId,
    this.funcionarioId,
    this.fechaAsignacion,
    this.estadoId,
    this.estado,
    this.reporte,
  });

  factory Asignacion.fromJson(Map<String, dynamic> json) {
    return Asignacion(
      idAsignacion: json['id_asignacion'] ?? '',
      reporteId: json['reporte_id'],
      funcionarioId: json['funcionario_id'],
      fechaAsignacion: json['fecha_asignacion'] != null
          ? DateTime.tryParse(json['fecha_asignacion'])
          : null,
      estadoId: json['estado_id'],
      estado:
          json['estados'] != null ? Estado.fromJson(json['estados']) : null,
      reporte:
          json['reportes'] != null ? Reporte.fromJson(json['reportes']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'reporte_id': reporteId,
        'funcionario_id': funcionarioId,
      };
}
