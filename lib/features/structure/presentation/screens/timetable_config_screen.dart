import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Timetable Configuration',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
      bloc.add(UpdateTimetableConfigRequested(apply(config), schoolId));
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
                  weekendDays: v
                      ? c.weekendDays.where((d) => d != day).toList()
                      : c.weekendDays,
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
        Text(
          'Weekend Days',
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
            final selected = config.weekendDays.contains(day);
            return ChoiceChip(
              label: Text(day),
              selected: selected,
              onSelected: (v) => update(
                (c) => c.copyWith(
                  weekendDays: v
                      ? [...c.weekendDays, day]
                      : c.weekendDays.where((d) => d != day).toList(),
                  teachingDays: v
                      ? c.teachingDays.where((d) => d != day).toList()
                      : c.teachingDays,
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
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            Expanded(
              child: PulseTextField(
                key: ValueKey('start-${config.schoolStartTime}'),
                label: 'School Start Time',
                hint: 'HH:MM',
                controller: TextEditingController(text: config.schoolStartTime),
                onChanged: (v) => update((c) => c.copyWith(schoolStartTime: v)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: PulseTextField(
                key: ValueKey('end-${config.schoolEndTime}'),
                label: 'School End Time',
                hint: 'HH:MM',
                controller: TextEditingController(text: config.schoolEndTime),
                onChanged: (v) => update((c) => c.copyWith(schoolEndTime: v)),
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
            color: slot.type == 'period' ? Colors.blue : Colors.orange,
            title: slot.name,
            subtitle: '${slot.startTime} - ${slot.endTime} - ${slot.type}',
            onEdit: () => showTimetableSlotFormDialog(
              context,
              existing: slot,
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
