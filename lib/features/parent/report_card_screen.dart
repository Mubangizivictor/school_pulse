import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
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

class _ReportCardScreenState extends State<ReportCardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late List<String> _termOptions;
  String? _selectedTerm;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
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

    // _selectedTerm looks like "Term 2 2026": the first two words are the
    // term as stored in Firestore, the last one is the year.
    final termParts = _selectedTerm?.split(' ');
    context.read<AcademicBloc>().add(
      GetAcademicRecordsRequested(
        studentId: studentId,
        term: termParts != null && termParts.length >= 3
            ? '${termParts[0]} ${termParts[1]}'
            : null,
        year: termParts != null && termParts.length >= 3 ? termParts[2] : null,
      ),
    );
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
            return const Center(child: CircularProgressIndicator());
          } else if (state is AcademicError) {
            return EmptyState(
              icon: Icons.cloud_off,
              title: 'Could not load report card',
              message: state.message,
              ctaLabel: 'Retry',
              onCtaPressed: _loadRecords,
            );
          } else if (state is AcademicLoaded) {
            final records = state.academicRecords;
            final averageScore = records.isEmpty
                ? 0.0
                : records.map((e) => e.score).reduce((a, b) => a + b) / records.length;

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTermSelector(),
                    const SizedBox(height: 16),
                    _buildSummaryHeader(context, averageScore),
                    const SizedBox(height: 24),
                    FadeInSlide(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subject Analysis',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          if (records.isEmpty)
                            const Center(child: Text('No records found for this term.'))
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: records.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final r = records[index];
                                return FadeInSlide(
                                  delay: Duration(milliseconds: 300 + (index * 100)),
                                  child: AppCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              r.subject,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            StatusBadge(
                                              label: r.grade,
                                              color: _getGradeColor(context, r.grade),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Score',
                                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                          color: Theme.of(context).colorScheme.outline,
                                                        ),
                                                  ),
                                                  AnimatedNumberText(
                                                    value: r.score,
                                                    suffix: '%',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Trend',
                                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                          color: Theme.of(context).colorScheme.outline,
                                                        ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        r.trend >= 0 ? Icons.trending_up : Icons.trending_down,
                                                        size: 16,
                                                        color: r.trend >= 0
                                                            ? Theme.of(context).extension<SemanticColors>()!.success
                                                            : Theme.of(context).extension<SemanticColors>()!.error,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${r.trend.abs()}%',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          color: r.trend >= 0
                                                              ? Theme.of(context).extension<SemanticColors>()!.success
                                                              : Theme.of(context).extension<SemanticColors>()!.error,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 24),
                                        Text(
                                          'Remark',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                color: Theme.of(context).colorScheme.outline,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          r.teacherRemark,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
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

  Color _getGradeColor(BuildContext context, String grade) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    if (grade.startsWith('D')) return semanticColors.success;
    if (grade.startsWith('C')) return semanticColors.warning;
    if (grade.startsWith('P')) return semanticColors.info;
    if (grade.startsWith('F')) return semanticColors.error;
    return Theme.of(context).colorScheme.outline;
  }
}
