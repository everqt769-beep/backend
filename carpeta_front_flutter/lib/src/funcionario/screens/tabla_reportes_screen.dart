import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../core/constants/app_colors.dart';
import '../../providers/reportes_provider.dart';
import '../../models/reporte.dart';
import '../../shared/widgets/estado_badge.dart';
import '../../shared/widgets/loading_widget.dart';
import 'detalle_reporte_funcionario_screen.dart';

/// Tabla de reportes para el funcionario con filtros, búsqueda y prioridad visual.
class TablaReportesScreen extends StatefulWidget {
  const TablaReportesScreen({super.key});

  @override
  State<TablaReportesScreen> createState() => _TablaReportesScreenState();
}

class _TablaReportesScreenState extends State<TablaReportesScreen> {
  String _busqueda = '';
  String? _estadoFiltro;
  String? _prioridadFiltro;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportesProvider>();

    final reportesFiltrados = _aplicarFiltros(provider.reportes);
    debugPrint('reportes filtrados: ${reportesFiltrados.length}');
    final jsonReportes = jsonEncode(
      reportesFiltrados.map((r) => r.toJson()).toList(),
    );
    debugPrint('Reportes estructura: $jsonReportes');
    //debugPrint('Reportes estructura : ${reportesFiltrados.toString()}');

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          color: AppColors.surface.withOpacity(0.8),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Gestión de Reportes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${reportesFiltrados.length} reportes',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
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
              const SizedBox(height: 10),
              TextField(
                onChanged: (v) => setState(() => _busqueda = v),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _chip(
                      'Todos',
                      _estadoFiltro == null && _prioridadFiltro == null,
                      () => setState(() {
                        _estadoFiltro = null;
                        _prioridadFiltro = null;
                      }),
                    ),
                    
                  ],
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _chip(
                      'Alta',
                      _prioridadFiltro == 'alta',
                      () => setState(() => _prioridadFiltro = 'alta'),
                      color: Colors.redAccent,
                    ),
                    _chip(
                      'Media',
                      _prioridadFiltro == 'media',
                      () => setState(() => _prioridadFiltro = 'media'),
                      color: Colors.orange,
                    ),
                    _chip(
                      'Baja',
                      _prioridadFiltro == 'baja',
                      () => setState(() => _prioridadFiltro = 'baja'),
                      color: Colors.lightBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.isLoading
              ? const LoadingWidget()
              : reportesFiltrados.isEmpty
              ? const Center(
                  child: Text(
                    'No hay reportes con esos filtros.',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: reportesFiltrados.length,
                  itemBuilder: (ctx, i) {
                    final r = reportesFiltrados[i];
                    debugPrint('reporte tabls: $r');
                    debugPrint(
                      'reporte id=${r.idReporte} analisisIa=${r.analisisIa}',
                    );
                    debugPrint(
                      'analisisIa.runtimeType=${r.analisisIa?.runtimeType}',
                    );
                    debugPrint(
                      'analisisIa.prioridad=${r.analisisIa?.prioridad}',
                    );

                    final fecha = r.fechaCreacion != null
                        ? DateFormat('dd/MM HH:mm').format(r.fechaCreacion!)
                        : '';

                    final prioridad = _prioridadReporte(r);
                    final colorPrioridad = _colorPrioridad(prioridad);

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleReporteFuncionarioScreen(
                            reporteId: r.idReporte,
                          ),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorPrioridad.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(color: colorPrioridad, width: 4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          r.nombreCategoria,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      _priorityMiniBadge(
                                        prioridad,
                                        colorPrioridad,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    r.descripcion,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textHint,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              r.nombreUsuario,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            EstadoBadge(
                              nombre: r.nombreEstado,
                              codigo: r.codigoEstado,
                              fontSize: 10,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              fecha,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textHint,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.textHint,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<Reporte> _aplicarFiltros(List<Reporte> reportes) {
    var lista = List<Reporte>.from(reportes);

    if (_estadoFiltro != null && _estadoFiltro!.isNotEmpty) {
      lista = lista.where((r) => r.codigoEstado == _estadoFiltro).toList();
    }

    if (_prioridadFiltro != null && _prioridadFiltro!.isNotEmpty) {
      lista = lista
          .where((r) => _prioridadReporte(r) == _prioridadFiltro)
          .toList();
    }

    if (_busqueda.isNotEmpty) {
      final q = _busqueda.toLowerCase();
      lista = lista.where((r) {
        return r.descripcion.toLowerCase().contains(q) ||
            r.nombreCategoria.toLowerCase().contains(q) ||
            r.nombreUsuario.toLowerCase().contains(q);
      }).toList();
    }

    // Orden: alta -> media -> baja -> sin prioridad
    lista.sort((a, b) {
      final pa = _pesoPrioridad(_prioridadReporte(a));
      final pb = _pesoPrioridad(_prioridadReporte(b));
      if (pa != pb) return pa.compareTo(pb);

      final fa = a.fechaCreacion ?? DateTime.fromMillisecondsSinceEpoch(0);
      final fb = b.fechaCreacion ?? DateTime.fromMillisecondsSinceEpoch(0);
      return fb.compareTo(fa);
    });

    return lista;
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

  int _pesoPrioridad(String prioridad) {
    switch (prioridad) {
      case 'alta':
        return 0;
      case 'media':
        return 1;
      case 'baja':
        return 2;
      default:
        return 3;
    }
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

  Widget _priorityMiniBadge(String prioridad, Color color) {
    final label = prioridad == 'sin prioridad'
        ? 'Sin prioridad'
        : prioridad[0].toUpperCase() + prioridad.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _chip(String label, bool sel, VoidCallback onTap, {Color? color}) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? c.withOpacity(0.2) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? c : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: sel ? c : AppColors.textHint,
            fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
