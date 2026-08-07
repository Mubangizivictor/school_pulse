import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/visitor.dart';
import '../repositories/gate_ops_repository.dart';

class CheckInVisitor {
  final GateOpsRepository repository;
  CheckInVisitor(this.repository);
  Future<Either<Failure, void>> call(Visitor visitor) =>
      repository.checkInVisitor(visitor);
}
