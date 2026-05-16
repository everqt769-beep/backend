import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
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
            // Área
            const Text('Área', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _areaSeleccionada,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.domain, color: AppColors.primary, size: 20)),
              dropdownColor: AppColors.surfaceLight,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              items: catalogos.areas.map((a) => DropdownMenuItem(value: a.idArea, child: Text(a.nombre))).toList(),
              onChanged: (val) => setState(() { _areaSeleccionada = val; _categoriaSeleccionada = null; }),
            ),
            const SizedBox(height: 16),
            // Categoría
            if (_areaSeleccionada != null) ...[
              const Text('Categoría', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.category, color: AppColors.primary, size: 20)),
                dropdownColor: AppColors.surfaceLight,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                items: catalogos.categoriasPorArea(_areaSeleccionada!).map((c) => DropdownMenuItem(value: c.idCategoria, child: Text(c.displayName))).toList(),
                onChanged: (val) => setState(() => _categoriaSeleccionada = val),
              ),
              const SizedBox(height: 16),
            ],
            // Descripción
            const Text('Descripción', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descripcionCtrl, maxLines: 4, maxLength: 500,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Describe con detalle qué está pasando...'),
            ),
            const SizedBox(height: 16),
            // Dirección
            const Text('Dirección', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _direccionCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Av. Ejemplo #123', prefixIcon: Icon(Icons.home_outlined, color: AppColors.primary, size: 20)),
            ),
            const SizedBox(height: 12),
            // Mapa
            OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<Map>(context, MaterialPageRoute(builder: (_) => MapaSelectorScreen(initialLat: _latitud, initialLng: _longitud)));
                if (result != null) setState(() { _latitud = result['lat']; _longitud = result['lng']; });
              },
              icon: Icon(_latitud != null ? Icons.check_circle : Icons.map_outlined, color: _latitud != null ? AppColors.secondary : AppColors.primary),
              label: Text(_latitud != null ? 'Ubicación: ${_latitud!.toStringAsFixed(4)}, ${_longitud!.toStringAsFixed(4)}' : 'Seleccionar en el Mapa'),
            ),
            const SizedBox(height: 16),
            // Evidencia
            const Text('Evidencia', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (_imagenes.isNotEmpty)
              Wrap(spacing: 8, runSpacing: 8, children: _imagenes.map((img) => Stack(children: [
                Container(width: 80, height: 80, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
                  child: ClipRRect(borderRadius: BorderRadius.circular(10), child: kIsWeb ? FutureBuilder<Uint8List>(future: img.readAsBytes(), builder: (c, s) => s.hasData ? Image.memory(s.data!, fit: BoxFit.cover) : const CircularProgressIndicator(strokeWidth: 2)) : Image.file(File(img.path), fit: BoxFit.cover))),
                Positioned(top: -4, right: -4, child: GestureDetector(onTap: () => setState(() => _imagenes.remove(img)), child: Container(width: 22, height: 22, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 14)))),
              ])).toList()),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt_outlined, size: 18), label: const Text('Cámara'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined, size: 18), label: const Text('Galería'))),
            ]),
            const SizedBox(height: 24),
            // Enviar
            SizedBox(height: 50, child: ElevatedButton(
              onPressed: _enviando ? null : _enviarReporte,
              child: _enviando ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Enviar Reporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            )),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final img = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (img != null) setState(() => _imagenes.add(img));
  }

  Future<void> _enviarReporte() async {
    if (_categoriaSeleccionada == null) { _showMsg('Selecciona área y categoría', AppColors.warning); return; }
    if (_descripcionCtrl.text.trim().length < 10) { _showMsg('Describe el problema (mín 10 caracteres)', AppColors.warning); return; }
    setState(() => _enviando = true);
    final reportes = context.read<ReportesProvider>();
    final nuevoReporte = await reportes.crearReporte(categoriaId: _categoriaSeleccionada!, descripcion: _descripcionCtrl.text.trim(), latitud: _latitud, longitud: _longitud, direccion: _direccionCtrl.text.trim().isNotEmpty ? _direccionCtrl.text.trim() : null);
    if (nuevoReporte == null) { setState(() => _enviando = false); _showMsg(reportes.error ?? 'Error', AppColors.error); return; }
    if (_imagenes.isNotEmpty) {
      final storage = StorageService();
      for (final img in _imagenes) {
        try {
          String url;
          if (kIsWeb) { final bytes = await img.readAsBytes(); url = await storage.uploadImageBytes(bytes: bytes, reporteId: nuevoReporte.idReporte, fileName: img.name); }
          else { url = await storage.uploadImage(file: File(img.path), reporteId: nuevoReporte.idReporte); }
          await reportes.registrarAdjunto(reporteId: nuevoReporte.idReporte, tipo: 'imagen', url: url, nombreArchivo: img.name);
        } catch (e) { debugPrint('Error subiendo imagen: $e'); }
      }
    }
    setState(() => _enviando = false);
    if (mounted) { _showMsg('¡Reporte enviado! 🎉', AppColors.success); Navigator.pop(context); }
  }

  void _showMsg(String msg, Color color) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
}
