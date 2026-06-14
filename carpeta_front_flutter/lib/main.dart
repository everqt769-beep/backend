import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/core/constants/api_constants.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/router/app_router.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/reportes_provider.dart';
import 'src/providers/catalogos_provider.dart';
import 'src/providers/bloqueos_provider.dart';
import 'src/providers/dashboard_provider.dart';
import 'src/core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
  );

  await initializeDateFormatting('es', null);

  final uri = Uri.base;
  if (uri.queryParameters.containsKey('code')) {
    try {
      await Supabase.instance.client.auth.exchangeCodeForSession(
        uri.queryParameters['code']!,
      );
    } catch (e) {
      debugPrint('Error exchanging code: $e');
    }
  }

  // Creamos el AuthProvider aquí para pasarlo
  final authService = AuthService();
  final authProvider = AuthProvider()..init();

  runApp(VecinApp(authProvider: authProvider, authService: authService));
}

class VecinApp extends StatefulWidget {
  final AuthService authService;
  final AuthProvider authProvider;

  const VecinApp({
    super.key,
    required this.authProvider,
    required this.authService,
  });

  @override
  State<VecinApp> createState() => _VecinAppState();
}

class _VecinAppState extends State<VecinApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(widget.authProvider); // Pasamos el authProvider

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        _appRouter.router.go('/update-password');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.authProvider),
        Provider<AuthService>.value(value: widget.authService),
        ChangeNotifierProvider(create: (_) => ReportesProvider()),
        ChangeNotifierProvider(create: (_) => CatalogosProvider()),
        ChangeNotifierProvider(create: (_) => BloqueosProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp.router(
        title: 'VecinApp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: _appRouter.router,
      ),
    );
  }
}
