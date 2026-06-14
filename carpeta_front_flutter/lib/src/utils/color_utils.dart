
import 'package:flutter/material.dart';

/// Utilidades para trabajar con colores.
class ColorUtils {
  /// Convierte un string de color en formato HEX (ej. "#RRGGBB" o "RRGGBB")
  /// a un objeto [Color] de Flutter.
  /// 
  /// Devuelve un color por defecto (blanco) si el string es inválido.
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff'); // Añade el canal alfa si no está presente
    }
    buffer.write(hexString.replaceFirst('#', ''));
    
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.white; // Color por defecto en caso de error
    }
  }
}
