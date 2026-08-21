import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_bloc.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_event.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_state.dart';
import 'package:school_pulse/features/director/presentation/widgets/director_drawer.dart';

/// "Staff Overview" screen from the reference: Total Staff / Staff
/// Attendance stat tiles plus workload/ratio/turnover rows.
///
/// [DirectorDashboardStats] exposes total staff and staff attendance, but no
/// teacher/non-teaching split, workload distribution, teacher/student ratio,
/// or turnover rate - those rows show an honest "not tracked yet" state
/// rather than invented figures.
class StaffOverviewScreen extends StatelessWidget {
  const StaffOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<DirectorBloc>().add(DirectorDashboardRequested());
    return Scaffold(
      drawer: const DirectorDrawer(),
      appBar: AppBar(title: const Text('Staff Overview')),
      body: BlocBuilder<DirectorBloc, DirectorState>(
        builder: (context, state) {
          if (state is! DirectorDashboardLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = state.stats;

          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.l, AppSpacing.xl, AppSpacing.x3l),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: 'Total Staff',
                      value: '${stats.totalStaff}',
                      icon: Icons.badge_outlined,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      label: 'Staff Attendance',
                      value: '${stats.staffAttendanceRate}%',
                      icon: Icons.how_to_reg_outlined,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Workforce Detail'),
              const SizedBox(height: AppSpacing.s),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TODO: Wire Teachers/Non-Teaching split, workload,
                    // teacher/student ratio, and staff turnover once the
                    // director module exposes those metrics beyond the
                    // dashboard's aggregate totalStaff/staffAttendanceRate.
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Teacher/non-teaching split, workload balance, '
                        'teacher-student ratio and staff turnover are not '
                        'tracked yet.',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppSpacing.m),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Theme.of(context).hintColor)),
      ],
    ),
  );
}
