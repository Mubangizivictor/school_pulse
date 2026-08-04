import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:school_pulse/core/notification/notification_service.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/matron/domain/entities/matron_entities.dart';
import 'package:school_pulse/features/matron/domain/repositories/matron_repository.dart';
import 'package:school_pulse/features/matron/domain/entities/boarding_entities.dart'
    as legacy;

/// Girls' boarding is always scoped to this gender so Matron never reads or
/// writes a boys' (Patron) dormitory/student record, even though both
/// share the same top-level `dormitories`/`students` collections.
const String _kGender = 'Female';

abstract class MatronRemoteDataSource {
  Stream<MatronDashboardOverview> watchDashboardOverview(String schoolId);

  Stream<List<Dormitory>> getDormitories();
  Future<void> addDormitory(Dormitory dormitory);
  Future<void> updateDormitory(Dormitory dormitory);
  Future<void> deleteDormitory(String id);
  Future<void> setDormLeadership(
    String dormitoryId, {
    String? roomLeaderId,
    String? dormPrefectId,
  });

  Stream<List<Bed>> getBeds(String dormitoryId);
  Future<void> addBed(String dormitoryId, String bedNumber);
  Future<void> removeBed(String dormitoryId, String bedId);
  Future<void> transferStudent({
    required String studentId,
    required String toDormitoryId,
    String? toBedNumber,
    required String transferredBy,
    String? reason,
  });
  Stream<List<BedTransfer>> getTransferHistory(String? studentId);

  Stream<List<BoardingStudent>> getBoardingStudents(String? dormitoryId);
  Stream<List<BoardingStudent>> getUnallocatedStudents();
  Future<void> allocateStudentToDorm(
    String studentId,
    String dormitoryId,
    String? bedNumber,
  );
  Future<void> updateStudentBed(String studentId, String? bedNumber);
  Future<void> setRoomLeader(String dormitoryId, String? studentId);

  Stream<List<BoardingAttendance>> getAttendance(
    String schoolId,
    DateTime date,
    String? dormitoryId,
    String? type,
  );
  Future<void> recordAttendance(BoardingAttendance attendance);
  Future<void> bulkRecordAttendance(List<BoardingAttendance> records);

  Stream<List<LeaveRequest>> getLeaveRequests({String? status});
  Future<void> requestLeave(LeaveRequest request);
  Future<void> updateLeaveStatus(
    String requestId,
    String status, {
    String? approvedBy,
    DateTime? actualReturnDate,
    String? notes,
  });

  Stream<List<WelfareRecord>> watchWelfareRecords(
    String schoolId,
    String studentId, {
    bool publicOnly = false,
  });
  Stream<List<WelfareRecord>> watchAllWelfareRecords(
    String schoolId, {
    bool publicOnly = false,
  });
  Future<void> logWelfareRecord(WelfareRecord record);

  Stream<List<CounselingReferral>> getCounselingReferrals(String? studentId);
  Future<void> logCounselingReferral(CounselingReferral referral);
  Future<void> updateReferralStatus(
    String referralId,
    String status, {
    String? followUpNotes,
  });

  Stream<List<BehaviourObservation>> getBehaviourObservations(
    String? studentId,
  );
  Future<void> logBehaviourObservation(BehaviourObservation observation);

  Stream<List<DisciplineIncident>> getDisciplineIncidents(String? studentId);
  Future<void> logDisciplineIncident(DisciplineIncident incident);
  Future<void> updateDisciplineStatus(
    String incidentId,
    String status,
    String actionTaken,
  );

  Stream<List<BoardingAnnouncement>> getAnnouncements();
  Future<void> postAnnouncement(BoardingAnnouncement announcement);

  /// Legacy compat surface - consumed directly by
  /// features/student/data/repositories/student_repository_impl.dart (which
  /// must not be modified), and transitively by the Discipline/Health/Parent
  /// modules. Ungendered by design: welfare_records/boarding_discipline are
  /// shared with Patron, so this naturally returns both boys' and girls'
  /// records for those cross-module consumers.
  Future<List<legacy.WelfareRecord>> getWelfareRecords({
    String? schoolId,
    String? studentId,
    bool publicOnly = false,
  });
  Future<List<legacy.DisciplineCase>> getDisciplineCases({
    String? studentId,
  });
}

class MatronRemoteDataSourceImpl implements MatronRemoteDataSource {
  final FirebaseFirestore firestore;
  final AuditRepository auditRepository;

  MatronRemoteDataSourceImpl({
    required this.firestore,
    required this.auditRepository,
  });

