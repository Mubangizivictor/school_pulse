import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:school_pulse/core/notification/notification_service.dart';
import '../models/academic_record_model.dart';
import '../models/attendance_record_model.dart';
import '../../domain/entities/report_card.dart';
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
    Query<Map<String, dynamic>> query = firestore.collection('report_cards');

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

    final reportRef = firestore.collection('report_cards').doc(reportCardId);
    await reportRef.update(updates);

    // Once the Head Teacher's signature makes this fully approved, let the
    // parent know - they can't see the report card until this point.
    if (isHeadTeacher) {
      final doc = await reportRef.get();
      final studentId = doc.data()?['studentId'] as String?;
      if (studentId != null) {
        await _notifyParentReportCardReady(studentId);
      }
    }
  }

  /// Best-effort: a notification failure shouldn't undo an already-recorded
  /// signature. Mirrors the parent-uid derivation loginParent uses
  /// server-side (`parent_accessCode`), since a student doc doesn't store
  /// its parent's uid directly.
  Future<void> _notifyParentReportCardReady(String studentId) async {
    try {
      final snap = await firestore
          .collection('parent_access_codes')
          .where('studentIds', arrayContains: studentId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return;
      final parentUid = 'parent_${snap.docs.first.id}';
      await NotificationService().sendDirectNotification(
        userId: parentUid,
        title: 'Report Card Ready',
        body: "Your child's report card has been approved and is ready to view.",
      );
    } catch (e) {
      if (kDebugMode) print('Error notifying parent of report card: $e');
    }
  }
}
