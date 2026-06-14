import 'area.dart';
import 'estado.dart';

/// Modelo de Usuario.
///
/// Mapea la tabla `usuarios` sincronizada con Supabase Auth.
/// Roles posibles: ciudadano, funcionario, admin.
class Usuario {
  final String idUsuario;
  final String nombre;
  final String correo;
  final String rol;
  final String? areaId;
  final String? telefono;
  final String? estadoId;
  final DateTime? fechaRegistro;
  final Area? area;
  final Estado? estado;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.correo,
    required this.rol,
    this.areaId,
    this.telefono,
    this.estadoId,
    this.fechaRegistro,
    this.area,
    this.estado,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['id_usuario'] ?? '',
      nombre: json['nombre'] ?? '',
      correo: json['correo'] ?? '',
      rol: json['rol'] ?? 'ciudadano',
      areaId: json['area_id'],
      telefono: json['telefono'],
      estadoId: json['estado_id'],
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.tryParse(json['fecha_registro'])
          : null,
      area: json['areas'] != null ? Area.fromJson(json['areas']) : null,
      estado: json['estados'] != null ? Estado.fromJson(json['estados']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_usuario': idUsuario,
        'nombre': nombre,
        'correo': correo,
        'rol': rol,
        'area_id': areaId,
        'telefono': telefono,
      };

  bool get esCiudadano => rol == 'ciudadano';
  bool get esFuncionario => rol == 'funcionario';
  bool get esAdmin => rol == 'admin';
}
