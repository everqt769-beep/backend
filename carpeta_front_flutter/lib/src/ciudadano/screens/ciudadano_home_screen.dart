import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reportes_provider.dart';
import '../../providers/catalogos_provider.dart';
import 'mis_reportes_screen.dart';
import 'crear_reporte_screen.dart';

/// Home del ciudadano — Dashboard con resumen y navegación.
class CiudadanoHomeScreen extends StatefulWidget {
  const CiudadanoHomeScreen({super.key});

  @override
  State<CiudadanoHomeScreen> createState() => _CiudadanoHomeScreenState();
}

class _CiudadanoHomeScreenState extends State<CiudadanoHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportesProvider>().fetchMisReportes();
      context.read<CatalogosProvider>().cargarTodo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final usuario = auth.usuario;

    final pages = [
      _DashboardTab(
        usuario: usuario,
        onVerTodos: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const MisReportesScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.primary.withOpacity(0.1)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded),
              label: 'Mis Reportes',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CrearReporteScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Reportar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

/// Tab de dashboard con resumen de estadísticas.
class _DashboardTab extends StatelessWidget {
  final dynamic usuario;
  final VoidCallback onVerTodos;

  const _DashboardTab({this.usuario, required this.onVerTodos});

  @override
  Widget build(BuildContext context) {
    final reportes = context.watch<ReportesProvider>();
    final auth = context.watch<AuthProvider>();
    final stats = reportes.estadisticas;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.darkGradient),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, ${usuario?.nombre ?? 'Vecino'} 👋',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tu ciudad, tu voz',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Avatar & logout
                    PopupMenuButton(
                      offset: const Offset(0, 40),
                      color: AppColors.surfaceLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            (usuario?.nombre ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'perfil',
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Mi Perfil',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout,
                                size: 18,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Cerrar Sesión',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (val) {
                        if (val == 'logout') {
                          auth.logout();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            // ── Estadísticas ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatCard(
                          icon: Icons.description_outlined,
                          label: 'Total',
                          value: '${reportes.totalReportes}',
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          icon: Icons.pending_outlined,
                          label: 'Pendientes',
                          value: '${stats['pendiente'] ?? 0}',
                          color: AppColors.pendiente,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          icon: Icons.check_circle_outline,
                          label: 'Resueltos',
                          value: '${stats['resuelto'] ?? 0}',
                          color: AppColors.resuelto,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _StatCard(
                          icon: Icons.engineering_outlined,
                          label: 'En Proceso',
                          value: '${stats['en_proceso'] ?? 0}',
                          color: AppColors.enProceso,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          icon: Icons.assignment_ind_outlined,
                          label: 'Asignados',
                          value: '${stats['asignado'] ?? 0}',
                          color: AppColors.asignado,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          icon: Icons.search,
                          label: 'En Revisión',
                          value: '${stats['en_revision'] ?? 0}',
                          color: AppColors.enRevision,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // ── Últimos reportes ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text(
                      'Últimos Reportes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onVerTodos,
                      child: const Text(
                        'Ver todos',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (reportes.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (reportes.reportes.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 48,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No hay reportes aún',
                        style: TextStyle(color: AppColors.textHint),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '¡Haz tu primer reporte!',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      if (i >= 5) return null; // Mostrar solo 5 últimos
                      final reporte = reportes.reportes[i];
                      return _QuickReporteItem(reporte: reporte);
                    },
                    childCount: reportes.reportes.length > 5
                        ? 5
                        : reportes.reportes.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

/// Card de estadística individual.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Item rápido de reporte para la lista del dashboard.
class _QuickReporteItem extends StatelessWidget {
  final dynamic reporte;

  const _QuickReporteItem({required this.reporte});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getEstadoColor(reporte.codigoEstado);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reporte.nombreCategoria,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  reporte.descripcion,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              reporte.nombreEstado,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
