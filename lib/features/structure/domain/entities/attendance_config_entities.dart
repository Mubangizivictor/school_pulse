import 'package:equatable/equatable.dart';

/// An attendance status option (Present, Absent, Late, Excused, ...).
class AttendanceTypeDef extends Equatable {
  final String id;
  final String name;
  final String colorHex;
  final bool isActive;

  const AttendanceTypeDef({
    required this.id,
    required this.name,
    this.colorHex = '',
    this.isActive = true,
  });

  AttendanceTypeDef copyWith({
    String? id,
    String? name,
    String? colorHex,
    bool? isActive,
  }) {
    return AttendanceTypeDef(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, colorHex, isActive];
}

/// An attendance-taking session (Morning, Afternoon, Lesson, Gate, ...).
class AttendanceSessionDef extends Equatable {
  final String id;
  final String name;
  final bool isActive;

  const AttendanceSessionDef({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  AttendanceSessionDef copyWith({
    String? id,
    String? name,
    bool? isActive,
  }) {
    return AttendanceSessionDef(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, isActive];
}
