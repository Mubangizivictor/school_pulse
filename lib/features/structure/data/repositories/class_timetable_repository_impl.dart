import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/class_timetable_entities.dart';
import '../../domain/repositories/class_timetable_repository.dart';
import '../../domain/services/structure_tenant_resolver.dart';
import '../../domain/services/timetable_conflict_resolver.dart';

class ClassTimetableRepositoryImpl implements ClassTimetableRepository {
  final FirebaseFirestore firestore;
  final StructureTenantResolver tenantResolver;
  final TimetableConflictResolver conflictResolver;

  ClassTimetableRepositoryImpl({
    required this.firestore,
    required this.tenantResolver,
    this.conflictResolver = const TimetableConflictResolver(),
  });

  CollectionReference<Map<String, dynamic>> get _timetables =>
      firestore.collection('structure_class_timetables');
  CollectionReference<Map<String, dynamic>> get _lessons =>
      firestore.collection('structure_timetable_lessons');

  @override
  Stream<List<ClassTimetable>> watchTimetables() async* {
    final schoolId = await tenantResolver.resolve();
    yield* _timetables
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _timetableFromMap(doc.id, doc.data()))
            .toList(growable: false));
  }

  @override
  Stream<List<ClassTimetableLesson>> watchLessons() async* {
    final schoolId = await tenantResolver.resolve();
    yield* _lessons
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _lessonFromMap(doc.id, doc.data()))
            .toList(growable: false));
  }

  @override
  Future<void> saveTimetable(ClassTimetable timetable) async {
    final schoolId = await tenantResolver.resolve();
    if (timetable.schoolId != schoolId) {
      throw StateError('Timetable tenant does not match the active school.');
    }
    if (timetable.academicYearId.isEmpty ||
        timetable.termId.isEmpty ||
        timetable.classId.isEmpty ||
        timetable.name.trim().isEmpty) {
      throw StateError('Academic year, term, class and timetable name are required.');
    }
    await _timetables.doc(timetable.id).set(_timetableToMap(timetable));
  }

  @override
  Future<void> saveLesson(ClassTimetableLesson lesson) async {
    final schoolId = await tenantResolver.resolve();
    if (lesson.schoolId != schoolId) {
      throw StateError('Lesson tenant does not match the active school.');
    }
    if (lesson.subjectId.isEmpty || lesson.teacherId.isEmpty) {
      throw StateError('A lesson requires a subject and teacher.');
    }

    final snapshot = await _lessons
        .where('schoolId', isEqualTo: schoolId)
        .where('academicYearId', isEqualTo: lesson.academicYearId)
        .where('termId', isEqualTo: lesson.termId)
        .where('day', isEqualTo: lesson.day)
        .where('isActive', isEqualTo: true)
        .get();
    final existing = snapshot.docs
        .map((doc) => _lessonFromMap(doc.id, doc.data()))
        .toList(growable: false);
    final conflicts = conflictResolver.findConflicts(
      proposed: lesson,
      existing: existing,
    );
    if (conflicts.isNotEmpty) {
      throw StateError(conflicts.first.message);
    }
    await _lessons.doc(lesson.id).set(_lessonToMap(lesson));
  }

  @override
  Future<void> deleteLesson(String lessonId) async {
    final schoolId = await tenantResolver.resolve();
    final ref = _lessons.doc(lessonId);
    final snapshot = await ref.get();
    if (!snapshot.exists || snapshot.data()?['schoolId'] != schoolId) {
      throw StateError('Lesson not found in the active school.');
    }
    await ref.update({'isActive': false, 'updatedAt': FieldValue.serverTimestamp()});
  }

  @override
  Future<void> publishTimetable(String timetableId) async {
    final schoolId = await tenantResolver.resolve();
    final targetRef = _timetables.doc(timetableId);
    final targetSnapshot = await targetRef.get();
    if (!targetSnapshot.exists || targetSnapshot.data()?['schoolId'] != schoolId) {
      throw StateError('Timetable not found in the active school.');
    }
    final target = _timetableFromMap(timetableId, targetSnapshot.data()!);

    final lessonSnapshot = await _lessons
        .where('schoolId', isEqualTo: schoolId)
        .where('academicYearId', isEqualTo: target.academicYearId)
        .where('termId', isEqualTo: target.termId)
        .where('isActive', isEqualTo: true)
        .get();
    final lessons = lessonSnapshot.docs
        .map((doc) => _lessonFromMap(doc.id, doc.data()))
        .toList(growable: false);
    for (final lesson in lessons.where((item) => item.timetableId == timetableId)) {
      final other = lessons.where((item) => item.id != lesson.id);
      final conflicts = conflictResolver.findConflicts(
        proposed: lesson,
        existing: other,
      );
      if (conflicts.isNotEmpty) {
        throw StateError('Cannot publish: ${conflicts.first.message}');
      }
    }

    final competing = await _timetables
        .where('schoolId', isEqualTo: schoolId)
        .where('academicYearId', isEqualTo: target.academicYearId)
        .where('termId', isEqualTo: target.termId)
        .where('classId', isEqualTo: target.classId)
        .where('streamId', isEqualTo: target.streamId)
        .where('status', isEqualTo: ClassTimetableStatus.active.name)
        .get();

    final batch = firestore.batch();
    for (final doc in competing.docs) {
      if (doc.id == timetableId) continue;
      batch.update(doc.reference, {
        'status': ClassTimetableStatus.archived.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    batch.update(targetRef, {
      'status': ClassTimetableStatus.active.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  @override
  Future<void> archiveTimetable(String timetableId) async {
    final schoolId = await tenantResolver.resolve();
    final ref = _timetables.doc(timetableId);
    final snapshot = await ref.get();
    if (!snapshot.exists || snapshot.data()?['schoolId'] != schoolId) {
      throw StateError('Timetable not found in the active school.');
    }
    await ref.update({
      'status': ClassTimetableStatus.archived.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  ClassTimetable _timetableFromMap(String id, Map<String, dynamic> map) {
    final statusRaw = map['status']?.toString() ?? ClassTimetableStatus.draft.name;
    final status = ClassTimetableStatus.values.firstWhere(
      (value) => value.name == statusRaw,
      orElse: () => ClassTimetableStatus.draft,
    );
    return ClassTimetable(
      id: id,
      schoolId: map['schoolId']?.toString() ?? '',
      academicYearId: map['academicYearId']?.toString() ?? '',
      termId: map['termId']?.toString() ?? '',
      classId: map['classId']?.toString() ?? '',
      streamId: map['streamId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      status: status,
      version: (map['version'] as num?)?.toInt() ?? 1,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      createdBy: map['createdBy']?.toString() ?? '',
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      updatedBy: map['updatedBy']?.toString() ?? '',
    );
  }

  Map<String, dynamic> _timetableToMap(ClassTimetable value) => {
        'schoolId': value.schoolId,
        'academicYearId': value.academicYearId,
        'termId': value.termId,
        'classId': value.classId,
        'streamId': value.streamId,
        'name': value.name,
        'status': value.status.name,
        'version': value.version,
        'createdAt': value.createdAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(value.createdAt!),
        'createdBy': value.createdBy,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': value.updatedBy,
      };

  ClassTimetableLesson _lessonFromMap(String id, Map<String, dynamic> map) =>
      ClassTimetableLesson(
        id: id,
        schoolId: map['schoolId']?.toString() ?? '',
        timetableId: map['timetableId']?.toString() ?? '',
        academicYearId: map['academicYearId']?.toString() ?? '',
        termId: map['termId']?.toString() ?? '',
        classId: map['classId']?.toString() ?? '',
        streamId: map['streamId']?.toString() ?? '',
        day: map['day']?.toString() ?? '',
        slotKey: map['slotKey']?.toString() ?? '',
        startTime: map['startTime']?.toString() ?? '',
        endTime: map['endTime']?.toString() ?? '',
        subjectId: map['subjectId']?.toString() ?? '',
        teacherId: map['teacherId']?.toString() ?? '',
        roomId: map['roomId']?.toString() ?? '',
        notes: map['notes']?.toString() ?? '',
        isActive: map['isActive'] != false,
      );

  Map<String, dynamic> _lessonToMap(ClassTimetableLesson value) => {
        'schoolId': value.schoolId,
        'timetableId': value.timetableId,
        'academicYearId': value.academicYearId,
        'termId': value.termId,
        'classId': value.classId,
        'streamId': value.streamId,
        'day': value.day,
        'slotKey': value.slotKey,
        'startTime': value.startTime,
        'endTime': value.endTime,
        'subjectId': value.subjectId,
        'teacherId': value.teacherId,
        'roomId': value.roomId,
        'notes': value.notes,
        'isActive': value.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
