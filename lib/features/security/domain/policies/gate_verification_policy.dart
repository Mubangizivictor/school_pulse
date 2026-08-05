import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/security/domain/repositories/security_repository.dart';
import 'package:school_pulse/features/security/presentation/gatekeeper/gatekeeper_shared.dart';
import 'package:school_pulse/features/verification/domain/entities/resolved_identity.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_decision.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import 'package:school_pulse/features/verification/domain/repositories/verification_policy_evaluator.dart';

/// Security/Gate's `VerificationPolicyEvaluator`. Reuses the same
/// smart-direction suggestion (`suggestStudentDirection`/
/// `suggestStaffDirection`) Gatekeeper Simple Mode already uses, so a
/// suggested direction always shows up the same way whether the operator
/// is in Reception mode or Gatekeeper mode - the operator still confirms
/// it, nothing is recorded automatically.
///
/// Deliberately does NOT introduce new duplicate-scan rejection: today's
/// gate flow allows re-recording the same direction back-to-back, and
/// Phase 1 keeps that behavior unchanged. `VerificationOutcome
/// .alreadyRecorded` is reserved for a later, stricter-duplicate-policy
/// module (e.g. meals) rather than used here.
class GateVerificationPolicy implements VerificationPolicyEvaluator {
  final PermissionEvaluator permissionEvaluator;
  final SecurityRepository securityRepository;

  GateVerificationPolicy({
    required this.permissionEvaluator,
    required this.securityRepository,
  });

  @override
  Future<Either<Failure, VerificationDecision>> evaluate({
    required ResolvedIdentity identity,
    required VerificationContext context,
  }) async {
    // Permission is checked before identity resolution is even considered,
    // so an operator who isn't authorized to scan at this gate never gets
    // a decision - not even a generic "no match" one - regardless of what
    // was scanned.
    final permissionResult = await permissionEvaluator.can(
      Permission.securityIdentityVerify,
      context.operatorUser,
      gate: context.gate,
    );

    if (permissionResult.isLeft()) {
      final failure = permissionResult.swap().getOrElse(
        () => const ServerFailure(),
      );
      return Left(failure);
    }

    final isAllowed = permissionResult.getOrElse(() => false);
    if (!isAllowed) {
      return Right(
        VerificationDecision(
          outcome: VerificationOutcome.denied,
          identity: identity,
          message: 'You are not authorized to verify identities at this gate.',
          reasonCode: 'NOT_AUTHORIZED',
        ),
      );
    }

    if (identity is UnresolvedResolvedIdentity) {
      return Right(
        VerificationDecision(
          outcome: VerificationOutcome.denied,
          identity: identity,
          message: _messageForUnresolvedReason(identity.reason),
          reasonCode: identity.reason,
        ),
      );
    }

    final suggestedDirection = await _suggestedDirection(identity, context);
    return Right(
      VerificationDecision(
        outcome: VerificationOutcome.allowed,
        identity: identity,
        message: 'Identity verified.',
        suggestedDirection: suggestedDirection,
      ),
    );
  }

  Future<String> _suggestedDirection(
    ResolvedIdentity identity,
    VerificationContext context,
  ) async {
    final schoolId = context.gate.schoolId;
    final today = DateTime.now();

    if (identity is StaffResolvedIdentity) {
      final movements = await securityRepository
          .watchStaffMovements(schoolId, date: today, gateId: context.gate.id)
          .first;
      return suggestStaffDirection(movements, identity.id);
    }

    final studentId = identity is StudentResolvedIdentity
        ? identity.id
        : identity is ParentPickupResolvedIdentity
        ? identity.childId
        : null;
    if (studentId == null) return 'In';

    final movements = await securityRepository
        .watchStudentMovements(schoolId, date: today, gateId: context.gate.id)
        .first;
    return suggestStudentDirection(movements, studentId);
  }

  String _messageForUnresolvedReason(String reason) {
    return switch (reason) {
      'revoked_credential' => 'This credential has been revoked.',
      'multiple_children' =>
        'This parent code has multiple children linked - please select one manually.',
      'fingerprint_mismatch' =>
        'Fingerprint did not match the expected person.',
      _ => 'No matching student or staff record was found.',
    };
  }
}
