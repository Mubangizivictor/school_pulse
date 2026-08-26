import 'package:equatable/equatable.dart';

/// One append-only row from schools/{schoolId}/credential_history.
///
/// Deliberately carries no raw credential value - only a masked reference
/// (kept server-side, not even surfaced here) - since this entry exists to
/// answer "what happened and when," not to reproduce the credential itself.
class CredentialHistoryEntry extends Equatable {
  final String action; // e.g. 'nfc_assigned', 'nfc_replaced', 'qr_replaced'
  final String credentialType; // 'nfc' | 'qr'
  final String? reason;
  final DateTime createdAt;
  final String? actorNameSnapshot;

  const CredentialHistoryEntry({
    required this.action,
    required this.credentialType,
    required this.createdAt,
    this.reason,
    this.actorNameSnapshot,
  });

  @override
  List<Object?> get props => [
    action,
    credentialType,
    reason,
    createdAt,
    actorNameSnapshot,
  ];
}
