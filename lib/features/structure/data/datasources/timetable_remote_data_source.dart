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
      configSnapshotId: data['configSnapshotId'] as String? ?? '',
      createdAt: _toDate(data['createdAt']) ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
      updatedAt: _toDate(data['updatedAt']),
      updatedBy: data['updatedBy'] as String?,
      publishedAt: _toDate(data['publishedAt']),
      publishedBy: data['publishedBy'] as String?,
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
      'configSnapshotId': t.configSnapshotId,
      'createdAt': Timestamp.fromDate(t.createdAt),
      'createdBy': t.createdBy,
      'updatedAt': t.updatedAt != null
          ? Timestamp.fromDate(t.updatedAt!)
          : FieldValue.serverTimestamp(),
      'updatedBy': t.updatedBy,
      'publishedAt': t.publishedAt != null
          ? Timestamp.fromDate(t.publishedAt!)
          : null,
      'publishedBy': t.publishedBy,
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
