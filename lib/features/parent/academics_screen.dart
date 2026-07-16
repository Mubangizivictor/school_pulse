import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/academic/domain/entities/attendance_record.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';

import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';

class AcademicsScreen extends StatefulWidget {
  const AcademicsScreen({super.key});

  @override
  State<AcademicsScreen> createState() => _AcademicsScreenState();
}

class _AcademicsScreenState extends State<AcademicsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final selectedStudentState = context.read<SelectedStudentBloc>().state;
      String? studentId;
      
      if (selectedStudentState is SelectedStudentLoaded) {
        studentId = selectedStudentState.student.id;
      } else {
        // Fallback to first student if available in user entity
        studentId = authState.user.studentIds.firstOrNull;
      }

      if (studentId != null) {
        context.read<AcademicBloc>().add(GetAcademicRecordsRequested(studentId: studentId));
        context.read<AcademicBloc>().add(GetAttendanceRecordsRequested(studentId: studentId));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudentAppBar(title: 'Academics'),
      body: BlocBuilder<AcademicBloc, AcademicState>(
        builder: (context, state) {
          if (state is AcademicLoading) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Skeleton(height: 140),
                const SizedBox(height: 24),
                const Skeleton(height: 180),
                const SizedBox(height: 24),
                const Skeleton(height: 24, width: 150),
                const SizedBox(height: 12),
                ...List.generate(4, (index) => const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Skeleton(height: 60),
                )),
              ],
            );
          } else if (state is AcademicError) {
            return Center(child: Text(state.message));
          } else if (state is AcademicLoaded) {
            final records = state.academicRecords;
            final attendance = state.attendanceRecords;

            final avgScore = records.isEmpty ? 0.0 : records.map((r) => r.score).reduce((a, b) => a + b) / records.length;
            final presentCount = attendance.where((r) => r.status == StudentStatus.present).length;
            final attendanceRate = attendance.isEmpty ? 0.0 : (presentCount / attendance.length * 100).toDouble();

            final subjectData = {for (var r in records) r.subject: r.score};

            return FadeTransition(
              opacity: _fadeAnimation,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FadeInSlide(
                    duration: const Duration(milliseconds: 600),
                    child: _buildSummaryCard(context, avgScore, attendanceRate),
                  ),
                  const SizedBox(height: 24),
                  if (subjectData.isNotEmpty) ...[
                    FadeInSlide(
                      delay: const Duration(milliseconds: 200),
                      child: PerformanceBarChart(data: subjectData),
                    ),
                    const SizedBox(height: 24),
                  ],
                  FadeInSlide(
                    delay: const Duration(milliseconds: 300),
                    child: SectionHeader(
                      title: 'Subject Marks',
                      actionLabel: 'Details',
                      onActionPressed: () {},
                    ),
                  ),
                  ...records.asMap().entries.map((entry) {
                    final index = entry.key;
                    final record = entry.value;
                    return FadeInSlide(
                      delay: Duration(milliseconds: 400 + (index * 50)),
                      child: _buildSubjectRow(context, record),
                    );
                  }),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 600),
                    child: SectionHeader(
                      title: 'Attendance History',
                      actionLabel: 'Full History',
                      onActionPressed: () => context.push('/parent/academics/attendance'),
                    ),
                  ),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 700),
                    child: _buildAttendanceMiniMap(context, attendance),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, double avg, double attendance) {
    return AppCard(
      onTap: () {},
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Average', avg, context, suffix: '%', decimalPlaces: 1),
              _buildStat('Attendance', attendance, context, suffix: '%'),
              _buildStat('Rank', 4, context, prefix: '', suffix: '/42'),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Report Card',
                  onPressed: () => context.push('/parent/academics/report-card'),
                  icon: Icons.assignment_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SecondaryButton(
                  label: 'Contact Teacher',
                  onPressed: () => context.push('/parent/messages'),
                  icon: Icons.chat_bubble_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, double value, BuildContext context, {String suffix = '', String prefix = '', int decimalPlaces = 0}) {
    return Column(
      children: [
        AnimatedNumberText(
          value: value,
          prefix: prefix,
          suffix: suffix,
          decimalPlaces: decimalPlaces,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildSubjectRow(BuildContext context, dynamic record) {
    return AppCard(
      onTap: () {},
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(record.grade, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Row(
            children: [
              AnimatedNumberText(
                value: record.score,
                suffix: '%',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(width: 8),
              Icon(
                record.trend >= 0 ? Icons.trending_up : Icons.trending_down,
                color: record.trend >= 0
                    ? Theme.of(context).extension<SemanticColors>()!.success
                    : Theme.of(context).extension<SemanticColors>()!.error,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceMiniMap(BuildContext context, List<AttendanceRecord> records) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    // Show last 14 days
    return AppCard(
      onTap: () {},
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: records.take(14).map((r) {
          Color color;
          switch (r.status) {
            case StudentStatus.present: color = semanticColors.success; break;
            case StudentStatus.absent: color = semanticColors.error; break;
            case StudentStatus.late: color = semanticColors.warning; break;
          }
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color),
            ),
            child: Center(child: Icon(_getStatusIcon(r.status), size: 12, color: color)),
          );
        }).toList(),
      ),
    );
  }

  IconData _getStatusIcon(StudentStatus status) {
    switch (status) {
      case StudentStatus.present: return Icons.check;
      case StudentStatus.absent: return Icons.close;
      case StudentStatus.late: return Icons.access_time;
    }
  }
}
