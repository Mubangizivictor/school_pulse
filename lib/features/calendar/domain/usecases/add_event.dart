import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/school_event.dart';
import '../repositories/calendar_repository.dart';

class AddEvent {
  final CalendarRepository repository;

  AddEvent(this.repository);

  Future<Either<Failure, void>> call(SchoolEvent event) async {
    return await repository.addEvent(event);
  }
}
