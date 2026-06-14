import 'estado.dart';

/// Modelo de Adjunto (foto, video, documento).
///
/// Mapea la tabla `adjuntos` vinculada a reportes.
class Adjunto {
  final String idAdjunto;
  final String? reporteId;
  final String? usuarioId;
  final String tipo; // 'imagen', 'video', 'documento'
  final String url;
  final String? estadoModeracionId;
  final String? nombreArchivo;
  final int? tamanoBytes;
  final String? descripcion;
  final DateTime? fechaSubida;
  final Estado? estadoModeracion;

  Adjunto({
    required this.idAdjunto,
    this.reporteId,
    this.usuarioId,
    required this.tipo,
    required this.url,
    this.estadoModeracionId,
    this.nombreArchivo,
    this.tamanoBytes,
    this.descripcion,
    this.fechaSubida,
    this.estadoModeracion,
  });

  factory Adjunto.fromJson(Map<String, dynamic> json) {
    return Adjunto(
      idAdjunto: json['id_adjunto'] ?? '',
      reporteId: json['reporte_id'],
      usuarioId: json['usuario_id'],
      tipo: json['tipo'] ?? 'imagen',
      url: json['url'] ?? '',
      estadoModeracionId: json['estado_moderacion_id'],
      nombreArchivo: json['nombre_archivo'],
      tamanoBytes: json['tamano_bytes'] as int?,
      descripcion: json['descripcion'],
      fechaSubida: json['fecha_subida'] != null
          ? DateTime.tryParse(json['fecha_subida'])
          : null,
      estadoModeracion: json['estados'] != null
          ? Estado.fromJson(json['estados'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'reporte_id': reporteId,
        'tipo': tipo,
        'url': url,
        'nombre_archivo': nombreArchivo,
        'tamano_bytes': tamanoBytes,
        'descripcion': descripcion,
      };

  bool get esImagen => tipo == 'imagen';
  bool get esVideo => tipo == 'video';
  bool get esDocumento => tipo == 'documento';

  /// Tamaño formateado (KB, MB).
  String get tamanoFormateado {
    if (tamanoBytes == null) return '';
    if (tamanoBytes! < 1024) return '${tamanoBytes}B';
    if (tamanoBytes! < 1024 * 1024) {
      return '${(tamanoBytes! / 1024).toStringAsFixed(1)}KB';
    }
    return '${(tamanoBytes! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
