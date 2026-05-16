import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/reportes_provider.dart';
import '../../shared/widgets/loading_widget.dart';

/// Pantalla de auditoría — vista global de actividad reciente (admin).
class AdminAuditoriaScreen extends StatelessWidget {
  const AdminAuditoriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportesProvider>();
    final reportes = provider.reportes;

    return Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        color: AppColors.surface.withOpacity(0.8),
        child: Row(children: [
          const Text('Auditoría', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Spacer(),
          IconButton(onPressed: () => provider.fetchReportes(), icon: const Icon(Icons.refresh_rounded, color: AppColors.primary)),
        ]),
      ),
      // Estadísticas generales
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          _statCard('Total Reportes', '${provider.totalReportes}', AppColors.primary, Icons.description),
          const SizedBox(width: 10),
          _statCard('Pendientes', '${provider.estadisticas['pendiente'] ?? 0}', AppColors.pendiente, Icons.pending),
          const SizedBox(width: 10),
          _statCard('Resueltos', '${provider.estadisticas['resuelto'] ?? 0}', AppColors.resuelto, Icons.check_circle),
          const SizedBox(width: 10),
          _statCard('Rechazados', '${provider.estadisticas['rechazado'] ?? 0}', AppColors.rechazado, Icons.cancel),
        ]),
      ),
      // Actividad reciente
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          const Text('Actividad Reciente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Spacer(),
          Text('${reportes.length} registros', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
        ]),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: provider.isLoading
            ? const LoadingWidget()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: reportes.length,
                itemBuilder: (ctx, i) {
                  final r = reportes[i];
                  final fecha = r.fechaCreacion != null ? DateFormat('dd/MM/yyyy HH:mm').format(r.fechaCreacion!) : '';
                  final color = AppColors.getEstadoColor(r.codigoEstado);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(child: Text('${r.nombreCategoria} — ${r.nombreUsuario}', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                        child: Text(r.nombreEstado, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Text(fecha, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
                    ]),
                  );
                }),
      ),
    ]);
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.15))),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textHint), textAlign: TextAlign.center),
      ]),
    ));
  }
}
