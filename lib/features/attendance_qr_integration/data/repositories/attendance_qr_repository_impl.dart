import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/qr_attendance_record.dart';
import '../../domain/repositories/attendance_qr_repository.dart';
import '../models/attendance_log_isar.dart';

class AttendanceQrRepositoryImpl implements AttendanceQrRepository {
  final FirebaseFirestore firestore;
  final Isar isar;

  AttendanceQrRepositoryImpl({
    required this.firestore,
    required this.isar,
  });

  @override
  Future<Either<Failure, void>> saveAttendance(QrAttendanceRecord record) async {
    try {
      // Save locally to Isar first (Offline First)
      final log = AttendanceLogIsar()
        ..studentUniqueId = record.studentUniqueId
        ..studentName = record.studentName
        ..className = record.className
        ..status = record.status.name
        ..timestamp = record.timestamp
        ..scannedBy = record.scannedBy
        ..schoolId = record.schoolId
        ..module = record.module
        ..isSynced = false;

      await isar.writeTxn(() async {
        await isar.attendanceLogIsars.put(log);
      });

      // Try to sync immediately if online (optional, can be handled by a separate sync process)
      // For now, we'll just return Success and let the sync process handle it.
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<QrAttendanceRecord>>> getPendingSyncRecords() async {
    try {
      final logs = await isar.attendanceLogIsars.filter().isSyncedEqualTo(false).findAll();
      return Right(logs.map((log) => QrAttendanceRecord(
        id: log.id.toString(),
        studentUniqueId: log.studentUniqueId,
        studentName: log.studentName,
        className: log.className,
        status: QrAttendanceStatus.values.byName(log.status),
        timestamp: log.timestamp,
        scannedBy: log.scannedBy,
        schoolId: log.schoolId,
        module: log.module,
        isSynced: log.isSynced,
      )).toList());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(String recordId) async {
    try {
      final id = int.parse(recordId);
      await isar.writeTxn(() async {
        final log = await isar.attendanceLogIsars.get(id);
        if (log != null) {
          log.isSynced = true;
          await isar.attendanceLogIsars.put(log);
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> syncWithFirebase() async {
    try {
      final pending = await getPendingSyncRecords();
      return pending.fold(
        (failure) => Left(failure),
        (records) async {
          for (final record in records) {
            await firestore.collection('attendance_qr_logs').add({
              'studentUniqueId': record.studentUniqueId,
              'studentName': record.studentName,
              'className': record.className,
              'status': record.status.name,
              'timestamp': record.timestamp,
              'scannedBy': record.scannedBy,
              'schoolId': record.schoolId,
              'module': record.module,
            });
            await markAsSynced(record.id);
          }
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> exportToGoogleSheets({
    required String schoolId,
    required List<QrAttendanceRecord> records,
    required String sheetName,
  }) async {
    // Implementation for Google Sheets export
    // This typically involves calling a Cloud Function or using a Google Sheets API client
    // For now, we'll mark it as a placeholder.
    return const Right(null);
  }
}
