import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/errors/auth_exceptions.dart';
import '../../models/user_model.dart';

/// Contrato para el data source remoto de autenticación
abstract class FirebaseAuthRemoteDataSource {
  /// Stream del estado de autenticación
  Stream<UserModel> get authStateChanges;

  /// Obtiene el usuario actual
  UserModel? getCurrentUser();

  /// Inicia sesión con correo y contraseña
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario con correo y contraseña
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Inicia sesión con Google
  Future<UserModel> signInWithGoogle();

  /// Cierra sesión
  Future<void> signOut();

  /// Envía correo de verificación
  Future<void> sendEmailVerification();

  /// Envía correo para restablecer contraseña
  Future<void> sendPasswordResetEmail({required String email});

  /// Actualiza el perfil del usuario
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Elimina la cuenta del usuario
  Future<void> deleteAccount();
}

/// Implementación del data source usando Firebase Auth
class FirebaseAuthRemoteDataSourceImpl implements FirebaseAuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  FirebaseAuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Stream<UserModel> get authStateChanges {
    return firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return UserModel.empty;
      }
      return UserModel.fromFirebaseUser(firebaseUser);
    });
  }

  @override
  UserModel? getCurrentUser() {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return UserModel.fromFirebaseUser(firebaseUser);
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw const UserNotFoundException('No se pudo obtener el usuario');
      }

      return UserModel.fromFirebaseUser(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Error inesperado al iniciar sesión: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw const UserNotFoundException('No se pudo crear el usuario');
      }

      // Actualizar nombre si se proporcionó
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName.trim());
        await credential.user!.reload();
      }

      // Enviar correo de verificación automáticamente
      await credential.user!.sendEmailVerification();

      return UserModel.fromFirebaseUser(
        firebaseAuth.currentUser ?? credential.user!,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Error inesperado al registrar usuario: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // 1. Iniciar flujo de Google Sign In
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // Usuario canceló el inicio de sesión
        throw const UserCancelledException();
      }

      // 2. Obtener credenciales de Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Crear credencial de Firebase
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Iniciar sesión en Firebase
      final userCredential =
          await firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const UserNotFoundException(
            'No se pudo obtener el usuario de Google');
      }

      return UserModel.fromFirebaseUser(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } on UserCancelledException {
      rethrow;
    } catch (e) {
      throw AuthException('Error inesperado al iniciar sesión con Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Cerrar sesión en Firebase y Google
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const UserNotFoundException('No hay usuario autenticado');
      }

      if (user.emailVerified) {
        throw const AuthException('El correo ya está verificado');
      }

      await user.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error al enviar correo de verificación: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Error al enviar correo de restablecimiento: $e');
    }
  }

  @override
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const UserNotFoundException('No hay usuario autenticado');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName.trim());
      }

      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl.trim());
      }

      await user.reload();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error al actualizar perfil: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const UserNotFoundException('No hay usuario autenticado');
      }

      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Error al eliminar cuenta: $e');
    }
  }

  /// Maneja las excepciones de Firebase Auth y las convierte a nuestras excepciones personalizadas
  AuthException _handleFirebaseAuthException(
      firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const UserNotFoundException();
      case 'wrong-password':
      case 'invalid-credential':
        return const InvalidCredentialsException();
      case 'email-already-in-use':
        return const EmailAlreadyInUseException();
      case 'weak-password':
        return const WeakPasswordException();
      case 'user-disabled':
        return const UserDisabledException();
      case 'invalid-email':
        return const InvalidEmailException();
      case 'too-many-requests':
        return const TooManyRequestsException();
      case 'network-request-failed':
        return const NetworkAuthException();
      case 'operation-not-allowed':
        return AuthException(
          'Esta operación no está permitida. Contacta al administrador.',
          e.code,
        );
      default:
        return AuthException(
          e.message ?? 'Error desconocido de autenticación',
          e.code,
        );
    }
  }
}
