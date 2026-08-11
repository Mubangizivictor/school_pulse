import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class LoginWithEmailPressed extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmailPressed({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginParentPressed extends AuthEvent {
  final String code;
  final String phoneNumber;
  final String pin;

  const LoginParentPressed({
    required this.code,
    required this.phoneNumber,
    required this.pin,
  });

  @override
  List<Object?> get props => [code, phoneNumber, pin];
}

class CompleteParentPinSetupRequested extends AuthEvent {
  final String code;
  final String phoneNumber;
  final String newPin;

  const CompleteParentPinSetupRequested({
    required this.code,
    required this.phoneNumber,
    required this.newPin,
  });

  @override
  List<Object?> get props => [code, phoneNumber, newPin];
}

class LogoutPressed extends AuthEvent {}

class ResolveAccessCodeRequested extends AuthEvent {
  final String code;

  const ResolveAccessCodeRequested({required this.code});

  @override
  List<Object?> get props => [code];
}

class EnterSupportModeRequested extends AuthEvent {
  final String schoolId;
  final String reason;

  const EnterSupportModeRequested({
    required this.schoolId,
    required this.reason,
  });

  @override
  List<Object?> get props => [schoolId, reason];
}

/// Ends an active support-mode session and signs the impersonated admin
/// out, landing the owner back on the login screen to sign in as themself.
class ExitSupportModePressed extends AuthEvent {}
