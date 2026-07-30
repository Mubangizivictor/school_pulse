import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/academic_dashboard_stats.dart';
import '../repositories/dean_repository.dart';

class GetDeanStats implements UseCase<AcademicDashboardStats, NoParams> {
  final DeanRepository repository;

  GetDeanStats(this.repository);

  @override
  Future<Either<Failure, AcademicDashboardStats>> call(NoParams params) async {
    return await repository.getAcademicDashboardStats();
  }
}
