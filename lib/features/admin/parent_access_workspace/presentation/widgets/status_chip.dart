import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../../domain/entities/parent_access_invite.dart';

class ParentAccessStatusChip extends StatelessWidget {
  final ParentAccessInvite invite;

  const ParentAccessStatusChip({super.key, required this.invite});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _labelAndColor(context, invite);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  (String, Color) _labelAndColor(BuildContext context, ParentAccessInvite i) {
    if (i.status == ParentInviteStatus.revoked) {
      return ('Revoked', AppColors.danger(context));
    }
    if (i.status == ParentInviteStatus.expired) {
      return ('Revoked', AppColors.danger(context));
    }
    if (i.expiringSoon) {
      return ('Expiring soon', AppColors.warning(context));
    }
    return ('Linked', AppColors.success(context));
  }
}

/// Access-codes-tab specific label set (Linked/Pending/Expiring soon/Revoked)
/// - distinct copy from the Parents tab's simpler Linked/Revoked, matching
/// the reference screenshots' two different vocabularies for the same
/// underlying invite status.
class AccessCodeStatusChip extends StatelessWidget {
  final ParentAccessInvite invite;

  const AccessCodeStatusChip({super.key, required this.invite});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _labelAndColor(context, invite);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  (String, Color) _labelAndColor(BuildContext context, ParentAccessInvite i) {
    if (i.status == ParentInviteStatus.revoked) {
      return ('Revoked', AppColors.danger(context));
    }
    if (i.status == ParentInviteStatus.expired) {
      return ('Expired', AppColors.danger(context));
    }
    if (i.expiringSoon) {
      return ('Expiring soon', AppColors.warning(context));
    }
    return ('Linked', AppColors.success(context));
  }
}
