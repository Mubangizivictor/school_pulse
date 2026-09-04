import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../data/models/parent_access_invite_model.dart';

class LearnerLinkRequest {
  final String studentId;
  final String relationship;

  const LearnerLinkRequest({required this.studentId, required this.relationship});
}

class IssuedParentAccessCode {
  final String inviteId;
  final String code;
  final DateTime expiresAt;

  const IssuedParentAccessCode({
    required this.inviteId,
    required this.code,
    required this.expiresAt,
  });
}

abstract class ParentAccessRepository {
  /// Initial link only - createParentAccessCode. Any of the six
  /// PARENT_INVITE_ADMIN_ROLES may call this.
  Future<Either<Failure, IssuedParentAccessCode>> issueParentAccessCode({
    required String parentName,
    required String phoneNumber,
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
}
