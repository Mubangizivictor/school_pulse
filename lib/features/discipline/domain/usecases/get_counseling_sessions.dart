import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/counseling_session.dart';
import '../repositories/discipline_repository.dart';

class GetCounselingSessions {
  final DisciplineRepository repository;

  GetCounselingSessions(this.repository);

  Future<Either<Failure, List<CounselingSession>>> call() {
    return repository.getCounselingSessions();
  }
}
