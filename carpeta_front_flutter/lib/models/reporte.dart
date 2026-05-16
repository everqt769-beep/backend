import 'categoria.dart';
import 'estado.dart';
import 'adjunto.dart';
import 'comentario.dart';
import 'seguimiento.dart';

/// Modelo de Reporte ciudadano.
///
/// Mapea la tabla `reportes`. Es el modelo central de la app.
/// Cuando se obtiene por ID incluye adjuntos, comentarios y seguimiento.
class Reporte {
  final String idReporte;
  final String? usuarioId;
  final String? categoriaId;
  final String descripcion;
  final double? latitud;
  final double? longitud;
  final String? direccion;
  final String? estadoId;
  final DateTime? fechaCreacion;

  // Relaciones
  final Map<String, dynamic>? usuario;
  final Categoria? categoria;
  final Estado? estado;
  final List<Adjunto>? adjuntos;
  final List<Comentario>? comentarios;
  final List<Seguimiento>? seguimiento;

  Reporte({
    required this.idReporte,
    this.usuarioId,
    this.categoriaId,
    required this.descripcion,
    this.latitud,
    this.longitud,
    this.direccion,
    this.estadoId,
    this.fechaCreacion,
    this.usuario,
    this.categoria,
    this.estado,
    this.adjuntos,
    this.comentarios,
    this.seguimiento,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) {
    return Reporte(
      idReporte: json['id_reporte'] ?? '',
      usuarioId: json['usuario_id'],
      categoriaId: json['categoria_id'],
      descripcion: json['descripcion'] ?? '',
      latitud: json['latitud'] != null
          ? double.tryParse(json['latitud'].toString())
          : null,
      longitud: json['longitud'] != null
          ? double.tryParse(json['longitud'].toString())
          : null,
      direccion: json['direccion'],
      estadoId: json['estado_id'],
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'])
          : null,
      usuario: json['usuarios'] is Map<String, dynamic>
          ? json['usuarios']
          : null,
      categoria: json['categorias'] != null
          ? Categoria.fromJson(json['categorias'])
          : null,
      estado: json['estados'] != null
          ? Estado.fromJson(json['estados'])
          : null,
      adjuntos: json['adjuntos'] != null
          ? (json['adjuntos'] as List)
              .map((a) => Adjunto.fromJson(a))
              .toList()
          : null,
      comentarios: json['comentarios'] != null
          ? (json['comentarios'] as List)
              .map((c) => Comentario.fromJson(c))
              .toList()
          : null,
      seguimiento: json['seguimiento'] != null
          ? (json['seguimiento'] as List)
              .map((s) => Seguimiento.fromJson(s))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'categoria_id': categoriaId,
        'descripcion': descripcion,
        'latitud': latitud,
        'longitud': longitud,
        'direccion': direccion,
      };

  /// Nombre del ciudadano que creó el reporte.
  String get nombreUsuario =>
      usuario?['nombre'] ?? 'Anónimo';

  /// Correo del ciudadano.
  String get correoUsuario =>
      usuario?['correo'] ?? '';

  /// Nombre de la categoría.
  String get nombreCategoria =>
      categoria?.nombre ?? 'Sin categoría';

  /// Nombre del estado actual.
  String get nombreEstado =>
      estado?.nombre ?? 'Desconocido';

  /// Código del estado actual.
  String get codigoEstado =>
      estado?.codigo ?? '';

  /// Color del estado.
  String get colorEstado =>
      estado?.color ?? '#6B7280';
}
