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

  /// Maps backend errors to plain-language messages. Cloud Functions
  /// attaches a machine-readable `reason` in `details` (see
  /// friendlyError() in functions/attendance_sheets.js) so this never has
  /// to string-match a raw Google/OAuth error message.
  Failure _mapError(Object error) {
    if (error is FirebaseFunctionsException) {
      final details = error.details;
      final reason = details is Map ? details['reason'] as String? : null;
      switch (reason) {
        case 'not_connected':
          return ServerFailure('Connect Google Sheets first.');
        case 'needs_reauth':
          return ServerFailure('Google Sheets connection needs to be renewed.');
        case 'temporary':
          return ServerFailure(
            'Attendance is saved. Google Sheets will sync automatically when available.',
          );
        default:
          return ServerFailure(error.message ?? 'Google Sheets sync failed.');
      }
    }
    return ServerFailure('Google Sheets sync failed.');
  }

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
  Future<Either<Failure, String>> startConnect(String schoolId) async {
    try {
      final callable = functions.httpsCallable('startGoogleSheetsOAuth');
      final result = await callable.call();
      final authUrl = (result.data as Map)['authUrl'] as String?;
      if (authUrl == null || authUrl.isEmpty) {
        return Left(
          ServerFailure('Could not start the Google Sheets connection.'),
        );
      }
      return Right(authUrl);
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> disconnect(String schoolId) async {
    try {
      final callable = functions.httpsCallable('disconnectGoogleSheetsOAuth');
      await callable.call();
      return const Right(null);
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateAutoSync(
    String schoolId,
    bool autoSync,
  ) async {
    try {
      await remoteDataSource.updatePreferences(schoolId, autoSync: autoSync);
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
    // spreadsheet, skipping anything already exported, and writes its own
    // SheetsSyncLogEntry/lastSyncAt - the same path the auto-sync trigger
    // uses when autoSync is on. This call is just the manual "Sync Now"
    // catch-up path.
    try {
      final callable = functions.httpsCallable('syncAttendanceToSheetsNow');
      await callable.call();
      return const Right(null);
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, ResyncResult>> resync(
    String schoolId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final callable = functions.httpsCallable('resyncAttendanceToSheets');
      final result = await callable.call({
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      return Right(
        ResyncResult(
          recordsScanned: data['recordsScanned'] as int? ?? 0,
          recordsExported: data['recordsExported'] as int? ?? 0,
          recordsSkippedAlreadyExported:
              data['recordsSkippedAlreadyExported'] as int? ?? 0,
        ),
      );
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, SessionExportResult>> exportSession(
    String schoolId,
    List<String> recordIds,
  ) async {
    try {
      final callable = functions.httpsCallable(
        'exportAttendanceSessionToSheets',
      );
      final result = await callable.call({'recordIds': recordIds});
      final data = Map<String, dynamic>.from(result.data as Map);
      return Right(
        SessionExportResult(
          recordCount: data['recordCount'] as int? ?? 0,
          alreadyExportedCount: data['alreadyExportedCount'] as int? ?? 0,
        ),
      );
    } catch (e) {
      return Left(_mapError(e));
    }
  }
}
