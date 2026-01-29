import 'package:equatable/equatable.dart';

/// Entidad que representa un usuario autenticado
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
  final String? phoneNumber;
  final DateTime? createdAt;
  final DateTime? lastSignIn;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.emailVerified,
    this.phoneNumber,
    this.createdAt,
    this.lastSignIn,
  });

  /// Usuario vacío para estados iniciales
  static const empty = UserEntity(
    uid: '',
    email: '',
    emailVerified: false,
  );

  /// Verifica si el usuario está vacío (no autenticado)
  bool get isEmpty => this == UserEntity.empty;

  /// Verifica si el usuario está autenticado
  bool get isNotEmpty => this != UserEntity.empty;

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoUrl,
        emailVerified,
        phoneNumber,
        createdAt,
        lastSignIn,
      ];

  /// Copia con campos actualizados
  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastSignIn,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastSignIn: lastSignIn ?? this.lastSignIn,
    );
  }
}
