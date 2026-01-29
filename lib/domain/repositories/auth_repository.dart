import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Contrato del repositorio de autenticación
abstract class AuthRepository {
  /// Stream del estado de autenticación del usuario
  /// Emite el usuario actual cuando cambia el estado de autenticación
  Stream<UserEntity> get authStateChanges;

  /// Obtiene el usuario actualmente autenticado
  /// Retorna [UserEntity.empty] si no hay usuario autenticado
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Inicia sesión con correo electrónico y contraseña
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario con correo electrónico y contraseña
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Inicia sesión con Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Cierra la sesión del usuario actual
  Future<Either<Failure, void>> signOut();

  /// Envía un correo de verificación al usuario actual
  Future<Either<Failure, void>> sendEmailVerification();

  /// Envía un correo para restablecer la contraseña
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  /// Actualiza el perfil del usuario (nombre y/o foto)
  Future<Either<Failure, void>> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Elimina la cuenta del usuario actual
  Future<Either<Failure, void>> deleteAccount();
}
