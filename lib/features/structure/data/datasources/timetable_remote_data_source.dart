import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/timetable.dart';

abstract class TimetableRemoteDataSource {
  Stream<List<Timetable>> watchTimetables({
    required String schoolId,
    String? academicYearId,
    String? classId,
  });

  Future<Timetable?> getTimetable({
    required String schoolId,
    required String timetableId,
  });

  Future<String> createTimetable(Timetable timetable);

  Future<void> updateTimetable(Timetable timetable);

  Stream<List<TimetableLesson>> watchLessons({
    required String schoolId,
    required String timetableId,
  });

  /// Every lesson at the school for an academic year (optionally narrowed to
  /// a term), regardless of which timetable it belongs to. This is what the
  /// conflict resolver needs: a teacher/room collision can come from a
  /// different class's timetable entirely.
  Future<List<TimetableLesson>> getAllLessonsForYear({
    required String schoolId,
    required String academicYearId,
    String? termId,
  });

  Future<String> upsertLesson(TimetableLesson lesson);

  Future<void> deleteLesson({
    required String schoolId,
    required String lessonId,
  });

  /// The currently published timetable for the same target
  /// (year/term/class/stream) as [timetable], if any. Used to find what a
  /// new publish would supersede.
  Future<Timetable?> getPublishedTimetableForTarget(Timetable timetable);

  Future<void> markValidated({
    required String schoolId,
    required String timetableId,
    required String validatedBy,
  });

  /// Atomically publishes [timetable] and, if a different timetable is
  /// currently published for the same target, stamps that one `superseded`
  /// in the same transaction - so a target is never left with two
  /// published timetables, or a published timetable "disappearing" with no
  /// replacement, even if the app crashes mid-operation.
  Future<void> publishTimetable({
    required Timetable timetable,
    required String publishedBy,
    DateTime? effectiveFrom,
  });

  Future<void> archiveTimetable({
    required String schoolId,
    required String timetableId,
    required String archivedBy,
  });

  Future<void> appendAuditEntry(TimetableAuditEntry entry);

  Stream<List<TimetableAuditEntry>> watchAuditTrail({
    required String schoolId,
    required String timetableId,
  });
}

class TimetableRemoteDataSourceImpl implements TimetableRemoteDataSource {
  final FirebaseFirestore firestore;

  TimetableRemoteDataSourceImpl({required this.firestore});

  DocumentReference<Map<String, dynamic>> _school(String schoolId) =>
      firestore.collection('schools').doc(schoolId);

  CollectionReference<Map<String, dynamic>> _timetables(String schoolId) =>
      _school(schoolId).collection('timetables');

  CollectionReference<Map<String, dynamic>> _lessons(String schoolId) =>
      _school(schoolId).collection('timetable_lessons');

  CollectionReference<Map<String, dynamic>> _auditTrail(
    String schoolId,
    String timetableId,
  ) => _timetables(schoolId).doc(timetableId).collection('audit_trail');