  Future<String?> _parentUidForStudent(String studentId) async {
    final snap = await firestore
        .collection('parent_access_codes')
        .where('studentIds', arrayContains: studentId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return 'parent_${snap.docs.first.id}';
  }

  Future<void> _notifyParent(String studentId, String title, String body) async {
    final parentUid = await _parentUidForStudent(studentId);
    if (parentUid == null) return;
    final studentDoc = await firestore.collection('students').doc(studentId).get();
    final schoolId = studentDoc.data()?['schoolId'] as String? ?? '';
    await NotificationService().sendStudentAlert(
      schoolId: schoolId,
      studentId: studentId,
      parentIds: [parentUid],
      title: title,
      body: body,
    );
  }

  // ---------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------

  @override
  Stream<MatronDashboardOverview> watchDashboardOverview(String schoolId) {
    final studentsStream = firestore
        .collection('students')
        .where('isBoarder', isEqualTo: true)
        .where('gender', isEqualTo: _kGender)
        .where('schoolId', isEqualTo: schoolId)
        .snapshots();
    final dormsStream = firestore
        .collection('dormitories')
        .where('gender', isEqualTo: _kGender)
        .snapshots();
    final leaveStream = firestore
        .collection('boarding_leave_requests')
        .where('schoolId', isEqualTo: schoolId)
        .snapshots();
    final disciplineStream = firestore
        .collection('boarding_discipline')
        .where('schoolId', isEqualTo: schoolId)
        .where('status', whereIn: ['Pending', 'Follow-up'])
        .snapshots();
    final welfareStream = firestore
        .collection('welfare_records')
        .where('schoolId', isEqualTo: schoolId)
        .where('gender', isEqualTo: _kGender)
        .where('category', isEqualTo: 'Concern')
        .snapshots();

    return Rx.combineLatest5(
      studentsStream,
      dormsStream,
      leaveStream,
      disciplineStream,
      welfareStream,
      (
        QuerySnapshot<Map<String, dynamic>> students,
        QuerySnapshot<Map<String, dynamic>> dorms,
        QuerySnapshot<Map<String, dynamic>> leave,
        QuerySnapshot<Map<String, dynamic>> discipline,
        QuerySnapshot<Map<String, dynamic>> welfare,
      ) {
        int present = 0;
        int absent = 0;
        int onLeave = 0;
        int inClinic = 0;
        int missing = 0;
        for (final doc in students.docs) {
          final status = doc.data()['boardingStatus'] ?? 'Present';
          switch (status) {
            case 'Present':
              present++;
              break;
            case 'Absent':
              absent++;
              break;
            case 'Leave':
              onLeave++;
              break;
            case 'Sick':
              inClinic++;
              break;
            case 'Missing':
              missing++;
              break;
          }
        }

        int totalBeds = 0;
        int occupiedBeds = 0;
        for (final doc in dorms.docs) {
          totalBeds += (doc.data()['capacity'] as num?)?.toInt() ?? 0;
          occupiedBeds += (doc.data()['currentOccupants'] as num?)?.toInt() ?? 0;
        }

        final now = DateTime.now();
        int overdueLeave = 0;
        int pendingLeave = 0;
        for (final doc in leave.docs) {
          final data = doc.data();
          if (data['status'] == 'Pending') pendingLeave++;
          if (data['status'] == 'Out') {
            final expected = (data['expectedReturnDate'] as Timestamp?)?.toDate();
            if (expected != null && now.isAfter(expected)) overdueLeave++;
          }
        }

        return MatronDashboardOverview(
          totalStudents: students.docs.length,
          studentsPresent: present,
          studentsAbsent: absent,
          studentsOnLeave: onLeave,
          studentsInClinic: inClinic,
          missingStudentCount: missing,
          totalBeds: totalBeds,
          occupiedBeds: occupiedBeds,
          pendingLeaveRequests: pendingLeave,
          overdueLeaveCount: overdueLeave,
          openDisciplineCases: discipline.docs.length,
          pendingWelfareConcerns: welfare.docs.length,
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // Dormitory Management
  // ---------------------------------------------------------------------

  @override
  Stream<List<Dormitory>> getDormitories() {
    return firestore
        .collection('dormitories')
        .where('gender', isEqualTo: _kGender)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Dormitory(
              id: doc.id,
              name: data['name'] ?? '',
              gender: data['gender'] ?? _kGender,
              capacity: data['capacity'] ?? 0,
              occupantCount: data['currentOccupants'] ?? 0,
              roomLeaderId: data['roomLeaderId'],
              roomLeaderName: data['roomLeaderName'],
              dormPrefectId: data['dormPrefectId'],
              dormPrefectName: data['dormPrefectName'],
              location: data['location'],
            );
          }).toList();
        });
  }

  @override
  Future<void> addDormitory(Dormitory dormitory) async {
    await firestore.collection('dormitories').doc(dormitory.id).set({
      'name': dormitory.name,
      'gender': _kGender,
      'capacity': dormitory.capacity,
      'currentOccupants': dormitory.occupantCount,
      'roomLeaderId': dormitory.roomLeaderId,
      'roomLeaderName': dormitory.roomLeaderName,
      'dormPrefectId': dormitory.dormPrefectId,
      'dormPrefectName': dormitory.dormPrefectName,
      'location': dormitory.location,
    });
    await auditRepository.logAction(
      schoolId: '',
      title: 'Dormitory created',
      description: '${dormitory.name} was added (capacity ${dormitory.capacity}).',
      iconName: 'hotel',
      colorHex: '#2196F3',
    );
  }

  @override
  Future<void> updateDormitory(Dormitory dormitory) async {
    await firestore.collection('dormitories').doc(dormitory.id).update({
      'name': dormitory.name,
      'capacity': dormitory.capacity,
      'roomLeaderId': dormitory.roomLeaderId,
      'roomLeaderName': dormitory.roomLeaderName,
      'dormPrefectId': dormitory.dormPrefectId,
      'dormPrefectName': dormitory.dormPrefectName,
      'location': dormitory.location,
    });
    await auditRepository.logAction(
      schoolId: '',
      title: 'Dormitory updated',
      description: '${dormitory.name} details were changed.',
      iconName: 'hotel',
      colorHex: '#2196F3',
    );
  }

  @override
  Future<void> deleteDormitory(String id) async {
    await firestore.collection('dormitories').doc(id).delete();
    await auditRepository.logAction(
      schoolId: '',
      title: 'Dormitory deleted',
      description: 'Dormitory $id was removed.',
      iconName: 'hotel',
      colorHex: '#F44336',
    );
  }

  @override
  Future<void> setDormLeadership(
    String dormitoryId, {
    String? roomLeaderId,
    String? dormPrefectId,
  }) async {
    final dormDoc = await firestore.collection('dormitories').doc(dormitoryId).get();
    final dormName = dormDoc.data()?['name'] ?? '';
    final previousRoomLeaderId = dormDoc.data()?['roomLeaderId'] as String?;
    final previousDormPrefectId = dormDoc.data()?['dormPrefectId'] as String?;

    final update = <String, dynamic>{};
    final batch = firestore.batch();

    if (roomLeaderId != null && roomLeaderId != previousRoomLeaderId) {
      final doc = await firestore.collection('students').doc(roomLeaderId).get();
      update['roomLeaderId'] = roomLeaderId;
      update['roomLeaderName'] = doc.data()?['fullName'] ?? doc.data()?['name'];
      if (previousRoomLeaderId != null) {
        batch.update(firestore.collection('students').doc(previousRoomLeaderId), {
          'dormLeadershipRole': null,
          'dormLeadershipDormId': null,
          'dormLeadershipDormName': null,
        });
      }
      batch.update(firestore.collection('students').doc(roomLeaderId), {
        'dormLeadershipRole': 'Room Leader',
        'dormLeadershipDormId': dormitoryId,
        'dormLeadershipDormName': dormName,
      });
    }
    if (dormPrefectId != null && dormPrefectId != previousDormPrefectId) {
      final doc = await firestore.collection('students').doc(dormPrefectId).get();
      update['dormPrefectId'] = dormPrefectId;
      update['dormPrefectName'] = doc.data()?['fullName'] ?? doc.data()?['name'];
      if (previousDormPrefectId != null) {
        batch.update(firestore.collection('students').doc(previousDormPrefectId), {
          'dormLeadershipRole': null,
          'dormLeadershipDormId': null,
          'dormLeadershipDormName': null,
        });
      }
      batch.update(firestore.collection('students').doc(dormPrefectId), {
        'dormLeadershipRole': 'Dorm Prefect',
        'dormLeadershipDormId': dormitoryId,
        'dormLeadershipDormName': dormName,
      });
    }
    if (update.isEmpty) return;
    batch.update(firestore.collection('dormitories').doc(dormitoryId), update);
    await batch.commit();
    await auditRepository.logAction(
      schoolId: '',
      title: 'Dorm leadership updated',
      description: 'Leadership roles updated for dormitory $dormitoryId.',
      iconName: 'star',
      colorHex: '#FFC107',
    );
  }

  // ---------------------------------------------------------------------
  // Bed Management
  // ---------------------------------------------------------------------

  @override
  Stream<List<Bed>> getBeds(String dormitoryId) {
    return firestore
        .collection('dormitories')
        .doc(dormitoryId)
        .collection('beds')
        .orderBy('bedNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Bed(
                id: doc.id,
                dormitoryId: dormitoryId,
                bedNumber: data['bedNumber'] ?? '',
                occupied: data['occupied'] ?? false,
                studentId: data['studentId'],
                studentName: data['studentName'],
              );
            }).toList());
  }

  @override
  Future<void> addBed(String dormitoryId, String bedNumber) async {
    await firestore
        .collection('dormitories')
        .doc(dormitoryId)
        .collection('beds')
        .add({'bedNumber': bedNumber, 'occupied': false});
  }

  @override
  Future<void> removeBed(String dormitoryId, String bedId) async {
    await firestore
        .collection('dormitories')
        .doc(dormitoryId)
        .collection('beds')
        .doc(bedId)
        .delete();
  }

  @override
  Future<void> transferStudent({
    required String studentId,
    required String toDormitoryId,
    String? toBedNumber,
    required String transferredBy,
    String? reason,
  }) async {
    final studentDoc = await firestore.collection('students').doc(studentId).get();
    final studentData = studentDoc.data() ?? {};
    final studentName = studentData['fullName'] ?? studentData['name'] ?? 'Unknown';
    final fromDormitoryId = studentData['dormitoryId'] as String?;
    final fromDormitoryName = studentData['dormitoryName'] as String?;
    final fromBedNumber = studentData['bedNumber'] as String?;

    final toDormDoc = await firestore.collection('dormitories').doc(toDormitoryId).get();
    final toDormName = toDormDoc.data()?['name'] ?? '';

    final batch = firestore.batch();
    batch.update(firestore.collection('students').doc(studentId), {
      'dormitoryId': toDormitoryId,
      'dormitoryName': toDormName,
      'bedNumber': toBedNumber,
    });

    if (fromDormitoryId != null && fromDormitoryId != toDormitoryId) {
      final fromDormRef = firestore.collection('dormitories').doc(fromDormitoryId);
      batch.update(fromDormRef, {'currentOccupants': FieldValue.increment(-1)});
      final toDormRef = firestore.collection('dormitories').doc(toDormitoryId);
      batch.update(toDormRef, {'currentOccupants': FieldValue.increment(1)});
    }

    final transferRef = firestore.collection('bed_transfers').doc();
    batch.set(transferRef, {
      'studentId': studentId,
      'studentName': studentName,
      'fromDormitoryId': fromDormitoryId,
      'fromDormitoryName': fromDormitoryName,
      'fromBedNumber': fromBedNumber,
      'toDormitoryId': toDormitoryId,
      'toDormitoryName': toDormName,
      'toBedNumber': toBedNumber,
      'date': Timestamp.fromDate(DateTime.now()),
      'transferredBy': transferredBy,
      'reason': reason,
      'gender': _kGender,
    });

    await batch.commit();
    await auditRepository.logAction(
      schoolId: studentDoc.data()?['schoolId'] as String? ?? '',
      title: 'Student transferred',
      description: '$studentName moved to $toDormName${toBedNumber != null ? ' (Bed $toBedNumber)' : ''}.',
      iconName: 'swap_horiz',
      colorHex: '#9C27B0',
      userId: transferredBy,
    );
    await _notifyParent(
      studentId,
      'Dormitory Transfer',
      '$studentName has been transferred to $toDormName.',
    );
  }

  @override
  Stream<List<BedTransfer>> getTransferHistory(String? studentId) {
    Query<Map<String, dynamic>> query = firestore
        .collection('bed_transfers')
        .where('gender', isEqualTo: _kGender);
    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }
    return query.snapshots().map((snapshot) {
      final transfers = snapshot.docs.map((doc) {
        final data = doc.data();
        return BedTransfer(
          id: doc.id,
          studentId: data['studentId'] ?? '',
          studentName: data['studentName'] ?? '',
          fromDormitoryId: data['fromDormitoryId'],
          fromDormitoryName: data['fromDormitoryName'],
          fromBedNumber: data['fromBedNumber'],
          toDormitoryId: data['toDormitoryId'] ?? '',
          toDormitoryName: data['toDormitoryName'] ?? '',
          toBedNumber: data['toBedNumber'],
          date: (data['date'] as Timestamp).toDate(),
          transferredBy: data['transferredBy'] ?? '',
          reason: data['reason'],
        );
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return transfers;
    });
  }

  // ---------------------------------------------------------------------
  // Student Allocation
  // ---------------------------------------------------------------------

  @override
  Stream<List<BoardingStudent>> getBoardingStudents(String? dormitoryId) {
    Query<Map<String, dynamic>> query = firestore
        .collection('students')
        .where('isBoarder', isEqualTo: true)
        .where('gender', isEqualTo: _kGender);
    if (dormitoryId != null) {
      query = query.where('dormitoryId', isEqualTo: dormitoryId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BoardingStudent(
          id: doc.id,
          name: data['fullName'] ?? data['name'] ?? '',
          dormitoryId: data['dormitoryId'],
          dormitoryName: data['dormitoryName'],
          bedNumber: data['bedNumber'],
          status: data['boardingStatus'] ?? 'Present',
          photoUrl: data['photoUrl'],
          studentClass: data['class'] ?? '',
          gender: data['gender'] ?? _kGender,
        );
      }).toList();
    });
  }

  @override
  Stream<List<BoardingStudent>> getUnallocatedStudents() {
    return firestore
        .collection('students')
        .where('isBoarder', isEqualTo: true)
        .where('gender', isEqualTo: _kGender)
        .where('dormitoryId', isNull: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return BoardingStudent(
                id: doc.id,
                name: data['fullName'] ?? data['name'] ?? '',
                studentClass: data['class'] ?? '',
                gender: data['gender'] ?? _kGender,
              );
            }).toList());
  }

  @override
  Future<void> allocateStudentToDorm(
    String studentId,
    String dormitoryId,
    String? bedNumber,
  ) async {
    final dormDoc = await firestore.collection('dormitories').doc(dormitoryId).get();
    final dormName = dormDoc.data()?['name'] ?? '';
    final studentDoc = await firestore.collection('students').doc(studentId).get();
    final studentName = studentDoc.data()?['fullName'] ?? studentDoc.data()?['name'] ?? '';
    final alreadyAllocated = studentDoc.data()?['dormitoryId'] != null;

    final batch = firestore.batch();
    batch.update(firestore.collection('students').doc(studentId), {
      'dormitoryId': dormitoryId,
      'dormitoryName': dormName,
      'bedNumber': bedNumber,
      'boardingStatus': studentDoc.data()?['boardingStatus'] ?? 'Present',
    });
    if (!alreadyAllocated) {
      batch.update(firestore.collection('dormitories').doc(dormitoryId), {
        'currentOccupants': FieldValue.increment(1),
      });
    }
    await batch.commit();

    await auditRepository.logAction(
      schoolId: studentDoc.data()?['schoolId'] as String? ?? '',
      title: 'Student allocated',
      description: '$studentName allocated to $dormName${bedNumber != null ? ' (Bed $bedNumber)' : ''}.',
      iconName: 'person_add',
      colorHex: '#4CAF50',
    );
    await _notifyParent(
      studentId,
      'Dorm Allocation',
      'Your child has been allocated to $dormName${bedNumber != null ? ' at Bed $bedNumber' : ''}.',
    );
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
      final studentDoc = await firestore.collection('students').doc(studentId).get();
      studentName = studentDoc.data()?['fullName'] ?? studentDoc.data()?['name'];
    }

    return firestore.collection('dormitories').doc(dormitoryId).update({
      'roomLeaderId': studentId,
      'roomLeaderName': studentName,
    });
  }

  // ---------------------------------------------------------------------
  // Attendance
  // ---------------------------------------------------------------------

  @override
  Stream<List<BoardingAttendance>> getAttendance(
    String schoolId,
    DateTime date,
    String? dormitoryId,
    String? type,
  ) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    Query<Map<String, dynamic>> query = firestore
        .collection('boarding_attendance')
        .where('schoolId', isEqualTo: schoolId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay));

    if (dormitoryId != null) {
      query = query.where('dormitoryId', isEqualTo: dormitoryId);
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BoardingAttendance(
          id: doc.id,
          schoolId: data['schoolId'] ?? schoolId,
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

  Future<void> _writeAttendanceRecord(
    DocumentReference<Map<String, dynamic>> ref,
    BoardingAttendance attendance,
  ) async {
    await ref.set({
      'schoolId': attendance.schoolId,
      'studentId': attendance.studentId,
      'studentName': attendance.studentName,
      'dormitoryId': attendance.dormitoryId,
      'date': Timestamp.fromDate(attendance.date),
      'type': attendance.type,
      'status': attendance.status,
      'remarks': attendance.remarks,
      'recordedBy': attendance.recordedBy,
      'gender': _kGender,
    });
    await firestore.collection('students').doc(attendance.studentId).update({
      'boardingStatus': attendance.status == 'Absent' ? 'Missing' : attendance.status,
    });
  }

  @override
  Future<void> recordAttendance(BoardingAttendance attendance) async {
    await _writeAttendanceRecord(
      firestore.collection('boarding_attendance').doc(),
      attendance,
    );
    if (attendance.status == 'Absent') {
      await _notifyParent(
        attendance.studentId,
        'Boarding Attendance Alert',
        '${attendance.studentName} was marked absent during the ${attendance.type} roll call.',
      );
    }
  }

  @override
  Future<void> bulkRecordAttendance(List<BoardingAttendance> records) async {
    final batch = firestore.batch();
    for (var record in records) {
      final docRef = firestore.collection('boarding_attendance').doc();
      batch.set(docRef, {
        'schoolId': record.schoolId,
        'studentId': record.studentId,
        'studentName': record.studentName,
        'dormitoryId': record.dormitoryId,
        'date': Timestamp.fromDate(record.date),
        'type': record.type,
        'status': record.status,
        'remarks': record.remarks,
        'recordedBy': record.recordedBy,
        'gender': _kGender,
      });
      batch.update(firestore.collection('students').doc(record.studentId), {
        'boardingStatus': record.status == 'Absent' ? 'Missing' : record.status,
      });
    }
    await batch.commit();

    await auditRepository.logAction(
      schoolId: '',
      title: 'Roll call submitted',
      description: '${records.length} ${records.isNotEmpty ? records.first.type : ''} attendance records saved.',
      iconName: 'how_to_reg',
      colorHex: '#4CAF50',
      userId: records.isNotEmpty ? records.first.recordedBy : null,
    );

    final absentees = records.where((r) => r.status == 'Absent');
    for (final record in absentees) {
      await _notifyParent(
        record.studentId,
        'Boarding Attendance Alert',
        '${record.studentName} was marked absent during the ${record.type} roll call.',
      );
    }
  }

  // ---------------------------------------------------------------------
  // Leave Management
  // ---------------------------------------------------------------------

  @override
  Stream<List<LeaveRequest>> getLeaveRequests({String? status}) {
    Query<Map<String, dynamic>> query = firestore
        .collection('boarding_leave_requests')
        .where('gender', isEqualTo: _kGender);
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query.snapshots().map((snapshot) {
      final requests = snapshot.docs.map((doc) {
        final data = doc.data();
        return LeaveRequest(
          id: doc.id,
          studentId: data['studentId'] ?? '',
          studentName: data['studentName'] ?? '',
          dormitoryId: data['dormitoryId'] ?? '',
          reason: data['reason'] ?? '',
          destination: data['destination'],
          requestedBy: data['requestedBy'] ?? '',
          departureDate: (data['departureDate'] as Timestamp).toDate(),
          expectedReturnDate: (data['expectedReturnDate'] as Timestamp).toDate(),
          actualReturnDate: (data['actualReturnDate'] as Timestamp?)?.toDate(),
          status: data['status'] ?? 'Pending',
          approvedBy: data['approvedBy'],
          notes: data['notes'],
        );
      }).toList()
        ..sort((a, b) => b.departureDate.compareTo(a.departureDate));
      return requests;
    });
  }

  @override
  Future<void> requestLeave(LeaveRequest request) async {
    final studentDoc = await firestore.collection('students').doc(request.studentId).get();
    final dormId = studentDoc.data()?['dormitoryId'] ?? request.dormitoryId;

    await firestore.collection('boarding_leave_requests').add({
      'schoolId': studentDoc.data()?['schoolId'],
      'studentId': request.studentId,
      'studentName': request.studentName,
      'dormitoryId': dormId,
      'reason': request.reason,
      'destination': request.destination,
      'requestedBy': request.requestedBy,
      'departureDate': Timestamp.fromDate(request.departureDate),
      'expectedReturnDate': Timestamp.fromDate(request.expectedReturnDate),
      'actualReturnDate': null,
      'status': 'Pending',
      'approvedBy': null,
      'notes': request.notes,
      'gender': _kGender,
    });

    await auditRepository.logAction(
      schoolId: '',
      title: 'Leave requested',
      description: '${request.studentName}: ${request.reason}',
      iconName: 'exit_to_app',
      colorHex: '#FF9800',
      userId: request.requestedBy,
    );
  }

  @override
  Future<void> updateLeaveStatus(
    String requestId,
    String status, {
    String? approvedBy,
    DateTime? actualReturnDate,
    String? notes,
  }) async {
    final update = <String, dynamic>{'status': status};
    if (approvedBy != null) update['approvedBy'] = approvedBy;
    if (actualReturnDate != null) {
      update['actualReturnDate'] = Timestamp.fromDate(actualReturnDate);
    }
    if (notes != null) update['notes'] = notes;

    final requestDoc = await firestore.collection('boarding_leave_requests').doc(requestId).get();
    final studentId = requestDoc.data()?['studentId'] as String?;
    final studentName = requestDoc.data()?['studentName'] ?? 'Student';

    await firestore.collection('boarding_leave_requests').doc(requestId).update(update);

    if (studentId != null) {
      if (status == 'Approved' || status == 'Out') {
        await firestore.collection('students').doc(studentId).update({
          'boardingStatus': 'Leave',
        });
      } else if (status == 'Returned') {
        await firestore.collection('students').doc(studentId).update({
          'boardingStatus': 'Present',
        });
      }
      await _notifyParent(
        studentId,
        'Leave Request $status',
        '$studentName\'s leave request is now $status.',
      );
    }

    final requestSchoolId = requestDoc.data()?['schoolId'] as String? ?? '';
    await auditRepository.logAction(
      schoolId: requestSchoolId,
      title: 'Leave request $status',
      description: '$studentName\'s leave request marked $status.',
      iconName: 'exit_to_app',
      colorHex: '#FF9800',
      userId: approvedBy,
    );
  }

  // ---------------------------------------------------------------------
  // Welfare
  // ---------------------------------------------------------------------

  @override
  Stream<List<WelfareRecord>> watchWelfareRecords(
    String schoolId,
    String studentId, {
    bool publicOnly = false,
  }) {
    Query<Map<String, dynamic>> query = firestore
        .collection('welfare_records')
        .where('schoolId', isEqualTo: schoolId)
        .where('studentId', isEqualTo: studentId);
    if (publicOnly) query = query.where('isPrivate', isEqualTo: false);
    return query.snapshots().map((snapshot) => _mapWelfare(snapshot));
  }

  @override
  Stream<List<WelfareRecord>> watchAllWelfareRecords(
    String schoolId, {
    bool publicOnly = false,
  }) {
    Query<Map<String, dynamic>> query = firestore
        .collection('welfare_records')
        .where('schoolId', isEqualTo: schoolId)
        .where('gender', isEqualTo: _kGender);
    if (publicOnly) query = query.where('isPrivate', isEqualTo: false);
    return query.snapshots().map((snapshot) => _mapWelfare(snapshot));
  }

  List<WelfareRecord> _mapWelfare(QuerySnapshot<Map<String, dynamic>> snapshot) {
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
        followUpDate: (data['followUpDate'] as Timestamp?)?.toDate(),
      );
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  @override
  Future<void> logWelfareRecord(WelfareRecord record) async {
    if (record.schoolId.trim().isEmpty) {
      throw StateError('A school assignment is required for welfare records.');
    }
    final studentDoc = await firestore.collection('students').doc(record.studentId).get();
    final recordRef = firestore.collection('welfare_records').doc();
    await recordRef.set({
      'schoolId': record.schoolId.trim(),
      'studentId': record.studentId,
      'studentName': record.studentName,
      'category': record.category,
      'note': record.note,
      'date': Timestamp.fromDate(record.date),
      'recordedBy': record.recordedBy,
      'isPrivate': record.isPrivate,
      'gender': studentDoc.data()?['gender'] ?? _kGender,
      'followUpDate': record.followUpDate != null ? Timestamp.fromDate(record.followUpDate!) : null,
    });

    await auditRepository.logAction(
      schoolId: record.schoolId,
      title: 'Welfare record logged',
      description: '${record.category} for ${record.studentName}.',
      iconName: 'favorite',
      colorHex: '#E91E63',
      userId: record.recordedBy,
    );

    if (!record.isPrivate) {
      await _notifyParent(
        record.studentId,
        'New welfare record: ${record.studentName}',
        'A new ${record.category} has been logged for your child.',
      );
    }
  }

  // ---------------------------------------------------------------------
  // Counseling Referrals
  // ---------------------------------------------------------------------

  @override
  Stream<List<CounselingReferral>> getCounselingReferrals(String? studentId) {
    Query<Map<String, dynamic>> query = firestore
        .collection('boarding_counseling_referrals')
        .where('gender', isEqualTo: _kGender);
    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }
    return query.snapshots().map((snapshot) {
      final referrals = snapshot.docs.map((doc) {
        final data = doc.data();
        return CounselingReferral(
          id: doc.id,
          studentId: data['studentId'] ?? '',
          studentName: data['studentName'] ?? '',
          reason: data['reason'] ?? '',
          referredBy: data['referredBy'] ?? '',
          referredTo: data['referredTo'],
          referralDate: (data['referralDate'] as Timestamp).toDate(),
          appointmentDate: (data['appointmentDate'] as Timestamp?)?.toDate(),
          status: data['status'] ?? 'Pending',
          followUpNotes: data['followUpNotes'],
        );
      }).toList()
        ..sort((a, b) => b.referralDate.compareTo(a.referralDate));
      return referrals;
    });
  }

  @override
  Future<void> logCounselingReferral(CounselingReferral referral) async {
    final studentDoc = await firestore.collection('students').doc(referral.studentId).get();
    await firestore.collection('boarding_counseling_referrals').add({
      'studentId': referral.studentId,
      'studentName': referral.studentName,
      'reason': referral.reason,
      'referredBy': referral.referredBy,
      'referredTo': referral.referredTo,
      'referralDate': Timestamp.fromDate(referral.referralDate),
      'appointmentDate': referral.appointmentDate != null
          ? Timestamp.fromDate(referral.appointmentDate!)
          : null,
      'status': referral.status,
      'followUpNotes': referral.followUpNotes,
      'gender': studentDoc.data()?['gender'] ?? _kGender,
      'schoolId': studentDoc.data()?['schoolId'],
    });

    await auditRepository.logAction(
      schoolId: studentDoc.data()?['schoolId'] as String? ?? '',
      title: 'Counseling referral logged',
      description: '${referral.studentName} referred: ${referral.reason}',
      iconName: 'psychology',
      colorHex: '#673AB7',
      userId: referral.referredBy,
    );
  }

  @override
  Future<void> updateReferralStatus(
    String referralId,
    String status, {
    String? followUpNotes,
  }) {
    final update = <String, dynamic>{'status': status};
    if (followUpNotes != null) update['followUpNotes'] = followUpNotes;
    return firestore.collection('boarding_counseling_referrals').doc(referralId).update(update);
  }

  // ---------------------------------------------------------------------
  // Behaviour Observations
  // ---------------------------------------------------------------------

  @override
  Stream<List<BehaviourObservation>> getBehaviourObservations(String? studentId) {
    Query<Map<String, dynamic>> query = firestore
        .collection('boarding_behaviour_observations')
        .where('gender', isEqualTo: _kGender);
    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }
    return query.snapshots().map((snapshot) {
      final observations = snapshot.docs.map((doc) {
        final data = doc.data();
        return BehaviourObservation(
          id: doc.id,
          studentId: data['studentId'] ?? '',
          studentName: data['studentName'] ?? '',
          type: data['type'] ?? 'Positive',
          description: data['description'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          recordedBy: data['recordedBy'] ?? '',
        );
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return observations;
    });
  }

  @override
  Future<void> logBehaviourObservation(BehaviourObservation observation) async {
    final studentDoc = await firestore.collection('students').doc(observation.studentId).get();
    await firestore.collection('boarding_behaviour_observations').add({
      'studentId': observation.studentId,
      'studentName': observation.studentName,
      'type': observation.type,
      'description': observation.description,
      'date': Timestamp.fromDate(observation.date),
      'recordedBy': observation.recordedBy,
      'gender': studentDoc.data()?['gender'] ?? _kGender,
      'schoolId': studentDoc.data()?['schoolId'],
    });

    await auditRepository.logAction(
      schoolId: studentDoc.data()?['schoolId'] as String? ?? '',
      title: 'Behaviour observation logged',
      description: '${observation.type}: ${observation.studentName} - ${observation.description}',
      iconName: 'visibility',
      colorHex: observation.type == 'Positive' ? '#4CAF50' : '#FF9800',
      userId: observation.recordedBy,
    );
  }

  // ---------------------------------------------------------------------
  // Discipline
  // ---------------------------------------------------------------------

  @override
  Stream<List<DisciplineIncident>> getDisciplineIncidents(String? studentId) {
    Query<Map<String, dynamic>> query = firestore
        .collection('boarding_discipline')
        .orderBy('date', descending: true);
    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
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
          location: data['location'],
          witnesses: List<String>.from(data['witnesses'] ?? const []),
          severity: data['severity'] ?? 'Low',
          parentNotified: data['parentNotified'] ?? false,
          followUpRequired: data['followUpRequired'] ?? false,
          followUpDate: (data['followUpDate'] as Timestamp?)?.toDate(),
          isPrivate: data['isPrivate'] ?? true,
        );
      }).toList();
    });
  }

  @override
  Future<void> logDisciplineIncident(DisciplineIncident incident) async {
    final studentDoc = await firestore.collection('students').doc(incident.studentId).get();
    await firestore.collection('boarding_discipline').add({
      'studentId': incident.studentId,
      'studentName': incident.studentName,
      'description': incident.description,
      'category': incident.category,
      'actionTaken': incident.actionTaken,
      'date': Timestamp.fromDate(incident.date),
      'status': incident.status,
      'recordedBy': incident.recordedBy,
      'location': incident.location,
      'witnesses': incident.witnesses,
      'severity': incident.severity,
      'parentNotified': incident.parentNotified,
      'followUpRequired': incident.followUpRequired,
      'followUpDate': incident.followUpDate != null ? Timestamp.fromDate(incident.followUpDate!) : null,
      'isPrivate': incident.isPrivate,
      'schoolId': studentDoc.data()?['schoolId'],
      'gender': studentDoc.data()?['gender'] ?? _kGender,
    });

    await auditRepository.logAction(
      schoolId: studentDoc.data()?['schoolId'] as String? ?? '',
      title: 'Discipline incident logged',
      description: '${incident.studentName}: ${incident.category} (${incident.severity})',
      iconName: 'gavel',
      colorHex: '#F44336',
      userId: incident.recordedBy,
    );

    if (incident.parentNotified) {
      await _notifyParent(
        incident.studentId,
        'Boarding Incident: ${incident.studentName}',
        'A new discipline incident (${incident.category}) has been logged.',
      );
    }
  }

  @override
  Future<void> updateDisciplineStatus(
    String incidentId,
    String status,
    String actionTaken,
  ) async {
    await firestore.collection('boarding_discipline').doc(incidentId).update({
      'status': status,
      'actionTaken': actionTaken,
    });
    await auditRepository.logAction(
      schoolId: '',
      title: 'Discipline case updated',
      description: 'Case $incidentId marked $status.',
      iconName: 'gavel',
      colorHex: '#F44336',
    );
  }

  // ---------------------------------------------------------------------
  // Communication
  // ---------------------------------------------------------------------

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
              targetGroups: List<String>.from(data['targetGroups'] ?? const []),
            );
          }).toList();
        });
  }

  @override
  Future<void> postAnnouncement(BoardingAnnouncement announcement) async {
    await firestore.collection('boarding_announcements').add({
      'title': announcement.title,
      'content': announcement.content,
      'date': Timestamp.fromDate(announcement.date),
      'authorName': announcement.authorName,
      'targetDormitoryId': announcement.targetDormitoryId,
      'targetGroups': announcement.targetGroups,
      'gender': _kGender,
    });

    if (announcement.targetGroups.isNotEmpty) {
      await NotificationService().sendBroadcast(
        schoolId: '',
        title: announcement.title,
        body: announcement.content,
        targetGroups: announcement.targetGroups,
      );
    }

    await auditRepository.logAction(
      schoolId: '',
      title: 'Boarding announcement posted',
      description: announcement.title,
      iconName: 'campaign',
      colorHex: '#FF5722',
      userId: announcement.authorName,
    );
  }

  // ---------------------------------------------------------------------
  // Legacy compat surface (see abstract method docs above)
  // ---------------------------------------------------------------------

  @override
  Future<List<legacy.WelfareRecord>> getWelfareRecords({
    String? schoolId,
    String? studentId,
    bool publicOnly = false,
  }) async {
    Query<Map<String, dynamic>> query = firestore.collection('welfare_records');
    if (schoolId != null) query = query.where('schoolId', isEqualTo: schoolId);
    if (studentId != null) query = query.where('studentId', isEqualTo: studentId);
    if (publicOnly) query = query.where('isPrivate', isEqualTo: false);
    final snapshot = await query.get();
    final records = snapshot.docs.map((doc) {
      final data = doc.data();
      return legacy.WelfareRecord(
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
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  @override
  Future<List<legacy.DisciplineCase>> getDisciplineCases({
    String? studentId,
  }) async {
    Query<Map<String, dynamic>> query = firestore.collection('boarding_discipline');
    if (studentId != null) query = query.where('studentId', isEqualTo: studentId);
    final snapshot = await query.get();
    final cases = snapshot.docs.map((doc) {
      final data = doc.data();
      return legacy.DisciplineCase(
        id: doc.id,
        studentId: data['studentId'],
        studentName: data['studentName'],
        incident: data['description'] ?? '',
        category: data['category'] ?? '',
        actionTaken: data['actionTaken'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        status: data['status'] ?? 'Pending',
        recordedBy: data['recordedBy'] ?? '',
      );
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return cases;
  }
}
