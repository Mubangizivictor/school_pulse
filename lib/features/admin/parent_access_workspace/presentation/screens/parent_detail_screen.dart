import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/components/phone_number_field.dart';
import 'package:school_pulse/design_system/responsive/app_responsive_content.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

import '../../domain/entities/parent_access_invite.dart';
import '../../domain/entities/parent_access_record.dart';
import '../cubit/parent_detail_cubit.dart';

/// Parent detail & access-management screen. Rendered inside the canonical
/// admin shell (desktop sidebar / mobile Parents tab) via
/// [AdminParentsSectionBody] at /staff/admin/parents/:inviteId.
class ParentDetailScreen extends StatelessWidget {
  final String inviteId;

  const ParentDetailScreen({super.key, required this.inviteId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ParentDetailCubit>(param1: inviteId)..load(),
      child: const _ParentDetailView(),
    );
  }
}

class _ParentDetailView extends StatelessWidget {
  const _ParentDetailView();

  bool _isSchoolAdmin(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    return auth is AuthAuthenticated &&
        auth.user.roles.contains(UserRole.schoolAdmin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Parent details'),
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: BlocConsumer<ParentDetailCubit, ParentDetailState>(
        listenWhen: (a, b) =>
            a.actionError != b.actionError ||
            a.actionSuccess != b.actionSuccess,
        listener: (context, state) {
          final msg = state.actionError ?? state.actionSuccess;
          if (msg == null) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: state.actionError != null
                  ? AppColors.danger(context)
                  : AppColors.success(context),
            ),
          );
          context.read<ParentDetailCubit>().clearActionFeedback();
        },
        builder: (context, state) {
          if (state.isPermissionDenied) {
            return const _Centered(
              icon: Icons.lock_outline,
              title: 'You do not have permission',
              message: 'Ask a school admin to manage parent access.',
            );
          }
          if (state.loading && state.record == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.record == null) {
            return _Centered(
              icon: state.isOffline
                  ? Icons.wifi_off_outlined
                  : Icons.error_outline,
              title: state.isOffline
                  ? 'You are offline'
                  : 'Could not load this parent',
              message: state.error ?? 'Something went wrong.',
              onRetry: () => context.read<ParentDetailCubit>().retry(),
            );
          }

          final record = state.record!;
          final canEdit = _isSchoolAdmin(context);
          return AppResponsiveContent(
            maxWidth: 720,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _GuardianCard(
                  record: record,
                  canEdit: canEdit,
                  busy: state.actionInFlight,
                ),
                const SizedBox(height: 16),
                _InvitationCard(record: record, busy: state.actionInFlight),
                const SizedBox(height: 16),
                _LearnersCard(
                  record: record,
                  canOverride: canEdit,
                  busy: state.actionInFlight,
                ),
                const SizedBox(height: 16),
                _AuditCard(entries: state.audit, loading: state.auditLoading),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _GuardianCard extends StatelessWidget {
  final ParentAccessRecord record;
  final bool canEdit;
  final bool busy;

  const _GuardianCard({
    required this.record,
    required this.canEdit,
    required this.busy,
  });

  String _maskPhone(String v) {
    final d = v.replaceAll(RegExp(r'\D'), '');
    return d.length < 4 ? '***' : '***${d.substring(d.length - 4)}';
  }

  String _maskEmail(String v) {
    if (!v.contains('@')) return v;
    return '${v[0]}***@${v.split('@').last}';
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Guardian',
      trailing: canEdit && record.status != ParentInviteStatus.revoked
          ? TextButton(
              onPressed: busy ? null : () => _openEdit(context),
              child: const Text('Edit'),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv(context, 'Name', record.parentName),
          _kv(context, 'Phone', _maskPhone(record.phoneNumber)),
          _kv(
            context,
            'Email',
            record.email.isEmpty ? '—' : _maskEmail(record.email),
          ),
        ],
      ),
    );
  }

  Future<void> _openEdit(BuildContext context) async {
    final cubit = context.read<ParentDetailCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated(context),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _EditGuardianSheet(record: record),
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              k,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditGuardianSheet extends StatefulWidget {
  final ParentAccessRecord record;
  const _EditGuardianSheet({required this.record});

  @override
  State<_EditGuardianSheet> createState() => _EditGuardianSheetState();
}

class _EditGuardianSheetState extends State<_EditGuardianSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.record.parentName,
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.record.email,
  );
  late String _dial;
  late String _national;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final phone = widget.record.phoneNumber;
    // Split an E.164 number into a best-effort dial/national pair.
    final match =
        kPhoneCountries.where((c) => phone.startsWith(c.dialCode)).toList()
          ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));
    if (match.isNotEmpty) {
      _dial = match.first.dialCode;
      _national = phone.substring(_dial.length);
    } else {
      _dial = kDefaultDialCode;
      _national = phone.replaceAll(RegExp(r'^\+'), '');
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  bool get _emailValid =>
      _email.text.trim().isEmpty ||
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim());

