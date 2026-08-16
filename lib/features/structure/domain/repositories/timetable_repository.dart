import '../entities/timetable.dart';

/// Class/stream timetables and their lesson assignments. Separate from
/// [StructureRepository] (which still owns the whole-school
/// [TimetableConfig] shape - periods/breaks/school hours) because a
/// timetable's lessons are a much higher-volume, independently-queried
/// dataset than the rest of Structure's master data.
abstract class TimetableRepository {
  Stream<List<Timetable>> watchTimetables({
    required String schoolId,
    String? academicYearId,
    String? classId,
  });

  Future<Timetable?> getTimetable({
    required String schoolId,
    required String timetableId,
  });

  Future<String> createTimetable(Timetable timetable);

  Future<void> updateTimetable(Timetable timetable);

  Stream<List<TimetableLesson>> watchLessons({
    required String schoolId,
    required String timetableId,
  });

  /// Every lesson at the school for an academic year (optionally narrowed to
  /// a term), regardless of which timetable it belongs to - the pool the
  /// conflict resolver checks a candidate lesson against.
  Future<List<TimetableLesson>> getAllLessonsForYear({
    required String schoolId,
    required String academicYearId,
    String? termId,
  });

  Future<String> upsertLesson(TimetableLesson lesson);

  Future<void> deleteLesson({
    required String schoolId,
    required String lessonId,
  });
}
