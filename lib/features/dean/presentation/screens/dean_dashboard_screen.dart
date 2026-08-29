import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

/// Dense mobile DOS overview; data remains sourced from the existing DeanBloc.
class DeanDashboardScreen extends StatelessWidget {
  const DeanDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<DeanBloc>()..add(AcademicDashboardRequested()),
    child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is! AcademicDashboardLoaded) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            }
            final s = state.stats;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Martin · Director of Studies',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.chat_bubble_outline, size: 21),
                    const SizedBox(width: 16),
                    const Icon(Icons.notifications_none, size: 21),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Academic overview',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: _box(),
                  child: Row(
                    children: [
                      Text(
                        '${s.currentTerm}, ${s.currentAcademicYear}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (_, c) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _kpi(
                        'Lessons today',
                        s.lessonsConductedToday,
                        'View today’s schedule',
                        false,
                        (c.maxWidth - 8) / 2,
                        () => context.push('/staff/dean/today'),
                      ),
                      _kpi(
                        'Timetable conflicts',
                        s.lessonsMissedToday,
                        'Require attention',
                        s.lessonsMissedToday > 0,
                        (c.maxWidth - 8) / 2,
                        () => context.push('/staff/dean/missed-lessons'),
                      ),
                      _kpi(
                        'Marks pending',
                        s.marksPendingEntry,
                        'Across ${s.assessmentsPending} assessments',
                        s.marksPendingEntry > 0,
                        (c.maxWidth - 8) / 2,
                        () => context.push('/staff/dean/marks-qa'),
                      ),
                      _kpi(
                        'Syllabus coverage',
                        '${s.teacherLessonCompletionRate.round()}%',
                        'On track',
                        false,
                        (c.maxWidth - 8) / 2,
                        () => context.push('/staff/dean/curriculum'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Today's lessons & cover",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: _box(),
                  child: Column(
                    children: [
                      _lesson(
                        '08:00',
                        'Senior 1A · Mathematics',
                        'Mr. Tumwine · Room 02',
                      ),
                      _lesson(
                        '10:00',
                        'Senior 2B · Physics',
                        'Mr. Kato · Room P1 (Cover)',
                        risk: true,
                      ),
                      _lesson(
                        '13:00',
                        'Senior 3A · English',
                        'Mr. Ssekandi · Room E3',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Quick actions',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _quick(
                      Icons.calendar_month_outlined,
                      'Build\ntimetable',
                      () => context.push('/staff/dean/curriculum'),
                    ),
                    _quick(
                      Icons.add_task_outlined,
                      'Add\nassessment',
                      () => context.push('/staff/dean/assessments'),
                    ),
                    _quick(
                      Icons.fact_check_outlined,
                      'Review\nmarks',
                      () => context.push('/staff/dean/marks-qa'),
                    ),
                    _quick(
                      Icons.person_outline,
                      'Assign\ncover',
                      () => context.push('/staff/dean/missed-lessons'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
  static BoxDecoration _box() => BoxDecoration(
    border: Border.all(color: const Color(0xffe5e5e7)),
    borderRadius: BorderRadius.circular(7),
  );
  static Widget _kpi(
    String title,
    Object value,
    String sub,
    bool red,
    double width,
    VoidCallback onTap,
  ) => SizedBox(
    width: width,
    child: InkWell(
      onTap: onTap,
      child: Container(
        height: 82,
        padding: const EdgeInsets.all(10),
        decoration: _box(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 10)),
            const Spacer(),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 22,
                height: 1,
                color: red ? const Color(0xffd92d20) : Colors.black,
              ),
            ),
            const Spacer(),
            Text(
              sub,
              style: TextStyle(
                fontSize: 9,
                color: red ? const Color(0xffd92d20) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    ),
  );
  static Widget _lesson(
    String time,
    String title,
    String sub, {
    bool risk = false,
  }) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: SizedBox(
        width: 42,
        child: Text(time, style: const TextStyle(fontSize: 10)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(sub, style: const TextStyle(fontSize: 9)),
      trailing: risk
          ? const Text(
              'Cover',
              style: TextStyle(fontSize: 9, color: Color(0xffd92d20)),
            )
          : null,
    );
  }

  static Widget _quick(IconData icon, String text, VoidCallback tap) =>
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 6),
          child: OutlinedButton(
            onPressed: tap,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 50),
              padding: const EdgeInsets.all(4),
              side: const BorderSide(color: Color(0xffe5e5e7)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: Colors.black),
                const SizedBox(height: 2),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.black,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