  Future<void> _save() async {
    final e164 = phoneToE164(_dial, _national);
    if (_name.text.trim().isEmpty || e164 == null || !_emailValid) return;
    setState(() => _saving = true);
    final original = widget.record;
    final ok = await context.read<ParentDetailCubit>().updateDetails(
      parentName: _name.text.trim() == original.parentName
          ? null
          : _name.text.trim(),
      phoneNumber: e164 == original.phoneNumber ? null : e164,
      email: _email.text.trim() == original.email ? null : _email.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit guardian',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          PhoneNumberField(
            dialCode: _dial,
            nationalNumber: _national,
            onDialCodeChanged: (v) => setState(() => _dial = v),
            onNationalNumberChanged: (v) => _national = v,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email (optional)',
              errorText: _emailValid ? null : 'Enter a valid email',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save changes'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final ParentAccessRecord record;
  final bool busy;

  const _InvitationCard({required this.record, required this.busy});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final revoked = record.status == ParentInviteStatus.revoked;
    final expired = record.status == ParentInviteStatus.expired;
    final canResend = record.canResendNow(now);

    final (label, color) = revoked
        ? ('Revoked', AppColors.danger(context))
        : expired
        ? ('Expired', AppColors.danger(context))
        : record.invitationStatus == ParentInvitationDelivery.accepted
        ? ('Active', AppColors.success(context))
        : ('Pending', AppColors.warning(context));

    return _SectionCard(
      title: 'Invitation & access',
      trailing: Row(
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
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (record.expiresAt != null)
            Text(
              '${revoked ? 'Was valid until' : 'Expires'} '
              '${_date(record.expiresAt!)}',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12.5,
              ),
            ),
          const SizedBox(height: 12),
          if (!revoked)
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: busy || !canResend
                      ? null
                      : () => context
                            .read<ParentDetailCubit>()
                            .resendInvitation(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(canResend ? 'Resend invitation' : 'Resend soon'),
                ),
                OutlinedButton.icon(
                  onPressed: busy ? null : () => _confirmRevoke(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger(context),
                    side: BorderSide(color: AppColors.danger(context)),
                  ),
                  icon: const Icon(Icons.block, size: 16),
                  label: const Text('Revoke access'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _confirmRevoke(BuildContext context) async {
    final cubit = context.read<ParentDetailCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Revoke parent access?'),
        content: const Text(
          'The parent can no longer use this invitation or code. Linked '
          'learners are not removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (ok == true) cubit.revoke();
  }

  String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

class _LearnersCard extends StatelessWidget {
  final ParentAccessRecord record;
  final bool canOverride;
  final bool busy;

  const _LearnersCard({
    required this.record,
    required this.canOverride,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    final active = record.learners
        .where((l) => l.linkStatus != 'revoked')
        .toList();
    return _SectionCard(
      title: 'Linked learners (${active.length})',
      child: Column(
        children: [
          for (final learner in active)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          learner.studentName,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          [
                            learner.className,
                            learner.relationship,
                            if (learner.isPrimaryContact) 'Primary contact',
                          ].where((v) => v.isNotEmpty).join(' · '),
                          style: TextStyle(
                            color: AppColors.textMuted(context),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Unlink learner',
                    icon: Icon(
                      Icons.link_off,
                      size: 18,
                      color: AppColors.danger(context),
                    ),
                    onPressed: busy
                        ? null
                        : () => _confirmUnlink(context, learner),
                  ),
                ],
              ),
            ),
          if (active.isEmpty)
            Text(
              'No active learner links.',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12.5,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmUnlink(
    BuildContext context,
    ParentLinkedLearner learner,
  ) async {
    final cubit = context.read<ParentDetailCubit>();
    // "Last remaining guardian" guard: we cannot see the learner's *other*
    // guardians from this record, so any unlink is treated as potentially
    // removing the last one and needs an explicit, authorised confirmation.
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setSt) {
          final hasReason = reasonController.text.trim().length >= 5;
          return AlertDialog(
            title: Text('Unlink ${learner.studentName}?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canOverride
                      ? 'If this is the learner’s only guardian, they '
                            'will have no linked parent until another is added. '
                            'Provide a reason (kept in the audit log).'
                      : 'Only a school admin can unlink a guardian. Ask an '
                            'admin to perform this change.',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                  ),
                ),
                if (canOverride) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    onChanged: (_) => setSt(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      hintText: 'e.g. custody transfer',
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: canOverride && hasReason
                    ? () => Navigator.of(context).pop(true)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.danger(context),
                ),
                child: const Text('Unlink'),
              ),
            ],
          );
        },
      ),
    );
    if (confirmed == true) {
      cubit.unlinkLearner(
        linkId: learner.linkId,
        reason: reasonController.text.trim(),
      );
    }
  }
}

class _AuditCard extends StatelessWidget {
  final List<ParentLinkAuditEntry> entries;
  final bool loading;

  const _AuditCard({required this.entries, required this.loading});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Audit history',
      child: loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator()),
            )
          : entries.isEmpty
          ? Text(
              'No reallocation or removal events recorded.',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12.5,
              ),
            )
          : Column(
              children: [
                for (final e in entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.history,
                          size: 14,
                          color: AppColors.textMuted(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${e.action} by ${e.actorRole}'
                            '${e.reason.isEmpty ? '' : ' — ${e.reason}'}'
                            '${e.createdAt == null ? '' : ' (${e.createdAt!.toLocal().toString().split('.').first})'}',
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _Centered extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const _Centered({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.textMuted(context)),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
