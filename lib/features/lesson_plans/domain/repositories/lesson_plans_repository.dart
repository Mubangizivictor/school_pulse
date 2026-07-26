import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/lesson_plan.dart';

abstract class LessonPlansRepository {
  Future<Either<Failure, List<LessonPlan>>> getLessonPlans(String teacherId);
  Future<Either<Failure, void>> addLessonPlan(LessonPlan plan);
}
