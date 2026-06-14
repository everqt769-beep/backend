/// Modelo de Bloqueo de Usuario.
///
/// Mapea la tabla `bloqueos_usuario` de Supabase.
/// Registra cada bloqueo/desbloqueo con su motivo, tipo y strikes.
class Bloqueo {
  final String idBloqueo;
  final String usuarioId;
  final String? reporteId;
  final String motivo;
  final String tipo; // 'manual' | 'automatico_ia'
  final int strikesAcumulados;
  final DateTime fechaBloqueo;
  final DateTime? fechaDesbloqueo;
  final String? desbloqueadoPor;
  final DateTime? fechaDesbloqueado;
  final bool activo;
  final String? notasAdmin;

  // Relaciones
  final Map<String, dynamic>? usuario;
  final Map<String, dynamic>? reporte;
  final Map<String, dynamic>? adminDesbloqueo;

  Bloqueo({
    required this.idBloqueo,
    required this.usuarioId,
    this.reporteId,
    required this.motivo,
    required this.tipo,
    required this.strikesAcumulados,
    required this.fechaBloqueo,
    this.fechaDesbloqueo,
    this.desbloqueadoPor,
    this.fechaDesbloqueado,
    required this.activo,
    this.notasAdmin,
    this.usuario,
    this.reporte,
    this.adminDesbloqueo,
  });

  factory Bloqueo.fromJson(Map<String, dynamic> json) {
    return Bloqueo(
      idBloqueo: json['id_bloqueo'] ?? '',
      usuarioId: json['usuario_id'] ?? '',
      reporteId: json['reporte_id'],
      motivo: json['motivo'] ?? '',
      tipo: json['tipo'] ?? 'manual',
      strikesAcumulados: json['strikes_acumulados'] ?? 1,
      fechaBloqueo: DateTime.tryParse(json['fecha_bloqueo'] ?? '') ?? DateTime.now(),
      fechaDesbloqueo: json['fecha_desbloqueo'] != null
          ? DateTime.tryParse(json['fecha_desbloqueo'])
          : null,
      desbloqueadoPor: json['desbloqueado_por'],
      fechaDesbloqueado: json['fecha_desbloqueado'] != null
          ? DateTime.tryParse(json['fecha_desbloqueado'])
          : null,
      activo: json['activo'] ?? true,
      notasAdmin: json['notas_admin'],
      usuario: json['usuario'] is Map<String, dynamic> ? json['usuario'] : null,
      reporte: json['reporte'] is Map<String, dynamic> ? json['reporte'] : null,
      adminDesbloqueo: json['admin_desbloqueo'] is Map<String, dynamic>
          ? json['admin_desbloqueo']
          : null,
    );
  }

  /// Verifica si el bloqueo es permanente (sin fecha de desbloqueo)
  bool get esPermanente => fechaDesbloqueo == null;

  /// Verifica si el bloqueo ya expiró
  bool get haExpirado =>
      fechaDesbloqueo != null && DateTime.now().isAfter(fechaDesbloqueo!);

  /// Tiempo restante del bloqueo (null si permanente o expirado)
  Duration? get tiempoRestante {
    if (esPermanente || haExpirado) return null;
    return fechaDesbloqueo!.difference(DateTime.now());
  }

  /// Nombre del usuario bloqueado (de la relación)
  String get nombreUsuario => usuario?['nombre'] ?? 'Desconocido';

  /// Correo del usuario bloqueado (de la relación)
  String get correoUsuario => usuario?['correo'] ?? '';

  /// Etiqueta del tipo de bloqueo
  String get tipoLabel => tipo == 'automatico_ia' ? 'IA Automático' : 'Manual';
}
