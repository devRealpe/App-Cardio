import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/usecases/auth/sign_in_with_email_usecase.dart';
import '../../../domain/usecases/auth/sign_in_with_google_usecase.dart';
import '../../../domain/usecases/auth/sign_up_with_email_usecase.dart';
import '../../../domain/usecases/auth/send_password_reset_email_usecase.dart';

// ============================================================================
// Events
// ============================================================================

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para iniciar sesión con correo y contraseña
class LoginWithEmailRequested extends LoginEvent {
  final String email;
  final String password;

  const LoginWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Evento para registrarse con correo y contraseña
class SignUpWithEmailRequested extends LoginEvent {
  final String email;
  final String password;
  final String? displayName;

  const SignUpWithEmailRequested({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Evento para iniciar sesión con Google
class LoginWithGoogleRequested extends LoginEvent {}

/// Evento para enviar correo de restablecimiento de contraseña
class SendPasswordResetEmailRequested extends LoginEvent {
  final String email;

  const SendPasswordResetEmailRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

// ============================================================================
// States
// ============================================================================

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class LoginInitial extends LoginState {}

/// Estado de carga (procesando login/registro)
class LoginLoading extends LoginState {}

/// Estado de éxito (se redirigirá automáticamente por AuthBloc)
class LoginSuccess extends LoginState {}

/// Estado de error
class LoginFailure extends LoginState {
  final String message;

  const LoginFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de correo de restablecimiento enviado
class PasswordResetEmailSent extends LoginState {}

// ============================================================================
// BLoC
// ============================================================================

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInWithEmailUseCase signInWithEmailUseCase;
  final SignUpWithEmailUseCase signUpWithEmailUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase;

  LoginBloc({
    required this.signInWithEmailUseCase,
    required this.signUpWithEmailUseCase,
    required this.signInWithGoogleUseCase,
    required this.sendPasswordResetEmailUseCase,
  }) : super(LoginInitial()) {
    on<LoginWithEmailRequested>(_onLoginWithEmailRequested);
    on<SignUpWithEmailRequested>(_onSignUpWithEmailRequested);
    on<LoginWithGoogleRequested>(_onLoginWithGoogleRequested);
    on<SendPasswordResetEmailRequested>(_onSendPasswordResetEmailRequested);
  }

  Future<void> _onLoginWithEmailRequested(
    LoginWithEmailRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    final result = await signInWithEmailUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(LoginFailure(message: failure.message)),
      (_) => emit(LoginSuccess()),
    );
  }

  Future<void> _onSignUpWithEmailRequested(
    SignUpWithEmailRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    final result = await signUpWithEmailUseCase(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    );

    result.fold(
      (failure) => emit(LoginFailure(message: failure.message)),
      (_) => emit(LoginSuccess()),
    );
  }

  Future<void> _onLoginWithGoogleRequested(
    LoginWithGoogleRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    final result = await signInWithGoogleUseCase();

    result.fold(
      (failure) => emit(LoginFailure(message: failure.message)),
      (_) => emit(LoginSuccess()),
    );
  }

  Future<void> _onSendPasswordResetEmailRequested(
    SendPasswordResetEmailRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    final result = await sendPasswordResetEmailUseCase(email: event.email);

    result.fold(
      (failure) => emit(LoginFailure(message: failure.message)),
      (_) => emit(PasswordResetEmailSent()),
    );
  }
}
