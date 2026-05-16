import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/reportes_provider.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/estado_badge.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/comentarios_widget.dart';
import '../widgets/adjuntos_widget.dart';

/// Pantalla de detalle completo de un reporte.
class DetalleReporteScreen extends StatefulWidget {
  final String reporteId;
  const DetalleReporteScreen({super.key, required this.reporteId});

  @override
  State<DetalleReporteScreen> createState() => _DetalleReporteScreenState();
}

class _DetalleReporteScreenState extends State<DetalleReporteScreen> {
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
      appBar: AppBar(
        title: const Text('Detalle del Reporte'),
        backgroundColor: AppColors.surface.withOpacity(0.9),
        actions: [
          IconButton(
            onPressed: () => provider.fetchReporteDetalle(widget.reporteId),
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: provider.isLoading || reporte == null
          ? const LoadingWidget(message: 'Cargando detalle...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(reporte.nombreCategoria,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            ),
                            EstadoBadge(nombre: reporte.nombreEstado, codigo: reporte.codigoEstado, colorHex: reporte.colorEstado),
                          ],
                        ),
                        if (reporte.categoria?.area != null) ...[
                          const SizedBox(height: 4),
                          Text('Área: ${reporte.categoria!.area!.nombre}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                        ],
                        const SizedBox(height: 12),
                        Text(reporte.descripcion, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
                        const SizedBox(height: 12),
                        // Ubicación y fecha
                        Row(children: [
                          if (reporte.direccion != null) ...[
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textHint),
                            const SizedBox(width: 4),
                            Expanded(child: Text(reporte.direccion!, style: const TextStyle(fontSize: 12, color: AppColors.textHint), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ] else const Spacer(),
                          const Icon(Icons.access_time, size: 13, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(reporte.fechaCreacion != null ? DateFormat('dd MMM yyyy · HH:mm', 'es').format(reporte.fechaCreacion!) : '', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                        ]),
                        // Reportado por
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.person_outline, size: 14, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text('Reportado por: ${reporte.nombreUsuario}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                        ]),
                      ],
                    ),
                  ),
                  // ── Mini mapa ──
                  if (reporte.latitud != null && reporte.longitud != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary.withOpacity(0.1))),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: FlutterMap(
                          options: MapOptions(initialCenter: LatLng(reporte.latitud!, reporte.longitud!), initialZoom: 15, interactionOptions: const InteractionOptions(flags: InteractiveFlag.none)),
                          children: [
                            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.vecinapp.app'),
                            MarkerLayer(markers: [Marker(point: LatLng(reporte.latitud!, reporte.longitud!), width: 40, height: 40, child: const Icon(Icons.location_on, color: AppColors.error, size: 40))]),
                          ],
                        ),
                      ),
                    ),
                  ],
                  // ── Adjuntos ──
                  const SizedBox(height: 20),
                  AdjuntosWidget(adjuntos: reporte.adjuntos ?? []),
                  // ── Timeline ──
                  const SizedBox(height: 20),
                  TimelineWidget(items: reporte.seguimiento ?? []),
                  // ── Comentarios ──
                  const SizedBox(height: 20),
                  ComentariosWidget(
                    comentarios: reporte.comentarios ?? [],
                    reporteId: reporte.idReporte,
                    rolUsuario: auth.rol,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
