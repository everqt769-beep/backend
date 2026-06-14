import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';

class CrearUsuarioDialog extends StatefulWidget {
  const CrearUsuarioDialog({super.key});

  @override
  State<CrearUsuarioDialog> createState() => _CrearUsuarioDialogState();
}

class _CrearUsuarioDialogState extends State<CrearUsuarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRol = 'ciudadano';
  bool _isLoading = false;
  String? _error;

  // ⚠️ SOLO PARA PRUEBAS - service_role key
  static const _supabaseUrl = 'https://nzsyekwmaalmrugkowav.supabase.co';
  static const _serviceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im56c3lla3dtYWFsbXJ1Z2tvd2F2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NzE3NzM2NiwiZXhwIjoyMDkyNzUzMzY2fQ.HvE0BnvhsrwJIuS2M7HWnWS-LiH5-nVGie5uJIEpggc';

  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Cliente admin con service_role key
      final adminClient = SupabaseClient(_supabaseUrl, _serviceRoleKey);

      final nombre = _nombreController.text.trim();
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;

      // 1) Crear usuario en Auth
      final authResponse = await adminClient.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
        ),
      );

      final userId = authResponse.user?.id;
      if (userId == null)
        throw Exception('No se pudo obtener el ID del usuario');

      // 2) Actualizar la fila que el trigger ya creó
      await adminClient
          .from('usuarios')
          .update({'nombre': nombre, 'correo': email, 'rol': _selectedRol})
          .eq('id_usuario', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario creado con éxito.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text(
        'Crear Nuevo Usuario',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
                    return 'Email no válido';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRol,
                onChanged: (v) => setState(() => _selectedRol = v!),
                items: ['ciudadano', 'funcionario', 'admin']
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text(v[0].toUpperCase() + v.substring(1)),
                      ),
                    )
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Rol del Usuario',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _crearUsuario,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Crear'),
        ),
      ],
    );
  }
}
