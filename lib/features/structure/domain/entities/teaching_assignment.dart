import 'package:equatable/equatable.dart';

enum TeachingResponsibilityType {
  subjectTeacher,
  classTeacher,
  headOfDepartment,
}

class TeachingAssignment extends Equatable {
  final String id;
  final String schoolId;
  final String staffId;
  final String academicYearId;
  final TeachingResponsibilityType responsibilityType;
  final String departmentId;
  final String classId;
  final String streamId;
  final String subjectId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isPrimary;
  final bool isActive;

  const TeachingAssignment({
    required this.id,
    this.schoolId = '',
    required this.staffId,
    required this.academicYearId,
    this.responsibilityType = TeachingResponsibilityType.subjectTeacher,
    this.departmentId = '',
    this.classId = '',
    this.streamId = '',
    this.subjectId = '',
    this.startDate,
    this.endDate,
    this.isPrimary = false,
    this.isActive = true,
  });

  TeachingAssignment copyWith({
    String? id,
    String? schoolId,
    String? staffId,
    String? academicYearId,
    TeachingResponsibilityType? responsibilityType,
    String? departmentId,
    String? classId,
    String? streamId,
    String? subjectId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isPrimary,
    bool? isActive,
  }) {
    return TeachingAssignment(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      staffId: staffId ?? this.staffId,
      academicYearId: academicYearId ?? this.academicYearId,
      responsibilityType: responsibilityType ?? this.responsibilityType,
      departmentId: departmentId ?? this.departmentId,
      classId: classId ?? this.classId,
      streamId: streamId ?? this.streamId,
      subjectId: subjectId ?? this.subjectId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        schoolId,
        staffId,
        academicYearId,
        responsibilityType,
        departmentId,
        classId,
        streamId,
        subjectId,
        startDate,
        endDate,
        isPrimary,
        isActive,
      ];
}
