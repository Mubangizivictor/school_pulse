import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/academic/domain/entities/attendance_record.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';

import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';

class AttendanceDetailScreen extends StatefulWidget {
  const AttendanceDetailScreen({super.key});

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (context.read<AcademicBloc>().state is! AcademicLoaded) {
      _fetchData();
    }
  }

  void _fetchData() {
    final studentState = context.read<SelectedStudentBloc>().state;
    if (studentState is SelectedStudentLoaded) {
      context.read<AcademicBloc>().add(
        GetAttendanceRecordsRequested(studentId: studentState.student.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudentAppBar(title: 'Attendance History'),
      body: BlocBuilder<AcademicBloc, AcademicState>(
        builder: (context, state) {
          if (state is AcademicLoading || state is AcademicInitial) {
            return const Center(child: SchoolPulseLoader());
          } else if (state is AcademicError) {
            return EmptyState(
              icon: Icons.cloud_off,
              title: 'Could not load attendance',
              message: state.message,
              ctaLabel: 'Retry',
              onCtaPressed: _fetchData,
            );
          } else if (state is AcademicLoaded) {
            final records = state.attendanceRecords;
            final semanticColors = Theme.of(
              context,
            ).extension<SemanticColors>()!;

            final presentCount = records
                .where((r) => r.status == StudentStatus.present)
                .length;
            final absentCount = records
                .where((r) => r.status == StudentStatus.absent)
                .length;
            final lateCount = records
                .where((r) => r.status == StudentStatus.late)
                .length;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                FadeInSlide(
                  child: AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryStat(
                          context,
                          'Present',
                          presentCount.toString(),
                          semanticColors.success,
                        ),
                        _buildSummaryStat(
                          context,
                          'Absent',
                          absentCount.toString(),
                          semanticColors.error,
                        ),
                        _buildSummaryStat(
                          context,
                          'Late',
                          lateCount.toString(),
                          semanticColors.warning,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const FadeInSlide(
                  delay: Duration(milliseconds: 100),
                  child: SectionHeader(title: 'Daily Log'),
                ),
                ...records.asMap().entries.map((entry) {
                  final index = entry.key;
                  final record = entry.value;
                  return FadeInSlide(
                    delay: Duration(milliseconds: 200 + (index * 50)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildAttendanceRow(
                        context,
                        record,
                        semanticColors,
                      ),
                    ),
                  );
                }),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildAttendanceRow(
    BuildContext context,
    AttendanceRecord record,
    SemanticColors colors,
  ) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (record.status) {
      case StudentStatus.present:
        statusColor = colors.success;
        statusLabel = 'Present';
        statusIcon = Icons.check_circle;
        break;
      case StudentStatus.absent:
        statusColor = colors.error;
        statusLabel = 'Absent';
        statusIcon = Icons.cancel;
        break;
      case StudentStatus.late:
        statusColor = colors.warning;
        statusLabel = 'Late';
        statusIcon = Icons.access_time_filled;
        break;
    }

    return AppCard(
      onTap: () =>
          _showAttendanceDetail(context, record, statusColor, statusLabel),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, dd MMM yyyy').format(record.date),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (record.note.isNotEmpty)
                  Text(
                    record.note,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          StatusBadge(label: statusLabel, color: statusColor),
        ],
      ),
    );
  }

  void _showAttendanceDetail(
    BuildContext context,
    AttendanceRecord record,
    Color color,
    String label,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Detail',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              DateFormat('MMMM dd, yyyy').format(record.date),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            StatusBadge(label: label, color: color, icon: Icons.info_outline),
            const SizedBox(height: 16),
            const Text('Note:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              record.note.isEmpty
                  ? 'No additional notes provided.'
                  : record.note,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Close',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
