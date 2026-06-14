import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reportes_provider.dart';
import '../../providers/catalogos_provider.dart';
import 'mapa_reportes_screen.dart';
import 'tabla_reportes_screen.dart';

/// Home del Funcionario — Dashboard web con mapa + tabla.
class FuncionarioHomeScreen extends StatefulWidget {
  const FuncionarioHomeScreen({super.key});

  @override
  State<FuncionarioHomeScreen> createState() => _FuncionarioHomeScreenState();
}

class _FuncionarioHomeScreenState extends State<FuncionarioHomeScreen> {
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ── Sidebar (web) ──
          if (isWide)
            Container(
              width: 240,
              color: AppColors.surface,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Text('VecinApp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  _SidebarItem(icon: Icons.map_rounded, label: 'Mapa', isSelected: _currentIndex == 0, onTap: () => setState(() => _currentIndex = 0)),
                  _SidebarItem(icon: Icons.table_chart_rounded, label: 'Reportes', isSelected: _currentIndex == 1, onTap: () => setState(() => _currentIndex = 1)),
                  const Divider(color: AppColors.surfaceLight, indent: 16, endIndent: 16),
                  // Stats rápidos
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      _MiniStat(label: 'Pendientes', value: '${stats['pendiente'] ?? 0}', color: AppColors.pendiente),
                      _MiniStat(label: 'En Proceso', value: '${stats['en_proceso'] ?? 0}', color: AppColors.enProceso),
                      _MiniStat(label: 'Resueltos', value: '${stats['resuelto'] ?? 0}', color: AppColors.resuelto),
                    ]),
                  ),
                  const Spacer(),
                  // Perfil + Logout
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      Row(children: [
                        CircleAvatar(
                          radius: 16, backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: Text((auth.usuario?.nombre ?? 'F')[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(auth.usuario?.nombre ?? 'Funcionario', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const Text('Funcionario', style: TextStyle(fontSize: 10, color: AppColors.textHint)),
                        ])),
                      ]),
                      const SizedBox(height: 8),
                      SizedBox(width: double.infinity, child: OutlinedButton.icon(
                        onPressed: () => auth.logout(),
                        icon: const Icon(Icons.logout, size: 16, color: AppColors.error),
                        label: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.error, fontSize: 12)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), padding: const EdgeInsets.symmetric(vertical: 8)),
                      )),
                    ]),
                  ),
                ],
              ),
            ),
          // ── Contenido principal ──
          Expanded(
            child: _currentIndex == 0
                ? const MapaReportesScreen()
                : const TablaReportesScreen(),
          ),
        ],
      ),
      // Bottom nav para mobile
      bottomNavigationBar: isWide ? null : BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.table_chart_rounded), label: 'Reportes'),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _SidebarItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Icon(icon, size: 20, color: isSelected ? AppColors.primary : AppColors.textHint),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 14, color: isSelected ? AppColors.primary : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
        ]),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}
