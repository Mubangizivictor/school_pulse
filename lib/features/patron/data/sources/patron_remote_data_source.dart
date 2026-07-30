import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';

abstract class PatronRemoteDataSource {
  Stream<List<Dormitory>> getDormitories();
  Future<void> addDormitory(Dormitory dormitory);
  Future<void> updateDormitory(Dormitory dormitory);
  Future<void> deleteDormitory(String id);

  Stream<List<BoardingStudent>> getBoardingStudents(String? dormitoryId);
  Future<void> allocateStudentToDorm(
    String studentId,
    String dormitoryId,
    String? bedNumber,
  );
  Future<void> updateStudentBed(String studentId, String? bedNumber);
  Future<void> setRoomLeader(String dormitoryId, String? studentId);

  Stream<List<BoardingAttendance>> getAttendance(
    DateTime date,
    String? dormitoryId,
    String? type,
  );
  Future<void> recordAttendance(BoardingAttendance attendance);
  Future<void> bulkRecordAttendance(List<BoardingAttendance> records);

  Stream<List<WelfareRecord>> getWelfareRecords(
    String schoolId,
    String studentId, {
    bool publicOnly = false,
  });
  Stream<List<WelfareRecord>> getAllWelfareRecords(
    String schoolId, {
    bool publicOnly = false,
  });
  Future<void> logWelfareRecord(WelfareRecord record);

  Stream<List<DisciplineIncident>> getDisciplineIncidents(String? studentId);
  Future<void> logDisciplineIncident(DisciplineIncident incident);
  Future<void> updateDisciplineStatus(
    String incidentId,
    String status,
    String actionTaken,
  );

  Stream<List<BoardingAnnouncement>> getAnnouncements();
  Future<void> postAnnouncement(BoardingAnnouncement announcement);
}

class PatronRemoteDataSourceImpl implements PatronRemoteDataSource {
  final FirebaseFirestore firestore;

  PatronRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<Dormitory>> getDormitories() {
    return firestore.collection('dormitories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Dormitory(
          id: doc.id,
          name: data['name'] ?? '',
          capacity: data['capacity'] ?? 0,
          occupantCount: data['occupantCount'] ?? 0,
          roomLeaderId: data['roomLeaderId'],
          roomLeaderName: data['roomLeaderName'],
        );
      }).toList();
    });
  }

  @override
  Future<void> addDormitory(Dormitory dormitory) {
    return firestore.collection('dormitories').doc(dormitory.id).set({
      'name': dormitory.name,
      'capacity': dormitory.capacity,
      'occupantCount': dormitory.occupantCount,
      'roomLeaderId': dormitory.roomLeaderId,
      'roomLeaderName': dormitory.roomLeaderName,
    });
  }

  @override
  Future<void> updateDormitory(Dormitory dormitory) {
    return firestore.collection('dormitories').doc(dormitory.id).update({
      'name': dormitory.name,
      'capacity': dormitory.capacity,
      'occupantCount': dormitory.occupantCount,
      'roomLeaderId': dormitory.roomLeaderId,
      'roomLeaderName': dormitory.roomLeaderName,
    });
  }

  @override
  Future<void> deleteDormitory(String id) {
    return firestore.collection('dormitories').doc(id).delete();
  }

  @override
  Stream<List<BoardingStudent>> getBoardingStudents(String? dormitoryId) {
    Query query = firestore
        .collection('students')
        .where('isBoarder', isEqualTo: true);
    if (dormitoryId != null) {
      query = query.where('dormitoryId', isEqualTo: dormitoryId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return BoardingStudent(
          id: doc.id,
          name: data['fullName'] ?? data['name'] ?? '',
          dormitoryId: data['dormitoryId'],
          dormitoryName: data['dormitoryName'],
          bedNumber: data['bedNumber'],
          status: data['boardingStatus'] ?? 'Present',
          photoUrl: data['photoUrl'],
          studentClass: data['class'] ?? '',
        );
      }).toList();
    });
  }

  @override
  Future<void> allocateStudentToDorm(
    String studentId,
    String dormitoryId,
    String? bedNumber,
  ) async {
    final dormDoc = await firestore
        .collection('dormitories')
        .doc(dormitoryId)
        .get();
    final dormName = dormDoc.data()?['name'] ?? '';

    return firestore.collection('students').doc(studentId).update({
      'dormitoryId': dormitoryId,
      'dormitoryName': dormName,
      'bedNumber': bedNumber,
    });
  }

  @override
  Future<void> updateStudentBed(String studentId, String? bedNumber) {
    return firestore.collection('students').doc(studentId).update({
      'bedNumber': bedNumber,
    });
  }

  @override
  Future<void> setRoomLeader(String dormitoryId, String? studentId) async {
    String? studentName;
    if (studentId != null) {
      final studentDoc = await firestore
          .collection('students')
          .doc(studentId)
          .get();
      studentName =
          studentDoc.data()?['fullName'] ?? studentDoc.data()?['name'];
    }

    return firestore.collection('dormitories').doc(dormitoryId).update({
      'roomLeaderId': studentId,
      'roomLeaderName': studentName,
    });
  }

  @override
  Stream<List<BoardingAttendance>> getAttendance(
    DateTime date,
    String? dormitoryId,
    String? type,
  ) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    Query query = firestore
        .collection('boarding_attendance')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay);

    if (dormitoryId != null) {
      query = query.where('dormitoryId', isEqualTo: dormitoryId);
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return BoardingAttendance(
          id: doc.id,
          studentId: data['studentId'],
          studentName: data['studentName'],
          dormitoryId: data['dormitoryId'],
          date: (data['date'] as Timestamp).toDate(),
          type: data['type'],
          status: data['status'],
          remarks: data['remarks'],
          recordedBy: data['recordedBy'],
        );
      }).toList();
    });
  }

  @override
  Future<void> recordAttendance(BoardingAttendance attendance) {
    return firestore.collection('boarding_attendance').add({
      'studentId': attendance.studentId,
      'studentName': attendance.studentName,
      'dormitoryId': attendance.dormitoryId,
      'date': Timestamp.fromDate(attendance.date),
      'type': attendance.type,
      'status': attendance.status,
      'remarks': attendance.remarks,
      'recordedBy': attendance.recordedBy,
    });
  }

  @override
  Future<void> bulkRecordAttendance(List<BoardingAttendance> records) async {
    final batch = firestore.batch();
    for (var record in records) {
      final docRef = firestore.collection('boarding_attendance').doc();
      batch.set(docRef, {
        'studentId': record.studentId,
        'studentName': record.studentName,
        'dormitoryId': record.dormitoryId,
        'date': Timestamp.fromDate(record.date),
        'type': record.type,
        'status': record.status,
        'remarks': record.remarks,
        'recordedBy': record.recordedBy,
      });
    }
    return batch.commit();
  }

  @override
  Stream<List<WelfareRecord>> getWelfareRecords(
    String schoolId,
    String studentId, {
    bool publicOnly = false,
  }) {
    Query<Map<String, dynamic>> query = firestore
        .collection('welfare_records')
        .where('schoolId', isEqualTo: schoolId)
        .where('studentId', isEqualTo: studentId);
    if (publicOnly) query = query.where('isPrivate', isEqualTo: false);
    return query.snapshots().map((snapshot) {
      final records = snapshot.docs.map((doc) {
        final data = doc.data();
        return WelfareRecord(
          id: doc.id,
          schoolId: data['schoolId'] ?? '',
          studentId: data['studentId'],
          studentName: data['studentName'],
          category: data['category'],
          note: data['note'],
          date: (data['date'] as Timestamp).toDate(),
          recordedBy: data['recordedBy'],
          isPrivate: data['isPrivate'] ?? false,
        );
      }).toList()..sort((a, b) => b.date.compareTo(a.date));
      return records;
    });
  }

  @override
  Stream<List<WelfareRecord>> getAllWelfareRecords(
    String schoolId, {
    bool publicOnly = false,
  }) {
    Query<Map<String, dynamic>> query = firestore
        .collection('welfare_records')
        .where('schoolId', isEqualTo: schoolId);
    if (publicOnly) query = query.where('isPrivate', isEqualTo: false);
    return query.snapshots().map((snapshot) {
      final records = snapshot.docs.map((doc) {
        final data = doc.data();
        return WelfareRecord(
          id: doc.id,
          schoolId: data['schoolId'] ?? '',
          studentId: data['studentId'],
          studentName: data['studentName'],
          category: data['category'],
          note: data['note'],
          date: (data['date'] as Timestamp).toDate(),
          recordedBy: data['recordedBy'],
          isPrivate: data['isPrivate'] ?? false,
        );
      }).toList()..sort((a, b) => b.date.compareTo(a.date));
      return records;
    });
  }

  @override
  Future<void> logWelfareRecord(WelfareRecord record) async {
    if (record.schoolId.trim().isEmpty) {
      throw StateError('A school assignment is required for welfare records.');
    }
    final studentDoc = await firestore
        .collection('students')
        .doc(record.studentId)
        .get();
    final recordRef = firestore.collection('welfare_records').doc();
    final batch = firestore.batch();
    batch.set(recordRef, {
      'schoolId': record.schoolId.trim(),
      'studentId': record.studentId,
      'studentName': record.studentName,
      'category': record.category,
      'note': record.note,
      'date': Timestamp.fromDate(record.date),
      'recordedBy': record.recordedBy,
      'isPrivate': record.isPrivate,
      'gender': studentDoc.data()?['gender'],
    });

    if (!record.isPrivate) {
      final codes = await firestore
          .collection('parent_access_codes')
          .where('schoolId', isEqualTo: record.schoolId.trim())
          .get();
      for (final code in codes.docs) {
        final studentIds = List<String>.from(
          code.data()['studentIds'] as List? ?? const [],
        );
        if (!studentIds.contains(record.studentId)) continue;
        final parentCode = code.data()['parentCode'] ?? code.data()['code'];
        if (parentCode is! String || parentCode.isEmpty) continue;
        final alert = firestore.collection('alerts').doc();
        batch.set(alert, {
          'userId': 'parent_$parentCode',
          'schoolId': record.schoolId.trim(),
          'studentId': record.studentId,
          'title': 'New welfare record: ${record.studentName}',
          'body': 'A new ${record.category} has been logged for your child.',
          'type': 'boarding_welfare',
          'recordId': recordRef.id,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    }
    await batch.commit();
  }

  @override
  Stream<List<DisciplineIncident>> getDisciplineIncidents(String? studentId) {
    Query query = firestore
        .collection('boarding_discipline')
        .orderBy('date', descending: true);
    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DisciplineIncident(
          id: doc.id,
          studentId: data['studentId'],
          studentName: data['studentName'],
          description: data['description'],
          category: data['category'],
          actionTaken: data['actionTaken'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          status: data['status'],
          recordedBy: data['recordedBy'],
        );
      }).toList();
    });
  }

  @override
  Future<void> logDisciplineIncident(DisciplineIncident incident) async {
    await firestore.collection('boarding_discipline').add({
      'studentId': incident.studentId,
      'studentName': incident.studentName,
      'description': incident.description,
      'category': incident.category,
      'actionTaken': incident.actionTaken,
      'date': Timestamp.fromDate(incident.date),
      'status': incident.status,
      'recordedBy': incident.recordedBy,
    });

    // Notify parent
    final studentDoc = await firestore
        .collection('students')
        .doc(incident.studentId)
        .get();
    final parentId = studentDoc.data()?['parentId'];
    if (parentId != null) {
      await firestore.collection('notification_queue').add({
        'userId': parentId,
        'notification': {
          'title': 'Boarding Incident: ${incident.studentName}',
          'body':
              'A new discipline incident (${incident.category}) has been logged.',
        },
        'data': {
          'type': 'boarding_discipline',
          'studentId': incident.studentId,
        },
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> updateDisciplineStatus(
    String incidentId,
    String status,
    String actionTaken,
  ) {
    return firestore.collection('boarding_discipline').doc(incidentId).update({
      'status': status,
      'actionTaken': actionTaken,
    });
  }

  @override
  Stream<List<BoardingAnnouncement>> getAnnouncements() {
    return firestore
        .collection('boarding_announcements')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return BoardingAnnouncement(
              id: doc.id,
              title: data['title'],
              content: data['content'],
              date: (data['date'] as Timestamp).toDate(),
              authorName: data['authorName'],
              targetDormitoryId: data['targetDormitoryId'],
            );
          }).toList();
        });
  }

  @override
  Future<void> postAnnouncement(BoardingAnnouncement announcement) {
    return firestore.collection('boarding_announcements').add({
      'title': announcement.title,
      'content': announcement.content,
      'date': Timestamp.fromDate(announcement.date),
      'authorName': announcement.authorName,
      'targetDormitoryId': announcement.targetDormitoryId,
    });
  }
}
