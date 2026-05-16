import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/reportes_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalogos_provider.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/estado_badge.dart';
import '../../ciudadano/widgets/timeline_widget.dart';
import '../../ciudadano/widgets/comentarios_widget.dart';
import '../../ciudadano/widgets/adjuntos_widget.dart';

/// Detalle de reporte para funcionario — con acciones de cambio de estado.
class DetalleReporteFuncionarioScreen extends StatefulWidget {
  final String reporteId;
  const DetalleReporteFuncionarioScreen({super.key, required this.reporteId});
  @override
  State<DetalleReporteFuncionarioScreen> createState() => _State();
}

class _State extends State<DetalleReporteFuncionarioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportesProvider>().fetchReporteDetalle(widget.reporteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportesProvider>();
    final auth = context.watch<AuthProvider>();
    final reporte = provider.reporteDetalle;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detalle del Reporte'), backgroundColor: AppColors.surface.withOpacity(0.9)),
      body: provider.isLoading || reporte == null
          ? const LoadingWidget(message: 'Cargando...')
          : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Info card
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: AppColors.cardGradient, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withOpacity(0.1))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(reporte.nombreCategoria, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                    EstadoBadge(nombre: reporte.nombreEstado, codigo: reporte.codigoEstado),
                  ]),
                  const SizedBox(height: 8),
                  Text(reporte.descripcion, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.person_outline, size: 14, color: AppColors.textHint), const SizedBox(width: 4),
                    Text(reporte.nombreUsuario, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                    const SizedBox(width: 16),
                    if (reporte.direccion != null) ...[
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textHint), const SizedBox(width: 4),
                      Flexible(child: Text(reporte.direccion!, style: const TextStyle(fontSize: 12, color: AppColors.textHint), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ]),
                ]),
              ),
              // Acciones funcionario
              const SizedBox(height: 16),
              const Text('Cambiar Estado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _estadoBtn('en_revision', 'En Revisión', AppColors.enRevision, provider),
                _estadoBtn('en_proceso', 'En Proceso', AppColors.enProceso, provider),
                _estadoBtn('resuelto', 'Resuelto', AppColors.resuelto, provider),
                _estadoBtn('rechazado', 'Rechazado', AppColors.rechazado, provider),
              ]),
              const SizedBox(height: 20),
              AdjuntosWidget(adjuntos: reporte.adjuntos ?? []),
              const SizedBox(height: 20),
              TimelineWidget(items: reporte.seguimiento ?? []),
              const SizedBox(height: 20),
              ComentariosWidget(comentarios: reporte.comentarios ?? [], reporteId: reporte.idReporte, rolUsuario: auth.rol),
              const SizedBox(height: 40),
            ])),
    );
  }

  Widget _estadoBtn(String codigo, String label, Color color, ReportesProvider provider) {
    return OutlinedButton(
      onPressed: () => _confirmarCambioEstado(codigo, label, provider),
      style: OutlinedButton.styleFrom(side: BorderSide(color: color), foregroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  void _confirmarCambioEstado(String codigo, String label, ReportesProvider provider) {
    final notaCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Cambiar a "$label"', style: const TextStyle(color: AppColors.textPrimary)),
      content: TextField(controller: notaCtrl, style: const TextStyle(color: AppColors.textPrimary), maxLines: 3, decoration: const InputDecoration(hintText: 'Nota de seguimiento (opcional)')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () async {
          Navigator.pop(ctx);
          await provider.cambiarEstado(reporteId: widget.reporteId, estadoCodigo: codigo, descripcionSeguimiento: notaCtrl.text.isNotEmpty ? notaCtrl.text : null);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Estado cambiado a $label'), backgroundColor: AppColors.success));
        }, child: const Text('Confirmar')),
      ],
    ));
  }
}
