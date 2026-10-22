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

  /// Exports the school's current student roster (identity/credential
  /// status, never a raw credential value) to the "Student Roster" tab of
  /// the same connected spreadsheet. Manual-only - there is no auto-sync
  /// trigger for this, unlike attendance.
  Future<Either<Failure, int>> exportRoster(String schoolId);
}
