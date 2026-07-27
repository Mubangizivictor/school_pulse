import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/counseling_session.dart';
import '../repositories/discipline_repository.dart';

class LogCounselingSession {
  final DisciplineRepository repository;

  LogCounselingSession(this.repository);

  Future<Either<Failure, void>> call(CounselingSession session) {
    return repository.logCounselingSession(session);
  }
}
