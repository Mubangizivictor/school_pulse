import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../repositories/gate_ops_repository.dart';

class CheckOutVisitor {
  final GateOpsRepository repository;
  CheckOutVisitor(this.repository);
  Future<Either<Failure, void>> call(String visitorId) =>
      repository.checkOutVisitor(visitorId);
}
