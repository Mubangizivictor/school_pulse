import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import '../../../bloc/structure_bloc.dart';
import '../../../bloc/timetable_bloc.dart';
import 'create_timetable_draft.dart';

class Step4Review extends StatelessWidget {
  final CreateTimetableDraft draft;
  final VoidCallback onCreate;

  const Step4Review({super.key, required this.draft, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final structureState = context.watch<StructureBloc>().state;
    final config = structureState.timetableConfig;
    final isSaving = context.watch<TimetableBloc>().state.isSaving;
    final colors = Theme.of(context).colorScheme;

    final className = structureState.classes
        .where((c) => c.id == draft.classId)
        .map((c) => c.name)
        .firstOrNull;
    final streamName = structureState.streams
        .where((s) => s.id == draft.streamId)
        .map((s) => s.name)
        .firstOrNull;
    final yearName = structureState.academicYears
        .where((y) => y.id == draft.academicYearId)
        .map((y) => y.name)
        .firstOrNull;
    final termName = structureState.academicTerms
        .where((t) => t.id == draft.termId)
        .map((t) => t.name)
        .firstOrNull;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.xl),
            children: [
              const Text(
                'Review Timetable',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.l),
              _ReviewCard(
                title: 'Basic Information',
                rows: {
                  'Class': [className ?? '-', ?streamName].join(' - '),
                  'Academic Year': yearName ?? '-',
                  'Term': ?termName,
                  'Timetable Name': draft.name,
                },
              ),
              const SizedBox(height: AppSpacing.m),
              _ReviewCard(
                title: 'Period Settings',
                rows: {
                  'Period Duration':
                      '${config.defaultPeriodDurationMinutes} minutes',
                  'School Timings':
                      '${config.schoolStartTime} - ${config.schoolEndTime}',
                },
              ),
              const SizedBox(height: AppSpacing.m),
              _ReviewCard(
                title: 'Teaching Days',
                rows: {'Days': config.teachingDays.join(', ')},
              ),
              const SizedBox(height: AppSpacing.l),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colors.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'The timetable is created as a Draft. Assign subjects and teachers in the builder, then publish once every conflict check passes.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving ? null : onCreate,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Timetable'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String title;
  final Map<String, String> rows;

  const _ReviewCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...rows.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    e.key,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      e.value,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
