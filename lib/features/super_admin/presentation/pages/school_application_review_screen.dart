import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/school_application.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';

class SchoolApplicationReviewScreen extends StatelessWidget {
  final SchoolApplication application;

  const SchoolApplicationReviewScreen({
    super.key,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SuperAdminBloc, SuperAdminState>(
      listenWhen: (previous, current) =>
          previous.actionMessage != current.actionMessage ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (state.actionMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).maybePop();
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final busy = state.reviewingApplicationId == application.id;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Review School Application'),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  children: [
                    _ApplicationHeader(application: application),
                    const SizedBox(height: 18),
                    _SectionCard(
                      title: 'School information',
                      icon: Icons.school_outlined,
                      children: [
                        _InfoRow('School name', application.schoolName),
                        _InfoRow('Short name', application.shortName),
                        _InfoRow('School prefix', application.prefix),
                        _InfoRow('Category', application.category),
                        _InfoRow('School email', application.schoolEmail),
                        _InfoRow('School phone', _phone(application.schoolPhone)),
                        _InfoRow('Motto', application.motto),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Location',
                      icon: Icons.location_on_outlined,
                      children: [
                        _InfoRow('Region', application.region),
                        _InfoRow('District', application.district),
                        _InfoRow('Physical address', application.address),
                        _InfoRow('Website', application.website),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Subscription & modules',
                      icon: Icons.workspace_premium_outlined,
                      children: [
                        _InfoRow('Selected plan', application.plan),
                        if (application.selectedModules.isEmpty)
                          const _InfoRow(
                            'Modules',
                            'Core School Pulse modules',
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: application.selectedModules
                                  .map(
                                    (module) => Chip(
                                      avatar: const Icon(
                                        Icons.check_circle_outline,
                                        size: 17,
                                      ),
                                      label: Text(module),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Administrator',
                      icon: Icons.admin_panel_settings_outlined,
                      children: [
                        _InfoRow('Name', application.administratorName),
                        _InfoRow('Email', application.administratorEmail),
                        _InfoRow(
                          'Email verification',
                          application.administratorEmailVerified
                              ? 'Verified'
                              : 'Not verified',
                          valueColor: application.administratorEmailVerified
                              ? Colors.green
                              : theme.colorScheme.error,
                        ),
                        _InfoRow(
                          'Phone',
                          _phone(application.administratorPhone),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Application checks',
                      icon: Icons.verified_user_outlined,
                      children: [
                        _InfoRow(
                          'Terms accepted',
                          application.termsAccepted ? 'Yes' : 'No',
                          valueColor: application.termsAccepted
                              ? Colors.green
                              : theme.colorScheme.error,
                        ),
                        _InfoRow(
                          'Submitted',
                          _date(application.createdAt),
                        ),
                        _InfoRow(
                          'Last updated',
                          _date(application.updatedAt),
                        ),
                        if (application.reviewedAt != null)
                          _InfoRow(
                            'Reviewed',
                            _date(application.reviewedAt),
                          ),
                        if ((application.rejectionReason ?? '').isNotEmpty)
                          _InfoRow(
                            'Rejection reason',
                            application.rejectionReason!,
                            valueColor: theme.colorScheme.error,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: application.canReview
              ? SafeArea(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        top: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: busy
                                    ? null
                                    : () => _reject(context),
                                icon: const Icon(Icons.close_rounded),
                                label: const Text('Reject'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error,
                                  minimumSize: const Size.fromHeight(52),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: FilledButton.icon(
                                onPressed: busy
                                    ? null
                                    : () => _approve(context),
                                icon: busy
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.check_rounded),
                                label: Text(
                                  busy ? 'Processing…' : 'Approve School',
                                ),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Future<void> _approve(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.verified_outlined),
        title: Text('Approve ${application.schoolName}?'),
        content: const Text(
          'This creates the live school tenant, activates the submitted plan and modules, links the verified applicant as the first School Admin, and records the approval in the platform audit trail.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Approve School'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<SuperAdminBloc>().add(
      ApproveSchoolApplicationEvent(application.id),
    );
  }

  Future<void> _reject(BuildContext context) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.cancel_outlined,
          color: Theme.of(dialogContext).colorScheme.error,
        ),
        title: const Text('Reject application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a clear reason. It is stored with the application and the owner audit trail.',
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 500,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'e.g. We could not verify the submitted school details.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.length < 3) return;
              Navigator.pop(dialogContext, value);
            },
            child: const Text('Reject Application'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || !context.mounted) return;
    context.read<SuperAdminBloc>().add(
      RejectSchoolApplicationEvent(
        applicationId: application.id,
        reason: reason,
      ),
    );
  }

  static String _date(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('dd MMM yyyy, h:mm a').format(date.toLocal());
  }

  static String _phone(String value) {
    if (value.isEmpty) return '—';
    if (value.startsWith('256')) return '+$value';
    return value;
  }
}

class _ApplicationHeader extends StatelessWidget {
  final SchoolApplication application;

  const _ApplicationHeader({required this.application});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(application.status, theme);
    final initial = application.schoolName.trim().isEmpty
        ? 'S'
        : application.schoolName.trim()[0].toUpperCase();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                initial,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.schoolName.isEmpty
                        ? 'Unnamed school'
                        : application.schoolName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${application.district.isEmpty ? 'Location pending' : application.district} • ${application.plan.isEmpty ? 'Plan not selected' : '${application.plan} plan'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      application.status.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 21, color: theme.colorScheme.primary),
                const SizedBox(width: 9),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '—' : value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(SchoolApplicationStatus status, ThemeData theme) {
  switch (status) {
    case SchoolApplicationStatus.pendingReview:
      return Colors.orange.shade800;
    case SchoolApplicationStatus.approved:
      return Colors.green.shade700;
    case SchoolApplicationStatus.rejected:
      return theme.colorScheme.error;
    case SchoolApplicationStatus.emailVerified:
      return Colors.blue.shade700;
    case SchoolApplicationStatus.emailVerificationPending:
      return Colors.amber.shade900;
    case SchoolApplicationStatus.unknown:
      return theme.colorScheme.outline;
  }
}
