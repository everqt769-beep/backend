import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/area.dart';
import '../models/categoria.dart';
import '../models/estado.dart';

/// Provider de catálogos maestros.
///
/// Carga áreas, categorías y estados que se usan
/// en selectores y filtros a lo largo de la app.
class CatalogosProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Area> _areas = [];
  List<Categoria> _categorias = [];
  List<Estado> _estados = [];
  bool _isLoading = false;

  List<Area> get areas => _areas;
  List<Categoria> get categorias => _categorias;
  List<Estado> get estados => _estados;
  bool get isLoading => _isLoading;

  /// Estados filtrados por entidad.
  List<Estado> estadosPorEntidad(String entidad) =>
      _estados.where((e) => e.entidad == entidad).toList();

  /// Categorías filtradas por área.
  List<Categoria> categoriasPorArea(String areaId) =>
      _categorias.where((c) => c.areaId == areaId).toList();

  /// Cargar todos los catálogos en paralelo.
  Future<void> cargarTodo() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      _cargarAreas(),
      _cargarCategorias(),
      _cargarEstados(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _cargarAreas() async {
    try {
      final result = await _api.get(ApiConstants.areas);
      _areas = (result as List).map((j) => Area.fromJson(j)).toList();
    } catch (e) {
      debugPrint('Error cargando áreas: $e');
    }
  }

  Future<void> _cargarCategorias() async {
    try {
      final result = await _api.get(ApiConstants.categorias);
      _categorias =
          (result as List).map((j) => Categoria.fromJson(j)).toList();
    } catch (e) {
      debugPrint('Error cargando categorías: $e');
    }
  }

  Future<void> _cargarEstados() async {
    try {
      final result = await _api.get(ApiConstants.estados);
      _estados = (result as List).map((j) => Estado.fromJson(j)).toList();
    } catch (e) {
      debugPrint('Error cargando estados: $e');
    }
  }

  /// Obtener nombre de categoría por ID.
  String? getNombreCategoria(String? id) {
    if (id == null) return null;
    try {
      return _categorias.firstWhere((c) => c.idCategoria == id).nombre;
    } catch (_) {
      return null;
    }
  }

  /// Obtener nombre de área por ID.
  String? getNombreArea(String? id) {
    if (id == null) return null;
    try {
      return _areas.firstWhere((a) => a.idArea == id).nombre;
    } catch (_) {
      return null;
    }
  }
}
