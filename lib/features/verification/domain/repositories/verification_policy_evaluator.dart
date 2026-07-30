import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/verification/domain/entities/resolved_identity.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_decision.dart';

/// Module-specific verification rules (duplicate detection, operating
/// hours, role/assignment scoping, etc). Each authorized module supplies
/// its own implementation - e.g. `GateVerificationPolicy` for
/// Security/Gate in Phase 1 - so business rules for one module never leak
/// into another.
abstract class VerificationPolicyEvaluator {
  Future<Either<Failure, VerificationDecision>> evaluate({
    required ResolvedIdentity identity,
    required VerificationContext context,
  });
}
