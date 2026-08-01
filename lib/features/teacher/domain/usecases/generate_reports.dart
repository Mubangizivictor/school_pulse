import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/teacher_repository.dart';

class GenerateReportsParams {
  final String className;
  final String term;
  final String year;
  final List<String> studentIds;
  final List<String> enabledSections;

  GenerateReportsParams({
    required this.className,
    required this.term,
    required this.year,
    required this.studentIds,
    required this.enabledSections,
  });
}

class GenerateReports implements UseCase<void, GenerateReportsParams> {
  final TeacherRepository repository;

  GenerateReports(this.repository);

  @override
  Future<Either<Failure, void>> call(GenerateReportsParams params) async {
    return await repository.generateReports(
      className: params.className,
      term: params.term,
      year: params.year,
      studentIds: params.studentIds,
      enabledSections: params.enabledSections,
    );
  }
}
