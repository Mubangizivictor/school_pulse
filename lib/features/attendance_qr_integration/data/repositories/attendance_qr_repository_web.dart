import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/qr_attendance_record.dart';
import '../../domain/repositories/attendance_qr_repository.dart';

AttendanceQrRepository create({dynamic firestore, dynamic isar}) =>
    AttendanceQrRepositoryWeb(firestore as FirebaseFirestore);

/// Legacy adapter retained only so stale direct links fail honestly. The
/// routed Attendance Hub owns QR writes and applies assignment/scope checks.
class AttendanceQrRepositoryWeb implements AttendanceQrRepository {
  final FirebaseFirestore firestore;

  AttendanceQrRepositoryWeb(this.firestore);

  @override
  Future<Either<Failure, void>> saveAttendance(QrAttendanceRecord record) =>
      _retired();

  @override
  Future<Either<Failure, List<QrAttendanceRecord>>>
  getPendingSyncRecords() async => const Right([]);

  @override
  Future<Either<Failure, void>> markAsSynced(String recordId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> syncWithFirebase() => _retired();

  @override
  Future<Either<Failure, void>> exportToGoogleSheets({
    required String schoolId,
    required List<QrAttendanceRecord> records,
    required String sheetName,
  }) async {
    return const Left(
      ServerFailure('Google Sheets integration has not been configured.'),
    );
  }

  Future<Either<Failure, T>> _retired<T>() async => const Left(
    ServerFailure(
      'This legacy QR attendance flow has been retired. Use Attendance Hub '
      'so marks are permission-checked and stored in the canonical record.',
    ),
  );
}
