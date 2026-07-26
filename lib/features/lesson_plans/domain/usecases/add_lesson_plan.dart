import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/lesson_plan.dart';
import '../repositories/lesson_plans_repository.dart';

class AddLessonPlan {
  final LessonPlansRepository repository;

  AddLessonPlan(this.repository);

  Future<Either<Failure, void>> call(LessonPlan plan) async {
    return await repository.addLessonPlan(plan);
  }
}
