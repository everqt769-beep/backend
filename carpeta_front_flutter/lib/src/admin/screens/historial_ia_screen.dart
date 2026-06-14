import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:myapp/src/core/constants/app_colors.dart';
import 'package:myapp/src/models/analisis_ia.dart';
import 'package:myapp/src/models/reporte_historial.dart';
import 'package:myapp/src/shared/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';

import '../../providers/reportes_provider.dart';
import '../../shared/widgets/loading_widget.dart';

class HistorialIAScreen extends StatefulWidget {
  const HistorialIAScreen({super.key});

  @override
  State<HistorialIAScreen> createState() => _HistorialIAScreenState();
}

class _HistorialIAScreenState extends State<HistorialIAScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportesProvider>().fetchHistorialAnalisis();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportesProvider>();
    final historial = provider.historial;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historial de Análisis IA'),
        backgroundColor: AppColors.surface.withOpacity(0.9),
        elevation: 1,
      ),
      body: provider.isLoading
          ? const LoadingWidget(message: 'Cargando historial...')
          : historial.isEmpty
          ? const EmptyStateWidget(
              title: 'No hay registros de cambios por IA todavía.',
              subtitle:
                  'Cuando la IA modifique un reporte, su estado original aparecerá aquí.',
              icon: Icons.history_toggle_off,
            )
          : RefreshIndicator(
              onRefresh: () => provider.fetchHistorialAnalisis(),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: historial.length,
                itemBuilder: (context, index) {
                  return HistorialCard(item: historial[index]);
                },
              ),
            ),
    );
  }
}

class HistorialCard extends StatelessWidget {
  final ReporteHistorial item;

  const HistorialCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final shortId = item.reporteId.split('-').first.toUpperCase();
    final analisis = item.reporteActual.analisisIa;

    final priority = _normalizePriority(analisis?.prioridad);
    final priorityColor = _priorityColor(priority);
    final priorityBg = priorityColor.withOpacity(0.08);
    final priorityBorder = priorityColor.withOpacity(0.28);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: priorityBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  priorityColor.withOpacity(0.16),
                  priorityColor.withOpacity(0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: priorityColor.withOpacity(0.3)),
                  ),
                  child: Icon(
                    _priorityIcon(priority),
                    color: priorityColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REPORTE #$shortId',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Análisis realizado el ${DateFormat('dd/MM/yyyy HH:mm').format(item.fechaModificacion)} Hs',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPriorityChip(priority, priorityColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildChangeColumn(
                    context,
                    title: 'Estado Original',
                    categoria: item.categoriaOriginal.nombre,
                    estado: item.estadoOriginal,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                Expanded(
                  child: _buildChangeColumn(
                    context,
                    title: 'Cambio Aplicado',
                    categoria: item.reporteActual.categoria.nombre,
                    estado: item.reporteActual.estado,
                  ),
                ),
              ],
            ),
          ),
          if (analisis != null) _buildAnalisisSection(context, analisis),
        ],
      ),
    );
  }

  Widget _buildChangeColumn(
    BuildContext context, {
    required String title,
    required String categoria,
    required EstadoHistorial estado,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        const SizedBox(height: 12),
        Text(
          'CATEGORÍA',
          style: textTheme.labelSmall?.copyWith(color: AppColors.textHint),
        ),
        const SizedBox(height: 2),
        Text(
          categoria,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'ESTADO',
          style: textTheme.labelSmall?.copyWith(color: AppColors.textHint),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: estado.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: estado.color.withOpacity(0.8),
              width: 1.2,
            ),
          ),
          child: Text(
            estado.nombre.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: estado.color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalisisSection(BuildContext context, AnalisisIA analisis) {
    final textTheme = Theme.of(context).textTheme;
    final priority = _normalizePriority(analisis.prioridad);
    final priorityColor = _priorityColor(priority);

    return Container(
      width: double.infinity,
      color: priorityColor.withOpacity(0.05),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: priorityColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Dictamen de la IA',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildPriorityChip(priority, priorityColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  analisis.esValido == true
                      ? 'Reporte válido'
                      : 'Reporte marcado como no válido',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            'CATEGORÍA SUGERIDA:',
            style: textTheme.labelSmall?.copyWith(color: AppColors.textHint),
          ),
          const SizedBox(height: 4),
          Text(
            analisis.categoriaSugerida,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'JUSTIFICACIÓN:',
            style: textTheme.labelSmall?.copyWith(color: AppColors.textHint),
          ),
          const SizedBox(height: 4),
          Text(
            analisis.justificacion,
            style: textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String prioridad, Color color) {
    final label = prioridad.toUpperCase();

    return Chip(
      avatar: Icon(_priorityIcon(prioridad), color: color, size: 18),
      label: Text('Prioridad $label'),
      backgroundColor: color.withOpacity(0.1),
      shape: StadiumBorder(
        side: BorderSide(color: color.withOpacity(0.9), width: 1.2),
      ),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }

  String _normalizePriority(String? prioridad) {
    final p = prioridad?.toLowerCase().trim() ?? '';
    if (p.contains('alta')) return 'alta';
    if (p.contains('media')) return 'media';
    if (p.contains('baja')) return 'baja';
    return 'sin prioridad';
  }

  Color _priorityColor(String prioridad) {
    switch (prioridad) {
      case 'alta':
        return AppColors.error;
      case 'media':
        return AppColors.pendiente;
      case 'baja':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  IconData _priorityIcon(String prioridad) {
    switch (_normalizePriority(prioridad)) {
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
}
