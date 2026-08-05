import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/lesson_plan.dart';
import '../../domain/repositories/lesson_plans_repository.dart';
import '../datasources/lesson_plans_remote_data_source.dart';
import '../models/lesson_plan_model.dart';

class LessonPlansRepositoryImpl implements LessonPlansRepository {
  final LessonPlansRemoteDataSource remoteDataSource;

  LessonPlansRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LessonPlan>>> getLessonPlans(
    String teacherId,
  ) async {
    try {
      final plans = await remoteDataSource.getLessonPlans(teacherId);
      return Right(plans);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addLessonPlan(LessonPlan plan) async {
    try {
      final model = LessonPlanModel(
        id: plan.id,
        teacherId: plan.teacherId,
        subject: plan.subject,
        className: plan.className,
        date: plan.date,
        content: plan.content,
      );
      await remoteDataSource.addLessonPlan(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
