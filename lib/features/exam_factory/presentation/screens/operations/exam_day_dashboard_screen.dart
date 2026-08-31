import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../../domain/entities/exam_factory_entities.dart';
import '../../bloc/exam_factory_cubit.dart';
import '../../widgets/exam_factory_shell.dart';

/// One sitting's operational hub: invigilators on duty, attendance summary
/// and open incidents, with quick links into each detail screen.
class ExamDayDashboardScreen extends StatelessWidget {
  final String sittingId;
  const ExamDayDashboardScreen({super.key, required this.sittingId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Exam-day dashboard',
      backFallback: '/staff/dean/exam-factory/timetable',
      child: StreamBuilder<ExamSitting?>(
        stream: cubit.watchSitting(sittingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ExamFactoryLoading();
          }
          final sitting = snapshot.data;
          if (sitting == null) {
            return const ExamFactoryEmpty(
              icon: Icons.error_outline,
              title: 'Sitting not found',
              message: 'This sitting may have been removed.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              100,
            ),
            children: [
              Text(
                sitting.venueName.isEmpty ? sitting.venueId : sitting.venueName,
                style: AppTypography.titleLarge.copyWith(fontSize: 18),
              ),
              Text('${sitting.startTime} · ${sitting.durationMinutes} minutes'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: StreamBuilder<List<ExamInvigilatorAssignment>>(
                      stream: cubit.watchInvigilators(sittingId: sittingId),
                      builder: (context, s) => _StatCard(
                        label: 'Invigilators',
                        value: '${s.data?.length ?? 0}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StreamBuilder<List<ExamAttendanceRecord>>(
                      stream: cubit.watchAttendance(sittingId: sittingId),
                      builder: (context, s) {
                        final present = (s.data ?? const [])
                            .where(
                              (r) => r.status == ExamAttendanceStatus.present,
                            )
                            .length;
                        return _StatCard(label: 'Present', value: '$present');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StreamBuilder<List<ExamIncident>>(
                      stream: cubit.watchIncidents(sittingId: sittingId),
                      builder: (context, s) {
                        final open = (s.data ?? const [])
                            .where(
                              (i) => i.status != ExamIncidentStatus.resolved,
                            )
                            .length;
                        return _StatCard(
                          label: 'Open incidents',
                          value: '$open',
                          warn: open > 0,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _NavCard(
                icon: Icons.groups_outlined,
                title: 'Invigilator assignment',
                subtitle: 'Assign staff to this sitting',
                onTap: () => context.push(
                  '/staff/dean/exam-factory/invigilators?sittingId=$sittingId',
                ),
              ),
              _NavCard(
                icon: Icons.how_to_reg_outlined,
                title: 'Exam attendance',
                subtitle: 'Mark candidates present, absent or late',
                onTap: () => context.push(
                  '/staff/dean/exam-factory/attendance?sittingId=$sittingId',
                ),
              ),
              _NavCard(
                icon: Icons.report_gmailerrorred_outlined,
                title: 'Incident reporting',
                subtitle: 'Log and resolve incidents',
                onTap: () => context.push(
                  '/staff/dean/exam-factory/incidents?sittingId=$sittingId',
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
  final String label, value;
  final bool warn;
  const _StatCard({
    required this.label,
    required this.value,
    this.warn = false,
  });
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              color: warn ? AppColors.warning(context) : null,
            ),
          ),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    ),
  );
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon, color: AppColors.information(context)),
      title: Text(title, style: AppTypography.titleSmall),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
