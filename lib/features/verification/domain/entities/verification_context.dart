import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';

/// Everything a verification attempt needs before a single credential is
/// scanned. The module that opens the scan session (Security/Gate, in
/// Phase 1) is responsible for constructing this - the engine never
/// invents its own purpose or permission requirements.
///
/// Direction (In/Out) is deliberately NOT part of this context: it isn't
/// known until after identity resolution (Reception mode asks the
/// operator to confirm it; Gatekeeper mode suggests it from the person's
/// last movement today) - see `VerificationDecision.suggestedDirection`.
class VerificationContext extends Equatable {
  final Gate gate;
  final UserEntity operatorUser;
  final String purpose; // e.g. 'security.identity.verify'
  final String deviceId;
  final DateTime requestedAt;

  const VerificationContext({
    required this.gate,
    required this.operatorUser,
    required this.purpose,
    required this.deviceId,
    required this.requestedAt,
  });

  @override
  List<Object?> get props => [
    gate,
    operatorUser,
    purpose,
    deviceId,
    requestedAt,
  ];
}
