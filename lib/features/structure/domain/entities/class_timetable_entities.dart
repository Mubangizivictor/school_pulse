import 'package:equatable/equatable.dart';

enum ClassTimetableStatus { draft, active, archived }

class ClassTimetable extends Equatable {
  final String id;
  final String schoolId;
  final String academicYearId;
  final String termId;
  final String classId;
  final String streamId;
  final String name;
  final ClassTimetableStatus status;
  final int version;
  final DateTime? createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String updatedBy;

  const ClassTimetable({
    required this.id,
    required this.schoolId,
    required this.academicYearId,
    required this.termId,
    required this.classId,
    this.streamId = '',
    required this.name,
    this.status = ClassTimetableStatus.draft,
    this.version = 1,
    this.createdAt,
    this.createdBy = '',
    this.updatedAt,
    this.updatedBy = '',
  });

  ClassTimetable copyWith({
    String? id,
    String? schoolId,
    String? academicYearId,
    String? termId,
    String? classId,
    String? streamId,
    String? name,
    ClassTimetableStatus? status,
    int? version,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return ClassTimetable(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      academicYearId: academicYearId ?? this.academicYearId,
      termId: termId ?? this.termId,
      classId: classId ?? this.classId,
      streamId: streamId ?? this.streamId,
      name: name ?? this.name,
      status: status ?? this.status,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        schoolId,
        academicYearId,
        termId,
        classId,
        streamId,
        name,
        status,
        version,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
      ];
}

class ClassTimetableLesson extends Equatable {
  final String id;
  final String schoolId;
  final String timetableId;
  final String academicYearId;
  final String termId;
  final String classId;
  final String streamId;
  final String day;
  final String slotKey;
  final String startTime;
  final String endTime;
  final String subjectId;
  final String teacherId;
  final String roomId;
  final String notes;
  final bool isActive;

  const ClassTimetableLesson({
    required this.id,
    required this.schoolId,
    required this.timetableId,
    required this.academicYearId,
    required this.termId,
    required this.classId,
    this.streamId = '',
    required this.day,
    required this.slotKey,
    required this.startTime,
    required this.endTime,
    required this.subjectId,
    required this.teacherId,
    this.roomId = '',
    this.notes = '',
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        schoolId,
        timetableId,
        academicYearId,
        termId,
        classId,
        streamId,
        day,
        slotKey,
        startTime,
        endTime,
        subjectId,
        teacherId,
        roomId,
        notes,
        isActive,
      ];
}
