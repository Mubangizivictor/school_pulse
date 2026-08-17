import '../entities/class_timetable_entities.dart';

abstract class ClassTimetableRepository {
  Stream<List<ClassTimetable>> watchTimetables();
  Stream<List<ClassTimetableLesson>> watchLessons();

  Future<void> saveTimetable(ClassTimetable timetable);
  Future<void> saveLesson(ClassTimetableLesson lesson);
  Future<void> deleteLesson(String lessonId);
  Future<void> publishTimetable(String timetableId);
  Future<void> archiveTimetable(String timetableId);
}
