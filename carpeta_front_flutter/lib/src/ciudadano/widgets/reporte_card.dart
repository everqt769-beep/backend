import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/reporte.dart';
import '../../shared/widgets/estado_badge.dart';

/// Card de reporte para la lista del ciudadano.
///
/// Muestra resumen: categoría, descripción, estado, fecha
/// y dirección con un diseño tipo glassmorphism.
class ReporteCard extends StatelessWidget {
  final Reporte reporte;
  final VoidCallback? onTap;

  const ReporteCard({
    super.key,
    required this.reporte,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fecha = reporte.fechaCreacion != null
        ? DateFormat('dd MMM yyyy · HH:mm', 'es').format(reporte.fechaCreacion!)
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Categoría + Estado ──
            Row(
              children: [
                // Ícono de categoría
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoriaIcon(reporte.nombreCategoria),
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reporte.nombreCategoria,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (reporte.categoria?.area != null)
                        Text(
                          reporte.categoria!.area!.nombre,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                    ],
                  ),
                ),
                EstadoBadge(
                  nombre: reporte.nombreEstado,
                  codigo: reporte.codigoEstado,
                  //colorHex: reporte.colorEstado,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ── Descripción ──
            Text(
              reporte.descripcion,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // ── Footer: Ubicación + Fecha ──
            Row(
              children: [
                if (reporte.direccion != null) ...[
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      reporte.direccion!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
                const Icon(Icons.access_time,
                    size: 13, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  fecha,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoriaIcon(String nombre) {
    final lower = nombre.toLowerCase();
    if (lower.contains('agua') || lower.contains('tuberia') || lower.contains('alcantarillado')) {
      return Icons.water_drop_outlined;
    }
    if (lower.contains('luminaria') || lower.contains('alumbrado') || lower.contains('cable') || lower.contains('poste')) {
      return Icons.lightbulb_outline;
    }
    if (lower.contains('bache') || lower.contains('calle') || lower.contains('hundimiento') || lower.contains('via')) {
      return Icons.warning_amber_rounded;
    }
    if (lower.contains('basura') || lower.contains('escombro') || lower.contains('contenedor')) {
      return Icons.delete_outline;
    }
    if (lower.contains('arbol') || lower.contains('parque') || lower.contains('poda')) {
      return Icons.park_outlined;
    }
    if (lower.contains('semaforo') || lower.contains('señal') || lower.contains('transito')) {
      return Icons.traffic_outlined;
    }
    if (lower.contains('gas') || lower.contains('inundacion') || lower.contains('derrumbe') || lower.contains('emergencia')) {
      return Icons.local_fire_department_outlined;
    }
    if (lower.contains('ambulante') || lower.contains('construccion') || lower.contains('ruido')) {
      return Icons.report_outlined;
    }
    return Icons.report_problem_outlined;
  }
}
