import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import '../../../domain/entities/calendar_event_type.dart';
import 'add_event_draft.dart';

class Step3Review extends StatelessWidget {
  final AddEventDraft draft;
  final VoidCallback onBack;
  final VoidCallback onSave;
  final bool saving;

  const Step3Review({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onSave,
    this.saving = false,
  });

  String _fmt(DateTime? d) => d == null ? '—' : '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final recurrence = draft.buildRecurrence();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Event',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        _ReviewRow('Event Type', draft.type.label),
        _ReviewRow('Event Title', draft.title),
        _ReviewRow('Start Date', _fmt(draft.startDate)),
        _ReviewRow('End Date', _fmt(draft.endDate)),
        _ReviewRow('All Day Event', draft.allDay ? 'Yes' : 'No'),
        _ReviewRow(
          'Recurrence',
          recurrence == null
              ? 'None'
              : 'Every ${recurrence.frequency.name[0].toUpperCase()}${recurrence.frequency.name.substring(1)}',
        ),
        if (recurrence != null && recurrence.repeatsOn.isNotEmpty)
          _ReviewRow(
            'Repeats On',
            recurrence.repeatsOn.map((w) => w.name).join(', '),
          ),
        _ReviewRow(
          'Description',
          draft.description.isEmpty ? '—' : draft.description,
        ),
        const SizedBox(height: AppSpacing.x3l),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: saving ? null : onBack,
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: saving ? null : onSave,
                child: saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Event'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(color: AppColors.textMuted(context)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
          ),
        ],
      ),
    );
  }
}
