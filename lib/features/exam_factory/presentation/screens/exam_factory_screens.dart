import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../domain/entities/exam_factory_entities.dart';
import '../bloc/exam_factory_cubit.dart';
import '../widgets/exam_factory_shell.dart';

class ExamFactoryDashboardScreen extends StatelessWidget {
  const ExamFactoryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Exam Factory',
      subtitle: 'Build, approve and prepare examinations',
      showBack: false,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          StreamBuilder<List<ExamQuestion>>(
            stream: cubit.watchQuestions(),
            builder: (context, qSnap) {
              final questions = qSnap.data ?? const <ExamQuestion>[];
              final pendingModeration = questions
                  .where(
                    (q) => const {
                      ExamQuestionStatus.submitted,
                      ExamQuestionStatus.resubmitted,
                      ExamQuestionStatus.underReview,
                    }.contains(q.status),
                  )
                  .length;
              return StreamBuilder<List<ExamPaper>>(
                stream: cubit.watchPapers(),
                builder: (context, pSnap) {
                  final papers = pSnap.data ?? const <ExamPaper>[];
                  final printReady = papers
                      .where((p) => p.status == ExamPaperStatus.printReady)
                      .length;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _Metric(
                        icon: Icons.quiz_outlined,
                        value: '${questions.length}',
                        label: 'Questions',
                      ),
                      _Metric(
                        icon: Icons.schedule_outlined,
                        value: '$pendingModeration',
                        label: 'To review',
                        color: _MetricTone.warning,
                      ),
                      _Metric(
                        icon: Icons.description_outlined,
                        value: '${papers.length}',
                        label: 'Papers',
                        color: _MetricTone.success,
                      ),
                      _Metric(
                        icon: Icons.print_outlined,
                        value: '$printReady',
                        label: 'Ready to print',
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _NavCard(
            icon: Icons.event_note_outlined,
            title: 'Examination Series',
            subtitle: 'Create and manage exam series',
            route: '/staff/dean/exam-factory/series',
          ),
          _NavCard(
            icon: Icons.menu_book_outlined,
            title: 'Question Bank',
            subtitle: 'Browse, search and manage questions',
            route: '/staff/dean/exam-factory/question-bank',
          ),
          _NavCard(
            icon: Icons.article_outlined,
            title: 'Paper Builder',
            subtitle: 'Create and assemble exam papers',
            route: '/staff/dean/exam-factory/papers',
          ),
          _NavCard(
            icon: Icons.groups_outlined,
            title: 'Moderation Queue',
            subtitle: 'Review and moderate questions',
            route: '/staff/dean/exam-factory/moderation',
          ),
          _NavCard(
            icon: Icons.print_outlined,
            title: 'Print Room',
            subtitle: 'Prepare controlled print jobs',
            route: '/staff/dean/exam-factory/print-room',
          ),
          _NavCard(
            icon: Icons.event_outlined,
            title: 'Exam Timetable',
            subtitle: 'Schedule papers to venues and times',
            route: '/staff/dean/exam-factory/timetable',
          ),
          _NavCard(
            icon: Icons.fact_check_outlined,
            title: 'Marking',
            subtitle: 'Enter marks and approve results',
            route: '/staff/dean/exam-factory/marking',
          ),
          _NavCard(
            icon: Icons.bar_chart_outlined,
            title: 'Reports',
            subtitle: 'Series-wide question, paper and print summary',
            route: '/staff/dean/exam-factory/reports',
          ),
          _NavCard(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Series configuration and role permissions',
            route: '/staff/dean/exam-factory/settings',
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final _MetricTone color;
  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
    this.color = _MetricTone.info,
  });
  @override
  Widget build(BuildContext context) {
    final c = switch (color) {
      _MetricTone.success => AppColors.success(context),
      _MetricTone.warning => AppColors.warning(context),
      _MetricTone.info => AppColors.information(context),
    };
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(icon, color: c),
              const SizedBox(height: 8),
              Text(value, style: AppTypography.titleLarge),
              Text(label, style: AppTypography.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MetricTone { info, success, warning }

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle, route;
  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon, color: AppColors.information(context)),
      title: Text(title, style: AppTypography.titleSmall),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(route),
    ),
  );
}
