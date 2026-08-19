import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/circular_progress_gauge.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../../domain/entities/curriculum.dart';

class SyllabusCoverageScreen extends StatelessWidget {
  final Subject subject;

  const SyllabusCoverageScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: Text(subject.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(context),
            const SizedBox(height: AppSpacing.x3l),
            Text('Topics & Subtopics', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.l),
            ...subject.topics.map((topic) => _TopicExpansionTile(topic: topic)),
            const SizedBox(height: AppSpacing.x3l),
            Text('Learning Objectives', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.l),
            ...subject.objectives.map((obj) => _ObjectiveTile(objective: obj)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text('Overall Syllabus Coverage', style: AppTypography.titleSmall),
          const SizedBox(height: AppSpacing.xl),
          CircularProgressGauge(
            value: subject.currentCoverage / 100,
            label: 'Coverage',
            size: 108,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                label: 'Topics',
                value: subject.topics.length.toString(),
              ),
              _SummaryItem(
                label: 'Subtopics',
                value: subject.topics
                    .fold(0, (sum, t) => sum + t.subTopics.length)
                    .toString(),
              ),
              _SummaryItem(
                label: 'Core Objectives',
                value: subject.objectives
                    .where((o) => o.isCore)
                    .length
                    .toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textMuted(context),
          ),
        ),
      ],
    );
  }
}

class _TopicExpansionTile extends StatelessWidget {
  final Topic topic;

  const _TopicExpansionTile({required this.topic});

  @override
  Widget build(BuildContext context) {
    final completedCount = topic.subTopics.where((st) => st.isCompleted).length;
    final totalCount = topic.subTopics.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.border(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(topic.title, style: AppTypography.titleSmall),
        subtitle: Text(
          '$completedCount/$totalCount subtopics completed',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMuted(context),
          ),
        ),
        leading: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: AppColors.border(context),
            color: AppColors.primary(context),
          ),
        ),
        children: topic.subTopics
            .map(
              (st) => ListTile(
                dense: true,
                title: Text(st.title, style: AppTypography.bodyMedium),
                trailing: Icon(
                  st.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: st.isCompleted
                      ? AppColors.success(context)
                      : AppColors.textMuted(context),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ObjectiveTile extends StatelessWidget {
  final LearningObjective objective;

  const _ObjectiveTile({required this.objective});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: ListTile(
        leading: Icon(
          Icons.track_changes,
          color: objective.isCore
              ? AppColors.primary(context)
              : AppColors.textMuted(context),
        ),
        title: Text(objective.description, style: AppTypography.bodyMedium),
        trailing: objective.isCore
            ? StatusBadge(label: 'Core', color: AppColors.primary(context))
            : null,
      ),
    );
  }
}
