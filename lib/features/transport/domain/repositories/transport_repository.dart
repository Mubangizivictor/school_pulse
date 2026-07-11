import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transport_info.dart';

abstract class TransportRepository {
  Future<Either<Failure, TransportInfo>> getTransportInfo(String studentId);
}
