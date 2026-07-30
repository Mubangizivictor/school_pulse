import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_decision.dart';

/// Writes the engine's own audit trail for a verification attempt (why it
/// was allowed/denied) and drains the offline sync queue. This is
/// separate from a module's business-action recording - e.g. Security's
/// `SecurityRepository.recordStudentMovement` remains the system of
/// record for the movement itself and is called independently.
abstract class VerificationEventRecorder {
  /// [direction] is the operator-confirmed In/Out movement (see
  /// `VerificationDecision.suggestedDirection`) - required for Phase 1's
  /// gate purpose, unused by future non-movement purposes.
  Future<Either<Failure, void>> record({
    required VerificationDecision decision,
    required VerificationContext context,
    required ScanCredential credential,
    required String direction,
  });

  Future<Either<Failure, void>> syncPendingEvents();
}
