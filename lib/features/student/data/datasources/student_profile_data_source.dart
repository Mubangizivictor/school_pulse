import 'package:cloud_firestore/cloud_firestore.dart';

/// One guardian entry inside the `student_guardians/{studentId}` document.
///
/// The field names mirror exactly what `direct_student_registration_screen`
/// builds and `directEnrolLearner` persists - see the guardian dialog in that
/// screen. This is intentionally a thin read model over that map rather than a
/// new domain entity, because the enrolment callable owns the write shape and
/// nothing on this branch writes `ParentStudentRelationship` yet.
class StudentGuardian {
  final String id;
  final String name;
  final String relationship;
  final String phone;
  final String email;
  final bool isPrimary;
  final bool pickup;
  final bool emergencyConsent;

  const StudentGuardian({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    required this.email,
    required this.isPrimary,
    required this.pickup,
    required this.emergencyConsent,
  });

  factory StudentGuardian.fromMap(Map<String, dynamic> map) => StudentGuardian(
    id: map['id'] as String? ?? '',
    name: map['name'] as String? ?? '',
    relationship: map['relationship'] as String? ?? '',
    phone: map['phone'] as String? ?? '',
    email: map['email'] as String? ?? '',
    isPrimary: map['primary'] == true,
    pickup: map['pickup'] == true,
    emergencyConsent: map['emergencyConsent'] == true,
  );
}

/// The maximum guardians a learner may have on file. The enrolment wizard does
/// not currently enforce a cap of its own, so this constant is the single
/// definition and the profile's "add guardian" affordance enforces it.
const int kMaxGuardiansPerStudent = 2;

/// Reads the student-scoped side collections the profile screen needs, none of
/// which had a repository method before this screen required them.
///
/// Every query is school-scoped: `student_guardians` documents carry a
/// `schoolId` that is verified against the caller's own school before the data
/// is returned, and attendance lives under `schools/{schoolId}/...` already.
class StudentProfileDataSource {
  final FirebaseFirestore _firestore;

  StudentProfileDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Guardians on file for one learner.
  ///
  /// Returns an empty list when the document is missing (a learner enrolled
  /// through a path that never wrote guardians) or when the document belongs to
  /// another school, which would indicate a tenant-isolation problem rather
  /// than a normal empty state.
  Future<List<StudentGuardian>> getGuardians({
    required String studentId,
    required String schoolId,
  }) async {
    final doc = await _firestore
        .collection('student_guardians')
        .doc(studentId)
        .get();
    final data = doc.data();
    if (data == null) return const [];
    if (data['schoolId'] != schoolId) return const [];
    final raw = data['guardians'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(StudentGuardian.fromMap)
        .toList();
  }

  /// Student ids within [schoolId] whose guardian phone contains [phone].
  ///
  /// Firestore cannot index into an array of maps, so the guardian entries are
  /// matched in memory. The query itself is still school-scoped, so this never
  /// reads another tenant's guardians - it only post-filters this school's.
  Future<Set<String>> findStudentIdsByGuardianPhone({
    required String schoolId,
    required String phone,
  }) async {
    final needle = phone.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    if (needle.isEmpty) return const {};
    final snapshot = await _firestore
        .collection('student_guardians')
        .where('schoolId', isEqualTo: schoolId)
        .get();
    final matches = <String>{};
    for (final doc in snapshot.docs) {
      final raw = doc.data()['guardians'];
      if (raw is! List) continue;
      final hit = raw.whereType<Map<String, dynamic>>().any((g) {
        final candidate = (g['phone'] as String? ?? '')
            .replaceAll(RegExp(r'\s+'), '')
            .toLowerCase();
        return candidate.isNotEmpty && candidate.contains(needle);
      });
      if (hit) matches.add(doc.id);
    }
    return matches;
  }

  /// Recent attendance events for one learner, newest first.
  ///
  /// Queries `schools/{schoolId}/attendance_records` directly - the collection
  /// `AttendanceRemoteDataSourceImpl.markAttendance/markBatch` actually writes.
  /// The hub's own `getRecords` has no `personId` filter, so this adds the
  /// per-student read rather than fetching a whole school's records and
  /// filtering them on the client.
  Future<List<StudentAttendanceEvent>> getAttendance({
    required String studentId,
    required String schoolId,
    required DateTime since,
  }) async {
    // Do not make the learner profile unusable while a composite index is
    // building. A single learner has a bounded attendance history, so read
    // that learner's records through Firestore's automatic equality index and
    // apply the small date window/order locally.
    final snapshot = await _firestore
        .collection('schools')
        .doc(schoolId)
        .collection('attendance_records')
        .where('personId', isEqualTo: studentId)
        .get();
    final cutoff = DateTime(since.year, since.month, since.day);
    final events =
        snapshot.docs
            .map((doc) {
              final data = doc.data();
              return StudentAttendanceEvent(
                id: doc.id,
                date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
                status: data['status'] as String? ?? 'unknown',
                sessionType: data['sessionType'] as String? ?? '',
                scopeName: data['scopeName'] as String? ?? '',
              );
            })
            .where((event) => !event.date.isBefore(cutoff))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return events;
  }

  /// Audit-log entries about one learner, newest first.
  ///
  /// Matches the shape `directEnrolLearner` writes: `targetType: "student"`
  /// with `targetId` set to the student id.
  Future<List<StudentHistoryEntry>> getHistory({
    required String studentId,
    required String schoolId,
  }) async {
    final snapshot = await _firestore
        .collection('audit_logs')
        .where('schoolId', isEqualTo: schoolId)
        .where('targetId', isEqualTo: studentId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return StudentHistoryEntry(
        id: doc.id,
        title: data['title'] as String? ?? data['action'] as String? ?? 'Event',
        description: data['description'] as String? ?? '',
        actor: data['userName'] as String? ?? data['userId'] as String? ?? '',
        timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      );
    }).toList();
  }
}

class StudentAttendanceEvent {
  final String id;
  final DateTime date;
  final String status;
  final String sessionType;
  final String scopeName;

  const StudentAttendanceEvent({
    required this.id,
    required this.date,
    required this.status,
    required this.sessionType,
    required this.scopeName,
  });
}

class StudentHistoryEntry {
  final String id;
  final String title;
  final String description;
  final String actor;
  final DateTime? timestamp;

  const StudentHistoryEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.actor,
    this.timestamp,
  });
}
