import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/sheets_integration.dart';

abstract class SheetsIntegrationRepository {
  Future<Either<Failure, SheetsIntegration>> getIntegration(String schoolId);

  /// Starts the OAuth connect flow, returning the Google consent URL to
  /// open in a browser.
  Future<Either<Failure, String>> startConnect(String schoolId);

  /// Disconnects the school's Google account. Does not delete attendance
  /// data or the spreadsheet itself.
  Future<Either<Failure, void>> disconnect(String schoolId);

  Future<Either<Failure, void>> updateAutoSync(String schoolId, bool autoSync);

  Future<Either<Failure, List<SheetsSyncLogEntry>>> getSyncLog(String schoolId);

  Future<Either<Failure, void>> triggerSync(String schoolId, int recordCount);

  Future<Either<Failure, ResyncResult>> resync(
    String schoolId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, SessionExportResult>> exportSession(
    String schoolId,
    List<String> recordIds,
  );
}
