import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
import 'package:school_pulse/features/academic/domain/entities/academic_record.dart';
import 'package:school_pulse/features/academic/domain/entities/report_card.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';

class ReportCardScreen extends StatefulWidget {
  const ReportCardScreen({super.key});

  @override
  State<ReportCardScreen> createState() => _ReportCardScreenState();
}

class _ReportCardScreenState extends State<ReportCardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<String> _termOptions;
  String? _selectedTerm;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();

    _termOptions = _buildTermOptions();
    _selectedTerm = _termOptions.first;
    _loadRecords();
  }

  /// "Term N YYYY" options for the configured academic year (falling back to
  /// the current calendar year) plus the previous year.
  List<String> _buildTermOptions() {
    final config = context.read<ThemeProvider>().config;
    final currentYear =
        int.tryParse(config?.academicYear ?? '') ?? DateTime.now().year;
    final currentTerm = config?.currentTerm ?? 'Term 1';

    final options = <String>['$currentTerm $currentYear'];
    for (var term = 3; term >= 1; term--) {
      final candidate = 'Term $term $currentYear';
      if (!options.contains(candidate)) options.add(candidate);
    }
    for (var term = 3; term >= 1; term--) {
      options.add('Term $term ${currentYear - 1}');
    }
    return options;
  }

  void _loadRecords() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final selectedState = context.read<SelectedStudentBloc>().state;
    final studentId = selectedState is SelectedStudentLoaded
        ? selectedState.student.id
        : authState.user.studentIds.firstOrNull;
    if (studentId == null) return;

    final termParts = _selectedTerm?.split(' ');
    if (termParts != null && termParts.length >= 3) {
      final term = '${termParts[0]} ${termParts[1]}';
      final year = termParts[2];

      context.read<AcademicBloc>().add(
        GetReportCardRequested(studentId: studentId, term: term, year: year),
      );

      context.read<AcademicBloc>().add(
        GetAcademicRecordsRequested(
          studentId: studentId,
          term: term,
          year: year,
        ),
      );
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
      appBar: StudentAppBar(
        title: 'Report Card',
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF export is coming soon.')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AcademicBloc, AcademicState>(
        builder: (context, state) {
          if (state is AcademicLoading || state is AcademicInitial) {
            return const Center(child: SchoolPulseLoader());
          } else if (state is AcademicError) {
            return EmptyState(
              icon: Icons.cloud_off,
              title: 'Could not load report card',
              message: state.message,
              ctaLabel: 'Retry',
              onCtaPressed: _loadRecords,
            );
          } else if (state is AcademicReportCardLoaded) {
            if (state.reportCard == null) {
              return EmptyState(
                icon: Icons.assignment_late,
                title: 'Report not ready',
                message:
                    'This report is currently being processed or awaiting final signatures.',
                ctaLabel: 'Refresh',
                onCtaPressed: _loadRecords,
              );
            }
            // If report card is found, we might want to load academic records too or they might be already loaded
            // Actually, we can trigger loading of academic records when report card is loaded or vice versa.
            // Let's assume we want to show the academic records if the report card is present.
            return _buildReportContent(context, state.reportCard!);
          } else if (state is AcademicLoaded) {
            // Fallback or handle combined state
            return const Center(child: SchoolPulseLoader());
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildReportContent(BuildContext context, ReportCard reportCard) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTermSelector(),
          const SizedBox(height: 20),
          if (reportCard.isLockedForFees)
            _buildFeesWarning()
          else ...[
            _buildSummaryHeader(context, reportCard.averageScore),
            const SizedBox(height: 24),
            _buildSubjectPerformanceList(context),
            const SizedBox(height: 24),
            if (reportCard.classTeacherComment != null)
              _buildTeacherRemarks(reportCard.classTeacherComment!),
          ],
        ],
      ),
    );
  }

  Widget _buildFeesWarning() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Column(
        children: [
          const Icon(Icons.lock, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Report Card Locked',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Access to this report card is restricted due to outstanding school fees. Please clear the balance to view results.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to Finance/Payments
            },
            child: const Text('View Fee Statement'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectPerformanceList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject Performance',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        BlocBuilder<AcademicBloc, AcademicState>(
          builder: (context, state) {
            if (state is AcademicLoaded) {
              if (state.academicRecords.isEmpty) {
                return const Center(
                  child: Text('No subject records found for this term.'),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.academicRecords.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final record = state.academicRecords[index];
                  return AppCard(
                    child: ListTile(
                      title: Text(
                        record.subject,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${record.score}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _gradeColor(context, record),
                            ),
                          ),
                          Text(
                            record.grade ?? 'Not graded',
                            style: TextStyle(
                              color: _gradeColor(context, record),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(child: SchoolPulseLoader());
          },
        ),
      ],
    );
  }

  Widget _buildTeacherRemarks(String comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Teacher\'s Remarks',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Text(
            comment,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(BuildContext context, double average) {
    return FadeInSlide(
      delay: const Duration(milliseconds: 100),
      child: DashboardStatCard(
        title: 'Average Score',
        value: average,
        suffix: '%',
        decimalPlaces: 1,
        icon: Icons.auto_graph,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTermSelector() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedTerm,
              isExpanded: true,
              underline: const SizedBox(),
              items: _termOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedTerm = val);
                _loadRecords();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Prefers the grading system's own configured band color
  /// (`record.gradeColorHex`, resolved by GradeResolver at mark-submission
  /// time). Falls back to the old D/C/P/F prefix pattern-match only for
  /// legacy records written before that field existed, so their visual
  /// appearance doesn't change - and to a neutral color when neither is
  /// available (e.g. record.grade is null because the school has no
  /// grading system configured).
  Color _gradeColor(BuildContext context, AcademicRecord record) {
    final hex = record.gradeColorHex;
    if (hex != null && hex.isNotEmpty) {
      try {
        return Color(int.parse(hex.replaceFirst('#', '0xff')));
      } catch (_) {
        // fall through to the legacy/neutral paths below
      }
    }
    final grade = record.grade;
    if (grade == null) return Theme.of(context).colorScheme.outline;
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    if (grade.startsWith('D')) return semanticColors.success;
    if (grade.startsWith('C')) return semanticColors.warning;
    if (grade.startsWith('P')) return semanticColors.info;
    if (grade.startsWith('F')) return semanticColors.error;
    return Theme.of(context).colorScheme.outline;
  }
}
