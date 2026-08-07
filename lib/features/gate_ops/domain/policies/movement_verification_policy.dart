import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/movement_event.dart';
import 'package:school_pulse/features/gate_ops/domain/policies/movement_direction_heuristics.dart';
import 'package:school_pulse/features/gate_ops/domain/repositories/gate_ops_repository.dart';
import 'package:school_pulse/features/verification/domain/entities/resolved_identity.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_decision.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import 'package:school_pulse/features/verification/domain/repositories/verification_policy_evaluator.dart';

/// Replaces the deleted `security` module's `GateVerificationPolicy` 1:1,
/// backed by [GateOpsRepository]'s unified `watchMovementEvents` instead of
/// the old module's separate `watchStudentMovements`/`watchStaffMovements`.
///
/// Deliberately does NOT introduce new duplicate-scan rejection - this
/// preserves the old policy's behavior unchanged (`VerificationOutcome
/// .alreadyRecorded` is reserved for a later, stricter-duplicate-policy
/// module rather than used here).
class MovementVerificationPolicy implements VerificationPolicyEvaluator {
  final PermissionEvaluator permissionEvaluator;
  final GateOpsRepository gateOpsRepository;

  MovementVerificationPolicy({
    required this.permissionEvaluator,
    required this.gateOpsRepository,
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
      final events = await gateOpsRepository
          .watchMovementEvents(
            schoolId,
            personType: PersonType.staff,
            gateId: context.gate.id,
            date: today,
          )
          .first;
      return suggestStaffDirection(events, identity.id);
    }

    final studentId = identity is StudentResolvedIdentity
        ? identity.id
        : identity is ParentPickupResolvedIdentity
        ? identity.childId
        : null;
    if (studentId == null) return 'In';

    final events = await gateOpsRepository
        .watchMovementEvents(
          schoolId,
          personType: PersonType.student,
          gateId: context.gate.id,
          date: today,
        )
        .first;
    return suggestStudentDirection(events, studentId);
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
