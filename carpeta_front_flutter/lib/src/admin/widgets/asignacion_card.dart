
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/asignacion.dart';
import '../../ciudadano/screens/detalle_reporte_screen.dart';

/// Tarjeta para mostrar un resumen de una asignación en una lista.
class AsignacionCard extends StatelessWidget {
  final Asignacion asignacion;

  const AsignacionCard({super.key, required this.asignacion});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.surface,
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navega al detalle del reporte para ver más información.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetalleReporteScreen(
                reporteId: asignacion.reporte.idReporte,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      asignacion.funcionario?.nombre ?? 'Funcionario no especificado',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(asignacion.fechaAsignacion),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Chip(
                  label: Text(asignacion.estado.toUpperCase()),
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
