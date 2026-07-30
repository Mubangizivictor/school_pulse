import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/verification/domain/entities/resolved_identity.dart';

enum VerificationOutcome { allowed, denied, requiresOverride, alreadyRecorded }

/// The result of evaluating a resolved identity against module policy and
/// operator permissions - not yet recorded, not yet fed back to the user.
///
/// [suggestedDirection] is populated by purpose-specific policies that
/// deal in In/Out movement (Security/Gate in Phase 1) using the same
/// smart-suggestion heuristic Gatekeeper Simple Mode already uses -
/// derived from the person's last recorded movement today, never applied
/// automatically. The operator still confirms (or overrides) it before
/// anything is recorded.
class VerificationDecision extends Equatable {
  final VerificationOutcome outcome;
  final ResolvedIdentity identity;
  final String message;
  final String? reasonCode;
  final String? suggestedDirection;

  const VerificationDecision({
    required this.outcome,
    required this.identity,
    required this.message,
    this.reasonCode,
    this.suggestedDirection,
  });

  @override
  List<Object?> get props => [
        outcome,
        identity,
        message,
        reasonCode,
        suggestedDirection,
      ];
}
