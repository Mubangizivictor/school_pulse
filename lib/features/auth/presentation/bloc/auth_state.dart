import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  /// Non-null only when this session is the owner acting as a school admin
  /// via Owner Support Mode: holds who is impersonating, which school, and
  /// when the server-side session expires. Drives the persistent "acting
  /// as" banner and its exit action.
  final SupportModeInfo? supportMode;

  const AuthAuthenticated(this.user, {this.supportMode});

  @override
  List<Object?> get props => [user, supportMode];
}

class SupportModeInfo extends Equatable {
  final String ownerId;
  final String schoolName;
  final DateTime expiresAt;

  const SupportModeInfo({
    required this.ownerId,
    required this.schoolName,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [ownerId, schoolName, expiresAt];
}

class AuthUnauthenticated extends AuthState {}

class AuthOtpSent extends AuthState {
  final String verificationId;

  const AuthOtpSent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

/// Firebase has accepted the password and is waiting for the enrolled
/// authenticator-app code. The resolver is intentionally short lived.
class AuthMfaChallengeRequired extends AuthState {
  final MultiFactorResolver resolver;

  const AuthMfaChallengeRequired(this.resolver);
}

class AuthAccessCodeResolved extends AuthState {
  final ParentAccessCode code;

  const AuthAccessCodeResolved(this.code);

  @override
  List<Object?> get props => [code];
}
