import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart';
import '../bloc/school_calendar_bloc.dart';
import '../bloc/school_calendar_event.dart';
import '../bloc/school_calendar_state.dart';
import 'add_event_flow/add_event_screen.dart';
import 'calendar_overview_screen.dart';

class CalendarHomeScreen extends StatelessWidget {
  const CalendarHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }
    final user = authState.user;

    return BlocProvider(
      create: (_) => sl<SchoolCalendarBloc>()
        ..add(
          LoadCalendarRequested(schoolId: user.schoolId, operatorUser: user),
        ),
      child: const _CalendarHomeBody(),
    );
  }
}

class _CalendarHomeBody extends StatelessWidget {
  const _CalendarHomeBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('School Calendar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<SchoolCalendarBloc, SchoolCalendarState>(
        builder: (context, state) {
          if (state is SchoolCalendarLoading ||
              state is SchoolCalendarInitial) {
            return const Center(child: SchoolPulseLoader());
          }
          if (state is SchoolCalendarError) {
            return Center(child: Text(state.message));
          }
          if (state is! SchoolCalendarLoaded) {
            return const SizedBox.shrink();
          }

          final year = state.academicYear;
          final events = state.events;
          final schoolDays = year?.totalDays ?? 0;
          final holidayCount = events
              .where((e) => e.type.name == 'holiday')
              .length;
          final breakDays = events
              .where((e) => e.type.name == 'breakDay')
              .length;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Text(
                'Manage school calendar, events and holidays',
                style: TextStyle(color: AppColors.textMuted(context)),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total Days',
                      value: '$schoolDays',
                      color: AppColors.electricBlue,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: _StatCard(
                      label: 'School Days',
                      value: '${schoolDays - holidayCount - breakDays}',
                      color: AppColors.successGreen,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: _StatCard(
                      label: 'Break Days',
                      value: '$breakDays',
                      color: AppColors.deepOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Calendar Overview',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              PulseCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<SchoolCalendarBloc>(),
                      child: const CalendarOverviewScreen(),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: AppColors.primary(context),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    const Expanded(child: Text('Academic Year Calendar')),
                    Text(
                      year?.isCurrent == true ? 'Current' : '—',
                      style: TextStyle(color: AppColors.textMuted(context)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Quick Actions',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              if (state.canManage)
                _QuickAction(
                  icon: Icons.event,
                  title: 'Add Event',
                  subtitle: 'Add single event to calendar',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<SchoolCalendarBloc>(),
                        child: const AddEventScreen(),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return PulseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PulseCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary(context)),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
        ],
      ),
    );
  }
}
