import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import '../../../domain/entities/calendar_event_type.dart';
import 'add_event_draft.dart';
import 'event_type_picker.dart';

class Step1EventDetails extends StatefulWidget {
  final AddEventDraft draft;
  final VoidCallback onNext;

  const Step1EventDetails({
    super.key,
    required this.draft,
    required this.onNext,
  });

  @override
  State<Step1EventDetails> createState() => _Step1EventDetailsState();
}

class _Step1EventDetailsState extends State<Step1EventDetails> {
  late final _titleController = TextEditingController(text: widget.draft.title);
  late final _descController = TextEditingController(
    text: widget.draft.description,
  );

  Future<void> _pickType() async {
    final selected = await Navigator.of(context).push<CalendarEventType>(
      MaterialPageRoute(
        builder: (_) => EventTypePickerScreen(initial: widget.draft.type),
      ),
    );
    if (selected != null) {
      setState(() => widget.draft.type = selected);
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        widget.draft.startDate = picked;
      } else {
        widget.draft.endDate = picked;
      }
    });
  }

  String _fmt(DateTime? d) =>
      d == null ? 'Select date' : '${d.day}/${d.month}/${d.year}';

  bool get _isValid =>
      widget.draft.title.trim().isNotEmpty &&
      widget.draft.startDate != null &&
      widget.draft.endDate != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Type *',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        const SizedBox(height: AppSpacing.s),
        InkWell(
          onTap: _pickType,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(child: Text(widget.draft.type.label)),
                Icon(Icons.expand_more, color: AppColors.textMuted(context)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        PulseTextField(
          label: 'Event Title *',
          hint: 'Enter title',
          controller: _titleController,
          onChanged: (v) => setState(() => widget.draft.title = v),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: _DateField(
                label: 'Start Date *',
                value: _fmt(widget.draft.startDate),
                onTap: () => _pickDate(isStart: true),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: _DateField(
                label: 'End Date *',
                value: _fmt(widget.draft.endDate),
                onTap: () => _pickDate(isStart: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Day Event',
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
            Switch(
              value: widget.draft.allDay,
              onChanged: (v) => setState(() => widget.draft.allDay = v),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        PulseTextField(
          label: 'Description',
          hint: 'Enter description (optional)',
          controller: _descController,
          maxLines: 3,
          onChanged: (v) => setState(() => widget.draft.description = v),
        ),
        const SizedBox(height: AppSpacing.x3l),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isValid ? widget.onNext : null,
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary(context))),
        const SizedBox(height: AppSpacing.s),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(child: Text(value)),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textMuted(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
