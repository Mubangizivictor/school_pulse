import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';

class ReportCardScreen extends StatefulWidget {
  const ReportCardScreen({super.key});

  @override
  State<ReportCardScreen> createState() => _ReportCardScreenState();
}

class _ReportCardScreenState extends State<ReportCardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String? _selectedTerm = 'Term 2 2023';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    
    _loadRecords();
  }

  void _loadRecords() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // For now, assuming first student if multiple. 
      // In a real app, we'd use a SelectedStudentBloc or pass the ID.
      final studentId = authState.user.studentIds.first;
      final termParts = _selectedTerm?.split(' ');
      context.read<AcademicBloc>().add(
        GetAcademicRecordsRequested(
          studentId: studentId,
          term: termParts?[0],
          year: termParts?[2],
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
                const SnackBar(content: Text('Generating PDF...')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AcademicBloc, AcademicState>(
        builder: (context, state) {
          if (state is AcademicLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AcademicError) {
            return Center(child: Text(state.message));
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
                                    onTap: () {}, // For the scale animation
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
                    const SizedBox(height: 24),
                    FadeInSlide(
                      delay: const Duration(milliseconds: 400),
                      child: _buildRemarkSection(context, 'Class Teacher Remark',
                          'Samuel is a hard-working student who shows great interest in Science. He should focus more on his handwriting.'),
                    ),
                    const SizedBox(height: 16),
                    FadeInSlide(
                      delay: const Duration(milliseconds: 600),
                      child: _buildRemarkSection(context, 'Head Teacher Remark',
                          'A very good performance. Keep the momentum for the next term.'),
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
    return Row(
      children: [
        Expanded(
          child: FadeInSlide(
            delay: const Duration(milliseconds: 100),
            child: DashboardStatCard(
              title: 'Average Score',
              value: average,
              suffix: '%',
              decimalPlaces: 1,
              icon: Icons.auto_graph,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FadeInSlide(
            delay: const Duration(milliseconds: 200),
            child: DashboardStatCard(
              title: 'Class Position',
              value: 4,
              suffix: '/45',
              icon: Icons.emoji_events_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ],
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
              items: ['Term 2 2023', 'Term 1 2023', 'Term 3 2022'].map((String value) {
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

  Widget _buildRemarkSection(BuildContext context, String title, String remark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        AppCard(
          child: Text(remark, style: const TextStyle(fontStyle: FontStyle.italic)),
        ),
      ],
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
