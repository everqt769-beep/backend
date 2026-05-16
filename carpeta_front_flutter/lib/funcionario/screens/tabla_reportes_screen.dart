import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/reportes_provider.dart';
import '../../models/reporte.dart';
import '../../shared/widgets/estado_badge.dart';
import '../../shared/widgets/loading_widget.dart';
import 'detalle_reporte_funcionario_screen.dart';

/// Tabla de reportes para el funcionario con filtros y búsqueda.
class TablaReportesScreen extends StatefulWidget {
  const TablaReportesScreen({super.key});
  @override
  State<TablaReportesScreen> createState() => _TablaReportesScreenState();
}

class _TablaReportesScreenState extends State<TablaReportesScreen> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportesProvider>();
    var reportes = provider.reportes;
    if (_busqueda.isNotEmpty) {
      reportes = reportes.where((r) =>
          r.descripcion.toLowerCase().contains(_busqueda.toLowerCase()) ||
          r.nombreCategoria.toLowerCase().contains(_busqueda.toLowerCase()) ||
          r.nombreUsuario.toLowerCase().contains(_busqueda.toLowerCase())).toList();
    }

    return Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        color: AppColors.surface.withOpacity(0.8),
        child: Column(children: [
          Row(children: [
            const Text('Gestión de Reportes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const Spacer(),
            Text('${reportes.length} reportes', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(width: 8),
            IconButton(onPressed: () => provider.fetchReportes(), icon: const Icon(Icons.refresh_rounded, color: AppColors.primary)),
          ]),
          const SizedBox(height: 10),
          TextField(
            onChanged: (v) => setState(() => _busqueda = v),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(hintText: 'Buscar...', prefixIcon: const Icon(Icons.search, color: AppColors.textHint, size: 20), filled: true, fillColor: AppColors.surfaceLight, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 10),
          SizedBox(height: 34, child: ListView(scrollDirection: Axis.horizontal, children: [
            _chip('Todos', provider.filtroEstado == null, () => provider.setFiltroEstado(null)),
            _chip('Pendiente', provider.filtroEstado == 'pendiente', () => provider.setFiltroEstado('pendiente'), color: AppColors.pendiente),
            _chip('En Revisión', provider.filtroEstado == 'en_revision', () => provider.setFiltroEstado('en_revision'), color: AppColors.enRevision),
            _chip('En Proceso', provider.filtroEstado == 'en_proceso', () => provider.setFiltroEstado('en_proceso'), color: AppColors.enProceso),
            _chip('Resuelto', provider.filtroEstado == 'resuelto', () => provider.setFiltroEstado('resuelto'), color: AppColors.resuelto),
          ])),
        ]),
      ),
      Expanded(
        child: provider.isLoading
            ? const LoadingWidget()
            : ListView.builder(
                padding: const EdgeInsets.all(12), itemCount: reportes.length,
                itemBuilder: (ctx, i) {
                  final r = reportes[i];
                  final fecha = r.fechaCreacion != null ? DateFormat('dd/MM HH:mm').format(r.fechaCreacion!) : '';
                  final color = AppColors.getEstadoColor(r.codigoEstado);
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetalleReporteFuncionarioScreen(reporteId: r.idReporte))),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: color, width: 3))),
                      child: Row(children: [
                        Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.nombreCategoria, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          Text(r.descripcion, style: const TextStyle(fontSize: 11, color: AppColors.textHint), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ])),
                        const SizedBox(width: 8),
                        Text(r.nombreUsuario, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(width: 8),
                        EstadoBadge(nombre: r.nombreEstado, codigo: r.codigoEstado, fontSize: 10),
                        const SizedBox(width: 8),
                        Text(fecha, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
                        const Icon(Icons.chevron_right, color: AppColors.textHint, size: 18),
                      ]),
                    ),
                  );
                }),
      ),
    ]);
  }

  Widget _chip(String label, bool sel, VoidCallback onTap, {Color? color}) {
    final c = color ?? AppColors.primary;
    return GestureDetector(onTap: onTap, child: Container(
      margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: sel ? c.withOpacity(0.2) : AppColors.surfaceLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: sel ? c : Colors.transparent)),
      child: Text(label, style: TextStyle(fontSize: 11, color: sel ? c : AppColors.textHint, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
    ));
  }
}
