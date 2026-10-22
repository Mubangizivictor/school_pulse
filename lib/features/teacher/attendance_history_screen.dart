import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_attendance.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_attendance/class_attendance_history_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';

class TeacherAttendanceHistoryScreen extends StatefulWidget {
  const TeacherAttendanceHistoryScreen({super.key});

  @override
  State<TeacherAttendanceHistoryScreen> createState() =>
      _TeacherAttendanceHistoryScreenState();
}

class _TeacherAttendanceHistoryScreenState
    extends State<TeacherAttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load({HistoryRange range = HistoryRange.month}) {
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active == null) return;
    context.read<ClassAttendanceHistoryBloc>().add(
      ClassAttendanceHistoryRequested(active, range: range),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Attendance History',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: BlocBuilder<ClassTeacherContextBloc, ClassTeacherContextState>(
        builder: (context, contextState) {
          if (contextState.active == null) {
            return const EmptyState(
              icon: Icons.class_outlined,
              title: 'No class assigned',
              message:
                  'You are not currently the Class Teacher for any class, '
                  'so there is no attendance history to show.',
            );
          }

          return BlocBuilder<
            ClassAttendanceHistoryBloc,
            ClassAttendanceHistoryState
          >(
            builder: (context, state) {
              if (state.isLoading) {
                return Center(child: const SchoolPulseLoader());
              }

              if (state.errorMessage != null && state.isEmpty) {
                return EmptyState(
                  icon: Icons.cloud_off,
                  title: 'Could not load history',
                  message: state.errorMessage!,
                  ctaLabel: 'Retry',
                  onCtaPressed: () => _load(range: state.range),
                );
              }

              if (state.isEmpty) {
                return const EmptyState(
                  icon: Icons.event_note_outlined,
                  title: 'No attendance history',
                  message:
                      'No registers have been submitted for your class in '
                      'this period.',
                );
              }

              return Column(
                children: [
                  _buildSummary(context, state),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => _load(range: state.range),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.sessions.length,
                        itemBuilder: (context, index) {
                          final session = state.sessions[index];
                          final counts = session.countsBy(state.options);
                          final present =
                              counts[AttendanceClassification.present] ?? 0;
                          final total = session.entries
                              .where((e) => e.isMarked)
                              .length;

                          return _HistoryCard(
                            className: session.className.isEmpty
                                ? session.classId
                                : session.className,
                            date: session.date,
                            presentCount: present,
                            totalCount: total,
                            status: session.isLocked
                                ? 'Locked'
                                : (session.isSubmitted ? 'Submitted' : 'Draft'),
                            wasCorrected: session.lastCorrectedAt != null,
                            color: session.isSubmitted
                                ? AppColors.success(context)
                                : AppColors.warning(context),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// The window totals. Rate is omitted rather than shown as 0% when nothing
  /// has been marked - an empty period and a period of total absence are not
  /// the same claim.
  Widget _buildSummary(
    BuildContext context,
    ClassAttendanceHistoryState state,
  ) {
    final rate = state.attendanceRate;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryStat(
            label: 'Days',
            value: '${state.daysRecorded}',
            color: AppColors.primary(context),
          ),
          _SummaryStat(
            label: 'Attendance',
            value: rate == null ? '—' : '${rate.toStringAsFixed(1)}%',
            color: AppColors.success(context),
          ),
          _SummaryStat(
            label: 'Absent',
            value: '${state.totalUnauthorisedAbsent}',
            color: AppColors.danger(context),
          ),
          _SummaryStat(
            label: 'Excused',
            value: '${state.totalAuthorisedAbsent}',
            color: AppColors.warning(context),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String className;
  final DateTime date;
  final int presentCount;
  final int totalCount;
  final String status;
  final bool wasCorrected;
  final Color color;

  const _HistoryCard({
    required this.className,
    required this.date,
    required this.presentCount,
    required this.totalCount,
    required this.status,
    required this.wasCorrected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              status == 'Submitted'
                  ? Icons.check_circle_outline
                  : (status == 'Locked'
                        ? Icons.lock_outline
                        : Icons.edit_outlined),
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  className,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(date),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                // Surfaced rather than hidden: a register that was changed
                // after submission is a different fact from one that was not.
                if (wasCorrected)
                  Text(
                    'Corrected after submission',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.warning(context),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$presentCount/$totalCount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(status, style: TextStyle(fontSize: 12, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
