import 'package:equatable/equatable.dart';

import 'parent_access_invite.dart';

/// One learner linked to a parent record, as returned by
/// `getParentAccessRecord`.
class ParentLinkedLearner extends Equatable {
  final String linkId;
  final String studentId;
  final String studentName;
  final String className;
  final String relationship;
  final bool isPrimaryContact;

  /// pending (parent not yet signed up) | active | revoked.
  final String linkStatus;
  final String linkType; // initial | reallocation

  const ParentLinkedLearner({
    required this.linkId,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.relationship,
    required this.isPrimaryContact,
    required this.linkStatus,
    required this.linkType,
  });

  @override
  List<Object?> get props => [
    linkId,
    studentId,
    studentName,
    className,
    relationship,
    isPrimaryContact,
    linkStatus,
    linkType,
  ];
}

/// One immutable parent_link_audit_log entry.
class ParentLinkAuditEntry extends Equatable {
  final String id;
  final String action; // reallocated | removed | ...
  final String actorRole;
  final String studentId;
  final String reason;
  final DateTime? createdAt;

  const ParentLinkAuditEntry({
    required this.id,
    required this.action,
    required this.actorRole,
    required this.studentId,
    required this.reason,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    action,
    actorRole,
    studentId,
    reason,
    createdAt,
  ];
}

/// Full parent record for the detail/access-management screen. Unlike the
/// directory list, phone/email are returned in the clear here (authenticated
/// same-school admin editing the record).
class ParentAccessRecord extends Equatable {
  final String inviteId;
  final String parentName;
  final String phoneNumber;
  final String email;
  final ParentInviteStatus status;
  final ParentInvitationDelivery invitationStatus;
  final DateTime? invitationSentAt;
  final DateTime? canResendAt;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final DateTime? revokedAt;
  final int maxGuardians;
  final List<ParentLinkedLearner> learners;

  const ParentAccessRecord({
    required this.inviteId,
    required this.parentName,
    required this.phoneNumber,
    required this.email,
    required this.status,
    required this.invitationStatus,
    this.invitationSentAt,
    this.canResendAt,
    this.createdAt,
    this.expiresAt,
    this.revokedAt,
    this.maxGuardians = 2,
    this.learners = const [],
  });

  bool canResendNow(DateTime now) =>
      canResendAt == null || !now.isBefore(canResendAt!);

  @override
  List<Object?> get props => [
    inviteId,
    parentName,
    phoneNumber,
    email,
    status,
    invitationStatus,
    invitationSentAt,
    canResendAt,
    createdAt,
    expiresAt,
    revokedAt,
    maxGuardians,
    learners,
  ];
}
