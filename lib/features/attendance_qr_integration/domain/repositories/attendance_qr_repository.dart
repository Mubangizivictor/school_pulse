import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/qr_attendance_record.dart';

abstract class AttendanceQrRepository {
  Future<Either<Failure, void>> saveAttendance(QrAttendanceRecord record);
  Future<Either<Failure, List<QrAttendanceRecord>>> getPendingSyncRecords();
  Future<Either<Failure, void>> markAsSynced(String recordId);
  Future<Either<Failure, void>> syncWithFirebase();
  
  // Google Sheets Export
  Future<Either<Failure, void>> exportToGoogleSheets({
    required String schoolId,
    required List<QrAttendanceRecord> records,
    required String sheetName,
  });
}
