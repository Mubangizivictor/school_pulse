import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/teacher_dashboard_stats.dart';
import '../repositories/teacher_repository.dart';

class GetTeacherDashboardStats implements UseCase<TeacherDashboardStats, String> {
  final TeacherRepository repository;

  GetTeacherDashboardStats(this.repository);

  @override
  Future<Either<Failure, TeacherDashboardStats>> call(String params) async {
    return await repository.getTeacherDashboardStats(params);
  }
}
