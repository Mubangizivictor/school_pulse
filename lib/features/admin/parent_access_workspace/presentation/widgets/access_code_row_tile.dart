import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../../domain/entities/parent_access_invite.dart';
import 'status_chip.dart';

/// Dense Access-codes-tab row. Never renders a raw code - only
/// [invite.maskedPhone] and code-state fields. Revoke/Reallocate are
/// gated by [canRevoke]/[canReallocate] (role permission, checked by the
/// caller against the signed-in user). Resend is always disabled this pass -
/// no backend support exists yet.
class AccessCodeRowTile extends StatelessWidget {
  final ParentAccessInvite invite;
  final bool canRevoke;
  final bool canReallocate;
  final VoidCallback? onRevoke;
  final VoidCallback? onReallocate;

  const AccessCodeRowTile({
    super.key,
    required this.invite,
    this.canRevoke = false,
    this.canReallocate = false,
    this.onRevoke,
    this.onReallocate,
  });

  bool get _isActionable => invite.status == ParentInviteStatus.active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
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
                  'learner${invite.learnerCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          AccessCodeStatusChip(invite: invite),
          const SizedBox(width: 8),
          _ActionsMenu(
            invite: invite,
            isActionable: _isActionable,
            canRevoke: canRevoke,
            canReallocate: canReallocate,
            onRevoke: onRevoke,
            onReallocate: onReallocate,
          ),
        ],
      ),
    );
  }
}

class _ActionsMenu extends StatelessWidget {
  final ParentAccessInvite invite;
  final bool isActionable;
  final bool canRevoke;
  final bool canReallocate;
  final VoidCallback? onRevoke;
  final VoidCallback? onReallocate;

  const _ActionsMenu({
    required this.invite,
    required this.isActionable,
    required this.canRevoke,
    required this.canReallocate,
    this.onRevoke,
    this.onReallocate,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Actions for ${invite.parentName}',
      button: true,
      child: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: AppColors.textMuted(context)),
        onSelected: (value) {
          if (value == 'revoke') onRevoke?.call();
          if (value == 'reallocate') onReallocate?.call();
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            // TODO(parent-access): resend requires a new Cloud Function.
            child: Row(
              children: [
                const Icon(Icons.send_outlined, size: 18),
                const SizedBox(width: 8),
                const Text('Resend'),
                const Spacer(),
                Text(
                  'Soon',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'reallocate',
            enabled: isActionable && canReallocate,
            child: const Row(
              children: [
                Icon(Icons.swap_horiz, size: 18),
                SizedBox(width: 8),
                Text('Reallocate'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'revoke',
            enabled: isActionable && canRevoke,
            child: Row(
              children: [
                Icon(Icons.block, size: 18, color: AppColors.danger(context)),
                const SizedBox(width: 8),
                Text('Revoke', style: TextStyle(color: AppColors.danger(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
