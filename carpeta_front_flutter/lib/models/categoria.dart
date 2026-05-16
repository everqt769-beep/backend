import 'area.dart';

/// Modelo de Categoría de reporte.
///
/// Mapea la tabla `categorias` que clasifica los tipos de
/// incidentes y está vinculada a un Área municipal.
class Categoria {
  final String idCategoria;
  final String nombre;
  final String? descripcion;
  final int? prioridadBase;
  final String? areaId;
  final Area? area;

  Categoria({
    required this.idCategoria,
    required this.nombre,
    this.descripcion,
    this.prioridadBase,
    this.areaId,
    this.area,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      idCategoria: json['id_categoria'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      prioridadBase: json['prioridad_base'],
      areaId: json['area_id'],
      area: json['areas'] != null ? Area.fromJson(json['areas']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_categoria': idCategoria,
        'nombre': nombre,
        'descripcion': descripcion,
        'prioridad_base': prioridadBase,
        'area_id': areaId,
      };

  /// Nombre con prioridad visual.
  String get displayName {
    final prio = prioridadBase ?? 3;
    final icon = prio == 1
        ? '🔴'
        : prio == 2
            ? '🟡'
            : '🟢';
    return '$icon $nombre';
  }
}
