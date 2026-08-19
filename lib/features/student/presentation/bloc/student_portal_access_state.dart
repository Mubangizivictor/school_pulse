import 'package:equatable/equatable.dart';
import '../../domain/entities/student_access_code.dart';

abstract class StudentPortalAccessState extends Equatable {
  const StudentPortalAccessState();

  @override
  List<Object?> get props => [];
}

class StudentPortalAccessInitial extends StudentPortalAccessState {}

class StudentPortalAccessLoading extends StudentPortalAccessState {}

class StudentPortalAccessLoaded extends StudentPortalAccessState {
  // Null means no access code has been provisioned for this student yet.
  final StudentAccessCode? accessCode;

  const StudentPortalAccessLoaded(this.accessCode);

  @override
  List<Object?> get props => [accessCode];
}

// Carries a snackbar-able message alongside the refreshed access code
// state after a provision/reset/status action succeeds.
class StudentPortalAccessActionSuccess extends StudentPortalAccessLoaded {
  final String message;
  const StudentPortalAccessActionSuccess(this.message, super.accessCode);

  @override
  List<Object?> get props => [message, accessCode];
}

class StudentPortalAccessError extends StudentPortalAccessState {
  final String message;
  const StudentPortalAccessError(this.message);

  @override
  List<Object?> get props => [message];
}
