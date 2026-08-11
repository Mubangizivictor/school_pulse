import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/entities/academic_year.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/school_calendar_repository.dart';
import '../datasources/school_calendar_remote_data_source.dart';
import '../models/calendar_event_model.dart';

class SchoolCalendarRepositoryImpl implements SchoolCalendarRepository {
  final SchoolCalendarRemoteDataSource remoteDataSource;

  SchoolCalendarRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AcademicYear?>> getCurrentAcademicYear(
    String schoolId,
  ) async {
    try {
      final year = await remoteDataSource.getCurrentAcademicYear(schoolId);
      return Right(year);
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
  Future<Either<Failure, void>> upsertEvent(CalendarEvent event) async {
    try {
      await remoteDataSource.upsertEvent(CalendarEventModel.fromEntity(event));
      return const Right(null);
    } catch (e, st) {
      debugPrint('SchoolCalendarRepositoryImpl error: $e\n$st');
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(
    String schoolId,
    String eventId,
  ) async {
    try {
      await remoteDataSource.deleteEvent(schoolId, eventId);
      return const Right(null);
    } catch (e, st) {
      debugPrint('SchoolCalendarRepositoryImpl error: $e\n$st');
      return Left(ServerFailure('$e'));
    }
  }
}
