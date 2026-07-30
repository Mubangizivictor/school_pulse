import 'package:equatable/equatable.dart';

/// A tier of education a school offers (Kindergarten, Primary, Secondary,
/// Vocational, University, or any custom tier a school defines). Nothing
/// academic is hardcoded elsewhere in the app - every Class belongs to one
/// of these, defined per-school by the admin.
class EducationalLevel extends Equatable {
  final String id;
  final String name;
  final String code;
  final int order;
  final String description;
  final bool isActive;

  const EducationalLevel({
    required this.id,
    required this.name,
    this.code = '',
    this.order = 0,
    this.description = '',
    this.isActive = true,
  });

  EducationalLevel copyWith({
    String? id,
    String? name,
    String? code,
    int? order,
    String? description,
    bool? isActive,
  }) {
    return EducationalLevel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      order: order ?? this.order,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, code, order, description, isActive];
}

/// A school year (e.g. "2026"). Multiple years can exist at once - past
/// (archived), current, and future/planned - unlike the single
/// current-term field on SystemConfig.
class AcademicYear extends Equatable {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCurrent;
  final bool isArchived;

  const AcademicYear({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isCurrent = false,
    this.isArchived = false,
  });

  AcademicYear copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    bool? isArchived,
  }) {
    return AcademicYear(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => [id, name, startDate, endDate, isCurrent, isArchived];
}

/// A term/semester/quarter within an academic year. The school decides the
/// system (Term 1-3, Semester 1-2, Quarter 1-4, ...) - nothing is assumed.
class AcademicTerm extends Equatable {
  final String id;
  final String academicYearId;
  final String name;
  final int order;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCurrent;

  const AcademicTerm({
    required this.id,
    required this.academicYearId,
    required this.name,
    this.order = 0,
    required this.startDate,
    required this.endDate,
    this.isCurrent = false,
  });

  AcademicTerm copyWith({
    String? id,
    String? academicYearId,
    String? name,
    int? order,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
  }) {
    return AcademicTerm(
      id: id ?? this.id,
      academicYearId: academicYearId ?? this.academicYearId,
      name: name ?? this.name,
      order: order ?? this.order,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  @override
  List<Object?> get props => [id, academicYearId, name, order, startDate, endDate, isCurrent];
}

/// A class/grade (P1, S1, Baby Class, Year 8, Grade 12, Level 300, ...).
/// Belongs to an EducationalLevel; nothing about naming is assumed.
class SchoolClass extends Equatable {
  final String id;
  final String name;
  final String code;
  final String levelId;
  final int capacity;
  final String description;
  final bool isActive;

  const SchoolClass({
    required this.id,
    required this.name,
    this.code = '',
    this.levelId = '',
    this.capacity = 0,
    this.description = '',
    this.isActive = true,
  });

  SchoolClass copyWith({
    String? id,
    String? name,
    String? code,
    String? levelId,
    int? capacity,
    String? description,
    bool? isActive,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      levelId: levelId ?? this.levelId,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, code, levelId, capacity, description, isActive];
}

/// A stream/section within a class (East, West, A, B, Blue, ...). Named
/// ClassStream, not Stream, to avoid colliding with dart:async's Stream.
class ClassStream extends Equatable {
  final String id;
  final String name;
  final String code;
  final String classId;
  final int capacity;
  final bool isActive;

  const ClassStream({
    required this.id,
    required this.name,
    this.code = '',
    required this.classId,
    this.capacity = 0,
    this.isActive = true,
  });

  ClassStream copyWith({
    String? id,
    String? name,
    String? code,
    String? classId,
    int? capacity,
    bool? isActive,
  }) {
    return ClassStream(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      classId: classId ?? this.classId,
      capacity: capacity ?? this.capacity,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, code, classId, capacity, isActive];
}

/// A subject, assignable to any set of levels/classes. No subject list is
/// hardcoded anywhere else in the app.
class Subject extends Equatable {
  final String id;
  final String name;
  final String code;
  final String departmentId;
  final String color;
  final String description;
  final bool isElective;
  final bool isPractical;
  final int creditUnits;
  final bool isActive;
  final List<String> assignedLevelIds;
  final List<String> assignedClassIds;

  const Subject({
    required this.id,
    required this.name,
    this.code = '',
    this.departmentId = '',
    this.color = '',
    this.description = '',
    this.isElective = false,
    this.isPractical = false,
    this.creditUnits = 0,
    this.isActive = true,
    this.assignedLevelIds = const [],
    this.assignedClassIds = const [],
  });

  Subject copyWith({
    String? id,
    String? name,
    String? code,
    String? departmentId,
    String? color,
    String? description,
    bool? isElective,
    bool? isPractical,
    int? creditUnits,
    bool? isActive,
    List<String>? assignedLevelIds,
    List<String>? assignedClassIds,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      departmentId: departmentId ?? this.departmentId,
      color: color ?? this.color,
      description: description ?? this.description,
      isElective: isElective ?? this.isElective,
      isPractical: isPractical ?? this.isPractical,
      creditUnits: creditUnits ?? this.creditUnits,
      isActive: isActive ?? this.isActive,
      assignedLevelIds: assignedLevelIds ?? this.assignedLevelIds,
      assignedClassIds: assignedClassIds ?? this.assignedClassIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        departmentId,
        color,
        description,
        isElective,
        isPractical,
        creditUnits,
        isActive,
        assignedLevelIds,
        assignedClassIds,
      ];
}

/// A staff department (Science, ICT, Administration, Transport, Stores, ...
/// or any custom department a school adds).
class Department extends Equatable {
  final String id;
  final String name;
  final String code;
  final String description;
  final String headOfDepartmentStaffId;
  final bool isActive;

  const Department({
    required this.id,
    required this.name,
    this.code = '',
    this.description = '',
    this.headOfDepartmentStaffId = '',
    this.isActive = true,
  });

  Department copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? headOfDepartmentStaffId,
    bool? isActive,
  }) {
    return Department(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      headOfDepartmentStaffId: headOfDepartmentStaffId ?? this.headOfDepartmentStaffId,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, code, description, headOfDepartmentStaffId, isActive];
}

/// A job title a staff member can hold (Principal, Bursar, Librarian,
/// Driver, ...). Distinct from the app's fixed permission-bearing
/// UserRole enum (lib/core/user_roles.dart) - this is admin-editable
/// descriptive metadata, not wired into auth/permissions.
class StaffDesignation extends Equatable {
  final String id;
  final String name;
  final String description;
  final bool isActive;

  const StaffDesignation({
    required this.id,
    required this.name,
    this.description = '',
    this.isActive = true,
  });

  StaffDesignation copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
  }) {
    return StaffDesignation(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, description, isActive];
}

/// A functional role a staff member performs (Class Teacher, Exam Officer,
/// Discipline Teacher, ...), separate from their Designation. A "Teacher"
/// designation might hold several such roles at once.
class StaffRole extends Equatable {
  final String id;
  final String name;
  final String designationId;
  final String description;
  final bool isActive;

  const StaffRole({
    required this.id,
    required this.name,
    this.designationId = '',
    this.description = '',
    this.isActive = true,
  });

  StaffRole copyWith({
    String? id,
    String? name,
    String? designationId,
    String? description,
    bool? isActive,
  }) {
    return StaffRole(
      id: id ?? this.id,
      name: name ?? this.name,
      designationId: designationId ?? this.designationId,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, designationId, description, isActive];
}
