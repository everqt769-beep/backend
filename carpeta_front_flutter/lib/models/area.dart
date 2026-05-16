/// Modelo de Área municipal.
///
/// Mapea la tabla `areas` — departamentos del municipio
/// a los que se asignan categorías y funcionarios.
class Area {
  final String idArea;
  final String nombre;
  final String? descripcion;
  final String? telefono;
  final String? email;

  Area({
    required this.idArea,
    required this.nombre,
    this.descripcion,
    this.telefono,
    this.email,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      idArea: json['id_area'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      telefono: json['telefono'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id_area': idArea,
        'nombre': nombre,
        'descripcion': descripcion,
        'telefono': telefono,
        'email': email,
      };
}
