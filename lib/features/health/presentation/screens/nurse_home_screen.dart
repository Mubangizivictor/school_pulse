import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/nurse/presentation/clinic_ui.dart';

class NurseHomeScreen extends StatefulWidget {
  const NurseHomeScreen({super.key});
  @override
  State<NurseHomeScreen> createState() => _NurseHomeScreenState();
}

class _NurseHomeScreenState extends State<NurseHomeScreen> {
  String get _schoolId {
    final s = context.read<AuthBloc>().state;
    return s is AuthAuthenticated ? s.user.schoolId : '';
  }

  String get _name {
    final s = context.read<AuthBloc>().state;
    return s is AuthAuthenticated ? s.user.name : 'Nurse';
  }

  @override
  void initState() {
    super.initState();
    if (_schoolId.isNotEmpty) {
      context.read<HealthBloc>().add(FetchHealthDashboardData(_schoolId));
    }
  }

  @override
  Widget build(BuildContext context) => ClinicPage(
    child: BlocBuilder<HealthBloc, HealthState>(
      builder: (_, state) {
        if (state is HealthLoading || state is HealthInitial) {
          return const Center(
            child: CircularProgressIndicator(color: ClinicUi.black),
          );
        }
        if (state is HealthError) {
          return ClinicEmptyState(
            title: 'Unable to load clinic',
            message: state.message,
            icon: Icons.cloud_off_outlined,
          );
        }
        final data = state is HealthDashboardLoaded ? state : null;
        final visits = data?.todayVisits ?? const <ClinicVisit>[];
        final waiting = visits
            .where((v) => v.outcome == VisitOutcome.admittedToSickBay)
            .length;
        final followUps = visits.where((v) => v.followUpRequired).length;
        return RefreshIndicator(
          color: ClinicUi.black,
          onRefresh: () async => context.read<HealthBloc>().add(
            FetchHealthDashboardData(_schoolId),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_name.split(' ').first} · School Nurse',
                      style: TextStyle(
                        fontSize: 14,
                        color: ClinicUi.foreground(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Clinic overview',
                style: TextStyle(
                  fontSize: 23,
                  color: ClinicUi.foreground(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (_, c) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Metric(
                      'Today’s visits',
                      visits.length,
                      'View all',
                      () => context.push('/staff/nurse/visits'),
                      width: (c.maxWidth - 8) / 2,
                    ),
                    _Metric(
                      'Waiting now',
                      waiting,
                      'View queue',
                      () => context.push('/staff/nurse/visits'),
                      danger: waiting > 0,
                      width: (c.maxWidth - 8) / 2,
                    ),
                    _Metric(
                      'Follow-ups due',
                      followUps,
                      'View list',
                      () => context.push('/staff/nurse/visits'),
                      width: (c.maxWidth - 8) / 2,
                    ),
                    _Metric(
                      'Low-stock items',
                      data?.lowStockItems.length ?? 0,
                      'View inventory',
                      () => context.push('/staff/nurse/inventory'),
                      danger: (data?.lowStockItems.isNotEmpty ?? false),
                      width: (c.maxWidth - 8) / 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Today · ${DateFormat('MMM d').format(DateTime.now())}',
                style: TextStyle(
                  color: ClinicUi.foreground(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              if (visits.isEmpty)
                const _CompactEmpty()
              else
                ...visits.take(6).map((v) => _TimelineVisit(visit: v)),
              const SizedBox(height: 16),
              Text(
                'Quick actions',
                style: TextStyle(
                  color: ClinicUi.foreground(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Quick(
                    icon: Icons.assignment_outlined,
                    label: 'Record visit',
                    onTap: () => context.push('/staff/nurse/lookup'),
                  ),
                  _Quick(
                    icon: Icons.search,
                    label: 'Search learner',
                    onTap: () => context.push('/staff/nurse/lookup'),
                  ),
                  _Quick(
                    icon: Icons.monitor_heart_outlined,
                    label: 'Add vitals',
                    onTap: () => context.push('/staff/nurse/lookup'),
                  ),
                  _Quick(
                    icon: Icons.medication_outlined,
                    label: 'Dispense item',
                    onTap: () => context.push('/staff/nurse/inventory'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric(
    this.label,
    this.value,
    this.action,
    this.onTap, {
    required this.width,
    this.danger = false,
  });
  final String label, action;
  final int value;
  final VoidCallback onTap;
  final double width;
  final bool danger;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        height: 93,
        padding: const EdgeInsets.all(11),
        decoration: ClinicUi.outlinedCard(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11)),
            const Spacer(),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 25,
                height: .9,
                color: danger ? ClinicUi.red : ClinicUi.foreground(context),
              ),
            ),
            const Spacer(),
            Text(
              action,
              style: TextStyle(
                fontSize: 11,
                color: danger ? ClinicUi.red : ClinicUi.foreground(context),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TimelineVisit extends StatelessWidget {
  const _TimelineVisit({required this.visit});
  final ClinicVisit visit;
  @override
  Widget build(BuildContext context) {
    final isFollowUp = visit.followUpRequired;
    final status = isFollowUp ? 'Follow-up' : 'Completed';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: Text(
              DateFormat('h:mm a').format(visit.dateTime),
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Icon(
            isFollowUp ? Icons.radio_button_checked : Icons.check_circle,
            size: 17,
            color: isFollowUp ? ClinicUi.red : ClinicUi.green,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              visit.studentId.length > 11
                  ? visit.studentId.substring(0, 11)
                  : visit.studentId,
              style: TextStyle(
                color: ClinicUi.foreground(context),
                fontSize: 13,
              ),
            ),
          ),
          ClinicUi.pill(
            status,
            color: isFollowUp ? ClinicUi.red : ClinicUi.green,
          ),
        ],
      ),
    );
  }
}

class _Quick extends StatelessWidget {
  const _Quick({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 48) / 2,
    child: OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        foregroundColor: ClinicUi.foreground(context),
        side: const BorderSide(color: ClinicUi.line),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 21),
      label: Text(label, style: const TextStyle(fontSize: 11)),
    ),
  );
}

class _CompactEmpty extends StatelessWidget {
  const _CompactEmpty();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: ClinicUi.outlinedCard(context),
    child: const Text(
      'No visits have been recorded today.',
      style: TextStyle(color: ClinicUi.muted, fontSize: 12),
    ),
  );
}
