
import 'reporte.dart';
import 'usuario_simple.dart';

// Modelo para representar una asignación de la base de datos.
class Asignacion {
  final String idAsignacion;
  final DateTime fechaAsignacion;
  final Reporte reporte;
  final UsuarioSimple? funcionario; // Puede ser nulo si no se expande
  final String estado;

  Asignacion({
    required this.idAsignacion,
    required this.fechaAsignacion,
    required this.reporte,
    this.funcionario,
    required this.estado,
  });

  factory Asignacion.fromJson(Map<String, dynamic> json) {
    // El backend devuelve 'reportes' en singular, lo manejamos aquí.
    final reporteData = json['reportes'] ?? json['reporte'];

    return Asignacion(
      idAsignacion: json['id_asignacion'],
      fechaAsignacion: DateTime.parse(json['fecha_asignacion']),
      reporte: Reporte.fromJson(reporteData),
      // Asumimos que la API puede devolver 'funcionarios' o se necesita expandir
      // Por ahora lo dejamos simple. El backend no lo devuelve, lo crearemos.
      funcionario: json['funcionarios'] != null
          ? UsuarioSimple.fromJson(json['funcionarios'])
          : null,
      // Asumimos que el estado viene en un objeto anidado
      estado: json['estados']?['nombre'] ?? 'Desconocido',
    );
  }
}
