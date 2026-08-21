import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/features/shared/staff_dashboard/staff_dashboard_widgets.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/injection_container.dart';
import '../../domain/entities/academic_dashboard_stats.dart';

/// Dean of Studies dashboard, built to match the School Admin dashboard's
/// layout, spacing, and card patterns exactly (gradient hero + KPI row,
/// AppBar header, Quick Access grid, AppCard+SectionHeader sections).
class DeanDashboardScreen extends StatefulWidget {
  const DeanDashboardScreen({super.key});

  @override
  State<DeanDashboardScreen> createState() => _DeanDashboardScreenState();
}

class _DeanDashboardScreenState extends State<DeanDashboardScreen> {
  AcademicTerm? _selectedTerm;

  void _showTermPicker(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : null;
    if (schoolId == null || schoolId.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _TermPickerSheet(
        schoolId: schoolId,
        onPicked: (term) => setState(() => _selectedTerm = term),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(AcademicDashboardRequested()),
      child: Scaffold(
        appBar: staffDashboardAppBar(context, roleLabel: 'Dean of Studies'),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.l,
                  AppSpacing.xl,
                  AppSpacing.x3l,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<DeanBloc, DeanState>(
                      builder: (context, state) {
                        final label =
                            _selectedTerm?.name ??
                            (state is AcademicDashboardLoaded
                                ? '${state.stats.currentAcademicYear} • ${state.stats.currentTerm}'
                                : null);
                        final stats = state is AcademicDashboardLoaded
                            ? state.stats
                            : null;
                        return StaffHeroSummaryCard(
                          greetingNameFallback: 'Dean',
                          periodLabel: label,
                          onPeriodTap: () => _showTermPicker(context),
                          kpis: stats == null
                              ? null
                              : [
                                  StaffKpiData(
                                    title: 'Lessons Today',
                                    valueText:
                                        '${stats.lessonsConductedToday}',
                                    subtitle:
                                        '${stats.lessonsConductedToday} completed',
                                    icon: Icons.menu_book_rounded,
                                    color: AppColors.information(context),
                                  ),
                                  StaffKpiData(
                                    title: 'Missed Lessons',
                                    valueText: '${stats.lessonsMissedToday}',
                                    subtitle: 'Needs action',
                                    icon: Icons.event_busy_rounded,
                                    color: AppColors.danger(context),
                                  ),
                                  StaffKpiData(
                                    title: 'Assessments',
                                    valueText: '${stats.assessmentsPending}',
                                    subtitle: 'Today',
                                    icon: Icons.fact_check_rounded,
                                    color: AppColors.success(context),
                                  ),
                                  StaffKpiData(
                                    title: 'Marks Pending',
                                    valueText: '${stats.marksPendingEntry}',
                                    subtitle: 'Requires review',
                                    icon: Icons.description_rounded,
                                    color: AppColors.warning(context),
                                  ),
                                ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _QuickAccessSection(),
                    const SizedBox(height: AppSpacing.xl),
                    const _CriticalAttentionCard(),
                    const SizedBox(height: AppSpacing.l),
                    const _RecentAlertsCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TermPickerSheet extends StatelessWidget {
  const _TermPickerSheet({required this.schoolId, required this.onPicked});

  final String schoolId;
  final ValueChanged<AcademicTerm> onPicked;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Switch Term'),
            const SizedBox(height: 12),
            StreamBuilder<List<AcademicTerm>>(
              stream: sl<StructureRepository>().watchAcademicTerms(schoolId),
              builder: (context, snapshot) {
                final terms =
                    (snapshot.data ?? const <AcademicTerm>[])
                        .where((t) => !t.isArchived)
                        .toList()
                      ..sort((a, b) => a.order.compareTo(b.order));
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (terms.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No terms configured yet.'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: terms.length,
                  itemBuilder: (context, index) {
                    final term = terms[index];
                    return ListTile(
                      leading: const Icon(Icons.calendar_today_rounded),
                      title: Text(term.name),
                      subtitle: Text(
                        '${_formatDate(term.startDate)} - ${_formatDate(term.endDate)}',
                      ),
                      trailing: term.isCurrent
                          ? Icon(
                              Icons.check_circle,
                              color: AppColors.success(context),
                            )
                          : null,
                      onTap: () {
                        Navigator.of(context).pop();
                        onPicked(term);
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}

class _QuickAccessItem {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  const _QuickAccessItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });
}

const _quickAccessItems = [
  _QuickAccessItem(
    label: 'Curriculum',
    icon: Icons.menu_book_rounded,
    color: Colors.blueAccent,
    route: '/staff/dean/curriculum',
  ),
  _QuickAccessItem(
    label: 'Lessons',
    icon: Icons.history_edu_rounded,
    color: Colors.indigo,
    route: '/staff/dean/lessons',
  ),
  _QuickAccessItem(
    label: 'Marks QA',
    icon: Icons.grading_rounded,
    color: Colors.teal,
    route: '/staff/dean/marks-qa',
  ),
  _QuickAccessItem(
    label: 'Interventions',
    icon: Icons.psychology_rounded,
    color: Colors.deepPurple,
    route: '/staff/dean/interventions',
  ),
  _QuickAccessItem(
    label: 'Observations',
    icon: Icons.visibility_rounded,
    color: Colors.cyan,
    route: '/staff/dean/observations',
  ),
  _QuickAccessItem(
    label: 'Report Approvals',
    icon: Icons.verified_user_rounded,
    color: Colors.green,
    route: '/staff/dean/approvals',
  ),
];

class _QuickAccessSection extends StatelessWidget {
  const _QuickAccessSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Access'),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppSpacing.m,
            crossAxisSpacing: AppSpacing.m,
            childAspectRatio: 2.05,
          ),
          itemCount: _quickAccessItems.length,
          itemBuilder: (context, index) =>
              _QuickAccessTile(item: _quickAccessItems[index]),
        ),
      ],
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  final _QuickAccessItem item;

  const _QuickAccessTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: 6,
      ),
      showShadow: false,
      onTap: () => GoRouter.of(context).push(item.route),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: AppRadius.medium,
            ),
            child: Icon(item.icon, color: item.color, size: 16),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              item.label,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CriticalAttentionCard extends StatelessWidget {
  const _CriticalAttentionCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeanBloc, DeanState>(
      builder: (context, state) {
        final loading = state is DeanLoading;
        final error = state is DeanError;
        final alerts = state is AcademicDashboardLoaded
            ? state.stats.activeAlerts
            : const <AcademicAlert>[];

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Critical Attention',
                actionLabel: alerts.isNotEmpty ? 'View all' : null,
                onActionPressed: () =>
                    Navigator.of(context).pushNamed('alerts'),
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: Skeleton(height: 56),
                )
              else if (error)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Text(
                          "Couldn't load alerts. Pull to refresh.",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              else if (alerts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.success(context),
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Text(
                          'All clear — nothing needs your attention.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...alerts
                    .take(4)
                    .map((alert) => _CriticalAttentionRow(alert: alert)),
            ],
          ),
        );
      },
    );
  }
}

class _CriticalAttentionRow extends StatelessWidget {
  final AcademicAlert alert;

  const _CriticalAttentionRow({required this.alert});

  Color _color(BuildContext context) {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return AppColors.danger(context);
      case AlertSeverity.high:
        return AppColors.warning(context);
      case AlertSeverity.medium:
        return AppColors.information(context);
      case AlertSeverity.low:
        return Theme.of(context).colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return InkWell(
      borderRadius: AppRadius.medium,
      onTap: () => Navigator.of(context).pushNamed('alerts'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadius.medium,
              ),
              child: Icon(Icons.error, color: color, size: 16),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Text(
                alert.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentAlertsCard extends StatelessWidget {
  const _RecentAlertsCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeanBloc, DeanState>(
      builder: (context, state) {
        final loading = state is DeanLoading;
        final error = state is DeanError;
        final alerts = state is AcademicDashboardLoaded
            ? state.stats.activeAlerts
            : const <AcademicAlert>[];

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Recent Activity',
                actionLabel: alerts.isNotEmpty ? 'View all' : null,
                onActionPressed: () =>
                    Navigator.of(context).pushNamed('alerts'),
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: Skeleton(height: 56),
                )
              else if (error)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: Text(
                    "Couldn't load recent activity. Pull to refresh.",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else if (alerts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: Text(
                    'No recent activity yet.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else
                ...alerts.skip(4).take(5).map((a) => _ActivityRow(alert: a)),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final AcademicAlert alert;

  const _ActivityRow({required this.alert});

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.medium,
            ),
            child: Icon(Icons.info_outline_rounded, color: color, size: 16),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  alert.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Text(
            _timeAgo(alert.timestamp),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
