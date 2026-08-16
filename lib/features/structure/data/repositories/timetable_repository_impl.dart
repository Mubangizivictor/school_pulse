import '../../domain/entities/timetable.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../datasources/timetable_remote_data_source.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  final TimetableRemoteDataSource remoteDataSource;

  TimetableRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<Timetable>> watchTimetables({
    required String schoolId,
    String? academicYearId,
    String? classId,
  }) => remoteDataSource.watchTimetables(
    schoolId: schoolId,
    academicYearId: academicYearId,
    classId: classId,
  );

  @override
  Future<Timetable?> getTimetable({
    required String schoolId,
    required String timetableId,
  }) => remoteDataSource.getTimetable(
    schoolId: schoolId,
    timetableId: timetableId,
  );

  @override
  Future<String> createTimetable(Timetable timetable) =>
      remoteDataSource.createTimetable(timetable);

  @override
  Future<void> updateTimetable(Timetable timetable) =>
      remoteDataSource.updateTimetable(timetable);

  @override
  Stream<List<TimetableLesson>> watchLessons({
    required String schoolId,
    required String timetableId,
  }) => remoteDataSource.watchLessons(
    schoolId: schoolId,
    timetableId: timetableId,
  );

  @override
  Future<List<TimetableLesson>> getAllLessonsForYear({
    required String schoolId,
    required String academicYearId,
    String? termId,
  }) => remoteDataSource.getAllLessonsForYear(
    schoolId: schoolId,
    academicYearId: academicYearId,
    termId: termId,
  );

  @override
  Future<String> upsertLesson(TimetableLesson lesson) =>
      remoteDataSource.upsertLesson(lesson);

  @override
  Future<void> deleteLesson({
    required String schoolId,
    required String lessonId,
  }) => remoteDataSource.deleteLesson(schoolId: schoolId, lessonId: lessonId);
}
