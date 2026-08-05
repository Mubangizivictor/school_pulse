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

  // The most recently assigned card UID, active or revoked - null if no
  // card was ever assigned. Lets the UI offer "revoke" for a lost/stolen
  // card without needing to re-scan it.
  final String? assignedCardUid;

  const StudentIdentityLoaded(this.identity, {this.assignedCardUid});

  @override
  List<Object?> get props => [identity, assignedCardUid];
}

// Carries a snackbar-able message alongside the refreshed identity/card
// state after an NFC lifecycle action succeeds.
class StudentIdentityActionSuccess extends StudentIdentityLoaded {
  final String message;
  const StudentIdentityActionSuccess(
    this.message,
    super.identity, {
    super.assignedCardUid,
  });

  @override
  List<Object?> get props => [message, identity, assignedCardUid];
}

class StudentIdentityError extends StudentIdentityState {
  final String message;
  const StudentIdentityError(this.message);

  @override
  List<Object?> get props => [message];
}

class StudentIdentityCacheSuccess extends StudentIdentityState {}
