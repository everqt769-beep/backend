import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/models/analisis_ia.dart';

class AnalisisIACard extends StatelessWidget {
  final AnalisisIA analisis;

  const AnalisisIACard({super.key, required this.analisis});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final esValidoColor = analisis.esValido
        ? Colors.green[700]
        : Colors.red[700];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Análisis de IA',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Icon(Icons.auto_awesome, color: colorScheme.primary),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              icon: analisis.esValido ? Icons.check_circle : Icons.cancel,
              label: 'Veredicto',
              value: analisis.esValido ? 'Reporte Válido' : 'Reporte Inválido',
              valueColor: esValidoColor,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              icon: Icons.priority_high,
              label: 'Prioridad Sugerida',
              value: analisis.prioridad.toUpperCase(),
              valueColor: _getPrioridadColor(analisis.prioridad),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              icon: Icons.category,
              label: 'Categoría Sugerida',
              value: analisis.categoriaSugerida,
            ),
            if (analisis.justificacion != null &&
                analisis.justificacion!.isNotEmpty) ...[
              const Divider(height: 24),
              _buildJustificacion(context),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Análisis realizado el ${DateFormat('dd/MM/yyyy HH:mm').format(analisis.fechaAnalisis)}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.secondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJustificacion(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lightbulb_outline, color: colorScheme.secondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Justificación de la IA',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  analisis.justificacion!,
                  style: textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPrioridadColor(String prioridad) {
    switch (prioridad.toLowerCase()) {
      case 'alta':
        return Colors.orange.shade800;
      case 'media':
        return Colors.amber.shade700;
      case 'baja':
        return Colors.blue.shade600;
      default:
        return Colors.grey;
    }
  }
}
