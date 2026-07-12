import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../presentation/bloc/gatekeeper_state.dart';

abstract class GatekeeperRepository {
  Future<Either<Failure, GatekeeperLoaded>> getDashboardData();
  Future<Either<Failure, void>> logVisitor(VisitorLog visitor);
  Future<Either<Failure, void>> signExit(String visitorId);
}
