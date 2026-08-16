import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import '../../../domain/entities/recurrence_rule.dart';
import 'add_event_draft.dart';

class Step3Review extends StatefulWidget {
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
  @override
  State<Step3Review> createState() => _Step3ReviewState();
}

const _weekdayLabels = {
  Weekday.monday: 'Mon',
  Weekday.tuesday: 'Tue',
  Weekday.wednesday: 'Wed',
  Weekday.thursday: 'Thu',
  Weekday.friday: 'Fri',
  Weekday.saturday: 'Sat',
  Weekday.sunday: 'Sun',
};

class _Step3ReviewState extends State<Step3Review> {
  late final notes = TextEditingController(text: widget.draft.notes);
  late final occurrencesController = TextEditingController(
    text: widget.draft.occurrences > 0 ? '${widget.draft.occurrences}' : '',
  );

  @override
  void dispose() {
    notes.dispose();
    occurrencesController.dispose();
    super.dispose();
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          widget.draft.recurrenceEndDate ??
          widget.draft.endDate ??
          DateTime.now(),
      firstDate: widget.draft.startDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => widget.draft.recurrenceEndDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _select(
        'Reminder',
        widget.draft.reminder,
        [
          'None',
          'At time of event',
          '30 minutes before',
          '1 hour before',
          '1 day before',
        ],
        (v) => setState(() => widget.draft.reminder = v ?? 'None'),
      ),
      const SizedBox(height: 18),
      _select(
        'Repeat',
        widget.draft.repeats
            ? _frequencyLabel(widget.draft.frequency)
            : 'Does not repeat',
        const ['Does not repeat', 'Daily', 'Weekly', 'Monthly', 'Yearly'],
        (v) => setState(() {
          widget.draft.repeats = v != 'Does not repeat';
          widget.draft.frequency = switch (v) {
            'Daily' => RecurrenceFrequency.daily,
            'Monthly' => RecurrenceFrequency.monthly,
            'Yearly' => RecurrenceFrequency.yearly,
            _ => RecurrenceFrequency.weekly,
          };
        }),
      ),
      if (widget.draft.repeats) ...[
        if (widget.draft.frequency == RecurrenceFrequency.weekly) ...[
          const SizedBox(height: 14),
          Text(
            'Repeats On',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Weekday.values
                .map(
                  (day) => FilterChip(
                    label: Text(_weekdayLabels[day]!),
                    selected: widget.draft.repeatsOn.contains(day),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        widget.draft.repeatsOn.add(day);
                      } else {
                        widget.draft.repeatsOn.remove(day);
                      }
                    }),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 14),
        Text(
          'Ends',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<RecurrenceEndType>(
          segments: const [
            ButtonSegment(value: RecurrenceEndType.never, label: Text('Never')),
            ButtonSegment(
              value: RecurrenceEndType.onDate,
              label: Text('On date'),
            ),
            ButtonSegment(
              value: RecurrenceEndType.afterOccurrences,
              label: Text('After N'),
            ),
          ],
          selected: {widget.draft.endType},
          onSelectionChanged: (selection) =>
              setState(() => widget.draft.endType = selection.first),
        ),
        if (widget.draft.endType == RecurrenceEndType.onDate) ...[
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _pickEndDate,
            child: Text(
              widget.draft.recurrenceEndDate == null
                  ? 'Select end date'
                  : _fmt(widget.draft.recurrenceEndDate!),
            ),
          ),
        ],
        if (widget.draft.endType == RecurrenceEndType.afterOccurrences) ...[
          const SizedBox(height: 10),
          TextField(
            controller: occurrencesController,
            keyboardType: TextInputType.number,
            onChanged: (v) => widget.draft.occurrences = int.tryParse(v) ?? 0,
            decoration: const InputDecoration(
              labelText: 'Number of occurrences',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ],
      const SizedBox(height: 18),
      Text(
        'Color',
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
      ),
      const SizedBox(height: 9),
      Wrap(
        spacing: 18,
        children: ['176BFF', '11A85B', 'E94B4B', 'FF9500', '7C3AED']
            .map(
              (hex) => InkWell(
                onTap: () => setState(() => widget.draft.colorHex = hex),
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Color(int.parse('FF$hex', radix: 16)),
                    shape: BoxShape.circle,
                    border: widget.draft.colorHex == hex
                        ? Border.all(
                            color: AppColors.textPrimary(context),
                            width: 2,
                          )
                        : null,
                  ),
                ),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 18),
      TextField(
        controller: notes,
        maxLines: 3,
        onChanged: (v) => widget.draft.notes = v,
        decoration: const InputDecoration(
          labelText: 'Notes (Optional)',
          hintText: 'Additional notes',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 30),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.saving ? null : widget.onBack,
              child: const Text('Back'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: widget.saving ? null : widget.onSave,
              child: widget.saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
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

  static String _frequencyLabel(RecurrenceFrequency frequency) =>
      switch (frequency) {
        RecurrenceFrequency.daily => 'Daily',
        RecurrenceFrequency.weekly => 'Weekly',
        RecurrenceFrequency.monthly => 'Monthly',
        RecurrenceFrequency.yearly => 'Yearly',
      };

  static String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Widget _select(
    String label,
    String current,
    List<String> values,
    ValueChanged<String?> change,
  ) => DropdownButtonFormField<String>(
    initialValue: values.contains(current) ? current : values.first,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      isDense: true,
    ),
    items: values
        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
        .toList(),
    onChanged: change,
  );
}
