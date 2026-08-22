import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import '../../../bloc/structure_bloc.dart';
import '../../../bloc/structure_state.dart';
import 'create_timetable_draft.dart';

class Step1BasicInfo extends StatefulWidget {
  final CreateTimetableDraft draft;
  final VoidCallback onNext;

  const Step1BasicInfo({super.key, required this.draft, required this.onNext});

  @override
  State<Step1BasicInfo> createState() => _Step1BasicInfoState();
}

class _Step1BasicInfoState extends State<Step1BasicInfo> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.draft.name);
    _descriptionController = TextEditingController(
      text: widget.draft.description,
    );
    if (widget.draft.classId.isNotEmpty && widget.draft.name.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _autofillName(context.read<StructureBloc>().state);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _autofillName(StructureState state) {
    final className = state.classes
        .where((c) => c.id == widget.draft.classId)
        .map((c) => c.name)
        .firstOrNull;
    final streamName = state.streams
        .where((s) => s.id == widget.draft.streamId)
        .map((s) => s.name)
        .firstOrNull;
    final year = state.academicYears
        .where((y) => y.id == widget.draft.academicYearId)
        .map((y) => y.name)
        .firstOrNull;
    if (className == null) return;
    final label = [
      className,
      if (streamName != null) '($streamName)',
      if (year != null) year,
    ].join(' ');
    setState(() {
      _nameController.text = label;
      widget.draft.name = label;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StructureBloc>().state;
    final streamsForClass = state.streams
        .where((s) => s.classId == widget.draft.classId)
        .toList();

    return ListView(
      padding: EdgeInsets.all(AppSpacing.xl),
      children: [
        Text(
          'Choose where this timetable applies.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        _Dropdown<String>(
          label: 'Academic year',
          required: true,
          value: widget.draft.academicYearId.isEmpty
              ? null
              : widget.draft.academicYearId,
          items: state.academicYears
              .map((y) => DropdownMenuItem(value: y.id, child: Text(y.name)))
              .toList(),
          onChanged: (v) =>
              setState(() => widget.draft.academicYearId = v ?? ''),
        ),
        const SizedBox(height: AppSpacing.m),
        _Dropdown<String>(
          label: 'Term',
          value: widget.draft.termId.isEmpty ? null : widget.draft.termId,
          items: state.academicTerms
              .where((t) => t.academicYearId == widget.draft.academicYearId)
              .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
              .toList(),
          onChanged: (v) => setState(() => widget.draft.termId = v ?? ''),
        ),
        const SizedBox(height: AppSpacing.m),
        _Dropdown<String>(
          label: 'Class',
          required: true,
          value: widget.draft.classId.isEmpty ? null : widget.draft.classId,
          items: state.classes
              .where((c) => c.isActive)
              .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
              .toList(),
          onChanged: (v) {
            setState(() {
              widget.draft.classId = v ?? '';
              widget.draft.streamId = '';
            });
            _autofillName(state);
          },
        ),
        if (streamsForClass.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.m),
          _Dropdown<String>(
            label: 'Stream',
            value: widget.draft.streamId.isEmpty ? null : widget.draft.streamId,
            items: streamsForClass
                .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                .toList(),
            onChanged: (v) {
              setState(() => widget.draft.streamId = v ?? '');
              _autofillName(state);
            },
          ),
        ],
        const SizedBox(height: AppSpacing.m),
        PulseTextField(
          label: 'Timetable name',
          isRequired: true,
          controller: _nameController,
          onChanged: (v) => widget.draft.name = v,
        ),
        const SizedBox(height: AppSpacing.m),
        PulseTextField(
          label: 'Description (optional)',
          controller: _descriptionController,
          maxLines: 3,
          onChanged: (v) => widget.draft.description = v,
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: widget.draft.isBasicInfoComplete ? widget.onNext : null,
            label: const Text('Continue'),
            icon: const Icon(Icons.arrow_forward, size: 18),
            iconAlignment: IconAlignment.end,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String label;
  final bool required;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _Dropdown({
    required this.label,
    this.required = false,
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(label: Text(required ? '$label *' : label)),
      items: items,
      onChanged: onChanged,
    );
  }
}
