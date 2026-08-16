import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../../domain/entities/timetable.dart';
import '../../../domain/entities/timetable_config.dart';
import '../../../domain/services/timetable_pdf_generator.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/structure_state.dart';
import '../../bloc/timetable_bloc.dart';
import '../../bloc/timetable_event.dart';
import '../../bloc/timetable_state.dart';
import '../../widgets/structure_ui_kit.dart';
import 'assign_subject_dialog.dart';

/// Structure -> Timetables -> tap a card: the day x period grid. Tapping an
/// empty period opens Assign Subject; tapping a filled one opens it for
/// editing. Publish runs a full conflict scan across the timetable first.
class TimetableBuilderScreen extends StatefulWidget {
  final String timetableId;

  const TimetableBuilderScreen({super.key, required this.timetableId});

  @override
  State<TimetableBuilderScreen> createState() => _TimetableBuilderScreenState();
}

class _TimetableBuilderScreenState extends State<TimetableBuilderScreen> {
  @override
  void initState() {
    super.initState();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    context.read<TimetableBloc>().add(
      TimetableOpened(schoolId: schoolId, timetableId: widget.timetableId),
    );
  }

  @override
  void dispose() {
    context.read<TimetableBloc>().add(const TimetableClosed());
    super.dispose();
  }

  Future<void> _publish() async {
    final userId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.id;
    context.read<TimetableBloc>().add(
      TimetablePublishRequested(publishedBy: userId),
    );
  }

  Future<({Uint8List pdfData, String classLabel})> _buildPdf(
    Timetable timetable,
    TimetableConfig config,
    List<TimetableLesson> lessons,
    StructureState structureState,
  ) async {
    final className = structureState.classes
        .where((c) => c.id == timetable.classId)
        .map((c) => c.name)
        .firstOrNull;
    final streamName = structureState.streams
        .where((s) => s.id == timetable.streamId)
        .map((s) => s.name)
        .firstOrNull;
    final academicYearName = structureState.academicYears
        .where((y) => y.id == timetable.academicYearId)
        .map((y) => y.name)
        .firstOrNull;
    final termName = structureState.academicTerms
        .where((t) => t.id == timetable.termId)
        .map((t) => t.name)
        .firstOrNull;
    final classLabel = [
      className ?? timetable.name,
      if (streamName != null) streamName,
    ].join(' - ');

    final pdfData = await TimetablePdfGenerator.generate(
      timetable: timetable,
      config: config,
      lessons: lessons,
      schoolName: structureState.institutionProfile.name.isNotEmpty
          ? structureState.institutionProfile.name
          : structureState.institutionProfile.displayName,
      academicYearName: academicYearName ?? '',
      termName: termName ?? '',
      classLabel: classLabel,
      schoolLogoUrl: structureState.institutionProfile.logoUrl.isEmpty
          ? null
          : structureState.institutionProfile.logoUrl,
    );
    return (pdfData: pdfData, classLabel: classLabel);
  }

  Future<void> _print(
    Timetable timetable,
    TimetableConfig config,
    List<TimetableLesson> lessons,
    StructureState structureState,
  ) async {
    final built = await _buildPdf(timetable, config, lessons, structureState);
    await TimetablePdfGenerator.print(built.pdfData);
  }

