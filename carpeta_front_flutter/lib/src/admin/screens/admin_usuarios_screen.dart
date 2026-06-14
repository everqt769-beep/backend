
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../models/usuario.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/estado_badge.dart';
import '../widgets/crear_usuario_dialog.dart'; // Importamos el nuevo diálogo

/// Pantalla de gestión de usuarios (solo admin).
class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});
  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  List<Usuario> _usuarios = [];
  bool _loading = true;
  String _filtroRol = '';

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final result = await ApiService().get(ApiConstants.usuarios);
      if (mounted) {
        setState(() {
          _usuarios = (result as List).map((j) => Usuario.fromJson(j)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar usuarios: $e')),
        );
      }
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  void _abrirDialogoCrearUsuario() {
    showDialog(
      context: context,
      builder: (context) => const CrearUsuarioDialog(),
    ).then((result) {
      // Si el diálogo devuelve 'true', significa que se creó un usuario
      if (result == true) {
        _cargarUsuarios(); // Recargamos la lista
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var lista = _filtroRol.isEmpty ? _usuarios : _usuarios.where((u) => u.rol == _filtroRol).toList();

    return Scaffold(
      backgroundColor: Colors.transparent, // Fondo transparente para que se vea el de la home
      body: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          color: AppColors.surface.withOpacity(0.8),
          child: Column(children: [
            Row(children: [
              const Text('Usuarios', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Spacer(),
              Text('${lista.length} usuarios', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              IconButton(onPressed: _cargarUsuarios, icon: const Icon(Icons.refresh_rounded, color: AppColors.primary)),
            ]),
            const SizedBox(height: 10),
            SizedBox(height: 34, child: ListView(scrollDirection: Axis.horizontal, children: [
              _chip('Todos', _filtroRol.isEmpty, () => setState(() => _filtroRol = '')),
              _chip('Ciudadanos', _filtroRol == 'ciudadano', () => setState(() => _filtroRol = 'ciudadano'), color: AppColors.secondary),
              _chip('Funcionarios', _filtroRol == 'funcionario', () => setState(() => _filtroRol = 'funcionario'), color: AppColors.info),
              _chip('Admins', _filtroRol == 'admin', () => setState(() => _filtroRol = 'admin'), color: AppColors.error),
            ])),
          ]),
        ),
        Expanded(
          child: _loading ? const LoadingWidget() : ListView.builder(
            padding: const EdgeInsets.all(12), itemCount: lista.length,
            itemBuilder: (ctx, i) {
              final u = lista[i];
              final rolColor = u.esAdmin ? AppColors.error : u.esFuncionario ? AppColors.info : AppColors.secondary;
              return Container(
                margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: rolColor, width: 3))),
                child: Row(children: [
                  CircleAvatar(radius: 18, backgroundColor: rolColor.withOpacity(0.2), child: Text(u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : '?', style: TextStyle(color: rolColor, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(u.nombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text(u.correo, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: rolColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: Text(u.rol.toUpperCase(), style: TextStyle(fontSize: 10, color: rolColor, fontWeight: FontWeight.w600)),
                  ),
                  if (u.estado != null) ...[const SizedBox(width: 8), EstadoBadge(nombre: u.estado!.nombre, codigo: u.estado!.codigo, fontSize: 10)],
                ]),
              );
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirDialogoCrearUsuario,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        tooltip: 'Crear Nuevo Usuario',
      ),
    );
  }

  Widget _chip(String label, bool sel, VoidCallback onTap, {Color? color}) {
    final c = color ?? AppColors.primary;
    return GestureDetector(onTap: onTap, child: Container(
      margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: sel ? c.withOpacity(0.2) : AppColors.surfaceLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: sel ? c : Colors.transparent)),
      child: Text(label, style: TextStyle(fontSize: 11, color: sel ? c : AppColors.textHint, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
    ));
  }
}
