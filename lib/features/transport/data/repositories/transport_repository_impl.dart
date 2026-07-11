import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transport_info.dart';
import '../../domain/repositories/transport_repository.dart';
import '../datasources/transport_remote_data_source.dart';

class TransportRepositoryImpl implements TransportRepository {
  final TransportRemoteDataSource remoteDataSource;

  TransportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TransportInfo>> getTransportInfo(String studentId) async {
    try {
      final info = await remoteDataSource.getTransportInfo(studentId);
      return Right(info);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
