import 'package:dartz/dartz.dart';
import '../../core/errors/auth_exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/firebase_auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserEntity> get authStateChanges {
    return remoteDataSource.authStateChanges;
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = remoteDataSource.getCurrentUser();
      if (user == null) {
        return const Right(UserEntity.empty);
      }
      return Right(user);
    } catch (e) {
      return Left(UnexpectedFailure('Error al obtener usuario actual: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(user);
    } on UserNotFoundException catch (e) {
      return Left(UserNotFoundFailure(e.message));
    } on InvalidCredentialsException catch (e) {
      return Left(InvalidCredentialsFailure(e.message));
    } on UserDisabledException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkAuthException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TooManyRequestsException catch (e) {
      return Left(AuthFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado al iniciar sesión: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final user = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      return Right(user);
    } on EmailAlreadyInUseException catch (e) {
      return Left(EmailAlreadyInUseFailure(e.message));
    } on WeakPasswordException catch (e) {
      return Left(WeakPasswordFailure(e.message));
    } on InvalidEmailException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkAuthException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(
          UnexpectedFailure('Error inesperado al registrar usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      return Right(user);
    } on UserCancelledException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkAuthException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(
          'Error inesperado al iniciar sesión con Google: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado al cerrar sesión: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
      return const Right(null);
    } on UserNotFoundException catch (e) {
      return Left(UserNotFoundFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(
          'Error inesperado al enviar correo de verificación: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on UserNotFoundException catch (e) {
      return Left(UserNotFoundFailure(e.message));
    } on InvalidEmailException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkAuthException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(
          'Error inesperado al enviar correo de restablecimiento: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await remoteDataSource.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return const Right(null);
    } on UserNotFoundException catch (e) {
      return Left(UserNotFoundFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(
          UnexpectedFailure('Error inesperado al actualizar perfil: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      return const Right(null);
    } on UserNotFoundException catch (e) {
      return Left(UserNotFoundFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado al eliminar cuenta: $e'));
    }
  }
}
