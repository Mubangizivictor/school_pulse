import '../../domain/entities/parent_access_invite.dart';

class ParentAccessInvitesPage {
  final List<ParentAccessInvite> rows;
  final String? nextCursor;
  final int pendingCount;
  final int expiringSoonCount;

  const ParentAccessInvitesPage({
    required this.rows,
    required this.nextCursor,
    required this.pendingCount,
    required this.expiringSoonCount,
  });

  factory ParentAccessInvitesPage.fromCallableData(Map<String, dynamic> data) {
    final rawRows = (data['rows'] as List?) ?? const [];
    return ParentAccessInvitesPage(
      rows: rawRows
          .map((row) => _inviteFromRow(Map<String, dynamic>.from(row as Map)))
          .toList(),
      nextCursor: data['nextCursor'] as String?,
      pendingCount: (data['pendingCount'] as num?)?.toInt() ?? 0,
      expiringSoonCount: (data['expiringSoonCount'] as num?)?.toInt() ?? 0,
    );
  }

  static ParentAccessInvite _inviteFromRow(Map<String, dynamic> row) {
    ParentInviteStatus status;
    switch (row['status']) {
      case 'revoked':
        status = ParentInviteStatus.revoked;
        break;
      case 'expired':
        status = ParentInviteStatus.expired;
        break;
      default:
        status = ParentInviteStatus.active;
    }
    return ParentAccessInvite(
      inviteId: row['inviteId'] as String? ?? '',
      parentName: row['parentName'] as String? ?? '',
      maskedPhone: row['maskedPhone'] as String? ?? '***',
      learnerCount: (row['learnerCount'] as num?)?.toInt() ?? 0,
      status: status,
      createdAt: _millisToDate(row['createdAt']),
      expiresAt: _millisToDate(row['expiresAt']),
      expiringSoon: row['expiringSoon'] as bool? ?? false,
    );
  }

  static DateTime? _millisToDate(dynamic value) {
    if (value is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
}
