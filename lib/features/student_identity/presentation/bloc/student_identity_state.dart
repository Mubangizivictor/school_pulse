import 'package:equatable/equatable.dart';
import '../../domain/entities/student_identity.dart';

abstract class StudentIdentityState extends Equatable {
  const StudentIdentityState();

  @override
  List<Object?> get props => [];
}

class StudentIdentityInitial extends StudentIdentityState {}

class StudentIdentityLoading extends StudentIdentityState {}

class StudentIdentityLoaded extends StudentIdentityState {
  final StudentIdentity identity;
  const StudentIdentityLoaded(this.identity);

  @override
  List<Object?> get props => [identity];
}

class StudentIdentityError extends StudentIdentityState {
  final String message;
  const StudentIdentityError(this.message);

  @override
  List<Object?> get props => [message];
}

class StudentIdentityCacheSuccess extends StudentIdentityState {}
