import 'package:equatable/equatable.dart';

import 'package:school_pulse/features/structure/domain/entities/timetable.dart';
import 'package:school_pulse/features/structure/domain/entities/timetable_config.dart';

/// One lesson placed against a real configured slot, so a timetable screen
/// can show a clock time and day rather than an index into a mock list.
///
/// Shared by [ClassTimetableBloc](../class_timetable/class_timetable_bloc.dart)
/// and [TeacherTimetableBloc](../teacher_timetable/teacher_timetable_bloc.dart)
/// - each bloc's own entry type is a `typedef` to this one. The blocs
/// themselves stay separate because their query strategies differ (one class's
/// active timetable via reactive streams vs. the whole school's lessons for
/// the year via one bulk fetch, filtered client-side by teacher), but the
/// shape of "a lesson against a slot on a day" and how it is built from raw
/// lessons + slot config is identical, so that part is not duplicated.
class TeacherTimetableEntry extends Equatable {
  final TimetableLesson lesson;
  final String day;
  final TimetableSlot slot;

  const TeacherTimetableEntry({
    required this.lesson,
    required this.day,
    required this.slot,
  });

  @override
  List<Object?> get props => [lesson, day, slot];
}

/// Builds [TeacherTimetableEntry] rows from raw lessons and the school's slot
/// config - the mapping step both timetable blocs performed identically.
List<TeacherTimetableEntry> mapLessonsToTimetableEntries({
  required List<TimetableLesson> lessons,
  required TimetableConfig config,
}) {
  final slotsById = {for (final slot in config.slots) slot.id: slot};

  final entries = <TeacherTimetableEntry>[];
  for (final lesson in lessons) {
    for (final occurrence in lesson.occurrences) {
      final slot = slotsById[occurrence.slotId];
      if (slot == null) continue;
      entries.add(
        TeacherTimetableEntry(lesson: lesson, day: occurrence.day, slot: slot),
      );
    }
  }
  return entries;
}

/// Days present in [entries], in first-seen order - the row order both
/// timetable screens render their day tabs in.
List<String> distinctTimetableDays(List<TeacherTimetableEntry> entries) {
  final seen = <String>{};
  final ordered = <String>[];
  for (final entry in entries) {
    if (seen.add(entry.day)) ordered.add(entry.day);
  }
  return ordered;
}

/// Entries for one day, sorted by slot start time - the per-day list both
/// timetable screens render.
List<TeacherTimetableEntry> timetableEntriesForDay(
  List<TeacherTimetableEntry> entries,
  String day,
) {
  final forDay = entries.where((e) => e.day == day).toList()
    ..sort((a, b) => a.slot.startTime.compareTo(b.slot.startTime));
  return forDay;
}
