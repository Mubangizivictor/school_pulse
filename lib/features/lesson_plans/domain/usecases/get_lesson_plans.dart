import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/lesson_plan.dart';
import '../repositories/lesson_plans_repository.dart';

class GetLessonPlans {
  final LessonPlansRepository repository;

  GetLessonPlans(this.repository);

  Future<Either<Failure, List<LessonPlan>>> call(String teacherId) async {
    return await repository.getLessonPlans(teacherId);
  }
}
