import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Badge visual para mostrar el estado de un reporte/adjunto.
///
/// Usa los colores definidos en el backend y muestra
/// el nombre del estado con un chip estilizado.
class EstadoBadge extends StatelessWidget {
  final String nombre;
  final String? codigo;
  final String? colorHex;
  final double fontSize;

  const EstadoBadge({
    super.key,
    required this.nombre,
    this.codigo,
    this.colorHex,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorHex != null
        ? AppColors.fromHex(colorHex)
        : AppColors.getEstadoColor(codigo);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            nombre,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
