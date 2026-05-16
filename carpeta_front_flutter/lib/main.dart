import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/reportes_provider.dart';
import 'providers/catalogos_provider.dart';

import 'auth/screens/login_screen.dart';
import 'ciudadano/screens/ciudadano_home_screen.dart';
import 'funcionario/screens/funcionario_home_screen.dart';
import 'admin/screens/admin_home_screen.dart';

/// Punto de entrada de VecinApp.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
  );

  // Inicializar formato de fechas en español
  await initializeDateFormatting('es', null);

  runApp(const VecinApp());
}

class VecinApp extends StatelessWidget {
  const VecinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => ReportesProvider()),
        ChangeNotifierProvider(create: (_) => CatalogosProvider()),
      ],
      child: MaterialApp(
        title: 'VecinApp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Gate de autenticación — redirige según estado de sesión y rol.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // No autenticado → Login
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    // Autenticado pero sin perfil cargado → Loading
    if (auth.usuario == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Redirigir según rol
    switch (auth.rol) {
      case 'admin':
        return const AdminHomeScreen();
      case 'funcionario':
        return const FuncionarioHomeScreen();
      case 'ciudadano':
      default:
        return const CiudadanoHomeScreen();
    }
  }
}
