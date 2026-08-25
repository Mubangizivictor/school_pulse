import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import '../../../bloc/structure_bloc.dart';

/// Read-only summary of the school's period/break configuration. Timetables
/// always schedule against the one shared TimetableConfig - there is no
/// per-timetable duplicate of period durations or break times to enter here,
/// which is what stops any lesson duration or break time from being
/// hardcoded per class.
class Step2Periods extends StatelessWidget {
  final VoidCallback onNext;

  const Step2Periods({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<StructureBloc>().state.timetableConfig;
    final colors = Theme.of(context).colorScheme;
    final isConfigured =
        config.schoolStartTime.isNotEmpty &&
        config.schoolEndTime.isNotEmpty &&
        config.slots.isNotEmpty;

    return ListView(
      padding: EdgeInsets.all(AppSpacing.xl),
      children: [
        const Text(
          'Period Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'This timetable schedules against the school\'s configured day.',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: AppSpacing.l),
        if (!isConfigured)
          _NotConfiguredCard(
            onEditConfig: () =>
                context.push('/staff/admin/structure/timetable-config'),
          )
        else ...[
          _SettingRow(
            label: 'Default Period Duration',
            value: '${config.defaultPeriodDurationMinutes} minutes',
          ),
          _SettingRow(
            label: 'School Start Time',
            value: config.schoolStartTime,
          ),
          _SettingRow(label: 'School End Time', value: config.schoolEndTime),
          _SettingRow(
            label: 'Number of Periods',
            value: '${config.slots.where((s) => s.type == 'period').length}',
          ),
          _SettingRow(
            label: 'Breaks',
            value:
                '${config.slots.where((s) => s.type == 'break' || s.type == 'tea_break').length}',
          ),
          _SettingRow(
            label: 'Lunch',
            value: '${config.slots.where((s) => s.type == 'lunch').length}',
          ),
          const SizedBox(height: AppSpacing.m),
          TextButton.icon(
            onPressed: () =>
                context.push('/staff/admin/structure/timetable-config'),
            icon: const Icon(Icons.tune_outlined, size: 18),
            label: const Text('Edit school day configuration'),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isConfigured ? onNext : null,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Next'),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotConfiguredCard extends StatelessWidget {
  final VoidCallback onEditConfig;

  const _NotConfiguredCard({required this.onEditConfig});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.error),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The school day has not been configured yet.',
            style: TextStyle(fontWeight: FontWeight.w700, color: colors.error),
          ),
          const SizedBox(height: 6),
          Text(
            'Set teaching days, school hours and periods/breaks before creating a class timetable.',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onEditConfig,
            child: const Text('Configure School Day'),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String value;

  const _SettingRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
