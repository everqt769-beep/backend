import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/seguimiento.dart';
import '../../shared/widgets/estado_badge.dart';

/// Widget de Timeline visual para el seguimiento del reporte.
///
/// Muestra una línea de tiempo vertical con los eventos
/// de creación, cambio de estado y asignación.
class TimelineWidget extends StatelessWidget {
  final List<Seguimiento> items;

  const TimelineWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'torial de seguimiento',
          style: TextStyle(color: AppColors.textHint),
        ),
      );
    }

    // Ordenar cronológicamente
    final sorted = List<Seguimiento>.from(items)
      ..sort((a, b) {
        if (a.fecha == null || b.fecha == null) return 0;
        return a.fecha!.compareTo(b.fecha!);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Evolución del Reporte',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ...List.generate(sorted.length, (i) {
          final item = sorted[i];
          final isLast = i == sorted.length - 1;
          final color = item.estadoNuevo != null
              ? AppColors.fromHex(item.estadoNuevo!.color)
              : AppColors.primary;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Línea vertical + Dot ──
                SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: color.withOpacity(0.2),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // ── Contenido del evento ──
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.icono,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _getEventTitle(item.tipoEvento),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (item.estadoNuevo != null)
                              EstadoBadge(
                                nombre: item.estadoNuevo!.nombre,
                                codigo: item.estadoNuevo!.codigo,
                                fontSize: 10,
                              ),
                          ],
                        ),
                        if (item.descripcion != null &&
                            item.descripcion!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            item.descripcion!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 12,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.nombreUsuario,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              item.fecha != null
                                  ? DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(item.fecha!)
                                  : '',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _getEventTitle(String? tipo) {
    switch (tipo) {
      case 'creacion':
        return 'Reporte Creado';
      case 'cambio_estado':
        return 'Cambio de Estado';
      case 'asignacion':
        return 'Asignación de Funcionario';
      default:
        return 'Actualización';
    }
  }
}
