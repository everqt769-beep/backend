import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';

import 'package:exif_reader/src/read_exif.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
import '../../models/area.dart';
import '../../models/categoria.dart';
import '../../providers/reportes_provider.dart';
import '../../providers/catalogos_provider.dart';
import 'mapa_selector_screen.dart';

/// Pantalla de creación de nuevo reporte ciudadano.
class CrearReporteScreen extends StatefulWidget {
  const CrearReporteScreen({super.key});

  @override
  State<CrearReporteScreen> createState() => _CrearReporteScreenState();
}

class _CrearReporteScreenState extends State<CrearReporteScreen> {
  final _descripcionCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  String? _areaSeleccionada;
  String? _categoriaSeleccionada;
  double? _latitud;
  double? _longitud;
  final List<XFile> _imagenes = [];
  bool _enviando = false;

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogos = context.watch<CatalogosProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nuevo Reporte'),
        backgroundColor: AppColors.surface.withOpacity(0.9),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Área',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _areaSeleccionada,
              decoration: const InputDecoration(
                hintText: 'Área (opcional)',
                prefixIcon: Icon(
                  Icons.domain,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              dropdownColor: AppColors.surfaceLight,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              items: catalogos.areas
                  .map(
                    (a) => DropdownMenuItem(
                      value: a.idArea,
                      child: Text(a.nombre),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() {
                _areaSeleccionada = val;
                _categoriaSeleccionada = null;
              }),
            ),
            const SizedBox(height: 16),

            if (_areaSeleccionada != null) ...[
              const Text(
                'Categoría',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: const InputDecoration(
                  hintText: 'Categoría (opcional)',
                  prefixIcon: Icon(
                    Icons.category,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                dropdownColor: AppColors.surfaceLight,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                items: catalogos
                    .categoriasPorArea(_areaSeleccionada!)
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.idCategoria,
                        child: Text(c.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (val) =>
                    setState(() => _categoriaSeleccionada = val),
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              'Descripción',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descripcionCtrl,
              maxLines: 4,
              maxLength: 500,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Describe con detalle qué está pasando...',
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Dirección',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _direccionCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Av. Ejemplo #123',
                prefixIcon: Icon(
                  Icons.home_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<Map>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapaSelectorScreen(
                      initialLat: _latitud,
                      initialLng: _longitud,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _latitud = result['lat'];
                    _longitud = result['lng'];
                  });
                }
              },
              icon: Icon(
                _latitud != null ? Icons.check_circle : Icons.map_outlined,
                color: _latitud != null
                    ? AppColors.secondary
                    : AppColors.primary,
              ),
              label: Text(
                _latitud != null
                    ? 'Ubicación: ${_latitud!.toStringAsFixed(4)}, ${_longitud!.toStringAsFixed(4)}'
                    : 'Seleccionar en el Mapa',
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Evidencia',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            if (_imagenes.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _imagenes.map((img) {
                  return Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FutureBuilder<Uint8List>(
                            future: img.readAsBytes(),
                            builder: (c, s) {
                              if (s.hasData) {
                                return Image.memory(s.data!, fit: BoxFit.cover);
                              }
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: GestureDetector(
                          onTap: () => setState(() => _imagenes.remove(img)),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),

            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Cámara'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _enviando ? null : _enviarReporte,
                child: _enviando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Enviar Reporte',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final img = await ImagePicker().pickImage(
      source: source,
      imageQuality: 100,
    );

    if (img == null) return;

    // Primero la agregamos a la vista
    setState(() => _imagenes.add(img));

    // Luego intentamos leer metadatos para mostrar el resultado
    final fecha = await _obtenerFechaImagen(img);

    if (!mounted) return;

  }

  void _showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _leerTextoTag(dynamic tag) {
    if (tag == null) return null;

    try {
      final printable = tag.printable;
      if (printable is String && printable.trim().isNotEmpty) {
        return printable.trim();
      }
    } catch (_) {}

    try {
      final values = tag.values;
      final text = values.toString().trim();
      if (text.isNotEmpty && text != '[]') return text;
    } catch (_) {}

    final text = tag.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;

    return null;
  }

  DateTime? _parseExifDate(String raw) {
    final cleaned = raw.trim();

    final normalized = cleaned.replaceFirstMapped(
      RegExp(r'^(\d{4}):(\d{2}):(\d{2})\s'),
      (m) => '${m[1]}-${m[2]}-${m[3]}T',
    );

    final parsed = DateTime.tryParse(normalized);
    if (parsed != null) return parsed;

    final match = RegExp(
      r'^(\d{4}):(\d{2}):(\d{2})[ T](\d{2}):(\d{2}):(\d{2})',
    ).firstMatch(cleaned);

    if (match != null) {
      return DateTime(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        int.parse(match.group(4)!),
        int.parse(match.group(5)!),
        int.parse(match.group(6)!),
      );
    }

    return null;
  }

  Future<DateTime?> _obtenerFechaImagen(XFile img) async {
    try {
      final bytes = await img.readAsBytes();
      final exif = await readExifFromBytes(bytes);

      final rawCandidates = <String?>[
        _leerTextoTag(exif.tags['EXIF DateTimeOriginal']),
        _leerTextoTag(exif.tags['Image DateTime']),
        _leerTextoTag(exif.tags['EXIF DateTimeDigitized']),
      ];

      for (final raw in rawCandidates) {
        if (raw == null) continue;
        final fecha = _parseExifDate(raw);
        if (fecha != null) return fecha;
      }
    } catch (e) {
      debugPrint('Error leyendo EXIF: $e');
    }

    return null;
  }

  Future<String?> _validarImagenesRecientes() async {
    if (_imagenes.isEmpty) return null;

    final ahora = DateTime.now();

    for (final img in _imagenes) {
      final fecha = await _obtenerFechaImagen(img);

      if (fecha == null) {
        return 'No se pudo verificar la fecha de "${img.name}". '
            'Por favor usa una foto tomada con la cámara.';
      }

      if (ahora.difference(fecha).inDays > 5) {
        return 'La imagen "${img.name}" tiene más de 5 días. '
            'Las imágenes deben ser actuales (máximo 5 días).';
      }
    }

    return null;
  }

  Future<Uint8List> _comprimirImagen(XFile img) async {
    if (kIsWeb) {
      return img.readAsBytes();
    }

    final comprimido = await FlutterImageCompress.compressWithFile(
      img.path,
      quality: 80,
    );

    return comprimido ?? await img.readAsBytes();
  }

  Future<void> _enviarReporte() async {
    if (_descripcionCtrl.text.trim().length < 10) {
      _showMsg(
        'La descripción debe tener al menos 10 caracteres.',
        AppColors.warning,
      );
      return;
    }

    final errorImagenes = await _validarImagenesRecientes();
    if (errorImagenes != null) {
      _showError(errorImagenes);
      return;
    }

    setState(() => _enviando = true);

    final catalogos = context.read<CatalogosProvider>();
    String? areaIdFinal = _areaSeleccionada;
    String? categoriaIdFinal = _categoriaSeleccionada;

    try {
      if (areaIdFinal == null) {
        final areaOtros = catalogos.areas.firstWhere(
          (a) => a.nombre.toLowerCase() == 'otros',
        );
        areaIdFinal = areaOtros.idArea;

        final categoriaOtros = catalogos.categorias.firstWhere(
          (c) => c.areaId == areaIdFinal && c.nombre.toLowerCase() == 'otros',
        );
        categoriaIdFinal = categoriaOtros.idCategoria;
      } else if (categoriaIdFinal == null) {
        final categoriaOtros = catalogos.categorias.firstWhere(
          (c) => c.areaId == areaIdFinal && c.nombre.toLowerCase() == 'otros',
        );
        categoriaIdFinal = categoriaOtros.idCategoria;
      }
    } catch (e) {
      _showError(
        'No se encontró la configuración por defecto de "Otros". '
        'Por favor, contacta a soporte.',
      );
      return;
    }

    final reportes = context.read<ReportesProvider>();
    final nuevoReporte = await reportes.crearReporte(
      categoriaId: categoriaIdFinal!,
      descripcion: _descripcionCtrl.text.trim(),
      latitud: _latitud,
      longitud: _longitud,
      direccion: _direccionCtrl.text.trim().isNotEmpty
          ? _direccionCtrl.text.trim()
          : null,
    );

    if (nuevoReporte == null) {
      _showError(reportes.error ?? 'Ocurrió un error al crear el reporte.');
      return;
    }

    if (_imagenes.isNotEmpty) {
      final storage = StorageService();

      for (final img in _imagenes) {
        try {
          final bytes = await _comprimirImagen(img);

          final url = await storage.uploadImageBytes(
            bytes: bytes,
            reporteId: nuevoReporte.idReporte,
            fileName: img.name,
          );

          await reportes.registrarAdjunto(
            reporteId: nuevoReporte.idReporte,
            tipo: 'imagen',
            url: url,
            nombreArchivo: img.name,
          );
        } catch (e) {
          debugPrint('Error subiendo imagen: $e');
        }
      }
    }

    if (mounted) {
      _showMsg('¡Reporte enviado con éxito! 🎉', AppColors.success);
      Navigator.pop(context);
    }

    setState(() => _enviando = false);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
      setState(() => _enviando = false);
    }
  }

  void _showMsg(String msg, Color color) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
}
