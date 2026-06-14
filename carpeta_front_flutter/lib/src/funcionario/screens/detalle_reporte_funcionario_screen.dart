import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/widgets/analisis_ia_card.dart';
import '../../core/constants/app_colors.dart';
import '../../models/reporte.dart';
import '../../providers/reportes_provider.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/estado_badge.dart';
import '../../ciudadano/widgets/timeline_widget.dart';
import '../../ciudadano/widgets/comentarios_widget.dart';
import '../../ciudadano/widgets/adjuntos_widget.dart';
import '../../admin/widgets/asignacion_dialog.dart';

/// Detalle de reporte para funcionario y admin.
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
      debugPrint('DETALLE RECIBIDO ID: ${widget.reporteId}');
    });
  }

  void _mostrarDialogoAsignacion(Reporte reporte) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AsignacionDialog(reporteId: reporte.idReporte);
      },
    ).then((asignado) {
      if (asignado == true) {
        context.read<ReportesProvider>().fetchReporteDetalle(widget.reporteId);
      }
    });
  }

  void _ejecutarAnalisisIA(ReportesProvider provider, Reporte reporte) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Confirmar Análisis'),
        content: const Text(
          'Esto utilizará IA para evaluar el reporte. El resultado puede cambiar la categoría o el estado del mismo. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final analisis = await provider.analizarReporte(
                reporte.idReporte,
              );
              if (mounted) {
                if (analisis != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Análisis de IA completado. Actualizando...',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  await provider.fetchReporteDetalle(widget.reporteId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.error ?? 'Error desconocido al analizar.',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Sí, analizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportesProvider>();
    final auth = context.watch<AuthProvider>();
    final reporte = provider.reporteDetalle;

    final esAdmin = auth.rol == 'admin';
    final puedeAsignar =
        esAdmin &&
        reporte != null &&
        (reporte.codigoEstado == 'pendiente' ||
            reporte.codigoEstado == 'en_revision');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalle del Reporte'),
        backgroundColor: AppColors.surface.withOpacity(0.92),
        elevation: 0.5,
      ),
      body: provider.isLoading && reporte == null
          ? const LoadingWidget(message: 'Cargando...')
          : reporte == null
          ? const Center(child: Text('No se pudo cargar el reporte.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, reporte),
                  const SizedBox(height: 16),

                  if (reporte.analisisIa != null)
                    _buildAnalisisWrapper(context, reporte),

                  const SizedBox(height: 16),

                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Analizar con IA'),
                      onPressed: provider.isLoading
                          ? null
                          : () => _ejecutarAnalisisIA(provider, reporte),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _priorityColor(
                          _prioridadReporte(reporte),
                        ),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  if (!esAdmin) ...[
                    const SizedBox(height: 16),
                    _sectionTitle('Cambiar Estado', Icons.swap_horiz),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _estadoBtn(
                          'en_revision',
                          'En Revisión',
                          AppColors.enRevision,
                          provider,
                          reporte.idReporte,
                        ),
                        _estadoBtn(
                          'en_proceso',
                          'En Proceso',
                          AppColors.enProceso,
                          provider,
                          reporte.idReporte,
                        ),
                        _estadoBtn(
                          'resuelto',
                          'Resuelto',
                          AppColors.resuelto,
                          provider,
                          reporte.idReporte,
                        ),
                        _estadoBtn(
                          'rechazado',
                          'Rechazado',
                          AppColors.rechazado,
                          provider,
                          reporte.idReporte,
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 18),
                  _sectionCard(
                    context,
                    title: 'Adjuntos',
                    icon: Icons.attach_file_rounded,
                    color: Colors.deepPurple,
                    child: AdjuntosWidget(adjuntos: reporte.adjuntos),
                  ),

                  const SizedBox(height: 18),
                  _sectionCard(
                    context,
                    title: 'Seguimiento',
                    icon: Icons.timeline_rounded,
                    color: _priorityColor(_prioridadReporte(reporte)),
                    child: TimelineWidget(items: reporte.seguimientos),
                  ),

                  const SizedBox(height: 18),
                  _sectionCard(
                    context,
                    title: 'Comentarios',
                    icon: Icons.chat_bubble_outline_rounded,
                    color: Colors.teal,
                    child: ComentariosWidget(
                      comentarios: reporte.comentarios,
                      reporteId: reporte.idReporte,
                      rolUsuario: auth.rol,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
      floatingActionButton: puedeAsignar
          ? FloatingActionButton.extended(
              onPressed: () => _mostrarDialogoAsignacion(reporte),
              icon: const Icon(Icons.assignment_ind_outlined),
              label: const Text('Asignar Funcionario'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context, Reporte reporte) {
    final prioridad = _prioridadReporte(reporte);
    final color = _priorityColor(prioridad);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.22), AppColors.surfaceCard],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reporte.nombreCategoria,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              EstadoBadge(
                nombre: reporte.nombreEstado,
                codigo: reporte.codigoEstado,
              ),
            ],
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _priorityChip(prioridad, color),
              _miniInfoChip(
                icon: _priorityIcon(prioridad),
                label: prioridad == 'sin prioridad'
                    ? 'Sin prioridad'
                    : prioridad.toUpperCase(),
                color: color,
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(
            reporte.descripcion,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 14,
                color: AppColors.textHint,
              ),
              const SizedBox(width: 4),
              Text(
                reporte.nombreUsuario,
                style: const TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
              const SizedBox(width: 16),
              if (reporte.direccion != null) ...[
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    reporte.direccion!,
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
        ],
      ),
    );
  }

  Widget _buildAnalisisWrapper(BuildContext context, Reporte reporte) {
    final prioridad = _prioridadReporte(reporte);
    final color = _priorityColor(prioridad);

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AnalisisIACard(analisis: reporte.analisisIa!),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _estadoBtn(
    String codigo,
    String label,
    Color color,
    ReportesProvider provider,
    String reporteId,
  ) {
    return OutlinedButton(
      onPressed: () =>
          _confirmarCambioEstado(codigo, label, provider, reporteId),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        foregroundColor: color,
        backgroundColor: color.withOpacity(0.06),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  void _confirmarCambioEstado(
    String codigo,
    String label,
    ReportesProvider provider,
    String reporteId,
  ) {
    final notaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Cambiar a "$label"',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: notaCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Nota de seguimiento (opcional)',
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.cambiarEstado(
                reporteId: reporteId,
                estadoCodigo: codigo,
                descripcionSeguimiento: notaCtrl.text.isNotEmpty
                    ? notaCtrl.text
                    : null,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Estado cambiado a $label'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Confirmar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
            ),
          ),
        ],
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

  Color _priorityColor(String prioridad) {
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

  IconData _priorityIcon(String prioridad) {
    switch (prioridad) {
      case 'alta':
        return Icons.priority_high_rounded;
      case 'media':
        return Icons.report_problem_rounded;
      case 'baja':
        return Icons.low_priority_rounded;
      default:
        return Icons.auto_awesome;
    }
  }

  Widget _priorityChip(String prioridad, Color color) {
    final label = prioridad == 'sin prioridad'
        ? 'Sin prioridad'
        : prioridad[0].toUpperCase() + prioridad.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_priorityIcon(prioridad), size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
