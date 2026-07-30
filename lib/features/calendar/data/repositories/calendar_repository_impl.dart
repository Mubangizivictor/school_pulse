import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/school_event.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_remote_data_source.dart';
import '../models/school_event_model.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarRemoteDataSource remoteDataSource;

  CalendarRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SchoolEvent>>> getUpcomingEvents() async {
    try {
      final events = await remoteDataSource.getUpcomingEvents();
      return Right(events);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addEvent(SchoolEvent event) async {
    try {
      final model = SchoolEventModel(
        id: event.id,
        title: event.title,
        description: event.description,
        date: event.date,
        createdBy: event.createdBy,
        targetGroups: event.targetGroups,
        type: event.type,
      );
      await remoteDataSource.addEvent(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String eventId) async {
    try {
      await remoteDataSource.deleteEvent(eventId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
