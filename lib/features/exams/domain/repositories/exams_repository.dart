import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../presentation/bloc/exams_state.dart';

abstract class ExamsRepository {
  Future<Either<Failure, ExamsLoaded>> getDashboardData();
}
