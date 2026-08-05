import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/entities/sheets_integration.dart';
import '../../domain/repositories/sheets_integration_repository.dart';
import '../datasources/sheets_integration_remote_data_source.dart';

class SheetsIntegrationRepositoryImpl implements SheetsIntegrationRepository {
  final SheetsIntegrationRemoteDataSource remoteDataSource;

  SheetsIntegrationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SheetsIntegration>> getIntegration(
    String schoolId,
  ) async {
    try {
      return Right(await remoteDataSource.getIntegration(schoolId));
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveIntegration(
    String schoolId,
    SheetsIntegration integration,
  ) async {
    try {
      await remoteDataSource.saveIntegration(schoolId, integration);
      return const Right(null);
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> disconnect(String schoolId) async {
    try {
      await remoteDataSource.disconnect(schoolId);
      return const Right(null);
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SheetsSyncLogEntry>>> getSyncLog(
    String schoolId,
  ) async {
    try {
      return Right(await remoteDataSource.getSyncLog(schoolId));
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> triggerSync(
    String schoolId,
    int recordCount,
  ) async {
    try {
      // No real Google Sheets API call yet (needs a Cloud Function proxy +
      // service account, or an Apps Script webhook - an explicit open
      // decision, see the plan). This records a successful sync attempt so
      // the settings/history UI is fully functional now and swaps in a real
      // write later without changing this contract.
      final entry = SheetsSyncLogEntry(
        id: '',
        startedAt: DateTime.now(),
        success: true,
        recordCount: recordCount,
      );
      await remoteDataSource.appendSyncLog(schoolId, entry);
      await remoteDataSource.saveIntegration(
        schoolId,
        SheetsIntegration(lastSyncAt: DateTime.now(), lastSyncStatus: 'success'),
      );
      return const Right(null);
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
