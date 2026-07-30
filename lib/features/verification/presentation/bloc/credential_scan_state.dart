import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/repositories/credential_reader_adapter.dart';

class CredentialScanState extends Equatable {
  final bool isScanning;
  final ScanCredentialKind? activeKind;
  final ScanCredential? lastCredential;

  const CredentialScanState({
    required this.isScanning,
    this.activeKind,
    this.lastCredential,
  });

  const CredentialScanState.initial() : this(isScanning: false);

  CredentialScanState copyWith({
    bool? isScanning,
    ScanCredentialKind? activeKind,
    ScanCredential? lastCredential,
  }) {
    return CredentialScanState(
      isScanning: isScanning ?? this.isScanning,
      activeKind: activeKind ?? this.activeKind,
      lastCredential: lastCredential ?? this.lastCredential,
    );
  }

  @override
  List<Object?> get props => [isScanning, activeKind, lastCredential];
}
