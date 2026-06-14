/// Modelo de Comentario.
///
/// Mapea la tabla `comentarios`. Tipos:
/// - publico: visible para todos
/// - interno: solo funcionarios/admin
/// - respuesta_oficial: respuesta formal del municipio
class Comentario {
  final String idComentario;
  final String? reporteId;
  final String? usuarioId;
  final String texto;
  final String tipo; // 'publico', 'interno', 'respuesta_oficial'
  final String? padreId;
  final DateTime? fecha;
  final Map<String, dynamic>? usuario;

  Comentario({
    required this.idComentario,
    this.reporteId,
    this.usuarioId,
    required this.texto,
    required this.tipo,
    this.padreId,
    this.fecha,
    this.usuario,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      idComentario: json['id_comentario'] ?? '',
      reporteId: json['reporte_id'],
      usuarioId: json['usuario_id'],
      texto: json['texto'] ?? '',
      tipo: json['tipo'] ?? 'publico',
      padreId: json['padre_id'],
      fecha: json['fecha'] != null ? DateTime.tryParse(json['fecha']) : null,
      usuario:
          json['usuarios'] is Map<String, dynamic> ? json['usuarios'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'reporte_id': reporteId,
        'texto': texto,
        'tipo': tipo,
        'padre_id': padreId,
      };

  /// Nombre del autor del comentario.
  String get nombreUsuario => usuario?['nombre'] ?? 'Usuario';

  /// Rol del autor.
  String get rolUsuario => usuario?['rol'] ?? 'ciudadano';

  bool get esPublico => tipo == 'publico';
  bool get esInterno => tipo == 'interno';
  bool get esRespuestaOficial => tipo == 'respuesta_oficial';

  /// ¿Es una respuesta a otro comentario?
  bool get esRespuesta => padreId != null;
}
