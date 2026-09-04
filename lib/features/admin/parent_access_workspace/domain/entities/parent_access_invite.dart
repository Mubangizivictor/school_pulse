import 'package:equatable/equatable.dart';

/// Server-recomputed state of one parent_access_code_invites document, as
/// returned by the `listParentAccessInvites` callable. Never carries a raw
/// phone number or code/codeHash - [maskedPhone] is the only phone field,
/// pre-masked server-side.
enum ParentInviteStatus { active, revoked, expired }

class ParentAccessInvite extends Equatable {
  final String inviteId;
  final String parentName;
  final String maskedPhone;
  final int learnerCount;
  final ParentInviteStatus status;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final bool expiringSoon;

  const ParentAccessInvite({
    required this.inviteId,
    required this.parentName,
    required this.maskedPhone,
    required this.learnerCount,
    required this.status,
    this.createdAt,
    this.expiresAt,
    this.expiringSoon = false,
  });

  bool get isLinked => status == ParentInviteStatus.active && !expiringSoon;

  @override
  List<Object?> get props => [
    inviteId,
    parentName,
    maskedPhone,
    learnerCount,
    status,
    createdAt,
    expiresAt,
    expiringSoon,
  ];
}
