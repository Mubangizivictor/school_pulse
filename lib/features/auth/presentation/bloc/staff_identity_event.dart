import 'package:equatable/equatable.dart';
import '../../domain/entities/staff_identity.dart';

abstract class StaffIdentityEvent extends Equatable {
  const StaffIdentityEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaffIdentityEvent extends StaffIdentityEvent {
  final String staffId;
  const LoadStaffIdentityEvent(this.staffId);

  @override
  List<Object?> get props => [staffId];
}

class RegenerateStaffQrCredentialEvent extends StaffIdentityEvent {
  final StaffIdentity identity;
  const RegenerateStaffQrCredentialEvent(this.identity);

  @override
  List<Object?> get props => [identity];
}

class AssignStaffNfcCardEvent extends StaffIdentityEvent {
  final String cardUid;
  final String staffId;
  final String schoolId;
  const AssignStaffNfcCardEvent({
    required this.cardUid,
    required this.staffId,
    required this.schoolId,
  });

  @override
  List<Object?> get props => [cardUid, staffId, schoolId];
}

class ReplaceStaffNfcCardEvent extends StaffIdentityEvent {
  final String oldCardUid;
  final String newCardUid;
  final String staffId;
  final String schoolId;
  final String reason;
  const ReplaceStaffNfcCardEvent({
    required this.oldCardUid,
    required this.newCardUid,
    required this.staffId,
    required this.schoolId,
    required this.reason,
  });

  @override
  List<Object?> get props => [
    oldCardUid,
    newCardUid,
    staffId,
    schoolId,
    reason,
  ];
}

class RevokeStaffNfcCardEvent extends StaffIdentityEvent {
  final String cardUid;
  final String staffId;
  final String schoolId;
  final String reason;
  const RevokeStaffNfcCardEvent({
    required this.cardUid,
    required this.staffId,
    required this.schoolId,
    required this.reason,
  });

  @override
  List<Object?> get props => [cardUid, staffId, schoolId, reason];
}

class ReactivateStaffNfcCardEvent extends StaffIdentityEvent {
  final String cardUid;
  final String staffId;
  final String schoolId;
  const ReactivateStaffNfcCardEvent({
    required this.cardUid,
    required this.staffId,
    required this.schoolId,
  });

  @override
  List<Object?> get props => [cardUid, staffId, schoolId];
}
