import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/reportes_provider.dart';
import '../../models/reporte.dart';
import '../../shared/widgets/estado_badge.dart';
import 'detalle_reporte_funcionario_screen.dart';

/// Mapa principal del funcionario con todos los reportes geolocalizados.
class MapaReportesScreen extends StatelessWidget {
  const MapaReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportesProvider>();
    final reportes = provider.reportesConUbicacion;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          color: AppColors.surface.withOpacity(0.8),
          child: Row(
            children: [
              const Text(
                'Mapa de Reportes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${reportes.length} con ubicación',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => provider.fetchReportes(),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: reportes.isNotEmpty
                        ? LatLng(
                            reportes.first.latitud!,
                            reportes.first.longitud!,
                          )
                        : const LatLng(-16.5, -68.119),
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.vecinapp.app',
                    ),
                    MarkerLayer(
                      markers: reportes.map((r) {
                        final prioridad = _prioridadReporte(r);
                        final color = _colorPrioridad(prioridad);

                        return Marker(
                          point: LatLng(r.latitud!, r.longitud!),
                          width: 46,
                          height: 46,
                          child: GestureDetector(
                            onTap: () => _showReportePopup(context, r),
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.45),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _iconoPrioridad(prioridad),
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  void _showReportePopup(BuildContext context, Reporte r) {
    final prioridad = _prioridadReporte(r);
    final colorPrioridad = _colorPrioridad(prioridad);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    r.nombreCategoria,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                EstadoBadge(nombre: r.nombreEstado, codigo: r.codigoEstado),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _priorityChip(prioridad, colorPrioridad),
                const SizedBox(width: 8),
                Text(
                  'Prioridad del reporte',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorPrioridad,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              r.descripcion,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 14,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  r.nombreUsuario,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
                const Spacer(),
                if (r.direccion != null) ...[
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      r.direccion!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalleReporteFuncionarioScreen(
                        reporteId: r.idReporte,
                      ),
                    ),
                  );
                },
                child: const Text('Ver Detalle Completo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _prioridadReporte(Reporte r) {
    final ia = r.analisisIa?.prioridad?.toLowerCase().trim();
    if (ia != null && ia.isNotEmpty) {
      if (ia.contains('alta')) return 'alta';
      if (ia.contains('media')) return 'media';
      if (ia.contains('baja')) return 'baja';
    }

    final prioridadBase = r.categoria?.prioridadBase;
    if (prioridadBase == null) return 'sin prioridad';

    if (prioridadBase == 1) return 'alta';
    if (prioridadBase == 2) return 'media';
    if (prioridadBase == 3) return 'baja';

    return 'sin prioridad';
  }

  Color _colorPrioridad(String prioridad) {
    switch (prioridad) {
      case 'alta':
        return Colors.redAccent;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.lightBlue;
      default:
        return AppColors.primary;
    }
  }

  IconData _iconoPrioridad(String prioridad) {
    switch (prioridad) {
      case 'alta':
        return Icons.priority_high_rounded;
      case 'media':
        return Icons.report_problem_rounded;
      case 'baja':
        return Icons.low_priority_rounded;
      default:
        return Icons.report_problem_rounded;
    }
  }

  Widget _priorityChip(String prioridad, Color color) {
    final label = prioridad == 'sin prioridad'
        ? 'Sin prioridad'
        : prioridad[0].toUpperCase() + prioridad.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
