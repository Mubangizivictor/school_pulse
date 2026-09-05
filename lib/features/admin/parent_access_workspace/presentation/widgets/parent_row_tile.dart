import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../../domain/entities/parent_access_invite.dart';
import 'status_chip.dart';

/// Dense parent directory row: initials avatar, name, masked phone, linked
/// learner count, status chip, chevron. [invite.maskedPhone] is already
/// server-masked (`***1234`) - never a raw phone number.
class ParentRowTile extends StatelessWidget {
  final ParentAccessInvite invite;
  final VoidCallback? onTap;

  const ParentRowTile({super.key, required this.invite, this.onTap});

  String get _initials {
    final parts = invite.parentName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 && parts.last.isNotEmpty
        ? parts.last[0]
        : '';
    return (first + last).toUpperCase();
  }

  // A deterministic pastel per name (not per row index), so the same parent
  // always gets the same avatar color across reloads/pagination - matches
  // the reference screenshot's varied green/purple/amber/pink/blue avatars
  // rather than one flat grey for every row.
  static const _palette = [
    Color(0xFFDCF5E3), // green
    Color(0xFFE6E1F9), // purple
    Color(0xFFFCEEDC), // amber
    Color(0xFFFBE1E8), // pink
    Color(0xFFDCEBFB), // blue
  ];

  Color _avatarColor(BuildContext context) {
    if (invite.parentName.isEmpty) return AppColors.surfaceContainerHigh(context);
    final index = invite.parentName.codeUnits.fold<int>(0, (a, b) => a + b) % _palette.length;
    return _palette[index];
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: '${invite.parentName}, ${invite.maskedPhone}, '
          '${invite.learnerCount} learner${invite.learnerCount == 1 ? '' : 's'} linked',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _avatarColor(context),
                child: Text(
                  _initials,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite.parentName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${invite.maskedPhone} • ${invite.learnerCount} '
                      'learner${invite.learnerCount == 1 ? '' : 's'} linked',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              ParentAccessStatusChip(invite: invite),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textMuted(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
