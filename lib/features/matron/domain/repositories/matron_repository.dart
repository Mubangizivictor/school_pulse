import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../presentation/bloc/matron_state.dart';

abstract class MatronRepository {
  Future<Either<Failure, MatronLoaded>> getDashboardData();
}
