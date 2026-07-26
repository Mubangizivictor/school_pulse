import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/school_event.dart';

abstract class CalendarRepository {
  Future<Either<Failure, List<SchoolEvent>>> getUpcomingEvents();
  Future<Either<Failure, void>> addEvent(SchoolEvent event);
}
