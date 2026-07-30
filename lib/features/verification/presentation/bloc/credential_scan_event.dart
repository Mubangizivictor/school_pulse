import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/repositories/credential_reader_adapter.dart';

sealed class CredentialScanEvent extends Equatable {
  const CredentialScanEvent();
  @override
  List<Object?> get props => [];
}

class StartCredentialScan extends CredentialScanEvent {
  final ScanCredentialKind kind;
  final VerificationContext context;

  const StartCredentialScan({required this.kind, required this.context});

  @override
  List<Object?> get props => [kind, context];
}

class StopCredentialScan extends CredentialScanEvent {
  const StopCredentialScan();
}

/// Added internally whenever the currently-active adapter's stream emits -
/// not dispatched by UI code.
class CredentialCapturedByAdapter extends CredentialScanEvent {
  final ScanCredential credential;

  const CredentialCapturedByAdapter(this.credential);

  @override
  List<Object?> get props => [credential];
}
