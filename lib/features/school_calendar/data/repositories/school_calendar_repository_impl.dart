import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../../domain/repositories/school_calendar_repository.dart';
import '../datasources/school_calendar_remote_data_source.dart';
import '../models/calendar_event_model.dart';

class SchoolCalendarRepositoryImpl implements SchoolCalendarRepository {
  final SchoolCalendarRemoteDataSource remoteDataSource;
  final StructureRepository structureRepository;

  SchoolCalendarRepositoryImpl({
    required this.remoteDataSource,
    required this.structureRepository,
  });

  /// Reuses the structure module's canonical AcademicYear rather than
  /// duplicating it - the calendar has no academic-year collection of its
  /// own. Takes the first emission of the years stream and picks the
  /// current one client-side (structure exposes no one-shot getter).
  @override
  Future<Either<Failure, AcademicYear?>> getCurrentAcademicYear(
    String schoolId,
  ) async {
    try {
      final years = await structureRepository
          .watchAcademicYears(schoolId)
          .first;
      final current = years.where((year) => year.isCurrent).toList();
      return Right(current.isEmpty ? null : current.first);
    } catch (e, st) {
      debugPrint('SchoolCalendarRepositoryImpl error: $e\n$st');
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, List<CalendarEvent>>> getEvents(
    String schoolId,
  ) async {
    try {
      final events = await remoteDataSource.getEvents(schoolId);
      return Right(events);
    } catch (e, st) {
      debugPrint('SchoolCalendarRepositoryImpl error: $e\n$st');
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, String>> upsertEvent(CalendarEvent event) async {
    try {
      final id = await remoteDataSource.upsertEvent(
        CalendarEventModel.fromEntity(event),
      );
      return Right(id);
    } catch (e, st) {
      debugPrint('SchoolCalendarRepositoryImpl error: $e\n$st');
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(
    String schoolId,
    String eventId, {
    RecurrenceEditScope scope = RecurrenceEditScope.allOccurrences,
  }) async {
    try {
      await remoteDataSource.deleteEvent(schoolId, eventId, scope: scope);
      return const Right(null);
    } catch (e, st) {
      debugPrint('SchoolCalendarRepositoryImpl error: $e\n$st');
      return Left(ServerFailure('$e'));
    }
  }
}
