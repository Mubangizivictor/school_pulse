import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';

sealed class VerificationSessionEvent extends Equatable {
  const VerificationSessionEvent();
  @override
  List<Object?> get props => [];
}

class VerificationCredentialCaptured extends VerificationSessionEvent {
  final ScanCredential credential;
  final VerificationContext context;

  const VerificationCredentialCaptured({required this.credential, required this.context});

  @override
  List<Object?> get props => [credential, context];
}

/// The operator confirming (or overriding a suggested) In/Out direction
/// after a successful identity verification - see
/// `VerificationDecision.suggestedDirection`.
class VerificationDirectionConfirmed extends VerificationSessionEvent {
  final String direction;

  const VerificationDirectionConfirmed(this.direction);

  @override
  List<Object?> get props => [direction];
}

class VerificationSessionReset extends VerificationSessionEvent {
  const VerificationSessionReset();
}
