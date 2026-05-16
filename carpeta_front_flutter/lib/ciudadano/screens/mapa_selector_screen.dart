import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';

/// Pantalla de selección de ubicación en mapa OpenStreetMap.
///
/// Permite al usuario:
/// 1. Ver su ubicación actual
/// 2. Mover el pin para seleccionar una ubicación diferente
/// 3. Confirmar la ubicación seleccionada
class MapaSelectorScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapaSelectorScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<MapaSelectorScreen> createState() => _MapaSelectorScreenState();
}

class _MapaSelectorScreenState extends State<MapaSelectorScreen> {
  final MapController _mapCtrl = MapController();
  LatLng? _selectedPosition;
  bool _isLoading = true;
  String? _errorMsg;

  // Ubicación por defecto: La Paz, Bolivia
  static const _defaultLat = -16.5000000;
  static const _defaultLng = -68.1192930;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    if (widget.initialLat != null && widget.initialLng != null) {
      setState(() {
        _selectedPosition = LatLng(widget.initialLat!, widget.initialLng!);
        _isLoading = false;
      });
      return;
    }

    try {
      // Verificar permisos
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() {
          _selectedPosition = const LatLng(_defaultLat, _defaultLng);
          _errorMsg = 'Permiso de ubicación denegado. Selecciona manualmente.';
          _isLoading = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedPosition = LatLng(pos.latitude, pos.longitude);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _selectedPosition = const LatLng(_defaultLat, _defaultLng);
        _errorMsg = 'No se pudo obtener la ubicación. Selecciona manualmente.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        backgroundColor: AppColors.surface.withOpacity(0.9),
        actions: [
          TextButton.icon(
            onPressed: _selectedPosition != null
                ? () => Navigator.pop(context, {
                      'lat': _selectedPosition!.latitude,
                      'lng': _selectedPosition!.longitude,
                    })
                : null,
            icon: const Icon(Icons.check, color: AppColors.secondary),
            label: const Text('Confirmar',
                style: TextStyle(color: AppColors.secondary)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 12),
                  Text('Obteniendo ubicación...',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapCtrl,
                  options: MapOptions(
                    initialCenter: _selectedPosition ??
                        const LatLng(_defaultLat, _defaultLng),
                    initialZoom: 16,
                    onTap: (tapPos, latLng) {
                      setState(() => _selectedPosition = latLng);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.vecinapp.app',
                    ),
                    if (_selectedPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPosition!,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.error,
                              size: 50,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                // ── Mensaje de error ──
                if (_errorMsg != null)
                  Positioned(
                    top: 8,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _errorMsg!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                // ── Coordenadas seleccionadas ──
                if (_selectedPosition != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Lat: ${_selectedPosition!.latitude.toStringAsFixed(6)}\n'
                              'Lng: ${_selectedPosition!.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          // Botón para ir a mi ubicación
                          IconButton(
                            onPressed: _goToMyLocation,
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.gps_fixed,
                                  color: AppColors.primary, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _goToMyLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() => _selectedPosition = latLng);
      _mapCtrl.move(latLng, 16);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener la ubicación'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
