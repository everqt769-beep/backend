import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bloqueos_provider.dart';

/// Pantalla de bloqueo para ciudadanos suspendidos.
///
/// Se muestra cuando el usuario tiene un bloqueo activo.
/// No permite navegar a ninguna otra pantalla.
/// Solo acción posible: cerrar sesión.
class BloqueadoScreen extends StatefulWidget {
  const BloqueadoScreen({super.key});

  @override
  State<BloqueadoScreen> createState() => _BloqueadoScreenState();
}

class _BloqueadoScreenState extends State<BloqueadoScreen>
    with SingleTickerProviderStateMixin {
  Timer? _countdownTimer;
  Duration _tiempoRestante = Duration.zero;
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _iniciarCountdown();
    });
  }

  void _iniciarCountdown() {
    final bloqueos = Provider.of<BloqueosProvider>(context, listen: false);
    final datos = bloqueos.datosBloqueo;

    if (datos != null && datos['fecha_desbloqueo'] != null) {
      final fechaDesbloqueo = DateTime.tryParse(datos['fecha_desbloqueo']);
      if (fechaDesbloqueo != null) {
        _actualizarTiempo(fechaDesbloqueo);
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          _actualizarTiempo(fechaDesbloqueo);
        });
      }
    }
  }

  void _actualizarTiempo(DateTime fechaDesbloqueo) {
    final ahora = DateTime.now();
    if (fechaDesbloqueo.isAfter(ahora)) {
      setState(() {
        _tiempoRestante = fechaDesbloqueo.difference(ahora);
      });
    } else {
      _countdownTimer?.cancel();
      // El bloqueo expiró, recargar estado
      Provider.of<BloqueosProvider>(context, listen: false)
          .verificarBloqueoActual();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BloqueosProvider>(
      builder: (context, bloqueos, _) {
        final datos = bloqueos.datosBloqueo ?? {};
        final motivo = datos['motivo'] ?? 'Reportes falsos detectados';
        final telefono = datos['telefono_contacto'] ?? '222-0000';
        final mensaje = datos['mensaje_bloqueo'] ??
            'Su cuenta ha sido suspendida.';
        final strikes = datos['strikes_acumulados'] ?? 1;
        final esPermanente = datos['fecha_desbloqueo'] == null;
        final tipo = datos['tipo'] == 'automatico_ia'
            ? 'Detección automática por IA'
            : 'Bloqueo manual por administrador';

        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícono animado de bloqueo
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF4444), Color(0xFFCC0000)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF4444).withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Título
                    const Text(
                      'CUENTA SUSPENDIDA',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFF4444),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mensaje configurable
                    Text(
                      mensaje,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tarjeta de detalles
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFF4444).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetalle(
                            Icons.warning_amber_rounded,
                            'Motivo',
                            motivo,
                            const Color(0xFFFF6B35),
                          ),
                          const Divider(
                            color: Colors.white12,
                            height: 24,
                          ),
                          _buildDetalle(
                            Icons.smart_toy_outlined,
                            'Tipo',
                            tipo,
                            const Color(0xFF64B5F6),
                          ),
                          const Divider(
                            color: Colors.white12,
                            height: 24,
                          ),
                          _buildDetalle(
                            Icons.gavel_rounded,
                            'Strikes acumulados',
                            '$strikes',
                            const Color(0xFFFFB74D),
                          ),
                          const Divider(
                            color: Colors.white12,
                            height: 24,
                          ),

                          // Tiempo restante o permanente
                          if (esPermanente)
                            _buildDetalle(
                              Icons.block,
                              'Duración',
                              'PERMANENTE',
                              const Color(0xFFFF4444),
                            )
                          else
                            _buildDetalle(
                              Icons.timer_outlined,
                              'Tiempo restante',
                              _formatDuration(_tiempoRestante),
                              const Color(0xFF81C784),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tarjeta de contacto
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2196F3).withOpacity(0.15),
                            const Color(0xFF1565C0).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF2196F3).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.phone_in_talk,
                            color: Color(0xFF64B5F6),
                            size: 36,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Para solicitar el desbloqueo, comuníquese con:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            telefono,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64B5F6),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Botón de cerrar sesión
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Provider.of<AuthProvider>(context, listen: false)
                              .logout();
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetalle(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds <= 0) return 'Expirando...';
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 24) {
      final days = hours ~/ 24;
      final remainHours = hours % 24;
      return '${days}d ${remainHours}h ${minutes}m';
    }
    return '${hours}h ${minutes}m ${seconds}s';
  }
}
