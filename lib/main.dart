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
import 'presentation/pages/formulario/formulario_page.dart';
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

        // Si está autenticado, mostrar formulario
        if (state is AuthAuthenticated) {
          return const FormularioPage();
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .primaryColor
                    .withAlpha((0.1 * 255).toInt()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ASCS',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Etiquetado Cardíaco',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
