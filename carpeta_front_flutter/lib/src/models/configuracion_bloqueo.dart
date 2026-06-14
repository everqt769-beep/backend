/// Modelo de Configuración del Sistema de Bloqueos.
///
/// Mapea la tabla singleton `configuracion_bloqueos` de Supabase.
/// Contiene todos los parámetros configurables por el admin.
class ConfiguracionBloqueo {
  final int id;
  final bool autoBloqueoIa;
  final int strikesParaBloqueo;
  final int duracionPrimerStrikeHoras;
  final int duracionSegundoStrikeHoras;
  final int duracionTercerStrikeHoras;
  final String telefonoContacto;
  final String mensajeBloqueo;
  final DateTime? updatedAt;

  ConfiguracionBloqueo({
    this.id = 1,
    required this.autoBloqueoIa,
    required this.strikesParaBloqueo,
    required this.duracionPrimerStrikeHoras,
    required this.duracionSegundoStrikeHoras,
    required this.duracionTercerStrikeHoras,
    required this.telefonoContacto,
    required this.mensajeBloqueo,
    this.updatedAt,
  });

  factory ConfiguracionBloqueo.fromJson(Map<String, dynamic> json) {
    return ConfiguracionBloqueo(
      id: json['id'] ?? 1,
      autoBloqueoIa: json['auto_bloqueo_ia'] ?? false,
      strikesParaBloqueo: json['strikes_para_bloqueo'] ?? 1,
      duracionPrimerStrikeHoras: json['duracion_primer_strike_horas'] ?? 24,
      duracionSegundoStrikeHoras: json['duracion_segundo_strike_horas'] ?? 72,
      duracionTercerStrikeHoras: json['duracion_tercer_strike_horas'] ?? 0,
      telefonoContacto: json['telefono_contacto'] ?? '222-0000',
      mensajeBloqueo: json['mensaje_bloqueo'] ?? 'Su cuenta ha sido suspendida.',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'auto_bloqueo_ia': autoBloqueoIa,
        'strikes_para_bloqueo': strikesParaBloqueo,
        'duracion_primer_strike_horas': duracionPrimerStrikeHoras,
        'duracion_segundo_strike_horas': duracionSegundoStrikeHoras,
        'duracion_tercer_strike_horas': duracionTercerStrikeHoras,
        'telefono_contacto': telefonoContacto,
        'mensaje_bloqueo': mensajeBloqueo,
      };

  /// Copia con valores modificados
  ConfiguracionBloqueo copyWith({
    bool? autoBloqueoIa,
    int? strikesParaBloqueo,
    int? duracionPrimerStrikeHoras,
    int? duracionSegundoStrikeHoras,
    int? duracionTercerStrikeHoras,
    String? telefonoContacto,
    String? mensajeBloqueo,
  }) {
    return ConfiguracionBloqueo(
      id: id,
      autoBloqueoIa: autoBloqueoIa ?? this.autoBloqueoIa,
      strikesParaBloqueo: strikesParaBloqueo ?? this.strikesParaBloqueo,
      duracionPrimerStrikeHoras:
          duracionPrimerStrikeHoras ?? this.duracionPrimerStrikeHoras,
      duracionSegundoStrikeHoras:
          duracionSegundoStrikeHoras ?? this.duracionSegundoStrikeHoras,
      duracionTercerStrikeHoras:
          duracionTercerStrikeHoras ?? this.duracionTercerStrikeHoras,
      telefonoContacto: telefonoContacto ?? this.telefonoContacto,
      mensajeBloqueo: mensajeBloqueo ?? this.mensajeBloqueo,
      updatedAt: updatedAt,
    );
  }

  /// Texto descriptivo de la duración del tercer strike
  String get tercerStrikeLabel =>
      duracionTercerStrikeHoras == 0 ? 'Permanente' : '${duracionTercerStrikeHoras}h';
}
