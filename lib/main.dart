// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'amplifyconfiguration.dart';
import 'injection_container.dart' as di;
import 'presentation/theme/app_theme.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/dashboard/main_dashboard.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/config/config_bloc.dart';
import 'presentation/blocs/config/config_event.dart';

/// Punto de entrada principal de la aplicación
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar Amplify (para S3)
  await _initializeAmplify();

  // Inicializar inyección de dependencias
  await di.init();

  runApp(const MyApp());
}

/// Configura e inicializa Amplify con Auth y Storage
Future<void> _initializeAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    final storage = AmplifyStorageS3();

    await Amplify.addPlugins([auth, storage]);
    await Amplify.configure(amplifyconfig);

    safePrint('Amplify configurado exitosamente');
  } catch (e) {
    safePrint('Error al configurar Amplify: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // AuthBloc - Maneja el estado global de autenticación
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>(),
        ),
        // ConfigBloc - Carga configuración médica
        BlocProvider<ConfigBloc>(
          create: (context) =>
              di.sl<ConfigBloc>()..add(CargarConfiguracionEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'ASCS - Etiquetado Cardíaco',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const AuthNavigator(),
      ),
    );
  }
}

/// Widget que maneja la navegación basada en el estado de autenticación
class AuthNavigator extends StatelessWidget {
  const AuthNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Si está cargando (estado desconocido), mostrar splash
        if (state is AuthUnknown) {
          return const SplashScreen();
        }

        // Si está autenticado, mostrar dashboard
        if (state is AuthAuthenticated) {
          return const MainDashboard();
        }

        // Si no está autenticado, mostrar login
        return const LoginPage();
      },
    );
  }
}

/// Pantalla de carga mientras se verifica el estado de autenticación
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .primaryColor
                          .withAlpha((0.1 * 255).toInt()),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .primaryColor
                              .withAlpha((0.3 * 255).toInt()),
                          blurRadius: 20 * value,
                          spreadRadius: 2 * value,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'ASCS',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Etiquetado Cardíaco',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),
            // Indicador de carga
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Verificando sesión...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
