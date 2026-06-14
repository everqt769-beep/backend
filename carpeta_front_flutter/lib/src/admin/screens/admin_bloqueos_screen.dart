import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bloqueos_provider.dart';
import '../../models/bloqueo.dart';
import '../../models/configuracion_bloqueo.dart';

/// Pantalla de gestión de bloqueos para el administrador.
///
/// Muestra: usuarios bloqueados, acciones de bloqueo/desbloqueo,
/// historial, configuración del sistema de auto-bloqueo y estadísticas.
class AdminBloqueosScreen extends StatefulWidget {
  const AdminBloqueosScreen({super.key});

  @override
  State<AdminBloqueosScreen> createState() => _AdminBloqueosScreenState();
}

class _AdminBloqueosScreenState extends State<AdminBloqueosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BloqueosProvider>(context, listen: false);
      provider.cargarUsuariosBloqueados();
      provider.cargarConfiguracion();
      provider.cargarEstadisticas();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        title: const Text('Gestión de Bloqueos'),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF4444),
          labelColor: const Color(0xFFFF4444),
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.block), text: 'Bloqueados'),
            Tab(icon: Icon(Icons.settings), text: 'Configuración'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Estadísticas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBloqueadosTab(),
          _buildConfiguracionTab(),
          _buildEstadisticasTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBloquearDialog(context),
        backgroundColor: const Color(0xFFFF4444),
        icon: const Icon(Icons.person_off, color: Colors.white),
        label: const Text('Bloquear Usuario',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TAB 1: Usuarios Bloqueados
  // ─────────────────────────────────────────────
  Widget _buildBloqueadosTab() {
    return Consumer<BloqueosProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.usuariosBloqueados.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.usuariosBloqueados.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 80, color: Colors.green.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'No hay usuarios bloqueados',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.cargarUsuariosBloqueados(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.usuariosBloqueados.length,
            itemBuilder: (context, index) {
              final bloqueo = provider.usuariosBloqueados[index];
              return _buildBloqueoCard(bloqueo);
            },
          ),
        );
      },
    );
  }

  Widget _buildBloqueoCard(Bloqueo bloqueo) {
    return Card(
      color: const Color(0xFF1A1A2E),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: bloqueo.esPermanente
              ? const Color(0xFFFF4444).withOpacity(0.3)
              : const Color(0xFFFF6B35).withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: nombre + badge tipo
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFFF4444).withOpacity(0.2),
                  child:
                      const Icon(Icons.person_off, color: Color(0xFFFF4444)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bloqueo.nombreUsuario,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        bloqueo.correoUsuario,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bloqueo.tipo == 'automatico_ia'
                        ? const Color(0xFF2196F3).withOpacity(0.2)
                        : const Color(0xFFFF6B35).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    bloqueo.tipoLabel,
                    style: TextStyle(
                      color: bloqueo.tipo == 'automatico_ia'
                          ? const Color(0xFF64B5F6)
                          : const Color(0xFFFF6B35),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Motivo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                bloqueo.motivo,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),

            // Info: strikes + duración
            Row(
              children: [
                _buildInfoChip(
                  Icons.gavel,
                  'Strikes: ${bloqueo.strikesAcumulados}',
                  const Color(0xFFFFB74D),
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.timer,
                  bloqueo.esPermanente
                      ? 'Permanente'
                      : _formatTimeLeft(bloqueo.tiempoRestante),
                  bloqueo.esPermanente
                      ? const Color(0xFFFF4444)
                      : const Color(0xFF81C784),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Acciones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showHistorialDialog(bloqueo.usuarioId),
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('Historial'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF64B5F6),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _confirmarDesbloqueo(bloqueo),
                  icon: const Icon(Icons.lock_open, size: 18,
                      color: Colors.white),
                  label: const Text('Desbloquear',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TAB 2: Configuración
  // ─────────────────────────────────────────────
  Widget _buildConfiguracionTab() {
    return Consumer<BloqueosProvider>(
      builder: (context, provider, _) {
        final config = provider.configuracion;

        if (config == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Auto-bloqueo IA
              _buildConfigCard(
                icon: Icons.smart_toy,
                title: 'Auto-bloqueo por IA',
                subtitle:
                    'Bloquear automáticamente cuando la IA detecte un reporte falso',
                child: Switch(
                  value: config.autoBloqueoIa,
                  activeColor: const Color(0xFF4CAF50),
                  onChanged: (val) {
                    final newConfig = config.copyWith(autoBloqueoIa: val);
                    provider.actualizarConfiguracion(newConfig);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Duración strikes
              _buildConfigCard(
                icon: Icons.timer,
                title: 'Duración de Strikes',
                subtitle: 'Tiempo de bloqueo por cada strike acumulado',
                child: Column(
                  children: [
                    _buildDuracionRow(
                      '1er Strike',
                      '${config.duracionPrimerStrikeHoras}h',
                      const Color(0xFFFFB74D),
                    ),
                    const SizedBox(height: 8),
                    _buildDuracionRow(
                      '2do Strike',
                      '${config.duracionSegundoStrikeHoras}h',
                      const Color(0xFFFF6B35),
                    ),
                    const SizedBox(height: 8),
                    _buildDuracionRow(
                      '3er Strike+',
                      config.tercerStrikeLabel,
                      const Color(0xFFFF4444),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Teléfono de contacto
              _buildConfigCard(
                icon: Icons.phone,
                title: 'Teléfono de Contacto',
                subtitle:
                    'Número que verá el usuario bloqueado para solicitar desbloqueo',
                child: _buildEditableField(
                  config.telefonoContacto,
                  (val) {
                    final newConfig =
                        config.copyWith(telefonoContacto: val);
                    provider.actualizarConfiguracion(newConfig);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Mensaje de bloqueo
              _buildConfigCard(
                icon: Icons.message,
                title: 'Mensaje de Bloqueo',
                subtitle:
                    'Mensaje que se muestra al usuario bloqueado',
                child: _buildEditableField(
                  config.mensajeBloqueo,
                  (val) {
                    final newConfig =
                        config.copyWith(mensajeBloqueo: val);
                    provider.actualizarConfiguracion(newConfig);
                  },
                  maxLines: 3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfigCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF64B5F6), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDuracionRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value,
              style:
                  TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildEditableField(String currentValue, Function(String) onSave,
      {int maxLines = 1}) {
    return InkWell(
      onTap: () async {
        final controller = TextEditingController(text: currentValue);
        final result = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: const Text('Editar', style: TextStyle(color: Colors.white)),
            content: TextField(
              controller: controller,
              maxLines: maxLines,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                ),
                child: const Text('Guardar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        if (result != null && result.isNotEmpty) {
          onSave(result);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                currentValue,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.edit, color: Colors.white30, size: 18),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TAB 3: Estadísticas
  // ─────────────────────────────────────────────
  Widget _buildEstadisticasTab() {
    return Consumer<BloqueosProvider>(
      builder: (context, provider, _) {
        final stats = provider.estadisticas;

        if (stats == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Activos',
                      '${stats['total_activos'] ?? 0}',
                      Icons.block,
                      const Color(0xFFFF4444),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Históricos',
                      '${stats['total_historicos'] ?? 0}',
                      Icons.history,
                      const Color(0xFF64B5F6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Este Mes',
                      '${stats['bloqueos_mes'] ?? 0}',
                      Icons.calendar_month,
                      const Color(0xFFFFB74D),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Por IA',
                      '${stats['bloqueos_ia'] ?? 0}',
                      Icons.smart_toy,
                      const Color(0xFF9C27B0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                'Bloqueos Manuales',
                '${stats['bloqueos_manuales'] ?? 0}',
                Icons.person,
                const Color(0xFFFF6B35),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Dialogs
  // ─────────────────────────────────────────────
  void _showBloquearDialog(BuildContext context) {
    final motivoController = TextEditingController();
    final usuarioIdController = TextEditingController();
    int duracionHoras = 24;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Bloquear Usuario',
            style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usuarioIdController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'ID del usuario',
                  labelStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: motivoController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Motivo del bloqueo',
                  labelStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                ),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setDialogState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duración: ${duracionHoras == 0 ? "Permanente" : "${duracionHoras}h"}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Slider(
                        value: duracionHoras.toDouble(),
                        min: 0,
                        max: 720,
                        divisions: 30,
                        activeColor: const Color(0xFFFF4444),
                        label:
                            duracionHoras == 0 ? 'Permanente' : '${duracionHoras}h',
                        onChanged: (val) {
                          setDialogState(() {
                            duracionHoras = val.toInt();
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (usuarioIdController.text.isEmpty ||
                  motivoController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Complete todos los campos')),
                );
                return;
              }
              Navigator.pop(ctx);
              final provider =
                  Provider.of<BloqueosProvider>(context, listen: false);
              final ok = await provider.bloquearUsuario(
                usuarioId: usuarioIdController.text,
                motivo: motivoController.text,
                duracionHoras: duracionHoras > 0 ? duracionHoras : null,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'Usuario bloqueado correctamente'
                        : provider.error ?? 'Error al bloquear'),
                    backgroundColor: ok ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4444),
            ),
            child: const Text('Bloquear',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmarDesbloqueo(Bloqueo bloqueo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Confirmar Desbloqueo',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Desbloquear a ${bloqueo.nombreUsuario}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider =
                  Provider.of<BloqueosProvider>(context, listen: false);
              final ok =
                  await provider.desbloquearUsuario(bloqueo.usuarioId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'Usuario desbloqueado'
                        : provider.error ?? 'Error'),
                    backgroundColor: ok ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Desbloquear',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHistorialDialog(String usuarioId) async {
    final provider = Provider.of<BloqueosProvider>(context, listen: false);
    await provider.cargarHistorial(usuarioId);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Historial de Bloqueos',
            style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Consumer<BloqueosProvider>(
            builder: (context, prov, _) {
              if (prov.historialUsuario.isEmpty) {
                return const Center(
                  child: Text('Sin historial',
                      style: TextStyle(color: Colors.white54)),
                );
              }
              return ListView.builder(
                itemCount: prov.historialUsuario.length,
                itemBuilder: (context, index) {
                  final b = prov.historialUsuario[index];
                  return ListTile(
                    leading: Icon(
                      b.activo ? Icons.block : Icons.check_circle,
                      color: b.activo ? Colors.red : Colors.green,
                    ),
                    title: Text(b.motivo,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13)),
                    subtitle: Text(
                      '${b.tipoLabel} • Strike #${b.strikesAcumulados} • ${b.fechaBloqueo.toString().substring(0, 16)}',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                    ),
                  );
                },
              );
            },
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
  String _formatTimeLeft(Duration? d) {
    if (d == null) return 'Permanente';
    if (d.inSeconds <= 0) return 'Expirado';
    if (d.inHours > 24) {
      return '${d.inHours ~/ 24}d ${d.inHours % 24}h';
    }
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
  }
}
