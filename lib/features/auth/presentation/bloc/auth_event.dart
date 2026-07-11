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

class LoginWithPhonePressed extends AuthEvent {
  final String phoneNumber;

  const LoginWithPhonePressed({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOtpPressed extends AuthEvent {
  final String verificationId;
  final String smsCode;
  final List<String>? linkedStudentIds;

  const VerifyOtpPressed({required this.verificationId, required this.smsCode, this.linkedStudentIds});

  @override
  List<Object?> get props => [verificationId, smsCode, linkedStudentIds];
}

class LogoutPressed extends AuthEvent {}

class ResolveAccessCodeRequested extends AuthEvent {
  final String code;

  const ResolveAccessCodeRequested({required this.code});

  @override
  List<Object?> get props => [code];
}
