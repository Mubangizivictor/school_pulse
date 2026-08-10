import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_state.dart';

class AttendanceSummaryScreen extends StatefulWidget {
  final String teacherId;
  final String className;

  const AttendanceSummaryScreen({
    super.key,
    this.teacherId = 'teacher_1',
    this.className = 'P.1 North',
  });

  @override
  State<AttendanceSummaryScreen> createState() =>
      _AttendanceSummaryScreenState();
}

class _AttendanceSummaryScreenState extends State<AttendanceSummaryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(
      TeacherAttendanceHistoryRequested(widget.teacherId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance & Punctuality')),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        builder: (context, state) {
          if (state is TeacherLoading) {
            return const Center(child: SchoolPulseLoader());
          }

          if (state is TeacherAttendanceHistoryLoaded) {
            // Filter history for the specific class
            final classHistory = state.history
                .where((h) => h.className == widget.className)
                .toList();

            final int daysOpen = classHistory.length;
            int totalPresent = 0;
            // In a real scenario, this screen is likely per-student in the report wizard
            // But if it's a summary for the class:
            for (var record in classHistory) {
              totalPresent += record.presentCount;
            }

            // Let's assume for this mock/demo that we are showing metrics for a specific student
            // and we would need a GetStudentAttendanceHistory use case.
            // For now, let's use the class metrics as a placeholder but with real data counts.

            final double attendanceRate = daysOpen > 0
                ? (totalPresent /
                          (daysOpen *
                              (classHistory.firstOrNull?.totalCount ?? 1))) *
                      100
                : 0;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const SectionHeader(title: 'Class Summary'),
                      const SizedBox(height: 12),
                      _AttendanceMetricItem(
                        label: 'Days School Open',
                        value: '$daysOpen',
                      ),
                      _AttendanceMetricItem(
                        label: 'Avg. Students Present',
                        value: daysOpen > 0
                            ? (totalPresent / daysOpen).toStringAsFixed(1)
                            : '0',
                      ),
                      _AttendanceMetricItem(
                        label: 'Total Present Markings',
                        value: '$totalPresent',
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Overall Attendance Rate',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: CircularProgressIndicator(
                                    value: attendanceRate / 100,
                                    strokeWidth: 12,
                                    backgroundColor:
                                        AppColors.surfaceContainerHigh(context),
                                    color: AppColors.success(context),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${attendanceRate.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PrimaryButton(
                    label: 'Save & Next',
                    onPressed: () =>
                        context.push('/staff/reports/behaviour-conduct'),
                  ),
                ),
              ],
            );
          }

          if (state is TeacherError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text('No attendance data found'));
        },
      ),
    );
  }
}

class _AttendanceMetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _AttendanceMetricItem({required this.label, required this.value});

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: AppColors.textPrimary(context),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
