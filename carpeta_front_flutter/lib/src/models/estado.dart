/// Modelo de Estado — Catálogo universal de estados.
///
/// Mapea la tabla `estados` que contiene estados para:
/// reportes, usuarios, adjuntos y asignaciones.
class Estado {
  final String idEstado;
  final String entidad;
  final String codigo;
  final String nombre;
  final String? color;
  final String? descripcion;

  Estado({
    required this.idEstado,
    required this.entidad,
    required this.codigo,
    required this.nombre,
    this.color,
    this.descripcion,
  });

  factory Estado.fromJson(Map<String, dynamic> json) {
    return Estado(
      idEstado: json['id_estado'] ?? '',
      entidad: json['entidad'] ?? '',
      codigo: json['codigo'] ?? '',
      nombre: json['nombre'] ?? '',
      color: json['color'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id_estado': idEstado,
        'entidad': entidad,
        'codigo': codigo,
        'nombre': nombre,
        'color': color,
        'descripcion': descripcion,
      };
}
