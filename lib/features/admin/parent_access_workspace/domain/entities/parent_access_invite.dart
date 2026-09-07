import 'package:equatable/equatable.dart';

/// Server-recomputed state of one parent_access_code_invites document, as
/// returned by the `listParentAccessInvites` callable. Never carries a raw
/// phone number or code/codeHash - [maskedPhone] / [maskedEmail] are the
/// only contact fields, pre-masked server-side.
enum ParentInviteStatus { active, revoked, expired }

/// Delivery / acceptance state of the verified invitation layered on a
/// parent record (parent_invitations.js). Distinct from [ParentInviteStatus]
/// which is the code's own lifecycle. `accepted` = the parent has completed
/// sign-up; anything else = still awaiting them.
enum ParentInvitationDelivery { sent, pendingManual, failed, cancelled, accepted }

ParentInvitationDelivery parentInvitationDeliveryFromString(String? raw) {
  switch (raw) {
    case 'accepted':
      return ParentInvitationDelivery.accepted;
    case 'failed':
      return ParentInvitationDelivery.failed;
    case 'cancelled':
      return ParentInvitationDelivery.cancelled;
    case 'pending_manual':
      return ParentInvitationDelivery.pendingManual;
    case 'sent':
    default:
      return ParentInvitationDelivery.sent;
  }
}

class ParentAccessInvite extends Equatable {
  final String inviteId;
  final String parentName;
  final String maskedPhone;
  final String maskedEmail;
  final bool hasEmail;
  final int learnerCount;
  final ParentInviteStatus status;
  final ParentInvitationDelivery invitationStatus;
  final DateTime? invitationSentAt;
  final DateTime? canResendAt;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final bool expiringSoon;

  const ParentAccessInvite({
    required this.inviteId,
    required this.parentName,
    required this.maskedPhone,
    this.maskedEmail = '',
    this.hasEmail = false,
    required this.learnerCount,
    required this.status,
    this.invitationStatus = ParentInvitationDelivery.sent,
    this.invitationSentAt,
    this.canResendAt,
    this.createdAt,
    this.expiresAt,
    this.expiringSoon = false,
  });

  /// The parent has completed portal sign-up.
  bool get isAccepted =>
      invitationStatus == ParentInvitationDelivery.accepted;

  /// Active code, parent has not yet accepted - i.e. an invitation still
  /// awaiting the parent.
  bool get isPendingAcceptance =>
      status == ParentInviteStatus.active && !isAccepted;

  bool get isLinked =>
      status == ParentInviteStatus.active && isAccepted && !expiringSoon;

  /// True when a resend is allowed right now (no cooldown, or it has lapsed).
  bool canResendNow(DateTime now) =>
      canResendAt == null || !now.isBefore(canResendAt!);

  @override
  List<Object?> get props => [
    inviteId,
    parentName,
    maskedPhone,
    maskedEmail,
    hasEmail,
    learnerCount,
    status,
    invitationStatus,
    invitationSentAt,
    canResendAt,
    createdAt,
    expiresAt,
    expiringSoon,
  ];
}
