import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../models/adjunto.dart';
import '../../shared/widgets/estado_badge.dart';

/// Widget para mostrar los adjuntos/evidencias de un reporte.
///
/// Muestra imágenes en grid, videos como thumbnails y
/// documentos como ítems en lista con estado de moderación.
class AdjuntosWidget extends StatelessWidget {
  final List<Adjunto> adjuntos;

  const AdjuntosWidget({super.key, required this.adjuntos});

  @override
  Widget build(BuildContext context) {
    if (adjuntos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Icons.attach_file, size: 16, color: AppColors.textHint),
            SizedBox(width: 8),
            Text(
              'Sin evidencia adjunta',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final imagenes = adjuntos.where((a) => a.esImagen).toList();
    final otros = adjuntos.where((a) => !a.esImagen).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evidencia',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        // ── Grid de imágenes ──
        if (imagenes.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imagenes.length,
              itemBuilder: (ctx, i) {
                final img = imagenes[i];
                return GestureDetector(
                  onTap: () => _showFullImage(context, img.url),
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: img.url,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.surfaceLight,
                              child: const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.surfaceLight,
                              child: const Icon(Icons.broken_image,
                                  color: AppColors.textHint),
                            ),
                          ),
                        ),
                        if (img.estadoModeracion != null)
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: EstadoBadge(
                              nombre: img.estadoModeracion!.nombre,
                              codigo: img.estadoModeracion!.codigo,
                              fontSize: 8,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        if (imagenes.isNotEmpty && otros.isNotEmpty)
          const SizedBox(height: 12),
        // ── Lista de videos/documentos ──
        ...otros.map((adj) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    adj.esVideo
                        ? Icons.videocam_outlined
                        : Icons.description_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adj.nombreArchivo ?? 'Archivo',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          adj.tamanoFormateado,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (adj.estadoModeracion != null)
                    EstadoBadge(
                      nombre: adj.estadoModeracion!.nombre,
                      codigo: adj.estadoModeracion!.codigo,
                      fontSize: 9,
                    ),
                ],
              ),
            )),
      ],
    );
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(ctx),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
