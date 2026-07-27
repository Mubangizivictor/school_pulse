import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/calendar_repository.dart';

class DeleteEvent {
  final CalendarRepository repository;

  DeleteEvent(this.repository);

  Future<Either<Failure, void>> call(String eventId) async {
    return await repository.deleteEvent(eventId);
  }
}
