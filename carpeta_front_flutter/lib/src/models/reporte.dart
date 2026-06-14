// lib/src/models/reporte.dart

import 'package:flutter/material.dart';

import 'analisis_ia.dart';
import 'categoria.dart';
import 'estado.dart';
import 'adjunto.dart';
import 'comentario.dart';
import 'seguimiento.dart';

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

  final Map<String, dynamic>? usuario;
  final Categoria? categoria;
  final Estado? estado;
  final List<Adjunto> adjuntos;
  final List<Comentario> comentarios;
  final List<Seguimiento> seguimientos;
  final AnalisisIA? analisisIa;

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
    required this.adjuntos,
    required this.comentarios,
    required this.seguimientos,
    this.analisisIa,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) {
    final adjuntosRaw = json['adjuntos'] ?? json['reportes_adjuntos'];
    final comentariosRaw = json['comentarios'] ?? json['reportes_comentarios'];
    final seguimientoRaw = json['seguimiento'] ?? json['reportes_seguimiento'];
    final analisisRaw =
        json['analisis_ia'] ?? json['analisisIa'] ?? json['ia_analisis'];

    debugPrint(
      '[REPORTE] analisis_ia type: ${analisisRaw.runtimeType} | value: $analisisRaw',
    );

    // Supabase/PostgREST retorna joins como List, no como Map.
    // Extraemos el primer elemento si es lista.
    dynamic analisisData;
    if (analisisRaw is List) {
      analisisData = analisisRaw.isEmpty ? null : analisisRaw.first;
    } else {
      analisisData = analisisRaw; // null o Map directo (endpoints custom)
    }

    return Reporte(
      idReporte: json['id_reporte']?.toString() ?? '',
      usuarioId: json['usuario_id']?.toString(),
      categoriaId: json['categoria_id']?.toString(),
      descripcion: json['descripcion']?.toString() ?? '',
      latitud: json['latitud'] != null
          ? double.tryParse(json['latitud'].toString())
          : null,
      longitud: json['longitud'] != null
          ? double.tryParse(json['longitud'].toString())
          : null,
      direccion: json['direccion']?.toString(),
      estadoId: json['estado_id']?.toString(),
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'].toString())
          : null,
      usuario: json['usuarios'] is Map<String, dynamic>
          ? json['usuarios']
          : null,
      categoria: json['categorias'] != null
          ? Categoria.fromJson(json['categorias'] as Map<String, dynamic>)
          : null,
      estado: json['estados'] != null
          ? Estado.fromJson(json['estados'] as Map<String, dynamic>)
          : null,
      adjuntos: adjuntosRaw is List
          ? adjuntosRaw
                .whereType<Map<String, dynamic>>()
                .map((a) => Adjunto.fromJson(a))
                .toList()
          : [],
      comentarios: comentariosRaw is List
          ? comentariosRaw
                .whereType<Map<String, dynamic>>()
                .map((c) => Comentario.fromJson(c))
                .toList()
          : [],
      seguimientos: seguimientoRaw is List
          ? seguimientoRaw
                .whereType<Map<String, dynamic>>()
                .map((s) => Seguimiento.fromJson(s))
                .toList()
          : [],
      // Usa analisisData (ya normalizado desde List o Map)
      // sin cast inseguro
      analisisIa: analisisData != null
          ? AnalisisIA.fromJson(analisisData)
          : null,
    );
  }

  /// Convierte el objeto Reporte a Map para serializar a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_reporte': idReporte,
      'usuario_id': usuarioId,
      'categoria_id': categoriaId,
      'descripcion': descripcion,
      'latitud': latitud,
      'longitud': longitud,
      'direccion': direccion,
      'estado_id': estadoId,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'usuario': usuario,
      'categoria': categoria?.toJson(),
      'estado': estado?.toJson(),
      'adjuntos': adjuntos.map((a) => a.toJson()).toList(),
      'comentarios': comentarios.map((c) => c.toJson()).toList(),
      'seguimientos': seguimientos.map((s) => s.toJson()).toList(),
      'analisis_ia': analisisIa?.toJson(),
    };
  }

  String get nombreUsuario => usuario?['nombre']?.toString() ?? 'Anónimo';
  String get nombreCategoria => categoria?.nombre ?? 'Sin categoría';
  String get nombreEstado => estado?.nombre ?? 'Desconocido';
  String get codigoEstado => estado?.codigo ?? 'pendiente';
}
