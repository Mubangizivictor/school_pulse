import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/entities/sheets_integration.dart';
import '../../domain/repositories/sheets_integration_repository.dart';
import '../datasources/sheets_integration_remote_data_source.dart';

class SheetsIntegrationRepositoryImpl implements SheetsIntegrationRepository {
  final SheetsIntegrationRemoteDataSource remoteDataSource;
  final FirebaseFunctions functions;

  SheetsIntegrationRepositoryImpl({
    required this.remoteDataSource,
    required this.functions,
  });

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
    // The real export runs server-side: syncAttendanceToSheetsNow (Cloud
    // Function) re-appends today's attendance_records rows to the linked
    // spreadsheet using a service account, and writes its own
    // SheetsSyncLogEntry/lastSyncAt - the same trigger that fires
    // automatically on every new attendance mark when autoSync is on. This
    // call is just the manual "Sync Now" catch-up path.
    try {
      final callable = functions.httpsCallable('syncAttendanceToSheetsNow');
      await callable.call();
      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? 'Google Sheets sync failed.'));
    } catch (_) {
      return Left(ServerFailure('Google Sheets sync failed.'));
    }
  }
}
