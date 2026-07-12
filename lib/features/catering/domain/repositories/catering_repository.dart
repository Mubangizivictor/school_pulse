import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../presentation/bloc/catering_state.dart';

abstract class CateringRepository {
  Future<Either<Failure, CateringLoaded>> getDashboardData();
}
