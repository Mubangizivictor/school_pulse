import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../../domain/entities/exam_factory_entities.dart';
import '../../bloc/exam_factory_cubit.dart';
import '../../widgets/exam_factory_shell.dart';

String _fmt(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

/// Lists every scheduled sitting across the exam series, sorted by time.
/// Distinct from the weekly class timetable: each row here is one dated
/// paper sitting at one venue, not a recurring lesson slot.
class ExamTimetableScreen extends StatelessWidget {
  const ExamTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Exam Timetable',
      backFallback: '/staff/dean/exam-factory',
      action: IconButton(
        tooltip: 'Schedule a paper',
        icon: const Icon(Icons.add_circle_outline),
        onPressed: () =>
            context.push('/staff/dean/exam-factory/schedule-editor'),
      ),
      child: ExamFactoryStreamView<ExamSitting>(
        stream: cubit.watchSittings(),
        emptyIcon: Icons.event_note_outlined,
        emptyTitle: 'No sittings scheduled',
        emptyMessage:
            'Schedule a paper to a venue and time to build the exam timetable.',
        emptyAction: FilledButton.icon(
          onPressed: () =>
              context.push('/staff/dean/exam-factory/schedule-editor'),
          icon: const Icon(Icons.add),
          label: const Text('Schedule a paper'),
        ),
        builder: (context, items) => ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            100,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final sitting = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.event_outlined),
                title: Text(
                  _fmt(sitting.startTime),
                  style: AppTypography.titleSmall,
                ),
                subtitle: Text(
                  '${sitting.venueName.isEmpty ? sitting.venueId : sitting.venueName} · ${sitting.durationMinutes} min',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  '/staff/dean/exam-factory/exam-day?sittingId=${sitting.id}',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ExamScheduleEditorScreen extends StatefulWidget {
  const ExamScheduleEditorScreen({super.key});

  @override
  State<ExamScheduleEditorScreen> createState() =>
      _ExamScheduleEditorScreenState();
}

class _ExamScheduleEditorScreenState extends State<ExamScheduleEditorScreen> {
  String? _paperId;
  String? _venueId;
  String? _venueName;
  DateTime? _startTime;
  final _durationController = TextEditingController(text: '60');
  bool _saving = false;

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _startTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save(ExamFactoryCubit cubit) async {
    if (_paperId == null || _venueId == null || _startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a paper, venue and start time.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await cubit.saveSitting(
        paperId: _paperId!,
        venueId: _venueId!,
        venueName: _venueName,
        startTime: _startTime!,
        durationMinutes: int.tryParse(_durationController.text.trim()),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sitting scheduled.')));
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cubit.state.error ?? 'Could not schedule this sitting.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Schedule paper',
      backFallback: '/staff/dean/exam-factory/timetable',
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          StreamBuilder<List<ExamPaper>>(
            stream: cubit.watchPapers(),
            builder: (context, snap) {
              final papers = (snap.data ?? const <ExamPaper>[])
                  .where((p) => p.isLocked)
                  .toList();
              return DropdownButtonFormField<String>(
                initialValue: _paperId,
                decoration: const InputDecoration(
                  labelText: 'Paper (locked papers only)',
                ),
                items: papers
                    .map(
                      (p) =>
                          DropdownMenuItem(value: p.id, child: Text(p.title)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _paperId = v),
              );
            },
          ),
          const SizedBox(height: 14),
          StreamBuilder<List<(String, String, int)>>(
            stream: cubit.watchVenues(),
            builder: (context, snap) {
              final venues = snap.data ?? const <(String, String, int)>[];
              return DropdownButtonFormField<String>(
                initialValue: _venueId,
                decoration: const InputDecoration(labelText: 'Venue'),
                items: venues
                    .map(
                      (v) => DropdownMenuItem(
                        value: v.$1,
                        child: Text(
                          '${v.$2}${v.$3 > 0 ? ' (${v.$3} seats)' : ''}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() {
                  _venueId = v;
                  _venueName = venues
                      .firstWhere(
                        (venue) => venue.$1 == v,
                        orElse: () => ('', '', 0),
                      )
                      .$2;
                }),
              );
            },
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _pickDateTime,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Start time'),
              child: Text(
                _startTime == null ? 'Select date and time' : _fmt(_startTime!),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Duration (minutes)'),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : () => _save(cubit),
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Saving…' : 'Save sitting'),
          ),
        ],
      ),
    );
  }
}
