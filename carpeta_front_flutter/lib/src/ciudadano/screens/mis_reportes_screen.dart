import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/reportes_provider.dart';
import '../widgets/reporte_card.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import 'detalle_reporte_screen.dart';
import 'crear_reporte_screen.dart';

/// Lista de reportes del ciudadano con filtros.
class MisReportesScreen extends StatefulWidget {
  const MisReportesScreen({super.key});

  @override
  State<MisReportesScreen> createState() => _MisReportesScreenState();
}

class _MisReportesScreenState extends State<MisReportesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportesProvider>().fetchMisReportes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportes = context.watch<ReportesProvider>();

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.darkGradient),
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text(
                    'Mis Reportes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => reportes.fetchMisReportes(),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Filtros de estado ──
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'Todos',
                    isSelected: reportes.filtroEstado == null,
                    onTap: () => reportes.setFiltroEstado(null),
                  ),
                  _FilterChip(
                    label: 'Pendiente',
                    isSelected: reportes.filtroEstado == 'pendiente',
                    color: AppColors.pendiente,
                    onTap: () => reportes.setFiltroEstado('pendiente'),
                  ),
                  _FilterChip(
                    label: 'En Revisión',
                    isSelected: reportes.filtroEstado == 'en_revision',
                    color: AppColors.enRevision,
                    onTap: () => reportes.setFiltroEstado('en_revision'),
                  ),
                  _FilterChip(
                    label: 'Asignado',
                    isSelected: reportes.filtroEstado == 'asignado',
                    color: AppColors.asignado,
                    onTap: () => reportes.setFiltroEstado('asignado'),
                  ),
                  _FilterChip(
                    label: 'En Proceso',
                    isSelected: reportes.filtroEstado == 'en_proceso',
                    color: AppColors.enProceso,
                    onTap: () => reportes.setFiltroEstado('en_proceso'),
                  ),
                  _FilterChip(
                    label: 'Resuelto',
                    isSelected: reportes.filtroEstado == 'resuelto',
                    color: AppColors.resuelto,
                    onTap: () => reportes.setFiltroEstado('resuelto'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Lista ──
            Expanded(
              child: reportes.isLoading
                  ? const LoadingWidget(message: 'Cargando reportes...')
                  : reportes.reportes.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.description_outlined,
                      title: 'No hay reportes',
                      subtitle: reportes.filtroEstado != null
                          ? 'No tienes reportes con este estado'
                          : 'Haz tu primer reporte para mejorar tu ciudad',
                      buttonText: 'Crear Reporte',
                      onButtonPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CrearReporteScreen(),
                          ),
                        );
                      },
                    )
                  : RefreshIndicator(
                      onRefresh: () => reportes.fetchMisReportes(),
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: reportes.reportes.length,
                        itemBuilder: (ctx, i) {
                          final reporte = reportes.reportes[i];
                          return ReporteCard(
                            reporte: reporte,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetalleReporteScreen(
                                    reporteId: reporte.idReporte,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip de filtro estilizado.
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withOpacity(0.2)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? chipColor : AppColors.textHint,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
