import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/academic_record_model.dart';
import '../models/attendance_record_model.dart';

abstract class AcademicRemoteDataSource {
  Future<List<AcademicRecordModel>> getAcademicRecords(
    String studentId, {
    String? term,
    String? year,
  });

  Future<List<AttendanceRecordModel>> getAttendanceRecords(
    String studentId, {
    DateTime? startDate,
    DateTime? endDate,
  });
}

class AcademicRemoteDataSourceImpl implements AcademicRemoteDataSource {
  final FirebaseFirestore firestore;

  AcademicRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<AcademicRecordModel>> getAcademicRecords(
    String studentId, {
    String? term,
    String? year,
  }) async {
    var query = firestore
        .collection('academic_records')
        .where('studentId', isEqualTo: studentId);

    if (term != null) {
      query = query.where('term', isEqualTo: term);
    }
    if (year != null) {
      query = query.where('year', isEqualTo: year);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => AcademicRecordModel.fromFirestore(doc.data()))
        .toList();
  }

  @override
  Future<List<AttendanceRecordModel>> getAttendanceRecords(
    String studentId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = firestore
        .collection('attendance_records')
        .where('studentId', isEqualTo: studentId);

    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => AttendanceRecordModel.fromFirestore(doc.data()))
        .toList();
  }
}
