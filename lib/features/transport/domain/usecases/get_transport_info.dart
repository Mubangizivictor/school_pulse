import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transport_info.dart';
import '../repositories/transport_repository.dart';

class GetTransportInfo {
  final TransportRepository repository;

  GetTransportInfo(this.repository);

  Future<Either<Failure, TransportInfo>> call(String studentId) async {
    return await repository.getTransportInfo(studentId);
  }
}
