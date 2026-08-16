import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import '../../../bloc/structure_bloc.dart';

/// Shows the school's teaching days and full day structure (periods, breaks,
/// lunch, prep, ...) that this timetable's builder grid will be laid out
/// against - read-only here, edited on the shared TimetableConfig screen.
class Step3Schedule extends StatelessWidget {
  final VoidCallback onNext;

  const Step3Schedule({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<StructureBloc>().state.timetableConfig;
    final colors = Theme.of(context).colorScheme;
    final sortedSlots = [...config.slots]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.xl),
            children: [
              const Text(
                'Teaching Days',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.m),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: config.teachingDays
                    .map(
                      (day) => Chip(
                        label: Text(day),
                        backgroundColor: colors.primaryContainer,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Day Structure',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.m),
              ...sortedSlots.map(
                (slot) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: slot.type == 'period'
                              ? colors.primary
                              : Colors.orange,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          slot.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${slot.startTime} - ${slot.endTime}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Next'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
