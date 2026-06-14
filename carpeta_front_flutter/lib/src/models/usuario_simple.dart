// Modelo simplificado para representar un usuario en listas.
class UsuarioSimple {
  final String id;
  final String nombre;
  final String email;
  final String? rol; // Rol puede ser útil para mostrarlo en la UI

  UsuarioSimple({
    required this.id,
    required this.nombre,
    required this.email,
    this.rol,
  });

  factory UsuarioSimple.fromJson(Map<String, dynamic> json) {
    return UsuarioSimple(
      id:
          json['id_usuario'] ??
          json['id'], // Compatible con diferentes respuestas
      nombre: json['nombre'] ?? 'Nombre no disponible',
      email: json['email'] ?? 'Email no disponible',
      rol: json['rol'], // Asume anidación de roles
    );
  }
}