  @override
  Stream<List<Timetable>> watchTimetables({
    required String schoolId,
    String? academicYearId,
    String? classId,
  }) {
    Query<Map<String, dynamic>> query = _timetables(schoolId);
    if (academicYearId != null && academicYearId.isNotEmpty) {
      query = query.where('academicYearId', isEqualTo: academicYearId);
    }
    if (classId != null && classId.isNotEmpty) {
      query = query.where('classId', isEqualTo: classId);
    }
    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((d) => _timetableFromDoc(d.id, d.data())).toList(),
    );
  }

  @override
  Future<Timetable?> getTimetable({
    required String schoolId,
    required String timetableId,
  }) async {
    final doc = await _timetables(schoolId).doc(timetableId).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return _timetableFromDoc(doc.id, data);
  }

  @override
  Future<String> createTimetable(Timetable timetable) async {
    final ref = await _timetables(
      timetable.schoolId,
    ).add(_timetableToMap(timetable));
    return ref.id;
  }

  @override
  Future<void> updateTimetable(Timetable timetable) async {
    await _timetables(
      timetable.schoolId,
    ).doc(timetable.id).update(_timetableToMap(timetable));
  }

  @override
  Stream<List<TimetableLesson>> watchLessons({
    required String schoolId,
    required String timetableId,
  }) {
    return _lessons(schoolId)
        .where('timetableId', isEqualTo: timetableId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((d) => _lessonFromDoc(d.id, d.data())).toList(),
        );
  }

  @override
  Future<List<TimetableLesson>> getAllLessonsForYear({
    required String schoolId,
    required String academicYearId,
    String? termId,
  }) async {
    Query<Map<String, dynamic>> query = _lessons(
      schoolId,
    ).where('academicYearId', isEqualTo: academicYearId);
    if (termId != null && termId.isNotEmpty) {
      query = query.where('termId', isEqualTo: termId);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((d) => _lessonFromDoc(d.id, d.data())).toList();
  }

  @override
  Future<String> upsertLesson(TimetableLesson lesson) async {
    if (lesson.id.isEmpty) {
      final ref = await _lessons(lesson.schoolId).add(_lessonToMap(lesson));
      return ref.id;
    }
    await _lessons(lesson.schoolId).doc(lesson.id).set(_lessonToMap(lesson));
    return lesson.id;
  }

  @override
  Future<void> deleteLesson({
    required String schoolId,
    required String lessonId,
  }) async {
    await _lessons(schoolId).doc(lessonId).delete();
  }

  @override
  Future<Timetable?> getPublishedTimetableForTarget(Timetable timetable) async {
    final snapshot = await _timetables(timetable.schoolId)
        .where('academicYearId', isEqualTo: timetable.academicYearId)
        .where('termId', isEqualTo: timetable.termId)
        .where('classId', isEqualTo: timetable.classId)
        .where('streamId', isEqualTo: timetable.streamId)
        .where('status', whereIn: ['published', 'active'])
        .get();
    final docs = snapshot.docs.where((d) => d.id != timetable.id).toList();
    if (docs.isEmpty) return null;
    // Guard against more than one - should never happen once publishing is
    // always routed through publishTimetable's transaction, but if legacy
    // data somehow has two, prefer the most recently published.
    docs.sort((a, b) {
      final aAt = _toDate(a.data()['publishedAt']) ?? DateTime(0);
      final bAt = _toDate(b.data()['publishedAt']) ?? DateTime(0);
      return bAt.compareTo(aAt);
    });
    return _timetableFromDoc(docs.first.id, docs.first.data());
  }

  @override
  Future<void> markValidated({
    required String schoolId,
    required String timetableId,
    required String validatedBy,
  }) async {
    await _timetables(schoolId).doc(timetableId).update({
      'status': TimetableStatus.validated.name,
      'validatedAt': FieldValue.serverTimestamp(),
      'validatedBy': validatedBy,
    });
  }

  @override
  Future<void> publishTimetable({
    required Timetable timetable,
    required String publishedBy,
    DateTime? effectiveFrom,
  }) async {
    final newRef = _timetables(timetable.schoolId).doc(timetable.id);
    await firestore.runTransaction((tx) async {
      final currentSnap = await tx.get(newRef);
      if (!currentSnap.exists) {
        throw StateError('Timetable not found.');
      }
      final currentStatus = TimetableStatus.fromId(
        currentSnap.data()?['status'] as String?,
      );
      if (currentStatus == TimetableStatus.published) {
        throw StateError('This timetable is already published.');
      }
      if (currentStatus == TimetableStatus.superseded ||
          currentStatus == TimetableStatus.archived) {
        throw StateError('A superseded or archived timetable cannot be published.');
      }

      final existingSnap = await _timetables(timetable.schoolId)
          .where('academicYearId', isEqualTo: timetable.academicYearId)
          .where('termId', isEqualTo: timetable.termId)
          .where('classId', isEqualTo: timetable.classId)
          .where('streamId', isEqualTo: timetable.streamId)
          .where('status', whereIn: ['published', 'active'])
          .get();
      final previous = existingSnap.docs.where((d) => d.id != timetable.id).toList();

      final now = DateTime.now();
      tx.update(newRef, {
        'status': TimetableStatus.published.name,
        'publishedAt': Timestamp.fromDate(now),
        'publishedBy': publishedBy,
        'effectiveFrom': Timestamp.fromDate(effectiveFrom ?? now),
        'revisionOf': previous.isNotEmpty ? previous.first.id : '',
        'version': (timetable.version) + (previous.isNotEmpty ? 1 : 0),
      });
      for (final doc in previous) {
        tx.update(doc.reference, {
          'status': TimetableStatus.superseded.name,
          'supersededAt': Timestamp.fromDate(now),
          'supersededBy': publishedBy,
        });
      }
    });
  }

  @override
  Future<void> archiveTimetable({
    required String schoolId,
    required String timetableId,
    required String archivedBy,
  }) async {
    await _timetables(schoolId).doc(timetableId).update({
      'status': TimetableStatus.archived.name,
      'archivedAt': FieldValue.serverTimestamp(),
      'archivedBy': archivedBy,
    });
  }

  @override
  Future<void> appendAuditEntry(TimetableAuditEntry entry) async {
    await _auditTrail(entry.schoolId, entry.timetableId).add({
      'schoolId': entry.schoolId,
      'timetableId': entry.timetableId,
      'action': entry.action,
      'actorId': entry.actorId,
      'at': Timestamp.fromDate(entry.at),
      'notes': entry.notes,
    });
  }

  @override
  Stream<List<TimetableAuditEntry>> watchAuditTrail({
    required String schoolId,
    required String timetableId,
  }) {
    return _auditTrail(schoolId, timetableId)
        .orderBy('at', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (d) => TimetableAuditEntry(
                  id: d.id,
                  schoolId: d.data()['schoolId'] as String? ?? '',
                  timetableId: d.data()['timetableId'] as String? ?? '',
                  action: d.data()['action'] as String? ?? '',
                  actorId: d.data()['actorId'] as String? ?? '',
                  at: _toDate(d.data()['at']) ?? DateTime.now(),
                  notes: d.data()['notes'] as String? ?? '',
                ),
              )
              .toList(),
        );
  }

  Timetable _timetableFromDoc(String id, Map<String, dynamic> data) {
    return Timetable(
      id: id,
      schoolId: data['schoolId'] as String? ?? '',
      academicYearId: data['academicYearId'] as String? ?? '',
      termId: data['termId'] as String? ?? '',
      classId: data['classId'] as String? ?? '',
      streamId: data['streamId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: TimetableStatus.fromId(data['status'] as String?),
      version: (data['version'] as num?)?.toInt() ?? 1,
      revisionOf: data['revisionOf'] as String? ?? '',
      effectiveFrom: _toDate(data['effectiveFrom']),
      configSnapshotId: data['configSnapshotId'] as String? ?? '',
      createdAt: _toDate(data['createdAt']) ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
      updatedAt: _toDate(data['updatedAt']),
      updatedBy: data['updatedBy'] as String?,
      validatedAt: _toDate(data['validatedAt']),
      validatedBy: data['validatedBy'] as String?,
      publishedAt: _toDate(data['publishedAt']),
      publishedBy: data['publishedBy'] as String?,
      supersededAt: _toDate(data['supersededAt']),
      supersededBy: data['supersededBy'] as String?,
      archivedAt: _toDate(data['archivedAt']),
      archivedBy: data['archivedBy'] as String?,
    );
  }

  Map<String, dynamic> _timetableToMap(Timetable t) {
    return {
      'schoolId': t.schoolId,
      'academicYearId': t.academicYearId,
      'termId': t.termId,
      'classId': t.classId,
      'streamId': t.streamId,
      'name': t.name,
      'description': t.description,
      'status': t.status.name,
      'version': t.version,
      'revisionOf': t.revisionOf,
      'effectiveFrom': t.effectiveFrom != null
          ? Timestamp.fromDate(t.effectiveFrom!)
          : null,
      'configSnapshotId': t.configSnapshotId,
      'createdAt': Timestamp.fromDate(t.createdAt),
      'createdBy': t.createdBy,
      'updatedAt': t.updatedAt != null
          ? Timestamp.fromDate(t.updatedAt!)
          : FieldValue.serverTimestamp(),
      'updatedBy': t.updatedBy,
      'validatedAt': t.validatedAt != null
          ? Timestamp.fromDate(t.validatedAt!)
          : null,
      'validatedBy': t.validatedBy,
      'publishedAt': t.publishedAt != null
          ? Timestamp.fromDate(t.publishedAt!)
          : null,
      'publishedBy': t.publishedBy,
      'supersededAt': t.supersededAt != null
          ? Timestamp.fromDate(t.supersededAt!)
          : null,
      'supersededBy': t.supersededBy,
      'archivedAt': t.archivedAt != null
          ? Timestamp.fromDate(t.archivedAt!)
          : null,
      'archivedBy': t.archivedBy,
    };
  }

  TimetableLesson _lessonFromDoc(String id, Map<String, dynamic> data) {
    final rawOccurrences = data['occurrences'] as List? ?? const [];
    return TimetableLesson(
      id: id,
      schoolId: data['schoolId'] as String? ?? '',
      timetableId: data['timetableId'] as String? ?? '',
      academicYearId: data['academicYearId'] as String? ?? '',
      termId: data['termId'] as String? ?? '',
      classId: data['classId'] as String? ?? '',
      className: data['className'] as String? ?? '',
      streamId: data['streamId'] as String? ?? '',
      streamName: data['streamName'] as String? ?? '',
      subjectId: data['subjectId'] as String? ?? '',
      subjectName: data['subjectName'] as String? ?? '',
      teacherId: data['teacherId'] as String? ?? '',
      teacherName: data['teacherName'] as String? ?? '',
      roomId: data['roomId'] as String?,
      roomName: data['roomName'] as String?,
      groupId: data['groupId'] as String?,
      notes: data['notes'] as String? ?? '',
      occurrences: rawOccurrences
          .whereType<Map>()
          .map(
            (o) => TimetableLessonOccurrence(
              day: o['day'] as String? ?? '',
              slotId: o['slotId'] as String? ?? '',
            ),
          )
          .toList(),
      createdAt: _toDate(data['createdAt']) ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
      updatedAt: _toDate(data['updatedAt']),
      updatedBy: data['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> _lessonToMap(TimetableLesson lesson) {
    return {
      'schoolId': lesson.schoolId,
      'timetableId': lesson.timetableId,
      'academicYearId': lesson.academicYearId,
      'termId': lesson.termId,
      'classId': lesson.classId,
      'className': lesson.className,
      'streamId': lesson.streamId,
      'streamName': lesson.streamName,
      'subjectId': lesson.subjectId,
      'subjectName': lesson.subjectName,
      'teacherId': lesson.teacherId,
      'teacherName': lesson.teacherName,
      'roomId': lesson.roomId,
      'roomName': lesson.roomName,
      'groupId': lesson.groupId,
      'notes': lesson.notes,
      'occurrences': lesson.occurrences
          .map((o) => {'day': o.day, 'slotId': o.slotId})
          .toList(),
      'createdAt': Timestamp.fromDate(lesson.createdAt),
      'createdBy': lesson.createdBy,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': lesson.updatedBy,
    };
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
