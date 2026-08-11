import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_category.dart';
import '../models/attendance_record_model.dart';

/// Builds the deterministic document id a record is stored under, so a
/// second mark for the same (category, scope, session, date, person)
/// collides with the first Firestore write instead of creating a duplicate.
String buildAttendanceRecordId({
  required AttendanceCategory category,
  required String scopeId,
  required String sessionType,
  required DateTime date,
  required String personId,
}) {
  final day =
      '${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  return '${category.name}_${scopeId}_${sessionType}_${day}_$personId';
}

abstract class AttendanceRemoteDataSource {
  Future<AttendanceRecordModel> markAttendance(AttendanceRecordModel record);
  Future<List<AttendanceRecordModel>> markBatch(
    List<AttendanceRecordModel> records,
  );
  Future<List<AttendanceRecordModel>> getRecords({
    required String schoolId,
    AttendanceCategory? category,
    DateTime? from,
    DateTime? to,
    String? scopeId,
  });
}

class DuplicateAttendanceException implements Exception {
  final String message;
  DuplicateAttendanceException([
    this.message = 'Attendance already recorded for this session',
  ]);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final FirebaseFirestore firestore;

  AttendanceRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> _records(String schoolId) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('attendance_records');

  @override
  Future<AttendanceRecordModel> markAttendance(
    AttendanceRecordModel record,
  ) async {
    final id = buildAttendanceRecordId(
      category: record.category,
      scopeId: record.scopeId,
      sessionType: record.sessionType,
      date: record.date,
      personId: record.personId,
    );
    final docRef = _records(record.schoolId).doc(id);

    final existing = await docRef.get();
    if (existing.exists) {
      throw DuplicateAttendanceException();
    }

    final withId = AttendanceRecordModel.fromEntity(record.copyWith());
    await docRef.set(withId.toFirestore());
    return AttendanceRecordModel.fromFirestore(await docRef.get());
  }

  @override
  Future<List<AttendanceRecordModel>> markBatch(
    List<AttendanceRecordModel> records,
  ) async {
    if (records.isEmpty) return [];
    final schoolId = records.first.schoolId;

    // Firestore has no batched "create if absent" - so each record's
    // existence is checked individually first, same as markAttendance's
    // single-record path, before anything is written. A batch that mixed
    // new and duplicate marks would otherwise silently overwrite the
    // duplicates instead of rejecting them.
    final docRefs = records.map((record) {
      final id = buildAttendanceRecordId(
        category: record.category,
        scopeId: record.scopeId,
        sessionType: record.sessionType,
        date: record.date,
        personId: record.personId,
      );
      return _records(schoolId).doc(id);
    }).toList();

    final existingChecks = await Future.wait(docRefs.map((ref) => ref.get()));
    final duplicateNames = <String>[];
    for (var i = 0; i < existingChecks.length; i++) {
      if (existingChecks[i].exists) {
        duplicateNames.add(records[i].personName);
      }
    }
    if (duplicateNames.isNotEmpty) {
      throw DuplicateAttendanceException(
        'Attendance already recorded for: ${duplicateNames.join(', ')}',
      );
    }

    final batch = firestore.batch();
    for (var i = 0; i < records.length; i++) {
      batch.set(docRefs[i], records[i].toFirestore(), SetOptions(merge: false));
    }
    await batch.commit();
    return records;
  }

  @override
  Future<List<AttendanceRecordModel>> getRecords({
    required String schoolId,
    AttendanceCategory? category,
    DateTime? from,
    DateTime? to,
    String? scopeId,
  }) async {
    Query<Map<String, dynamic>> query = _records(schoolId);
    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }
    if (scopeId != null) {
      query = query.where('scopeId', isEqualTo: scopeId);
    }
    if (from != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(
          DateTime(from.year, from.month, from.day),
        ),
      );
    }
    if (to != null) {
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(
          DateTime(to.year, to.month, to.day, 23, 59, 59),
        ),
      );
    }
    query = query.orderBy('date', descending: true);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => AttendanceRecordModel.fromFirestore(doc))
        .toList();
  }
}
