import 'package:equatable/equatable.dart';
import '../../domain/entities/staff_identity.dart';

abstract class StaffIdentityState extends Equatable {
  const StaffIdentityState();

  @override
  List<Object?> get props => [];
}

class StaffIdentityInitial extends StaffIdentityState {}

class StaffIdentityLoading extends StaffIdentityState {}

class StaffIdentityLoaded extends StaffIdentityState {
  final StaffIdentity identity;

  // The most recently assigned card UID, active or revoked - null if no
  // card was ever assigned.
  final String? assignedCardUid;

  const StaffIdentityLoaded(this.identity, {this.assignedCardUid});

  @override
  List<Object?> get props => [identity, assignedCardUid];
}

class StaffIdentityActionSuccess extends StaffIdentityLoaded {
  final String message;
  const StaffIdentityActionSuccess(
    this.message,
    super.identity, {
    super.assignedCardUid,
  });

  @override
  List<Object?> get props => [message, identity, assignedCardUid];
}

class StaffIdentityError extends StaffIdentityState {
  final String message;
  const StaffIdentityError(this.message);

  @override
  List<Object?> get props => [message];
}
