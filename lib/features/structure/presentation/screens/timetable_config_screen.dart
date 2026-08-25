import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/timetable_config.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../widgets/timetable_config_dialogs.dart';
import '../widgets/structure_empty_hint.dart';
import '../widgets/structure_ui_kit.dart';

const List<String> kWeekDays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// The school's timetable shape - days, periods, breaks - a singleton
/// config the Timetable module reads through Structure's repository.
/// Nothing about periods/breaks/school hours is hardcoded.
class TimetableConfigScreen extends StatelessWidget {
  const TimetableConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AdminAppBar(title: 'Timetable Configuration'),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) => _TimetableConfigBody(state: state),
      ),
    );
  }
}

class _TimetableConfigBody extends StatelessWidget {
  final StructureState state;
  const _TimetableConfigBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    final config = state.timetableConfig;

    void update(TimetableConfig Function(TimetableConfig) apply) {
      // Clear the retired legacy field whenever this document is touched.
      // A day can therefore never remain both teaching and "weekend".
      final next = apply(config).copyWith(weekendDays: const []);
      final start = timetableMinutes(next.schoolStartTime);
      final end = timetableMinutes(next.schoolEndTime);
      if (start != null && end != null && end <= start) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('School end time must be after start time.'),
          ),
        );
        return;
      }
      bloc.add(UpdateTimetableConfigRequested(next, schoolId));
    }

    return ListView(
      padding: EdgeInsets.all(AppSpacing.xl),
      children: [
        Text(
          'Teaching Days',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kWeekDays.map((day) {
            final selected = config.teachingDays.contains(day);
            return ChoiceChip(
              label: Text(day),
              selected: selected,
              onSelected: (v) => update(
                (c) => c.copyWith(
                  teachingDays: v
                      ? [...c.teachingDays, day]
                      : c.teachingDays.where((d) => d != day).toList(),
                ),
              ),
              selectedColor: AppColors.primary(context),
              labelStyle: TextStyle(
                color: selected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
              showCheckmark: false,
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.xl),
        const SizedBox(height: AppSpacing.s),
        Text(
          'Non-teaching days are inferred from the selected teaching days.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: PulseTextField(
                key: ValueKey('periods-${config.periodsPerDay}'),
                label: 'Periods Per Day',
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: config.periodsPerDay.toString(),
                ),
                onChanged: (v) => update(
                  (c) => c.copyWith(
                    periodsPerDay: int.tryParse(v) ?? c.periodsPerDay,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: PulseTextField(
                key: ValueKey(
                  'duration-${config.defaultPeriodDurationMinutes}',
                ),
                label: 'Lesson Duration (min)',
                hint: 'e.g. 45',
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: config.defaultPeriodDurationMinutes == 0
                      ? ''
                      : config.defaultPeriodDurationMinutes.toString(),
                ),
                onChanged: (v) => update(
                  (c) => c.copyWith(
                    defaultPeriodDurationMinutes: (int.tryParse(v) ?? 0) > 0
                        ? int.parse(v)
                        : c.defaultPeriodDurationMinutes,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            Expanded(
              child: _SchoolTimePicker(
                label: 'School Start Time',
                value: config.schoolStartTime,
                onChanged: (value) =>
                    update((c) => c.copyWith(schoolStartTime: value)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _SchoolTimePicker(
                label: 'School End Time',
                value: config.schoolEndTime,
                onChanged: (value) =>
                    update((c) => c.copyWith(schoolEndTime: value)),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        StructureSectionHeader(
          title: 'Periods & Breaks',
          actionLabel: 'Add Slot',
          onAction: () => showTimetableSlotFormDialog(
            context,
            teachingDays: config.teachingDays,
            occupiedSlots: config.slots,
            schoolStartTime: config.schoolStartTime,
            schoolEndTime: config.schoolEndTime,
            onSave: (slot) =>
                update((c) => c.copyWith(slots: [...c.slots, slot])),
          ),
        ),
        if (config.slots.isEmpty)
          const StructureEmptyHint('No periods or breaks defined yet.'),
        ...config.slots.asMap().entries.map((entry) {
          final index = entry.key;
          final slot = entry.value;
          return StructureListRow(
            icon: slot.type == 'period'
                ? Icons.menu_book_outlined
                : Icons.free_breakfast_outlined,
            color: slot.type == 'period' ? Colors.black : Colors.black,
            title: slot.name,
            subtitle: '${slot.startTime} - ${slot.endTime} - ${slot.type}',
            onEdit: () => showTimetableSlotFormDialog(
              context,
              existing: slot,
              teachingDays: config.teachingDays,
              occupiedSlots: config.slots,
              schoolStartTime: config.schoolStartTime,
              schoolEndTime: config.schoolEndTime,
              onSave: (updated) => update((c) {
                final slots = [...c.slots];
                slots[index] = updated;
                return c.copyWith(slots: slots);
              }),
            ),
            onDelete: () async {
              final confirmed = await showDeleteConfirmDialog(
                context,
                title: 'Delete Slot',
                message: 'Delete "${slot.name}"?',
              );
              if (confirmed == true) {
                update((c) {
                  final slots = [...c.slots]..removeAt(index);
                  return c.copyWith(slots: slots);
                });
              }
            },
          );
        }),
        const SizedBox(height: AppSpacing.x4l),
      ],
    );
  }
}

class _SchoolTimePicker extends StatelessWidget {
  const _SchoolTimePicker({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final minutes = timetableMinutes(value) ?? 8 * 60;
        final selected = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
        );
        if (selected != null) onChanged(timetableTime(selected));
      },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.schedule_outlined),
        ),
        child: Text(value.isEmpty ? 'Select time' : value),
      ),
    );
  }
}
