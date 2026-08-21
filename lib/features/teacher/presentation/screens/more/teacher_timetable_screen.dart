import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_timetable/teacher_timetable_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;

class TeacherTimetableScreen extends StatelessWidget {
  const TeacherTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = di.sl<TeacherTimetableBloc>();
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          bloc.add(
            TeacherTimetableRequested(
              schoolId: authState.user.schoolId,
              teacherId: authState.user.id,
            ),
          );
        }
        return bloc;
      },
      child: const _TeacherTimetableView(),
    );
  }
}

class _TeacherTimetableView extends StatefulWidget {
  const _TeacherTimetableView();

  @override
  State<_TeacherTimetableView> createState() => _TeacherTimetableViewState();
}

class _TeacherTimetableViewState extends State<_TeacherTimetableView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedDay;

  static const _weekdayOrder = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Timetable'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Timetable'),
            Tab(text: 'Full School'),
          ],
        ),
      ),
      body: BlocBuilder<TeacherTimetableBloc, TeacherTimetableState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const SchoolPulseLoader();
          }

          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTimetable(context, state, state.myEntries, mine: true),
              _buildTimetable(context, state, state.allEntries, mine: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimetable(
    BuildContext context,
    TeacherTimetableState state,
    List<TeacherTimetableEntry> entries, {
    required bool mine,
  }) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          mine
              ? 'You have no lessons scheduled.'
              : 'No timetable has been published for this school yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      );
    }

    final days = state.daysOf(entries)
      ..sort(
        (a, b) => _weekdayOrder.indexOf(a).compareTo(_weekdayOrder.indexOf(b)),
      );
    final selected = _selectedDay ?? days.first;
    final forDay = state.entriesFor(entries, selected);

    return Column(
      children: [
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: days.map((day) {
              final isSelected = day == selected;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(day.substring(0, 3).toUpperCase()),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedDay = day),
                  selectedColor: AppColors.primary(context),
                  backgroundColor: AppColors.surfaceElevated(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary(context)
                        : AppColors.border(context),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : AppColors.textSecondary(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: forDay.isEmpty
              ? Center(
                  child: Text(
                    'No lessons on $selected.',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final entry in forDay)
                      _TimetableSlot(
                        time: '${entry.slot.startTime} - ${entry.slot.endTime}',
                        subject: entry.lesson.subjectName.isNotEmpty
                            ? entry.lesson.subjectName
                            : entry.slot.name,
                        className: mine
                            ? entry.lesson.classLabel
                            : '${entry.lesson.classLabel} • ${entry.lesson.teacherName}',
                        room: entry.lesson.roomName ?? '',
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _TimetableSlot extends StatelessWidget {
  final String time;
  final String subject;
  final String className;
  final String room;

  const _TimetableSlot({
    required this.time,
    required this.subject,
    required this.className,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted(context),
                  ),
                ),
                Text(
                  '$className - $subject',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (room.isNotEmpty)
            Text(
              room,
              style: TextStyle(
                color: AppColors.primary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
