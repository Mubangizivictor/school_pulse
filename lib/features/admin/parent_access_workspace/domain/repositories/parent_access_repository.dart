import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../data/models/parent_access_invite_model.dart';
import '../entities/parent_access_record.dart';

class LearnerLinkRequest {
  final String studentId;
  final String relationship;
  final bool isPrimaryContact;

  const LearnerLinkRequest({
    required this.studentId,
    required this.relationship,
    this.isPrimaryContact = false,
  });
}

class IssuedParentAccessCode {
  final String inviteId;
  final String code;
  final DateTime expiresAt;

  /// Delivery state of the verified invitation the backend auto-enqueued
  /// (present when an email was supplied). 'sent' | 'pending_manual' |
  /// 'failed'.
  final String invitationStatus;
  final bool invitationDelivered;

  const IssuedParentAccessCode({
    required this.inviteId,
    required this.code,
    required this.expiresAt,
    this.invitationStatus = 'pending_manual',
    this.invitationDelivered = false,
  });
}

abstract class ParentAccessRepository {
  /// Initial link only - createParentAccessCode. Any of the six
  /// PARENT_INVITE_ADMIN_ROLES may call this.
  Future<Either<Failure, IssuedParentAccessCode>> issueParentAccessCode({
    required String parentName,
    required String phoneNumber,
    String? email,
    required List<LearnerLinkRequest> learners,
  });

  /// schoolAdmin-only - reassigns/replaces/removes an existing active or
  /// pending link. Pass null parentName/phoneNumber to remove without
  /// replacing.
  Future<Either<Failure, IssuedParentAccessCode?>> reallocateParentLink({
    required String linkId,
    String? parentName,
    String? phoneNumber,
    required String reason,
  });

  Future<Either<Failure, void>> revokeParentAccessCode({
    required String inviteId,
  });

  Future<Either<Failure, ParentAccessInvitesPage>> listParentAccessInvites({
    int pageSize = 25,
    String? cursor,
  });

  /// (Re)send the verified invitation for an existing parent record. [rawCode]
  /// may be passed straight after creation so the email carries it.
  Future<Either<Failure, void>> resendParentInvitation({
    required String inviteId,
    String? rawCode,
  });

  Future<Either<Failure, void>> cancelParentInvitation({
    required String inviteId,
  });

  Future<Either<Failure, ParentAccessRecord>> getParentAccessRecord({
    required String inviteId,
  });

  /// schoolAdmin-only guardian-detail edit. [email] null = unchanged,
  /// '' = clear, non-empty = set.
  Future<Either<Failure, void>> updateParentDetails({
    required String inviteId,
    String? parentName,
    String? phoneNumber,
    String? email,
  });

  /// Add learners to an existing parent record (duplicate-safe alternative to
  /// creating a second parent).
  Future<Either<Failure, void>> linkLearnersToExistingParent({
    required String inviteId,
    required List<LearnerLinkRequest> learners,
  });

  Future<Either<Failure, List<ParentLinkAuditEntry>>> listParentLinkAudit({
    String? inviteId,
    String? studentId,
  });
}
