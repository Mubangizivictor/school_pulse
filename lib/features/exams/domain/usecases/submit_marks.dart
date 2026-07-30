import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/assessment_repository.dart';

class SubmitMarks implements UseCase<void, List<String>> {
  final AssessmentRepository repository;

  SubmitMarks(this.repository);

  @override
  Future<Either<Failure, void>> call(List<String> markIds) async {
    return await repository.submitMarks(markIds);
  }
}
