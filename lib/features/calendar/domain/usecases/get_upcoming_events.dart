import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/school_event.dart';
import '../repositories/calendar_repository.dart';

class GetUpcomingEvents {
  final CalendarRepository repository;

  GetUpcomingEvents(this.repository);

  Future<Either<Failure, List<SchoolEvent>>> call() async {
    return await repository.getUpcomingEvents();
  }
}
