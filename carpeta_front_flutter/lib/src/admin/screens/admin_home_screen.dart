
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reportes_provider.dart';
import '../../providers/catalogos_provider.dart';
import '../../funcionario/screens/mapa_reportes_screen.dart';
import '../../funcionario/screens/tabla_reportes_screen.dart';
import 'admin_usuarios_screen.dart';
import 'admin_auditoria_screen.dart';
import 'admin_asignaciones_screen.dart';
import 'historial_ia_screen.dart';
import 'admin_bloqueos_screen.dart';
import 'admin_dashboard_screen.dart';

/// Home del Admin — Dashboard completo con sidebar.
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportesProvider>().fetchReportes();
      context.read<CatalogosProvider>().cargarTodo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final reportes = context.watch<ReportesProvider>();
    final stats = reportes.estadisticas;
    final isWide = MediaQuery.of(context).size.width > 800;

    final pages = [
      const MapaReportesScreen(),
      const TablaReportesScreen(),
      const AdminAsignacionesScreen(),
      const HistorialIAScreen(),
      const AdminUsuariosScreen(),
      const AdminAuditoriaScreen(),
      const AdminBloqueosScreen(),
      const AdminDashboardScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(children: [
        if (isWide) Container(width: 250, color: AppColors.surface, child: Column(children: [
          const SizedBox(height: 24),
          Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 22)),
            const SizedBox(width: 10),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('VecinApp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('Panel Admin', style: TextStyle(fontSize: 10, color: AppColors.secondary)),
            ]),
          ])),
          _navItem(Icons.map_rounded, 'Mapa', 0),
          _navItem(Icons.table_chart_rounded, 'Reportes', 1),
          _navItem(Icons.assignment_ind_rounded, 'Asignaciones', 2),
          _navItem(Icons.auto_awesome, 'Historial IA', 3),
          _navItem(Icons.people_rounded, 'Usuarios', 4),
          _navItem(Icons.history_rounded, 'Auditoría', 5),
          _navItem(Icons.shield_rounded, 'Bloqueos', 6),
          _navItem(Icons.dashboard_rounded, 'Dashboard', 7),
          const Divider(color: AppColors.surfaceLight, indent: 16, endIndent: 16),
          Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            _miniStat('Total', '${reportes.totalReportes}', AppColors.primary),
            _miniStat('Pendientes', '${stats['pendiente'] ?? 0}', AppColors.pendiente),
            _miniStat('Resueltos', '${stats['resuelto'] ?? 0}', AppColors.resuelto),
          ])),
          const Spacer(),
          Padding(padding: const EdgeInsets.all(16), child: SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () => auth.logout(),
            icon: const Icon(Icons.logout, size: 16, color: AppColors.error),
            label: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.error, fontSize: 12)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
          ))),
        ])),
        Expanded(child: pages[_currentIndex]),
      ]),
      bottomNavigationBar: isWide ? null : BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.table_chart_rounded), label: 'Reportes'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_ind_rounded), label: 'Asignaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Historial IA'),
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Usuarios'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Auditoría'),
          BottomNavigationBarItem(icon: Icon(Icons.shield_rounded), label: 'Bloqueos'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final sel = _currentIndex == index;
    return GestureDetector(onTap: () => setState(() => _currentIndex = index),
      child: Container(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: sel ? AppColors.primary.withOpacity(0.15) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [Icon(icon, size: 20, color: sel ? AppColors.primary : AppColors.textHint), const SizedBox(width: 10), Text(label, style: TextStyle(fontSize: 14, color: sel ? AppColors.primary : AppColors.textSecondary, fontWeight: sel ? FontWeight.w600 : FontWeight.normal))])));
  }

  Widget _miniStat(String label, String value, Color color) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
    ]));
  }
}
