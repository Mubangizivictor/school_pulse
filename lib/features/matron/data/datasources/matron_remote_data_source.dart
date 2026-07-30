import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:school_pulse/core/notification/notification_service.dart';
import '../../domain/entities/boarding_entities.dart';
import '../../domain/repositories/matron_repository.dart';

abstract class MatronRemoteDataSource {
  Future<BoardingDashboardData> getDashboardData({
    String? schoolId,
    String? gender,
  });
  Future<List<Dormitory>> getDormitories({String? gender});
  Future<List<BoardingStudent>> getUnallocatedStudents({String? gender});
  Future<void> allocateStudent(
    String studentId,
    String dormitoryId,
    String? bedNumber,
  );
  Future<List<BoardingStudent>> getDormitoryStudents(String dormitoryId);
  Future<void> submitAttendance({
    required String dormitoryId,
    required String type,
    required Map<String, String> attendance,
  });
  Future<List<WelfareRecord>> getWelfareRecords({
    String? schoolId,
    String? studentId,
    String? gender,
    bool publicOnly = false,
  });
  Future<void> addWelfareRecord(WelfareRecord record);
  Future<List<DisciplineCase>> getDisciplineCases({
    String? studentId,
    String? gender,
  });
  Future<void> addDisciplineCase(DisciplineCase disciplineCase);
  Future<List<HygieneCheck>> getHygieneChecks({
    String? dormitoryId,
    String? gender,
  });
  Future<void> addHygieneCheck(HygieneCheck check);
  Future<List<BoardingStudent>> getStudentsOnLeave({String? gender});
}

class MatronRemoteDataSourceImpl implements MatronRemoteDataSource {
  final FirebaseFirestore firestore;

  MatronRemoteDataSourceImpl({required this.firestore});

  @override
  Future<BoardingDashboardData> getDashboardData({
    String? schoolId,
    String? gender,
  }) async {
    final dormitories = await getDormitories(gender: gender);

    Query<Map<String, dynamic>> boarderQuery = firestore
        .collection('students')
        .where('isBoarder', isEqualTo: true);
    if (gender != null) {
      boarderQuery = boarderQuery.where('gender', isEqualTo: gender);
    }
    final boarders = await boarderQuery.get();
    final totalStudents = boarders.docs.length;

    // Simplified stats for dashboard
    int present = 0;
    int onLeave = 0;
    for (var doc in boarders.docs) {
      final status = doc.data()['status'] ?? 'Present';
      if (status == 'Present') present++;
      if (status == 'Leave') onLeave++;
    }

    Query disciplineQuery = firestore
        .collection('discipline_cases')
        .where('status', isEqualTo: 'Pending');
    if (gender != null) {
      disciplineQuery = disciplineQuery.where('gender', isEqualTo: gender);
    }
    final disciplineSnap = await disciplineQuery.get();

    final welfareRecords = await getWelfareRecords(
      schoolId: schoolId,
      gender: gender,
    );

    return BoardingDashboardData(
      dormitories: dormitories,
      totalStudents: totalStudents,
      studentsPresent: present,
      studentsOnLeave: onLeave,
      activeDisciplineCases: disciplineSnap.docs.length,
      pendingWelfareConcerns: welfareRecords
          .where((record) => record.category == 'Concern')
          .length,
    );
  }

