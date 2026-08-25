import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/shared/staff_dashboard/staff_dashboard_widgets.dart';

/// Nurse Home tab. Matches the attached reference: greeting header with a
/// term/date chip, a "Clinic overview" summary card, primary CTAs, quick
/// actions, a "Needs attention" list and today's follow-ups. All figures
/// come from [HealthBloc]'s [HealthDashboardLoaded] state - no mock data.
class NurseHomeScreen extends StatefulWidget {
  const NurseHomeScreen({super.key});

  @override
  State<NurseHomeScreen> createState() => _NurseHomeScreenState();
}

class _NurseHomeScreenState extends State<NurseHomeScreen> {
  static const _bg = Colors.black;
  static const _card = Colors.black;
  static const _muted = Colors.black;

  UserAuthDetails? get _currentUser {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated
        ? UserAuthDetails(name: state.user.name, schoolId: state.user.schoolId)
        : null;
  }

  @override
  void initState() {
    super.initState();
    final schoolId = _currentUser?.schoolId ?? '';
    if (schoolId.isNotEmpty) {
      context.read<HealthBloc>().add(FetchHealthDashboardData(schoolId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final schoolId = _currentUser?.schoolId ?? '';

    return Scaffold(
      backgroundColor: _bg,
      appBar: staffDashboardAppBar(context, roleLabel: 'Nurse'),
      body: SafeArea(
        child: schoolId.isEmpty
            ? const _NoSchoolAssigned()
            : BlocBuilder<HealthBloc, HealthState>(
                builder: (context, state) {
                  if (state is HealthLoading || state is HealthInitial) {
                    return const Center(child: SchoolPulseLoader());
                  }
                  if (state is HealthError) {
                    return _ErrorState(
                      message: state.message,
                      onRetry: () => context.read<HealthBloc>().add(
                        FetchHealthDashboardData(schoolId),
                      ),
                    );
                  }
                  if (state is HealthDashboardLoaded) {
                    final inClinic = state.todayVisits
                        .where(
                          (v) => v.outcome == VisitOutcome.admittedToSickBay,
                        )
                        .length;
                    final urgent = state.todayEmergencies.length;
                    final today = DateTime.now();
                    const months = [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug',
                      'Sep',
                      'Oct',
                      'Nov',
                      'Dec',
                    ];
                    final periodLabel =
                        '${months[today.month - 1]} ${today.day}, ${today.year}';
                    return RefreshIndicator(
                      onRefresh: () async => context.read<HealthBloc>().add(
                        FetchHealthDashboardData(schoolId),
                      ),
                      child: SingleChildScrollView(
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
                                  StaffHeroSummaryCard(
                                    greetingNameFallback: 'Nurse',
                                    periodLabel: periodLabel,
                                    kpis: [
                                      StaffKpiData(
                                        title: 'In Clinic',
                                        valueText: '$inClinic',
                                        subtitle: 'Students',
                                        icon: Icons.groups_outlined,
                                        color: AppColors.information(context),
                                      ),
                                      StaffKpiData(
                                        title: 'Visits Today',
                                        valueText:
                                            '${state.todayVisits.length}',
                                        subtitle: 'Logged',
                                        icon: Icons.monitor_heart_outlined,
                                        color: AppColors.success(context),
                                      ),
                                      StaffKpiData(
                                        title: 'Urgent',
                                        valueText: '$urgent',
                                        subtitle: 'Needs attention',
                                        icon: Icons.warning_amber_rounded,
                                        color: AppColors.danger(context),
                                      ),
                                      StaffKpiData(
                                        title: 'Low Stock',
                                        valueText:
                                            '${state.lowStockItems.length}',
                                        subtitle: 'Items',
                                        icon: Icons.inventory_2_outlined,
                                        color: AppColors.warning(context),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _PrimaryActions(schoolId: schoolId),
                                  const SizedBox(height: 24),
                                  const _SectionLabel('Quick actions'),
                                  const SizedBox(height: 12),
                                  _QuickActions(schoolId: schoolId),
                                  const SizedBox(height: 24),
                                  const _SectionLabel('Needs attention'),
                                  const SizedBox(height: 12),
                                  _NeedsAttentionList(state: state),
                                  const SizedBox(height: 24),
                                  _FollowUpsSection(state: state),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
      ),
    );
  }
}

class UserAuthDetails {
  final String name;
  final String schoolId;
  const UserAuthDetails({required this.name, required this.schoolId});
}

class _NoSchoolAssigned extends StatelessWidget {
  const _NoSchoolAssigned();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'This nurse account is not assigned to a school. Ask an administrator to update the account.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _PrimaryActions extends StatelessWidget {
  final String schoolId;
  const _PrimaryActions({required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            key: const Key('nurse-new-visit-button'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => context.push('/staff/nurse/visits/new', extra: ''),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Start new visit'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.black),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => context.push('/staff/nurse/lookup'),
            icon: const Icon(Icons.qr_code_scanner, size: 20),
            label: const Text('Scan student ID'),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.titleMedium.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final String schoolId;
  const _QuickActions({required this.schoolId});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickActionData(
        'Medication',
        Icons.medication_outlined,
        Colors.black,
        () {
          context.push('/staff/nurse/inventory');
        },
      ),
      _QuickActionData('Sick bay', Icons.bed_outlined, Colors.black, () {
        context.push('/staff/nurse/records');
      }),
      _QuickActionData('Send home', Icons.home_outlined, Colors.black, () {
        context.push('/staff/nurse/visits/new', extra: '');
      }),
      _QuickActionData('Emergency', Icons.emergency_outlined, Colors.black, () {
        context.push('/staff/nurse/records');
      }),
    ];

    return Row(
      children: actions
          .map((a) => Expanded(child: _QuickActionButton(data: a)))
          .toList(),
    );
  }
}

class _QuickActionData {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionData(this.label, this.icon, this.color, this.onTap);
}

class _QuickActionButton extends StatelessWidget {
  final _QuickActionData data;
  const _QuickActionButton({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _NurseHomeScreenState._card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(data.icon, color: data.color, size: 26),
              const SizedBox(height: 8),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 11.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeedsAttentionList extends StatelessWidget {
  final HealthDashboardLoaded state;
  const _NeedsAttentionList({required this.state});

  @override
  Widget build(BuildContext context) {
    final lowStockCount = state.lowStockItems.length;

    final items = <Widget>[];
    if (lowStockCount > 0) {
      items.add(
        _AttentionRow(
          icon: Icons.inventory_2_outlined,
          color: Colors.black,
          title:
              '$lowStockCount low-stock item${lowStockCount == 1 ? '' : 's'}',
          actionLabel: 'Review',
          onTap: () => context.push('/staff/nurse/inventory'),
        ),
      );
    }

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _NurseHomeScreenState._card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Nothing needs attention right now.',
          style: TextStyle(color: _NurseHomeScreenState._muted),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _NurseHomeScreenState._card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            if (i != items.length - 1)
              const Divider(
                height: 1,
                color: Colors.white,
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  const _AttentionRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      trailing: TextButton(
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(actionLabel, style: const TextStyle(color: Colors.black)),
            const Icon(Icons.chevron_right, color: Colors.black, size: 18),
          ],
        ),
      ),
    );
  }
}

class _FollowUpsSection extends StatelessWidget {
  final HealthDashboardLoaded state;
  const _FollowUpsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final upcoming = state.todayVisits
        .where((v) => v.followUpRequired)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionLabel("Today's follow-ups"),
            TextButton(
              onPressed: () => context.push('/staff/nurse/visits'),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (upcoming.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _NurseHomeScreenState._card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'No follow-ups scheduled for today.',
              style: TextStyle(color: _NurseHomeScreenState._muted),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: _NurseHomeScreenState._card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                for (var i = 0; i < upcoming.length && i < 5; i++) ...[
                  _FollowUpRow(visit: upcoming[i]),
                  if (i != upcoming.length - 1 && i != 4)
                    const Divider(
                      height: 1,
                      color: Colors.white,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _FollowUpRow extends StatelessWidget {
  final ClinicVisit visit;
  const _FollowUpRow({required this.visit});

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(visit.dateTime);
    final label = time.format(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        child: const Icon(
          Icons.schedule_outlined,
          color: Colors.black,
          size: 18,
        ),
      ),
      title: Text(
        label,
        style: const TextStyle(color: Colors.black, fontSize: 12),
      ),
      subtitle: Text(
        visit.reason,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white),
      onTap: () => context.push('/staff/nurse/profile/${visit.studentId}'),
    );
  }
}
