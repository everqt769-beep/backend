import 'package:flutter/material.dart';

/// Paleta de colores de VecinApp.
///
/// Diseño oscuro premium con acentos vibrantes inspirados en
/// los colores de estados del backend.
class AppColors {
  // ── Primarios ────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42D4);

  // ── Secundarios ──────────────────────────────
  static const Color secondary = Color(0xFF00D9A6);
  static const Color secondaryLight = Color(0xFF5EFFD4);
  static const Color secondaryDark = Color(0xFF00A87A);

  // ── Fondo (Dark Theme) ───────────────────────
  static const Color background = Color(0xFF0F0F1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF252542);
  static const Color surfaceCard = Color(0xFF1E1E35);

  // ── Texto ────────────────────────────────────
  static const Color textPrimary = Color(0xFFEAEAF0);
  static const Color textSecondary = Color(0xFF9B9BB4);
  static const Color textHint = Color(0xFF6B6B80);

  // ── Estados del reporte ──────────────────────
  static const Color pendiente = Color(0xFFF59E0B);
  static const Color enRevision = Color(0xFF3B82F6);
  static const Color asignado = Color(0xFF8B5CF6);
  static const Color enProceso = Color(0xFFEC4899);
  static const Color resuelto = Color(0xFF10B981);
  static const Color rechazado = Color(0xFFEF4444);
  static const Color duplicado = Color(0xFF6B7280);

  // ── Utilidades ───────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Gradientes ───────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [background, surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceCard, Color(0xFF16162B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Obtener color de estado desde el código del backend
  static Color getEstadoColor(String? codigo) {
    switch (codigo) {
      case 'pendiente':
        return pendiente;
      case 'en_revision':
        return enRevision;
      case 'asignado':
        return asignado;
      case 'en_proceso':
        return enProceso;
      case 'resuelto':
        return resuelto;
      case 'rechazado':
        return rechazado;
      case 'duplicado':
        return duplicado;
      case 'activo':
        return success;
      case 'bloqueado':
        return error;
      case 'pendiente_mod':
        return pendiente;
      case 'aprobado_mod':
        return success;
      case 'rechazado_mod':
        return error;
      case 'activa':
        return success;
      case 'pausada':
        return warning;
      case 'completada':
        return duplicado;
      default:
        return textSecondary;
    }
  }

  /// Parsear color hex del backend (ej: "#F59E0B")
  static Color fromHex(String? hex) {
    if (hex == null || hex.isEmpty) return textSecondary;
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('FF');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
