import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/academic_record_model.dart';
import '../models/attendance_record_model.dart';

import '../models/report_card_model.dart';

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

  Future<List<ReportCardModel>> getReportCards({
    String? studentId,
    String? className,
    String? term,
    String? year,
    ReportCardStatus? status,
  });

  Future<void> signReportCard({
    required String reportCardId,
    required String signerId,
    required bool isHeadTeacher,
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

  @override
  Future<List<ReportCardModel>> getReportCards({
    String? studentId,
    String? className,
    String? term,
    String? year,
    ReportCardStatus? status,
  }) async {
    var query = firestore.collection('report_cards').asQuery();

    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }
    if (className != null) {
      query = query.where('className', isEqualTo: className);
    }
    if (term != null) {
      query = query.where('term', isEqualTo: term);
    }
    if (year != null) {
      query = query.where('year', isEqualTo: year);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ReportCardModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> signReportCard({
    required String reportCardId,
    required String signerId,
    required bool isHeadTeacher,
  }) async {
    final updates = isHeadTeacher
        ? {
            'headTeacherId': signerId,
            'headTeacherSignedAt': FieldValue.serverTimestamp(),
            'status': ReportCardStatus.fullySigned.name,
          }
        : {
            'deanId': signerId,
            'deanSignedAt': FieldValue.serverTimestamp(),
            'status': ReportCardStatus.deanSigned.name,
          };

    await firestore.collection('report_cards').doc(reportCardId).update(updates);
  }
}
