import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/dean_stats.dart';

abstract class DeanRepository {
  Future<Either<Failure, DeanStats>> getDeanStats();
}
