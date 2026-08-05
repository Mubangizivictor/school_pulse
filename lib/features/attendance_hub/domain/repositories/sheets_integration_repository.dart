import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/sheets_integration.dart';

abstract class SheetsIntegrationRepository {
  Future<Either<Failure, SheetsIntegration>> getIntegration(String schoolId);
  Future<Either<Failure, void>> saveIntegration(
    String schoolId,
    SheetsIntegration integration,
  );
  Future<Either<Failure, void>> disconnect(String schoolId);
  Future<Either<Failure, List<SheetsSyncLogEntry>>> getSyncLog(
    String schoolId,
  );
  Future<Either<Failure, void>> triggerSync(String schoolId, int recordCount);
}
