import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_provider.dart';

/// Dashboard principal del administrador.
///
/// Muestra: tarjetas de conteos, reportes del día, estadísticas históricas,
/// reportes rechazados con detalle, tendencias y generación de reportes.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _filtroTipo = 'todos';
  DateTimeRange? _rangoFechas;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).cargarTodo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<DashboardProvider>(context, listen: false)
                  .cargarTodo();
            },
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () => provider.cargarTodo(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Tarjetas rápidas ──
                  _buildConteos(provider),
                  const SizedBox(height: 24),

                  // ── Resumen del día ──
                  _buildSeccionTitulo('📋 Reportes de Hoy', Icons.today),
                  const SizedBox(height: 12),
                  _buildResumenDiario(provider),
                  const SizedBox(height: 24),

                  // ── Distribución por estado ──
                  _buildSeccionTitulo(
                      '📊 Distribución por Estado', Icons.pie_chart),
                  const SizedBox(height: 12),
                  _buildDistribucionEstados(provider),
                  const SizedBox(height: 24),

                  // ── Tendencia mensual ──
                  _buildSeccionTitulo(
                      '📈 Tendencia Mensual', Icons.trending_up),
                  const SizedBox(height: 12),
                  _buildTendenciaMensual(provider),
                  const SizedBox(height: 24),

                  // ── Filtros y estadísticas históricas ──
                  _buildSeccionTitulo(
                      '🔍 Estadísticas Históricas', Icons.history),
                  const SizedBox(height: 12),
                  _buildFiltros(provider),
                  const SizedBox(height: 12),
                  _buildEstadisticasHistoricas(provider),
                  const SizedBox(height: 24),

                  // ── Reportes rechazados ──
                  _buildSeccionTitulo(
                      '🚫 Reportes Rechazados', Icons.cancel),
                  const SizedBox(height: 12),
                  _buildReportesRechazados(provider),
                  const SizedBox(height: 24),

                  // ── Generar reporte ──
                  _buildGenerarReporte(provider),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Tarjetas de conteos rápidos
  // ─────────────────────────────────────────────
  Widget _buildConteos(DashboardProvider provider) {
    final c = provider.conteos;
    if (c == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildConteoCard(
                'Reportes Hoy',
                '${c['reportes_hoy'] ?? 0}',
                Icons.today,
                const Color(0xFF2196F3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildConteoCard(
                'Total Reportes',
                '${c['total_reportes'] ?? 0}',
                Icons.assignment,
                const Color(0xFF9C27B0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildConteoCard(
                'Sin Atender',
                '${c['sin_atender'] ?? 0}',
                Icons.pending_actions,
                const Color(0xFFFF9800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildConteoCard(
                'Resueltos',
                '${c['total_resueltos'] ?? 0}',
                Icons.check_circle,
                const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildConteoCard(
                'Rechazados',
                '${c['total_rechazados'] ?? 0}',
                Icons.cancel,
                const Color(0xFFFF4444),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildConteoCard(
                'Tasa Resolución',
                '${c['tasa_resolucion'] ?? 0}%',
                Icons.speed,
                const Color(0xFF00BCD4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildConteoCard(
                'Ciudadanos',
                '${c['total_ciudadanos'] ?? 0}',
                Icons.people,
                const Color(0xFF607D8B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildConteoCard(
                'Bloqueados',
                '${c['usuarios_bloqueados'] ?? 0}',
                Icons.person_off,
                const Color(0xFFFF6B35),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConteoCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Resumen del día
  // ─────────────────────────────────────────────
  Widget _buildResumenDiario(DashboardProvider provider) {
    final resumen = provider.resumenDiario;
    if (resumen == null) {
      return _buildLoadingCard();
    }

    final reportes = resumen['reportes_hoy'] as List? ?? [];

    if (reportes.isEmpty) {
      return _buildEmptyCard('No hay reportes hoy', Icons.inbox);
    }

    return Column(
      children: reportes.take(10).map<Widget>((r) {
        final reporte = r as Map<String, dynamic>;
        final estado = reporte['estados'] as Map<String, dynamic>?;
        final usuario = reporte['usuarios'] as Map<String, dynamic>?;
        final categoria = reporte['categorias'] as Map<String, dynamic>?;
        final colorEstado = _parseColor(estado?['color']);

        return Card(
          color: const Color(0xFF1A1A2E),
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorEstado.withOpacity(0.3)),
          ),
          child: ListTile(
            leading: Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: colorEstado,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            title: Text(
              reporte['descripcion']?.toString().substring(
                      0,
                      (reporte['descripcion']?.toString().length ?? 0) > 60
                          ? 60
                          : reporte['descripcion']?.toString().length ?? 0) ??
                  'Sin descripción',
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${usuario?['nombre'] ?? 'Anónimo'} • ${categoria?['nombre'] ?? 'Sin categoría'}',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorEstado.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                estado?['nombre'] ?? '',
                style: TextStyle(color: colorEstado, fontSize: 11),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────
  // Distribución por estado (barras horizontales)
  // ─────────────────────────────────────────────
  Widget _buildDistribucionEstados(DashboardProvider provider) {
    final resumen = provider.resumenDiario;
    if (resumen == null) return _buildLoadingCard();

    final conteos =
        resumen['conteos_por_estado'] as Map<String, dynamic>? ?? {};

    if (conteos.isEmpty) {
      return _buildEmptyCard('Sin datos de estados', Icons.pie_chart);
    }

    final total = conteos.values
        .fold<int>(0, (sum, v) => sum + ((v as int?) ?? 0));

    final colores = {
      'Pendiente': const Color(0xFFF59E0B),
      'En Revision': const Color(0xFF3B82F6),
      'Asignado': const Color(0xFF8B5CF6),
      'En Proceso': const Color(0xFFEC4899),
      'Resuelto': const Color(0xFF10B981),
      'Rechazado': const Color(0xFFEF4444),
      'Duplicado': const Color(0xFF6B7280),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: conteos.entries.map((e) {
          final porcentaje =
              total > 0 ? ((e.value as int) / total) : 0.0;
          final color = colores[e.key] ?? Colors.grey;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    Text('${e.value} (${(porcentaje * 100).toStringAsFixed(0)}%)',
                        style: TextStyle(color: color, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: porcentaje,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Tendencia mensual
  // ─────────────────────────────────────────────
  Widget _buildTendenciaMensual(DashboardProvider provider) {
    final tendencia = provider.tendenciaMensual;
    if (tendencia == null || tendencia.isEmpty) {
      return _buildEmptyCard('Sin datos de tendencia', Icons.trending_up);
    }

    final sortedKeys = tendencia.keys.toList()..sort();
    final maxTotal = tendencia.values
        .map((v) => (v as Map<String, dynamic>)['total'] as int? ?? 0)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: sortedKeys.map((mes) {
          final data = tendencia[mes] as Map<String, dynamic>;
          final total = data['total'] as int? ?? 0;
          final resueltos = data['resueltos'] as int? ?? 0;
          final rechazados = data['rechazados'] as int? ?? 0;
          final barWidth = maxTotal > 0 ? total / maxTotal : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    mes,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: barWidth,
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2196F3),
                                Color(0xFF1565C0)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '$total',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '✅$resueltos ❌$rechazados',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Filtros de fecha y tipo
  // ─────────────────────────────────────────────
  Widget _buildFiltros(DashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Selector de fechas
          InkWell(
            onTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
                initialDateRange: _rangoFechas,
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFF2196F3),
                        surface: Color(0xFF1A1A2E),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (range != null) {
                setState(() => _rangoFechas = range);
                provider.cargarEstadisticasHistoricas(
                  fechaInicio: DateFormat('yyyy-MM-dd').format(range.start),
                  fechaFin: DateFormat('yyyy-MM-dd').format(range.end),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range,
                      color: Color(0xFF64B5F6), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _rangoFechas != null
                        ? '${DateFormat('dd/MM/yyyy').format(_rangoFechas!.start)} - ${DateFormat('dd/MM/yyyy').format(_rangoFechas!.end)}'
                        : 'Seleccionar rango de fechas (últimos 30 días)',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filtro por tipo
          Row(
            children: [
              _buildFilterChip('Todos', 'todos', provider),
              const SizedBox(width: 8),
              _buildFilterChip('Rechazados', 'rechazados', provider),
              const SizedBox(width: 8),
              _buildFilterChip('Resueltos', 'resueltos', provider),
              const SizedBox(width: 8),
              _buildFilterChip('Pendientes', 'pendientes', provider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, String value, DashboardProvider provider) {
    final selected = _filtroTipo == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _filtroTipo = value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF2196F3).withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? const Color(0xFF2196F3)
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF64B5F6) : Colors.white38,
              fontSize: 11,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Estadísticas históricas
  // ─────────────────────────────────────────────
  Widget _buildEstadisticasHistoricas(DashboardProvider provider) {
    final stats = provider.estadisticasHistoricas;
    if (stats == null) {
      return OutlinedButton.icon(
        onPressed: () => provider.cargarEstadisticasHistoricas(),
        icon: const Icon(Icons.search),
        label: const Text('Cargar estadísticas'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF64B5F6),
        ),
      );
    }

    final totales = stats['totales'] as Map<String, dynamic>? ?? {};
    final tasas = stats['tasas'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Totales
          Row(
            children: [
              Expanded(
                  child: _buildMiniStat(
                      'Total', '${totales['total'] ?? 0}', Colors.white)),
              Expanded(
                  child: _buildMiniStat('Atendidos',
                      '${totales['atendidos'] ?? 0}', Colors.blue)),
              Expanded(
                  child: _buildMiniStat('No atendidos',
                      '${totales['no_atendidos'] ?? 0}', Colors.orange)),
            ],
          ),
          const SizedBox(height: 16),
          // Tasas
          Row(
            children: [
              Expanded(
                  child: _buildMiniStat('Aceptación',
                      '${tasas['tasa_aceptacion'] ?? 0}%', Colors.green)),
              Expanded(
                  child: _buildMiniStat('Rechazo',
                      '${tasas['tasa_rechazo'] ?? 0}%', Colors.red)),
              Expanded(
                  child: _buildMiniStat('Resolución',
                      '${tasas['tasa_resolucion'] ?? 0}%', Colors.cyan)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
            textAlign: TextAlign.center),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Reportes rechazados
  // ─────────────────────────────────────────────
  Widget _buildReportesRechazados(DashboardProvider provider) {
    final data = provider.reportesRechazados;

    return Column(
      children: [
        if (data == null)
          OutlinedButton.icon(
            onPressed: () => provider.cargarReportesRechazados(),
            icon: const Icon(Icons.cancel),
            label: const Text('Ver reportes rechazados'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF4444),
            ),
          )
        else ...[
          Text(
            'Total: ${data['total'] ?? 0} rechazados',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ...((data['reportes'] as List? ?? []).take(10).map((r) {
            final reporte = r as Map<String, dynamic>;
            final ia = reporte['analisis_ia'] as Map<String, dynamic>?;
            final usuario =
                reporte['usuarios'] as Map<String, dynamic>?;

            return Card(
              color: const Color(0xFF1A1A2E),
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                    color: const Color(0xFFFF4444).withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reporte['descripcion']?.toString() ?? '',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 14, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(width: 4),
                        Text(
                          usuario?['nombre'] ?? 'Anónimo',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12),
                        ),
                        const Spacer(),
                        if (ia != null) ...[
                          Icon(Icons.smart_toy,
                              size: 14,
                              color: Colors.blue.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              ia['justificacion'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          })),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Generar reporte exportable
  // ─────────────────────────────────────────────
  Widget _buildGenerarReporte(DashboardProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1565C0).withOpacity(0.2),
            const Color(0xFF0D47A1).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.description, color: Color(0xFF64B5F6), size: 40),
          const SizedBox(height: 12),
          const Text(
            'Generar Reporte',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Exporta un reporte detallado en formato JSON con todos los datos filtrados.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await provider.generarReporte(
                      tipo: _filtroTipo == 'todos' ? null : _filtroTipo,
                      fechaInicio: _rangoFechas != null
                          ? DateFormat('yyyy-MM-dd')
                              .format(_rangoFechas!.start)
                          : null,
                      fechaFin: _rangoFechas != null
                          ? DateFormat('yyyy-MM-dd')
                              .format(_rangoFechas!.end)
                          : null,
                    );
                    if (mounted && provider.reporteGenerado != null) {
                      _showReporteDialog(provider.reporteGenerado!);
                    }
                  },
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: const Text('Generar',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReporteDialog(Map<String, dynamic> reporte) {
    final datos = reporte['datos'] as List? ?? [];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          '${reporte['titulo'] ?? 'Reporte'}\n${reporte['periodo']?['inicio'] ?? ''} - ${reporte['periodo']?['fin'] ?? ''}',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total: ${reporte['total_registros'] ?? 0} registros | Filtro: ${reporte['tipo_filtro'] ?? 'todos'}',
                style:
                    const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: datos.length,
                  itemBuilder: (context, index) {
                    final d = datos[index] as Map<String, dynamic>;
                    return Card(
                      color: Colors.white.withOpacity(0.03),
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          d['descripcion']?.toString() ?? '',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${d['estado'] ?? ''} • ${d['categoria'] ?? ''} • ${d['ciudadano'] ?? ''}',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 10),
                        ),
                        trailing: Text(
                          d['prioridad_ia']?.toString() ?? '',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 10),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  Widget _buildSeccionTitulo(String titulo, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64B5F6), size: 22),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyCard(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, color: Colors.white24, size: 40),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: Colors.white38)),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }
}
