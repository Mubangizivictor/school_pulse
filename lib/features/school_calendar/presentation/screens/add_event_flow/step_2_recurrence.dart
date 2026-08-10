import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import '../../../domain/entities/recurrence_rule.dart';
import 'add_event_draft.dart';

class Step2Recurrence extends StatefulWidget {
  final AddEventDraft draft;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const Step2Recurrence({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<Step2Recurrence> createState() => _Step2RecurrenceState();
}

class _Step2RecurrenceState extends State<Step2Recurrence> {
  static const _weekdayLabels = {
    Weekday.monday: 'M',
    Weekday.tuesday: 'T',
    Weekday.wednesday: 'W',
    Weekday.thursday: 'T',
    Weekday.friday: 'F',
    Weekday.saturday: 'S',
    Weekday.sunday: 'S',
  };

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Repeat this event',
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
            Switch(
              value: draft.repeats,
              onChanged: (v) => setState(() => draft.repeats = v),
            ),
          ],
        ),
        if (draft.repeats) ...[
          const SizedBox(height: AppSpacing.xl),
          Text('Repeat', style: TextStyle(color: AppColors.textSecondary(context))),
          const SizedBox(height: AppSpacing.s),
          DropdownButtonFormField<RecurrenceFrequency>(
            initialValue: draft.frequency,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: RecurrenceFrequency.values
                .map(
                  (f) => DropdownMenuItem(
                    value: f,
                    child: Text('Every ${f.name[0].toUpperCase()}${f.name.substring(1)}'),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => draft.frequency = v!),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Repeats On', style: TextStyle(color: AppColors.textSecondary(context))),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            children: Weekday.values.map((w) {
              final selected = draft.repeatsOn.contains(w);
              return ChoiceChip(
                label: Text(_weekdayLabels[w]!),
                selected: selected,
                onSelected: (v) => setState(() {
                  if (v) {
                    draft.repeatsOn.add(w);
                  } else {
                    draft.repeatsOn.remove(w);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Ends', style: TextStyle(color: AppColors.textSecondary(context))),
          RadioGroup<RecurrenceEndType>(
            groupValue: draft.endType,
            onChanged: (v) => setState(() => draft.endType = v!),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioListTile<RecurrenceEndType>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Never'),
                  value: RecurrenceEndType.never,
                ),
                RadioListTile<RecurrenceEndType>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('On date'),
                  value: RecurrenceEndType.onDate,
                ),
                if (draft.endType == RecurrenceEndType.onDate)
                  OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => draft.recurrenceEndDate = picked);
                      }
                    },
                    child: Text(
                      draft.recurrenceEndDate == null
                          ? 'Select date'
                          : '${draft.recurrenceEndDate!.day}/${draft.recurrenceEndDate!.month}/${draft.recurrenceEndDate!.year}',
                    ),
                  ),
                RadioListTile<RecurrenceEndType>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('After'),
                  value: RecurrenceEndType.afterOccurrences,
                ),
                if (draft.endType == RecurrenceEndType.afterOccurrences)
                  TextFormField(
                    initialValue: draft.occurrences > 0
                        ? '${draft.occurrences}'
                        : '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      suffixText: 'occurrences',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(
                      () => draft.occurrences = int.tryParse(v) ?? 0,
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.x3l),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onBack,
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: widget.onNext,
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
