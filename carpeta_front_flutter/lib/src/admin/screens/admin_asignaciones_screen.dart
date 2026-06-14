import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reportes_provider.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../core/constants/app_colors.dart';
import '../../models/asignacion.dart';
import '../widgets/asignacion_card.dart';

/// Pantalla para que el administrador vea la lista de todas las asignaciones.
class AdminAsignacionesScreen extends StatefulWidget {
  const AdminAsignacionesScreen({super.key});

  @override
  State<AdminAsignacionesScreen> createState() =>
      _AdminAsignacionesScreenState();
}

class _AdminAsignacionesScreenState extends State<AdminAsignacionesScreen> {
  @override
  void initState() {
    super.initState();
    // Llama a la función para cargar las asignaciones al entrar en la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportesProvider>().fetchAsignaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Asignaciones'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchAsignaciones(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(ReportesProvider provider) {
    if (provider.isLoading) {
      return const LoadingWidget(message: 'Cargando asignaciones...');
    }

    if (provider.asignaciones.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.assignment,
        title: 'No hay asignaciones',
        subtitle: 'Aún no se ha asignado ningún reporte a un funcionario.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchAsignaciones(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: provider.asignaciones.length,
        itemBuilder: (context, index) {
          final asignacion = provider.asignaciones[index];
          // Necesitaremos crear un AsignacionCard para mostrar esto.
          return AsignacionCard(asignacion: asignacion);
        },
      ),
    );
  }
}