  @override
  Future<List<Dormitory>> getDormitories({String? gender}) async {
    Query<Map<String, dynamic>> query = firestore.collection('dormitories');
    if (gender != null) query = query.where('gender', isEqualTo: gender);
    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Dormitory(
        id: doc.id,
        name: data['name'] ?? '',
        gender: data['gender'] ?? '',
        capacity: data['capacity'] ?? 0,
        occupantCount: data['currentOccupants'] ?? 0,
        roomLeaderId: data['roomLeaderId'],
        roomLeaderName: data['roomLeaderName'],
      );
    }).toList();
  }

  @override
  Future<List<BoardingStudent>> getUnallocatedStudents({String? gender}) async {
    Query<Map<String, dynamic>> query = firestore
        .collection('students')
        .where('isBoarder', isEqualTo: true)
        .where('dormitoryId', isNull: true);
    if (gender != null) query = query.where('gender', isEqualTo: gender);
    final snapshot = await query.get();

    return snapshot.docs
        .map(
          (doc) => BoardingStudent(
            id: doc.id,
            name: doc.data()['name'] ?? 'Unknown Student',
            gender: doc.data()['gender'] ?? '',
          ),
        )
        .toList();
  }

  @override
  Future<void> allocateStudent(
    String studentId,
    String dormitoryId,
    String? bedNumber,
  ) async {
    await firestore.collection('students').doc(studentId).update({
      'dormitoryId': dormitoryId,
      'bedNumber': bedNumber,
    });

    final dormRef = firestore.collection('dormitories').doc(dormitoryId);
    await firestore.runTransaction((transaction) async {
      final dormDoc = await transaction.get(dormRef);
      final current = dormDoc.data()?['currentOccupants'] ?? 0;
      transaction.update(dormRef, {'currentOccupants': current + 1});
    });

    try {
      final dormName =
          (await dormRef.get()).data()?['name'] as String? ?? 'a dormitory';
      final parentUid = await _parentUidForStudent(studentId);
      if (parentUid != null) {
        await NotificationService().sendDirectNotification(
          userId: parentUid,
          title: 'Dorm Allocation',
          body:
              'Your child has been allocated to $dormName ${bedNumber != null ? 'at Bed $bedNumber' : ''}.',
        );
      }
    } catch (e) {
      if (kDebugMode) print('Error notifying parent of dorm allocation: $e');
    }
  }

  @override
  Future<List<BoardingStudent>> getDormitoryStudents(String dormitoryId) async {
    final snapshot = await firestore
        .collection('students')
        .where('dormitoryId', isEqualTo: dormitoryId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return BoardingStudent(
        id: doc.id,
        name: data['name'] ?? 'Unknown Student',
        gender: data['gender'] ?? '',
        dormitoryId: dormitoryId,
        bedNumber: data['bedNumber'],
        status: data['status'],
      );
    }).toList();
  }

  @override
  Future<void> submitAttendance({
    required String dormitoryId,
    required String type,
    required Map<String, String> attendance,
  }) async {
    final batch = firestore.batch();
    final today = DateTime.now().toIso8601String().split('T')[0];

    attendance.forEach((studentId, status) {
      final ref = firestore
          .collection('attendance')
          .doc('${today}_${type}_$dormitoryId')
          .collection('students')
          .doc(studentId);

      batch.set(ref, {
        'studentId': studentId,
        'dormitoryId': dormitoryId,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
        'type': type,
      });

      // Update student status if it's night roll call or similar
      if (type == 'night') {
        batch.update(firestore.collection('students').doc(studentId), {
          'status': status,
        });
      }
    });

    await batch.commit();

    final absentStudentIds = attendance.entries
        .where((e) => e.value == 'Absent')
        .map((e) => e.key);
    for (final studentId in absentStudentIds) {
      try {
        final parentUid = await _parentUidForStudent(studentId);
        if (parentUid != null) {
          await NotificationService().sendDirectNotification(
            userId: parentUid,
            title: 'Boarding Attendance Alert',
            body: 'Your child was marked absent during the $type roll call.',
          );
        }
      } catch (e) {
        if (kDebugMode) print('Error notifying parent: $e');
      }
    }
  }

  @override
  Future<List<WelfareRecord>> getWelfareRecords({
    String? schoolId,
    String? studentId,
    String? gender,
    bool publicOnly = false,
  }) async {
    Query<Map<String, dynamic>> query = firestore.collection('welfare_records');
    if (schoolId != null && schoolId.trim().isNotEmpty) {
      query = query.where('schoolId', isEqualTo: schoolId.trim());
    }
    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }
    if (gender != null) query = query.where('gender', isEqualTo: gender);
    if (publicOnly) query = query.where('isPrivate', isEqualTo: false);

    final snapshot = await query.get();
    final records = snapshot.docs.map((doc) {
      final data = doc.data();
      return WelfareRecord(
        id: doc.id,
        schoolId: data['schoolId'] ?? '',
        studentId: data['studentId'] ?? '',
        studentName: data['studentName'] ?? '',
        category: data['category'] ?? '',
        note: data['note'] ?? '',
        date: data['date'] is Timestamp
            ? (data['date'] as Timestamp).toDate()
            : DateTime.tryParse(data['date']?.toString() ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0),
        recordedBy: data['recordedBy'] ?? '',
        isPrivate: data['isPrivate'] ?? false,
      );
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  @override
  Future<void> addWelfareRecord(WelfareRecord record) async {
    if (record.schoolId.trim().isEmpty) {
      throw StateError('A school assignment is required for welfare records.');
    }
    // Need gender of student for scoping
    final studentDoc = await firestore
        .collection('students')
        .doc(record.studentId)
        .get();
    final gender = studentDoc.data()?['gender'];

    await firestore.collection('welfare_records').add({
      'schoolId': record.schoolId.trim(),
      'studentId': record.studentId,
      'studentName': record.studentName,
      'category': record.category,
      'note': record.note,
      'date': Timestamp.fromDate(record.date),
      'recordedBy': record.recordedBy,
      'isPrivate': record.isPrivate,
      'gender': gender,
    });
  }

  @override
  Future<List<DisciplineCase>> getDisciplineCases({
    String? studentId,
    String? gender,
  }) async {
    Query<Map<String, dynamic>> query = firestore.collection(
      'discipline_cases',
    );
    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }
    if (gender != null) query = query.where('gender', isEqualTo: gender);

    final snapshot = await query.orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return DisciplineCase(
        id: doc.id,
        studentId: data['studentId'] ?? '',
        studentName: data['studentName'] ?? '',
        incident: data['incident'] ?? '',
        category: data['category'] ?? '',
        actionTaken: data['actionTaken'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        status: data['status'] ?? '',
        recordedBy: data['recordedBy'] ?? '',
      );
    }).toList();
  }

  @override
  Future<void> addDisciplineCase(DisciplineCase disciplineCase) async {
    final studentDoc = await firestore
        .collection('students')
        .doc(disciplineCase.studentId)
        .get();
    final data = studentDoc.data();
    final gender = data?['gender'];
    final studentName = data?['name'] ?? disciplineCase.studentName;

    await firestore.collection('discipline_cases').add({
      'studentId': disciplineCase.studentId,
      'studentName': studentName,
      'incident': disciplineCase.incident,
      'category': disciplineCase.category,
      'actionTaken': disciplineCase.actionTaken,
      'date': Timestamp.fromDate(disciplineCase.date),
      'status': disciplineCase.status,
      'recordedBy': disciplineCase.recordedBy,
      'gender': gender,
    });

    // Write to alerts for parent visibility and push notification
    try {
      await firestore.collection('alerts').add({
        'studentId': disciplineCase.studentId,
        'title': 'Boarding Discipline: ${disciplineCase.category}',
        'message': '$studentName: ${disciplineCase.incident}',
        'severity': 'Medium',
        'timestamp': FieldValue.serverTimestamp(),
      });

      final parentUid = await _parentUidForStudent(disciplineCase.studentId);
      if (parentUid != null) {
        await NotificationService().sendDirectNotification(
          userId: parentUid,
          title: 'Boarding Discipline Record',
          body: '${disciplineCase.category}: ${disciplineCase.incident}',
        );
      }
    } catch (e) {
      if (kDebugMode) print('Error notifying parent of discipline case: $e');
    }
  }

  @override
  Future<List<HygieneCheck>> getHygieneChecks({
    String? dormitoryId,
    String? gender,
  }) async {
    Query<Map<String, dynamic>> query = firestore.collection('hygiene_checks');
    if (dormitoryId != null) {
      query = query.where('dormitoryId', isEqualTo: dormitoryId);
    }
    if (gender != null) query = query.where('gender', isEqualTo: gender);

    final snapshot = await query.orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return HygieneCheck(
        id: doc.id,
        dormitoryId: data['dormitoryId'] ?? '',
        dormitoryName: data['dormitoryName'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        score: (data['score'] ?? 0).toDouble(),
        notes: data['notes'] ?? '',
        maintenanceRequired: List<String>.from(
          data['maintenanceRequired'] ?? [],
        ),
        recordedBy: data['recordedBy'] ?? '',
      );
    }).toList();
  }

  @override
  Future<void> addHygieneCheck(HygieneCheck check) async {
    final dormDoc = await firestore
        .collection('dormitories')
        .doc(check.dormitoryId)
        .get();
    final gender = dormDoc.data()?['gender'];

    await firestore.collection('hygiene_checks').add({
      'dormitoryId': check.dormitoryId,
      'dormitoryName': check.dormitoryName,
      'date': Timestamp.fromDate(check.date),
      'score': check.score,
      'notes': check.notes,
      'maintenanceRequired': check.maintenanceRequired,
      'recordedBy': check.recordedBy,
      'gender': gender,
    });
  }

  @override
  Future<List<BoardingStudent>> getStudentsOnLeave({String? gender}) async {
    Query<Map<String, dynamic>> query = firestore
        .collection('students')
        .where('isBoarder', isEqualTo: true)
        .where('status', isEqualTo: 'Leave');
    if (gender != null) query = query.where('gender', isEqualTo: gender);
    final snapshot = await query.get();

    return snapshot.docs
        .map(
          (doc) => BoardingStudent(
            id: doc.id,
            name: doc.data()['name'] ?? 'Unknown Student',
            gender: doc.data()['gender'] ?? '',
            dormitoryId: doc.data()['dormitoryId'],
            bedNumber: doc.data()['bedNumber'],
            status: 'Leave',
          ),
        )
        .toList();
  }

  Future<String?> _parentUidForStudent(String studentId) async {
    final snap = await firestore
        .collection('parent_access_codes')
        .where('studentIds', arrayContains: studentId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return 'parent_${snap.docs.first.id}';
  }
}
