import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_timetable/class_timetable_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;

class ClassTimetableScreen extends StatelessWidget {
  final String classId;
  const ClassTimetableScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = di.sl<ClassTimetableBloc>();
        final active = context.read<ClassTeacherContextBloc>().state.active;
        if (active != null) {
          bloc.add(ClassTimetableRequested(active));
        }
        return bloc;
      },
      child: const _ClassTimetableView(),
    );
  }
}

class _ClassTimetableView extends StatefulWidget {
  const _ClassTimetableView();

  @override
  State<_ClassTimetableView> createState() => _ClassTimetableViewState();
}

class _ClassTimetableViewState extends State<_ClassTimetableView> {
  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.textPrimary(context);
    final className =
        context.watch<ClassTeacherContextBloc>().state.active?.className ?? '';

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timetable',
              style: AppTypography.titleLarge.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (className.isNotEmpty)
              Text(
                className,
                style: AppTypography.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
          ],
        ),
      ),
      body: BlocBuilder<ClassTimetableBloc, ClassTimetableState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const SchoolPulseLoader();
          }

          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ),
            );
          }

          if (!state.hasPublishedTimetable) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'No timetable has been published for this class yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ),
            );
          }

          final days = state.days.isEmpty
              ? _weekdays.take(6).toList()
              : (List<String>.from(state.days)..sort(
                  (a, b) =>
                      _weekdays.indexOf(a).compareTo(_weekdays.indexOf(b)),
                ));
          final selected = _selectedDay ?? days.first;
          final entries = state.entriesFor(selected);

          return Column(
            children: [
              _buildDaySelector(isDark, days, selected),
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Text(
                          'No lessons scheduled for $selected.',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        itemCount: entries.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.m),
                        itemBuilder: (context, index) =>
                            _buildTimetableItem(entries[index], isDark),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDaySelector(bool isDark, List<String> days, String selected) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day == selected;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = day),
            child: Container(
              margin: const EdgeInsets.only(right: AppSpacing.m),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.s,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? AppColors.royalBlue
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  day.substring(0, 3).toUpperCase(),
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.royalBlue
                        : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimetableItem(ClassTimetableEntry entry, bool isDark) {
    return PulseCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _colorFor(entry.slot.colorHex),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.slot.startTime} - ${entry.slot.endTime}',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
                Text(
                  entry.lesson.subjectName.isNotEmpty
                      ? entry.lesson.subjectName
                      : entry.slot.name,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (entry.lesson.roomName != null)
            Text(
              entry.lesson.roomName!,
              style: AppTypography.labelSmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
        ],
      ),
    );
  }

  Color _colorFor(String hex) {
    if (hex.isEmpty) return AppColors.royalBlue;
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(
      cleaned.length == 6 ? 'FF$cleaned' : cleaned,
      radix: 16,
    );
    return value == null ? AppColors.royalBlue : Color(value);
  }
}
