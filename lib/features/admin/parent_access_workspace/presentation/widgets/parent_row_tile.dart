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
                backgroundColor: AppColors.surfaceContainerHigh(context),
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
              if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textMuted(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
