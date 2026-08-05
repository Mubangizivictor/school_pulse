import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/academic_year.dart';
import '../entities/calendar_event.dart';

abstract class SchoolCalendarRepository {
  Future<Either<Failure, AcademicYear?>> getCurrentAcademicYear(
    String schoolId,
  );

  Future<Either<Failure, List<CalendarEvent>>> getEvents(String schoolId);

  Future<Either<Failure, void>> upsertEvent(CalendarEvent event);

  Future<Either<Failure, void>> deleteEvent(String schoolId, String eventId);
}
