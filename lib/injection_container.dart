import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Core
import 'core/network/network_info.dart';

// Data Sources
import 'data/datasources/local/config_local_datasource.dart';
import 'data/datasources/remote/aws_s3_remote_datasource.dart';
import 'data/datasources/remote/firebase_auth_remote_datasource.dart';

// Repositories
import 'data/repositories/config_repository_impl.dart';
import 'data/repositories/formulario_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/config_repository.dart';
import 'domain/repositories/formulario_repository.dart';
import 'domain/repositories/auth_repository.dart';

// Use Cases - Config
import 'domain/usecases/config/obtener_hospitales_usecase.dart';
import 'domain/usecases/config/obtener_consultorios_por_hospital_usecase.dart';
import 'domain/usecases/config/obtener_focos_usecase.dart';

// Use Cases - Formulario
import 'domain/usecases/enviar_formulario_usecase.dart';
import 'domain/usecases/generar_nombre_archivo_usecase.dart';

// Use Cases - Auth
import 'domain/usecases/auth/sign_in_with_email_usecase.dart';
import 'domain/usecases/auth/sign_up_with_email_usecase.dart';
import 'domain/usecases/auth/sign_in_with_google_usecase.dart';
import 'domain/usecases/auth/sign_out_usecase.dart';
import 'domain/usecases/auth/get_current_user_usecase.dart';
import 'domain/usecases/auth/send_password_reset_email_usecase.dart';

// BLoCs
import 'presentation/blocs/config/config_bloc.dart';
import 'presentation/blocs/formulario/formulario_bloc.dart';
import 'presentation/blocs/upload/upload_bloc.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/login/login_bloc.dart';

final sl = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación
Future<void> init() async {
  //! Core

  // Network Info
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      connectivity: sl(),
      httpClient: sl(),
    ),
  );

  //! Firebase Instances
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());

  //! Features - Auth

  // BLoCs
  sl.registerLazySingleton(
    () => AuthBloc(
      authRepository: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => LoginBloc(
      signInWithEmailUseCase: sl(),
      signUpWithEmailUseCase: sl(),
      signInWithGoogleUseCase: sl(),
      sendPasswordResetEmailUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SignInWithEmailUseCase(repository: sl()));
  sl.registerLazySingleton(() => SignUpWithEmailUseCase(repository: sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(repository: sl()));
  sl.registerLazySingleton(() => SignOutUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(repository: sl()));
  sl.registerLazySingleton(
      () => SendPasswordResetEmailUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<FirebaseAuthRemoteDataSource>(
    () => FirebaseAuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
    ),
  );

  //! Features - Config

  // BLoC
  sl.registerFactory(
    () => ConfigBloc(
      configRepository: sl(),
      obtenerConsultoriosUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => ObtenerHospitalesUseCase(repository: sl()));
  sl.registerLazySingleton(
    () => ObtenerConsultoriosPorHospitalUseCase(repository: sl()),
  );
  sl.registerLazySingleton(() => ObtenerFocosUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<ConfigRepository>(
    () => ConfigRepositoryImpl(localDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<ConfigLocalDataSource>(
    () => ConfigLocalDataSourceImpl(),
  );

  //! Features - Formulario

  // BLoC
  sl.registerFactory(
    () => FormularioBloc(
      enviarFormularioUseCase: sl(),
      generarNombreArchivoUseCase: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerFactory(() => UploadBloc());

  // Use Cases
  sl.registerLazySingleton(() => EnviarFormularioUseCase(repository: sl()));
  sl.registerLazySingleton(() => GenerarNombreArchivoUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<FormularioRepository>(
    () => FormularioRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AwsS3RemoteDataSource>(
    () => AwsS3RemoteDataSourceImpl(),
  );

  //! External

  // HTTP Client
  sl.registerLazySingleton(() => http.Client());

  // Connectivity
  sl.registerLazySingleton(() => Connectivity());
}
