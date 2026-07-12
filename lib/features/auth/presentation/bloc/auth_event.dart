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
  final String newPin;

  const CompleteParentPinSetupRequested({required this.code, required this.newPin});

  @override
  List<Object?> get props => [code, newPin];
}

class LogoutPressed extends AuthEvent {}

class ResolveAccessCodeRequested extends AuthEvent {
  final String code;

  const ResolveAccessCodeRequested({required this.code});

  @override
  List<Object?> get props => [code];
}
