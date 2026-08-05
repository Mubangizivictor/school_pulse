import 'package:equatable/equatable.dart';

/// An attendance status option (Present, Absent, Late, Excused, ...).
class AttendanceTypeDef extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String colorHex;
  final bool isActive;

  const AttendanceTypeDef({
    required this.id,
    required this.schoolId,
    required this.name,
    this.colorHex = '',
    this.isActive = true,
  });

  AttendanceTypeDef copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? colorHex,
    bool? isActive,
  }) {
    return AttendanceTypeDef(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, schoolId, name, colorHex, isActive];
}

/// An attendance-taking session (Morning, Afternoon, Lesson, Gate, ...).
class AttendanceSessionDef extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final bool isActive;

  const AttendanceSessionDef({
    required this.id,
    required this.schoolId,
    required this.name,
    this.isActive = true,
  });

  AttendanceSessionDef copyWith({
    String? id,
    String? schoolId,
    String? name,
    bool? isActive,
  }) {
    return AttendanceSessionDef(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, schoolId, name, isActive];
}
