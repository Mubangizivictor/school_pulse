import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/competency_rating.dart';
import '../repositories/teacher_repository.dart';

class GetCompetencyRatings {
  final TeacherRepository repository;
  GetCompetencyRatings(this.repository);

  Future<Either<Failure, List<CompetencyRating>>> call({
    required String schoolId,
    required String className,
    required String term,
    required String year,
    required String competency,
  }) async {
    return await repository.getCompetencyRatings(
      schoolId: schoolId,
      className: className,
      term: term,
      year: year,
      competency: competency,
    );
  }
}

class SaveCompetencyRating {
  final TeacherRepository repository;
  SaveCompetencyRating(this.repository);

  Future<Either<Failure, void>> call(CompetencyRating rating) async {
    return await repository.saveCompetencyRating(rating);
  }
}
