import 'package:equatable/equatable.dart';

class CurriculumAssignment extends Equatable {
  final String id;
  final String schoolId;
  final String academicYearId;
  final String levelId;
  final String classId;
  final String streamId;
  final String subjectId;
  final bool isCompulsory;
  final int periodsPerWeek;
  final int displayOrder;
  final bool isActive;

  const CurriculumAssignment({
    required this.id,
    this.schoolId = '',
    required this.academicYearId,
    required this.levelId,
    required this.classId,
    this.streamId = '',
    required this.subjectId,
    this.isCompulsory = true,
    this.periodsPerWeek = 0,
    this.displayOrder = 0,
    this.isActive = true,
  });

  CurriculumAssignment copyWith({
    String? id,
    String? schoolId,
    String? academicYearId,
    String? levelId,
    String? classId,
    String? streamId,
    String? subjectId,
    bool? isCompulsory,
    int? periodsPerWeek,
    int? displayOrder,
    bool? isActive,
  }) {
    return CurriculumAssignment(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      academicYearId: academicYearId ?? this.academicYearId,
      levelId: levelId ?? this.levelId,
      classId: classId ?? this.classId,
      streamId: streamId ?? this.streamId,
      subjectId: subjectId ?? this.subjectId,
      isCompulsory: isCompulsory ?? this.isCompulsory,
      periodsPerWeek: periodsPerWeek ?? this.periodsPerWeek,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    academicYearId,
    levelId,
    classId,
    streamId,
    subjectId,
    isCompulsory,
    periodsPerWeek,
    displayOrder,
    isActive,
  ];
}
