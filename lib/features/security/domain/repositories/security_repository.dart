import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../presentation/bloc/security_state.dart';

abstract class SecurityRepository {
  Future<Either<Failure, SecurityLoaded>> getDashboardData();
}
