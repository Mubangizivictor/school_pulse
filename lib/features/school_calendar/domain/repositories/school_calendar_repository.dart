import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import '../entities/calendar_event.dart';
import '../entities/recurrence_rule.dart';

abstract class SchoolCalendarRepository {
  Future<Either<Failure, AcademicYear?>> getCurrentAcademicYear(
    String schoolId,
  );

  Future<Either<Failure, List<CalendarEvent>>> getEvents(String schoolId);

  /// Returns the saved event's id on success. When [event] carries a
  /// [CalendarEvent.recurrence] and has no id yet, this materializes one
  /// document per occurrence and returns the first occurrence's id.
  Future<Either<Failure, String>> upsertEvent(CalendarEvent event);

  Future<Either<Failure, void>> deleteEvent(
    String schoolId,
    String eventId, {
    RecurrenceEditScope scope = RecurrenceEditScope.allOccurrences,
  });
}
