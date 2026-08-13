import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/qr_attendance_record.dart';
import '../../domain/repositories/attendance_qr_repository.dart';
import 'attendance_qr_firestore_writer.dart';

AttendanceQrRepository create({dynamic firestore, dynamic isar}) =>
    AttendanceQrRepositoryWeb(firestore as FirebaseFirestore);

/// No local database and no offline queue on web - saveAttendance writes
/// straight to the same tenant-scoped Firestore collection syncWithFirebase
/// uses on mobile, so every write is already durable. getPendingSyncRecords
/// is always empty and markAsSynced/syncWithFirebase are no-ops since
/// nothing is ever queued.
class AttendanceQrRepositoryWeb
    with AttendanceQrFirestoreWriter
    implements AttendanceQrRepository {
  @override
  final FirebaseFirestore firestore;

  AttendanceQrRepositoryWeb(this.firestore);

  @override
  Future<Either<Failure, void>> saveAttendance(
    QrAttendanceRecord record,
  ) async {
    try {
      await writeToScopedCollection(record);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QrAttendanceRecord>>>
  getPendingSyncRecords() async => const Right([]);

  @override
  Future<Either<Failure, void>> markAsSynced(String recordId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> syncWithFirebase() async => const Right(null);

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
}
