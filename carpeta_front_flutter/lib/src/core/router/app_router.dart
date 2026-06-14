import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/bloqueos_provider.dart';

import '../../auth/screens/login_screen.dart';
import '../../auth/screens/register_screen.dart';
import '../../auth/screens/forgot_password_screen.dart';
import '../../auth/screens/update_password_screen.dart';

import '../../ciudadano/screens/ciudadano_home_screen.dart';
import '../../ciudadano/screens/bloqueado_screen.dart';
import '../../funcionario/screens/funcionario_home_screen.dart';
import '../../admin/screens/admin_home_screen.dart';

class AppRouter {
  late final GoRouter router;

  AppRouter(Listenable refreshListenable) {
    router = GoRouter(
      initialLocation: '/',
      refreshListenable: refreshListenable, // Lo pasamos aquí
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/update-password',
          builder: (context, state) => const UpdatePasswordScreen(),
        ),

        // Rutas Protegidas
        GoRoute(
          path: '/ciudadano',
          builder: (context, state) => const CiudadanoHomeScreen(),
        ),
        GoRoute(
          path: '/funcionario',
          builder: (context, state) => const FuncionarioHomeScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminHomeScreen(),
        ),

        // Ruta de usuario bloqueado
        GoRoute(
          path: '/bloqueado',
          builder: (context, state) => const BloqueadoScreen(),
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        final isAuthenticated = authProvider.isAuthenticated;
        final isAuthRoute = [
          '/',
          '/register',
          '/forgot-password',
          '/update-password',
        ].contains(state.matchedLocation);

        if (state.matchedLocation == '/update-password') return null;

        if (isAuthenticated && isAuthRoute) {
          if (authProvider.usuario == null) return null;

          // Verificar si el usuario está bloqueado (solo ciudadanos)
          if (authProvider.estaBloqueado) {
            return '/bloqueado';
          }

          switch (authProvider.rol) {
            case 'admin':
              return '/admin';
            case 'funcionario':
              return '/funcionario';
            default:
              return '/ciudadano';
          }
        }

        if (!isAuthenticated && !isAuthRoute) {
          return '/';
        }

        // Si el usuario está bloqueado y trata de ir a otra ruta que no sea /bloqueado
        if (isAuthenticated &&
            authProvider.estaBloqueado &&
            state.matchedLocation != '/bloqueado' &&
            !isAuthRoute) {
          return '/bloqueado';
        }

        return null;
      },
    );
  }
}
