
import 'package:flutter/material.dart';
import 'package:myapp/src/models/analisis_ia.dart';
import '../utils/color_utils.dart';


/// Modelo para el estado de un reporte (original o actual) dentro del historial.
class EstadoHistorial {
  final String nombre;
  final Color color;

  EstadoHistorial({required this.nombre, required this.color});

  factory EstadoHistorial.fromJson(Map<String, dynamic> json) {
    return EstadoHistorial(
      nombre: json['nombre'] ?? 'N/A',
      color: ColorUtils.hexToColor(json['color'] ?? '#ffffff'),
    );
  }
}

/// Modelo para la categoría de un reporte (original o actual) dentro del historial.
class CategoriaHistorial {
  final String nombre;

  CategoriaHistorial({required this.nombre});

  factory CategoriaHistorial.fromJson(Map<String, dynamic> json) {
    return CategoriaHistorial(
      nombre: json['nombre'] ?? 'N/A',
    );
  }
}

/// Modelo para la versión actual del reporte, anidado en la respuesta del historial.
class ReporteActualHistorial {
  final String idReporte;
  final String descripcion;
  final CategoriaHistorial categoria;
  final EstadoHistorial estado;
  final AnalisisIA? analisisIa; // Ahora contiene el análisis completo de la IA.

  ReporteActualHistorial({
    required this.idReporte,
    required this.descripcion,
    required this.categoria,
    required this.estado,
    this.analisisIa, // Es opcional, por si algún reporte no lo tuviera.
  });

  factory ReporteActualHistorial.fromJson(Map<String, dynamic> json) {
    return ReporteActualHistorial(
      idReporte: json['id_reporte'] ?? '',
      descripcion: json['descripcion'] ?? 'Sin descripción.',
      categoria: CategoriaHistorial.fromJson(json['categorias'] ?? {}),
      estado: EstadoHistorial.fromJson(json['estados'] ?? {}),
      // Mapeamos el nuevo objeto anidado 'analisis_ia'
      analisisIa: json['analisis_ia'] != null
          ? AnalisisIA.fromJson(json['analisis_ia'])
          : null,
    );
  }
}


/// Modelo principal para un registro en el historial de análisis de IA.
class ReporteHistorial {
  final String idHistorial;
  final String reporteId;
  final DateTime fechaModificacion;
  
  final ReporteActualHistorial reporteActual;
  final CategoriaHistorial categoriaOriginal;
  final EstadoHistorial estadoOriginal;

  ReporteHistorial({
    required this.idHistorial,
    required this.reporteId,
    required this.fechaModificacion,
    required this.reporteActual,
    required this.categoriaOriginal,
    required this.estadoOriginal,
  });

  factory ReporteHistorial.fromJson(Map<String, dynamic> json) {
    return ReporteHistorial(
      idHistorial: json['id_historial'] ?? '',
      reporteId: json['reporte_id'] ?? '',
      fechaModificacion: json['fecha_modificacion'] != null
          ? DateTime.parse(json['fecha_modificacion'])
          : DateTime.now(),
      
      reporteActual: ReporteActualHistorial.fromJson(json['reporte_actual'] ?? {}),
      categoriaOriginal: CategoriaHistorial.fromJson(json['categoria_original'] ?? {}),
      estadoOriginal: EstadoHistorial.fromJson(json['estado_original'] ?? {}),
    );
  }
}
