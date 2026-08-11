import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/qr_attendance_record.dart';
import '../../domain/repositories/attendance_qr_repository.dart';

AttendanceQrRepository create({dynamic firestore, dynamic isar}) =>
    _AttendanceQrRepositoryStub();

class _AttendanceQrRepositoryStub implements AttendanceQrRepository {
  @override
  Future<Either<Failure, void>> saveAttendance(QrAttendanceRecord record) =>
      _unsupported();
  @override
  Future<Either<Failure, List<QrAttendanceRecord>>>
  getPendingSyncRecords() => _unsupported();
  @override
  Future<Either<Failure, void>> markAsSynced(String recordId) =>
      _unsupported();
  @override
  Future<Either<Failure, void>> syncWithFirebase() => _unsupported();
  @override
  Future<Either<Failure, void>> exportToGoogleSheets({
    required String schoolId,
    required List<QrAttendanceRecord> records,
    required String sheetName,
  }) => _unsupported();

  Never _unsupported() =>
      throw UnimplementedError('No AttendanceQrRepository for this platform');
}
