import 'package:school_pulse/features/institution/data/datasources/institution_context_remote_datasource.dart';
import 'package:school_pulse/features/institution/domain/entities/institution_context.dart';
import 'package:school_pulse/features/institution/domain/repositories/institution_context_repository.dart';

class InstitutionContextRepositoryImpl implements InstitutionContextRepository {
  final InstitutionContextRemoteDataSource remoteDataSource;

  InstitutionContextRepositoryImpl({required this.remoteDataSource});

  @override
  Future<InstitutionContext> loadContext(String institutionId) {
    return remoteDataSource.loadContext(institutionId);
  }

  @override
  Stream<InstitutionContext> watchContext(String institutionId) {
    return remoteDataSource.watchContext(institutionId);
  }
}
