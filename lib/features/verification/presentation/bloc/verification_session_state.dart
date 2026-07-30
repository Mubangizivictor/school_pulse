import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_decision.dart';

sealed class VerificationSessionState extends Equatable {
  const VerificationSessionState();
  @override
  List<Object?> get props => [];
}

class VerificationIdle extends VerificationSessionState {
  const VerificationIdle();
}

class VerificationResolving extends VerificationSessionState {
  const VerificationResolving();
}

/// A decision has been reached but nothing has been recorded yet. For an
/// `allowed` outcome, the UI shows the suggested direction and waits for
/// `VerificationDirectionConfirmed`; for `denied`/`requiresOverride`/
/// `alreadyRecorded`, this is a terminal state until the operator resets.
class VerificationDecided extends VerificationSessionState {
  final VerificationDecision decision;
  final ScanCredential credential;
  final VerificationContext context;

  const VerificationDecided({
    required this.decision,
    required this.credential,
    required this.context,
  });

  @override
  List<Object?> get props => [decision, credential, context];
}

class VerificationRecording extends VerificationSessionState {
  const VerificationRecording();
}

class VerificationRecorded extends VerificationSessionState {
  final VerificationDecision decision;
  final String direction;

  const VerificationRecorded({required this.decision, required this.direction});

  @override
  List<Object?> get props => [decision, direction];
}

class VerificationSessionError extends VerificationSessionState {
  final String message;

  const VerificationSessionError(this.message);

  @override
  List<Object?> get props => [message];
}
