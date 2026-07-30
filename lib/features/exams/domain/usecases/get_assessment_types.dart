import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/assessment_type.dart';
import '../repositories/assessment_repository.dart';

class GetAssessmentTypes implements UseCase<List<AssessmentType>, String> {
  final AssessmentRepository repository;

  GetAssessmentTypes(this.repository);

  @override
  Future<Either<Failure, List<AssessmentType>>> call(String schoolId) async {
    return await repository.getAssessmentTypes(schoolId);
  }
}
