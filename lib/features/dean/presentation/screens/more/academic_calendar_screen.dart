import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class _CalendarEvent {
  final String title;
  final DateTime date;
  final String category;
  final Color color;

  const _CalendarEvent(this.title, this.date, this.category, this.color);
}

class AcademicCalendarScreen extends StatelessWidget {
  const AcademicCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = [
      _CalendarEvent(
        'Term 2 Opens',
        DateTime.now().add(const Duration(days: 2)),
        'Term',
        AppColors.primary(context),
      ),
      _CalendarEvent(
        'Mid-Term Exams',
        DateTime.now().add(const Duration(days: 14)),
        'Examinations',
        AppColors.warning(context),
      ),
      _CalendarEvent(
        'Departmental Meeting',
        DateTime.now().add(const Duration(days: 5)),
        'Meeting',
        AppColors.information(context),
      ),
      _CalendarEvent(
        'Report Card Deadline',
        DateTime.now().add(const Duration(days: 30)),
        'Reports',
        AppColors.danger(context),
      ),
      _CalendarEvent(
        'Mock Examinations',
        DateTime.now().add(const Duration(days: 45)),
        'Examinations',
        AppColors.warning(context),
      ),
      _CalendarEvent(
        'Term 2 Closes',
        DateTime.now().add(const Duration(days: 90)),
        'Term',
        AppColors.primary(context),
      ),
    ]..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Academic Calendar')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: events.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.l),
        itemBuilder: (context, index) {
          final event = events[index];
          return AppCard(
            child: Row(
              children: [
                Container(width: 4, height: 40, color: event.color),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, d MMMM yyyy').format(event.date),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: event.category, color: event.color),
              ],
            ),
          );
        },
      ),
    );
  }
}
