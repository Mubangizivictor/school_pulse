import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

import 'package:school_pulse/core/error/friendly_error_message.dart';

import '../../data/services/school_admin_management_service.dart';
import '../../domain/entities/school.dart';
import '../../domain/repositories/super_admin_repository.dart';
import '../bloc/super_admin_bloc.dart';

/// Real School Admin Management screen for the selected school. Super
/// Admin only - this screen is only reachable via the /super-admin route
/// tree, whose top-level redirect guard (lib/app/router.dart) already
/// denies every other role, so no separate gate is added here.
///
/// Every sensitive action (setPrimary/disable/enable/remove) goes through
/// the owner-only, transactional `manageSchoolAdmin` callable - the
/// last-active-admin protection, audit log, and session revocation all live
/// server-side there, not in this widget. Invite writes the real
/// `school_admin_invitations` doc the existing `provisionSchoolAdmin`
/// trigger already consumes.
class SchoolAdminManagementScreen extends StatefulWidget {
  const SchoolAdminManagementScreen({super.key, required this.school});
  final School school;

  @override
  State<SchoolAdminManagementScreen> createState() =>
      _SchoolAdminManagementScreenState();
}

class _SchoolAdminManagementScreenState
    extends State<SchoolAdminManagementScreen> {
  final SchoolAdminManagementService _service = SchoolAdminManagementService();

  bool _loading = true;
  String? _error;
  List<SchoolAdminSummary> _admins = const [];

  bool get _schoolIsActive => widget.school.status == SchoolStatus.active;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = context.read<SuperAdminBloc>().repository;
      final admins = await repository.getSchoolAdmins(widget.school.id);
      if (!mounted) return;
      setState(() {
        _admins = admins;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = friendlyErrorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          '${widget.school.name} · Admins',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Invite administrator',
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: _schoolIsActive ? _openInviteSheet : null,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.x4l),
            child: Center(child: SchoolPulseLoader()),
          ),
        ],
      );
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              children: [
                Icon(Icons.error_outline_rounded, color: AppColors.danger(context)),
                const SizedBox(height: AppSpacing.s),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                TextButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        if (!_schoolIsActive)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.l),
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.warningSurface(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.warning(context)),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    'This school is ${widget.school.status.name}. Admin access changes are unavailable until it is reactivated.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (_admins.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text(
                'No school admin accounts found for this school.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
          )
        else
          for (final admin in _admins) ...[
            _AdminCard(
              admin: admin,
              schoolActive: _schoolIsActive,
              onSetPrimary: admin.isPrimary
                  ? null
                  : () => _confirmAction(
                      admin: admin,
                      action: SchoolAdminAction.setPrimary,
                      title: 'Make primary administrator?',
                      message:
                          '${admin.name} will become the primary administrator for ${widget.school.name}.',
                    ),
              onDisable: () => _confirmAction(
                admin: admin,
                action: SchoolAdminAction.disable,
                title: 'Disable administrator?',
                message:
                    '${admin.name} will immediately lose access. Every active session is revoked. This is logged.',
                requireReason: true,
              ),
              onRemove: () => _confirmAction(
                admin: admin,
                action: SchoolAdminAction.remove,
                title: 'Remove administrator?',
                message:
                    '${admin.name} will be removed as an administrator and lose access immediately. This is logged.',
                requireReason: true,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
          ],
      ],
    );
  }

  void _openInviteSheet() {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool sending = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.l,
            right: AppSpacing.l,
            top: AppSpacing.l,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.l,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite administrator',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(sheetContext),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'They will receive a temporary password to sign in and set up their own account.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(sheetContext),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                TextFormField(
                  controller: emailController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email address'),
                  validator: (value) =>
                      (value == null || !value.contains('@'))
                      ? 'Enter a valid email address'
                      : null,
                ),
                const SizedBox(height: AppSpacing.l),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: sending ? null : () => Navigator.pop(sheetContext),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: FilledButton(
                        onPressed: sending
                            ? null
                            : () async {
                                if (formKey.currentState?.validate() != true) return;
                                setSheetState(() => sending = true);
                                try {
                                  await _service.inviteAdmin(
                                    schoolId: widget.school.id,
                                    tenantId: widget.school.tenantId,
                                    email: emailController.text,
                                  );
                                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Invitation sent.')),
                                    );
                                    _load();
                                  }
                                } catch (e) {
                                  setSheetState(() => sending = false);
                                  if (sheetContext.mounted) {
                                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          friendlyErrorMessage(e),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                        child: sending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Send invite'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmAction({
    required SchoolAdminSummary admin,
    required SchoolAdminAction action,
    required String title,
    required String message,
    bool requireReason = false,
  }) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (requireReason) ...[
              const SizedBox(height: AppSpacing.m),
              TextField(
                controller: reasonController,
                autofocus: true,
                minLines: 2,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'e.g. Requested by the school',
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: action == SchoolAdminAction.disable || action == SchoolAdminAction.remove
                ? FilledButton.styleFrom(backgroundColor: Theme.of(dialogContext).colorScheme.error)
                : null,
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (requireReason && reason.length < 3) return;
              Navigator.pop(dialogContext);
              try {
                await _service.manage(
                  schoolId: widget.school.id,
                  targetUid: admin.uid,
                  action: action,
                  reason: requireReason ? reason : null,
                );
                if (mounted) _load();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        friendlyErrorMessage(e),
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({
    required this.admin,
    required this.schoolActive,
    required this.onSetPrimary,
    required this.onDisable,
    required this.onRemove,
  });
  final SchoolAdminSummary admin;
  final bool schoolActive;
  final VoidCallback? onSetPrimary;
  final VoidCallback onDisable;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary(context).withValues(alpha: .14),
                child: Text(
                  admin.name.isEmpty ? '?' : admin.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(color: AppColors.primary(context), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            admin.name,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        if (admin.isPrimary) ...[
                          const SizedBox(width: 6),
                          StatusBadge(label: 'Primary', color: AppColors.primary(context)),
                        ],
                      ],
                    ),
                    Text(
                      admin.email,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: admin.mfaEnabled ? '2FA on' : '2FA off',
                color: admin.mfaEnabled ? AppColors.success(context) : AppColors.textSecondary(context),
              ),
            ],
          ),
          if (admin.lastSignInAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Last sign in ${DateFormat('MMM d, yyyy, h:mm a').format(admin.lastSignInAt!)}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted(context),
                fontSize: 11,
              ),
            ),
          ],
          if (schoolActive) ...[
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              children: [
                if (onSetPrimary != null)
                  OutlinedButton(onPressed: onSetPrimary, child: const Text('Make primary')),
                OutlinedButton(onPressed: onDisable, child: const Text('Disable')),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger(context)),
                  onPressed: onRemove,
                  child: const Text('Remove'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
