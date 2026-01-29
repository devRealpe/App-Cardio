import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/auth/sign_out_usecase.dart';

// Events

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento cuando cambia el estado de autenticación
class AuthUserChanged extends AuthEvent {
  final UserEntity user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

/// Evento para cerrar sesión
class AuthSignOutRequested extends AuthEvent {}

// States

abstract class AuthState extends Equatable {
  final UserEntity user;

  const AuthState({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Estado desconocido (inicial, cargando)
class AuthUnknown extends AuthState {
  const AuthUnknown() : super(user: UserEntity.empty);
}

/// Estado autenticado
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required super.user});
}

/// Estado no autenticado
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated() : super(user: UserEntity.empty);
}

// BLoC

/// BLoC principal para el estado de autenticación
/// Este BLoC escucha los cambios en el estado de autenticación de Firebase
/// y emite los estados correspondientes
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  late final StreamSubscription<UserEntity> _authStateSubscription;

  AuthBloc({
    required this.authRepository,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthUnknown()) {
    // Registrar handlers de eventos
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignOutRequested>(_onSignOutRequested);

    // Suscribirse al stream de cambios de autenticación
    _authStateSubscription = authRepository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );

    // Verificar estado inicial del usuario
    _checkInitialAuthState();
  }

  /// Verifica el estado de autenticación inicial
  Future<void> _checkInitialAuthState() async {
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) => add(const AuthUserChanged(UserEntity.empty)),
      (user) => add(AuthUserChanged(user)),
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user.isEmpty) {
      emit(const AuthUnauthenticated());
    } else {
      emit(AuthAuthenticated(user: event.user));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await signOutUseCase();
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
