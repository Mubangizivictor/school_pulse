import 'package:equatable/equatable.dart';

enum TeachingResponsibilityType {
  subjectTeacher,
  classTeacher,
  streamTeacher,
  headOfDepartment,
  directorOfStudies,
  academicCoordinator,
  examinationsOfficer,
  timetableCoordinator,
  assessmentReportsCoordinator,
}

class TeachingAssignment extends Equatable {
  final String id;
  final String schoolId;
  final String staffId;
  final String academicYearId;
  final String academicTermId;
  final String designationId;
  final TeachingResponsibilityType responsibilityType;
  final String departmentId;
  final String classId;
  final String streamId;
  final String subjectId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isPrimary;
  final bool isActive;
  final DateTime? createdAt;
  final String assignedBy;

  const TeachingAssignment({
    required this.id,
    this.schoolId = '',
    required this.staffId,
    required this.academicYearId,
    this.academicTermId = '',
    this.designationId = '',
    this.responsibilityType = TeachingResponsibilityType.subjectTeacher,
    this.departmentId = '',
    this.classId = '',
    this.streamId = '',
    this.subjectId = '',
    this.startDate,
    this.endDate,
    this.isPrimary = false,
    this.isActive = true,
    this.createdAt,
    this.assignedBy = '',
  });

  TeachingAssignment copyWith({
    String? id,
    String? schoolId,
    String? staffId,
    String? academicYearId,
    String? academicTermId,
    String? designationId,
    TeachingResponsibilityType? responsibilityType,
    String? departmentId,
    String? classId,
    String? streamId,
    String? subjectId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isPrimary,
    bool? isActive,
    DateTime? createdAt,
    String? assignedBy,
  }) {
    return TeachingAssignment(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      staffId: staffId ?? this.staffId,
      academicYearId: academicYearId ?? this.academicYearId,
      academicTermId: academicTermId ?? this.academicTermId,
      designationId: designationId ?? this.designationId,
      responsibilityType: responsibilityType ?? this.responsibilityType,
      departmentId: departmentId ?? this.departmentId,
      classId: classId ?? this.classId,
      streamId: streamId ?? this.streamId,
      subjectId: subjectId ?? this.subjectId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      assignedBy: assignedBy ?? this.assignedBy,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    staffId,
    academicYearId,
    academicTermId,
    designationId,
    responsibilityType,
    departmentId,
    classId,
    streamId,
    subjectId,
    startDate,
    endDate,
    isPrimary,
    isActive,
    createdAt,
    assignedBy,
  ];
}