  Future<void> _save(
    Timetable timetable,
    TimetableConfig config,
    List<TimetableLesson> lessons,
    StructureState structureState,
  ) async {
    final built = await _buildPdf(timetable, config, lessons, structureState);
    final fileName = '${built.classLabel.replaceAll(' ', '_')}_Timetable.pdf';
    await TimetablePdfGenerator.save(built.pdfData, fileName);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TimetableBloc, TimetableState>(
      listenWhen: (previous, current) =>
          previous.publishConflicts != current.publishConflicts,
      listener: (context, state) {
        if (state.publishConflicts.isNotEmpty) {
          final total = state.publishConflicts.values.fold<int>(
            0,
            (sum, list) => sum + list.length,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cannot publish: $total conflict${total == 1 ? '' : 's'} found. Resolve them first.',
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final timetable = state.current;
        if (state.isLoadingDetail || timetable == null) {
          return Scaffold(
            appBar: const AdminAppBar(title: 'Timetable'),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final config = context.watch<StructureBloc>().state.timetableConfig;
        final structureState = context.watch<StructureBloc>().state;
        final className = structureState.classes
            .where((c) => c.id == timetable.classId)
            .map((c) => c.name)
            .firstOrNull;
        final streamName = structureState.streams
            .where((s) => s.id == timetable.streamId)
            .map((s) => s.name)
            .firstOrNull;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AdminAppBar(
            title: 'Timetable Builder',
            actions: [
              IconButton(
                tooltip: 'School Day Settings',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () =>
                    context.push('/staff/admin/structure/timetable-config'),
              ),
              IconButton(
                tooltip: 'Print',
                icon: const Icon(Icons.print_outlined),
                onPressed: () =>
                    _print(timetable, config, state.lessons, structureState),
              ),
              IconButton(
                tooltip: 'Save',
                icon: const Icon(Icons.download_outlined),
                onPressed: () =>
                    _save(timetable, config, state.lessons, structureState),
              ),
              if (timetable.status == TimetableStatus.draft)
                TextButton(
                  onPressed: state.isSaving ? null : _publish,
                  child: const Text('Publish'),
                ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        [
                          className ?? timetable.name,
                          if (streamName != null) streamName,
                        ].join(' - '),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    StructureStatusBadge(
                      label: timetable.status.label,
                      isActive: timetable.status == TimetableStatus.active,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _BuilderGrid(
                  timetable: timetable,
                  config: config,
                  lessons: state.lessons,
                  subjects: structureState.subjects,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BuilderGrid extends StatelessWidget {
  final Timetable timetable;
  final TimetableConfig config;
  final List<TimetableLesson> lessons;
  final List<dynamic> subjects;

  const _BuilderGrid({
    required this.timetable,
    required this.config,
    required this.lessons,
    required this.subjects,
  });

  @override
  Widget build(BuildContext context) {
    final sortedSlots = [...config.slots]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    if (config.teachingDays.isEmpty || sortedSlots.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'The school day has not been configured yet. Set teaching days and periods in Timetable Configuration.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(AppSpacing.m),
      children: config.teachingDays.map((day) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ...sortedSlots
                  .where((s) => s.days.isEmpty || s.days.contains(day))
                  .map(
                    (slot) => _SlotRow(
                      timetable: timetable,
                      day: day,
                      slot: slot,
                      lesson: lessons
                          .where(
                            (l) => l.occurrences.any(
                              (o) => o.day == day && o.slotId == slot.id,
                            ),
                          )
                          .firstOrNull,
                      subjects: subjects.cast(),
                    ),
                  ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SlotRow extends StatelessWidget {
  final Timetable timetable;
  final String day;
  final TimetableSlot slot;
  final TimetableLesson? lesson;
  final List subjects;

  const _SlotRow({
    required this.timetable,
    required this.day,
    required this.slot,
    required this.lesson,
    required this.subjects,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPeriod = slot.type == 'period';

    if (!isPeriod) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                slot.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              '${slot.startTime} - ${slot.endTime}',
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: lesson == null
            ? Theme.of(context).cardColor
            : colors.primaryContainer.withValues(alpha: .3),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => showAssignSubjectDialog(
            context,
            timetable: timetable,
            day: day,
            consecutivePeriodSlots: [slot],
            subjects: subjects.cast(),
            existing: lesson,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.outline.withValues(alpha: .18)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 76,
                  child: Text(
                    '${slot.name}\n${slot.startTime}-${slot.endTime}',
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: lesson == null
                      ? Text(
                          'Tap to assign',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson!.subjectName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              lesson!.teacherName,
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                ),
                if (lesson != null)
                  Icon(Icons.chevron_right, size: 18, color: colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
