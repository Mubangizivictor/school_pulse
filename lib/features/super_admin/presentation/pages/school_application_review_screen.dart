import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import '../../domain/entities/school_application.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';

class SchoolApplicationReviewScreen extends StatelessWidget {
  final SchoolApplication application;

  const SchoolApplicationReviewScreen({super.key, required this.application});

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
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: .35,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.chevron_left,
                  color: theme.colorScheme.primary,
                ),
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'School Application',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Review before approving',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth >= 700 ? 28.0 : 16.0;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        horizontal,
                        14,
                        horizontal,
                        128,
                      ),
                      children: [
                        _ApplicationHero(application: application),
                        const SizedBox(height: 14),
                        _ReviewChecklist(application: application),
                        const SizedBox(height: 14),
                        _DetailCard(
                          title: 'School',
                          icon: Icons.school_outlined,
                          rows: [
                            _Detail('School name', application.schoolName),
                            _Detail('Short name', application.shortName),
                            _Detail('Initials', application.prefix),
                            _Detail('Category', application.category),
                            _Detail('Email', application.schoolEmail),
                            _Detail('Phone', _phone(application.schoolPhone)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DetailCard(
                          title: 'Location',
                          icon: Icons.location_on_outlined,
                          rows: [
                            _Detail('Area', application.address),
                            _Detail('District', application.district),
                            _Detail('Region', application.region),
                            const _Detail('Country', 'Uganda'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DetailCard(
                          title: 'Subscription',
                          icon: Icons.workspace_premium_outlined,
                          rows: [
                            _Detail('Selected plan', application.plan),
                            _Detail(
                              'Modules',
                              application.selectedModules.isEmpty
                                  ? 'Core School Pulse modules'
                                  : application.selectedModules.join(', '),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DetailCard(
                          title: 'Administrator',
                          icon: Icons.admin_panel_settings_outlined,
                          rows: [
                            _Detail('Name', application.administratorName),
                            _Detail('Email', application.administratorEmail),
                            _Detail(
                              'Phone',
                              _phone(application.administratorPhone),
                            ),
                            _Detail(
                              'Email verified',
                              application.administratorEmailVerified
                                  ? 'Yes'
                                  : 'No',
                              valueColor: application.administratorEmailVerified
                                  ? AppColors.success(context)
                                  : theme.colorScheme.error,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DetailCard(
                          title: 'Application',
                          icon: Icons.fact_check_outlined,
                          rows: [
                            _Detail(
                              'Terms accepted',
                              application.termsAccepted ? 'Yes' : 'No',
                            ),
                            _Detail('Submitted', _date(application.createdAt)),
                            _Detail(
                              'Last updated',
                              _date(application.updatedAt),
                            ),
                            if ((application.rejectionReason ?? '').isNotEmpty)
                              _Detail(
                                'Previous review note',
                                application.rejectionReason!,
                                valueColor: theme.colorScheme.error,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: application.canReview
              ? _ReviewActions(
                  busy: busy,
                  onReject: () => _reject(context),
                  onApprove: () => _approve(context),
                )
              : null,
        );
      },
    );
  }

  Future<void> _approve(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            4,
            20,
            20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.verified_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Approve ${application.schoolName}?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This creates the school tenant and makes the verified applicant the first School Admin. Paid access stays locked until the subscription payment is received and manually verified.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: .55,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_clock_outlined, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Approval does not activate the dashboard. The school must complete payment first.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(sheetContext, true),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Approve & Request Payment'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    context.read<SuperAdminBloc>().add(
      ApproveSchoolApplicationEvent(application.id),
    );
  }

  Future<void> _reject(BuildContext context) async {
    final controller = TextEditingController();
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reject application',
              style: Theme.of(
                sheetContext,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Give the school a clear reason so they know what needs correction.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 500,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText:
                    'e.g. We could not verify the submitted school details.',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final value = controller.text.trim();
                  if (value.length < 3) return;
                  Navigator.pop(sheetContext, value);
                },
                icon: const Icon(Icons.close_rounded),
                label: const Text('Reject Application'),
              ),
            ),
          ],
        ),
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

  static String _date(DateTime? date) => date == null
      ? '—'
      : DateFormat('dd MMM yyyy, h:mm a').format(date.toLocal());
  static String _phone(String value) => value.isEmpty
      ? '—'
      : value.startsWith('256')
      ? '+$value'
      : value;
}

class _ApplicationHero extends StatelessWidget {
  final SchoolApplication application;
  const _ApplicationHero({required this.application});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(application.status, context);
    final initial = application.schoolName.trim().isEmpty
        ? 'S'
        : application.schoolName.trim()[0].toUpperCase();
    final statusIcon = switch (application.status) {
      SchoolApplicationStatus.approved => Icons.check_circle,
      SchoolApplicationStatus.rejected => Icons.cancel,
      _ => Icons.schedule,
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: .6),
              theme.colorScheme.surface,
            ],
          ),
          border: Border.all(color: theme.dividerColor.withValues(alpha: .7)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _HeroWavePainter(
                  color: theme.colorScheme.primary.withValues(alpha: .16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      initial,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.schoolName.isEmpty
                              ? 'Unnamed school'
                              : application.schoolName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${application.district.isEmpty ? 'Uganda' : application.district} • ${application.plan.isEmpty ? 'Plan not selected' : '${application.plan} plan'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 15, color: color),
                              const SizedBox(width: 5),
                              Text(
                                application.status.label,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _HeroWavePainter extends CustomPainter {
  final Color color;
  const _HeroWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width * .55, size.height)
      ..quadraticBezierTo(
        size.width * .78,
        size.height * .35,
        size.width,
        size.height * .55,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeroWavePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ReviewChecklist extends StatelessWidget {
  final SchoolApplication application;
  const _ReviewChecklist({required this.application});
  @override
  Widget build(BuildContext context) {
    final items = <(String, bool)>[
      ('Email verified', application.administratorEmailVerified),
      ('Terms accepted', application.termsAccepted),
      ('Plan selected', application.plan.trim().isNotEmpty),
      ('School location provided', application.district.trim().isNotEmpty),
    ];
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 420 ? 2 : 1;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: columns == 2 ? 3.6 : 5.2,
          children: items.map((item) {
            final color = item.$2
                ? AppColors.success(context)
                : theme.colorScheme.error;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: .6),
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.$2 ? Icons.check : Icons.close,
                      size: 14,
                      color: theme.colorScheme.surface,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.$1,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Detail {
  final String label;
  final String value;
  final Color? valueColor;
  const _Detail(this.label, this.value, {this.valueColor});
}

class _DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_Detail> rows;
  const _DetailCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.dividerColor.withValues(alpha: .65)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: .45,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 19, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 118,
                    child: Text(
                      row.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      row.value.trim().isEmpty ? '—' : row.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: row.valueColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewActions extends StatelessWidget {
  final bool busy;
  final VoidCallback onReject;
  final VoidCallback onApprove;
  const _ReviewActions({
    required this.busy,
    required this.onReject,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: busy ? null : onReject,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: busy ? null : onApprove,
                icon: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(busy ? 'Processing…' : 'Approve & Request Payment'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _statusColor(SchoolApplicationStatus status, BuildContext context) {
  switch (status) {
    case SchoolApplicationStatus.pendingReview:
      return AppColors.warning(context);
    case SchoolApplicationStatus.approved:
      return AppColors.success(context);
    case SchoolApplicationStatus.rejected:
      return Theme.of(context).colorScheme.error;
    case SchoolApplicationStatus.emailVerified:
      return AppColors.information(context);
    case SchoolApplicationStatus.emailVerificationPending:
      return AppColors.warning(context);
    case SchoolApplicationStatus.unknown:
      return Theme.of(context).colorScheme.outline;
  }
}
