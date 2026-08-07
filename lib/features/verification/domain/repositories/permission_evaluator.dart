import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/gate.dart';

/// Checks whether an operator holds a given permission, optionally scoped
/// to a specific [Gate] (or, in later phases, any other assignable
/// resource). Scanning a credential never grants access on its own - this
/// is the single gate every verification decision must pass through.
abstract class PermissionEvaluator {
  Future<Either<Failure, bool>> can(
    String permissionId,
    UserEntity operatorUser, {
    Gate? gate,
  });
}
