/// Excepción de autenticación general
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, [this.code]);

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Excepción de usuario no encontrado
class UserNotFoundException extends AuthException {
  const UserNotFoundException([String message = 'Usuario no encontrado'])
      : super(message, 'user-not-found');
}

/// Excepción de credenciales inválidas
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException(
      [String message = 'Correo o contraseña incorrectos'])
      : super(message, 'invalid-credentials');
}

/// Excepción de correo ya en uso
class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException(
      [String message = 'Este correo ya está registrado'])
      : super(message, 'email-already-in-use');
}

/// Excepción de contraseña débil
class WeakPasswordException extends AuthException {
  const WeakPasswordException(
      [String message = 'La contraseña debe tener al menos 6 caracteres'])
      : super(message, 'weak-password');
}

/// Excepción de operación cancelada
class UserCancelledException extends AuthException {
  const UserCancelledException(
      [String message = 'Operación cancelada por el usuario'])
      : super(message, 'user-cancelled');
}

/// Excepción de cuenta deshabilitada
class UserDisabledException extends AuthException {
  const UserDisabledException(
      [String message = 'Esta cuenta ha sido deshabilitada'])
      : super(message, 'user-disabled');
}

/// Excepción de correo mal formateado
class InvalidEmailException extends AuthException {
  const InvalidEmailException(
      [String message = 'El formato del correo es inválido'])
      : super(message, 'invalid-email');
}

/// Excepción de demasiados intentos
class TooManyRequestsException extends AuthException {
  const TooManyRequestsException(
      [String message = 'Demasiados intentos fallidos. Intenta más tarde'])
      : super(message, 'too-many-requests');
}

/// Excepción de red
class NetworkAuthException extends AuthException {
  const NetworkAuthException(
      [String message = 'Error de conexión. Verifica tu internet'])
      : super(message, 'network-error');
}
