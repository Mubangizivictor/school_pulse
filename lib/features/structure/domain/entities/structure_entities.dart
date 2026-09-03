import 'package:equatable/equatable.dart';

/// A tier of education a school offers (Kindergarten, Primary, Secondary,
/// Vocational, University, or any custom tier a school defines). Nothing
/// academic is hardcoded elsewhere in the app - every Class belongs to one
/// of these, defined per-school by the admin.
class EducationalLevel extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String code;
  final int order;
  final String description;

  final bool isActive;

  const EducationalLevel({
    required this.id,
    required this.schoolId,
    required this.name,
    this.code = '',
    this.order = 0,
    this.description = '',
    this.isActive = true,
  });

  EducationalLevel copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? code,
    int? order,
    String? description,
    bool? isActive,
  }) {
    return EducationalLevel(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      code: code ?? this.code,
      order: order ?? this.order,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    code,
    order,
    description,
    isActive,
  ];
}

/// A school year (e.g. "2026"). Multiple years can exist at once - past
/// (archived), current, and future/planned - unlike the single
/// current-term field on SystemConfig.
class AcademicYear extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final bool isCurrent;
  final bool isArchived;

  const AcademicYear({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.description = '',
    this.isCurrent = false,
    this.isArchived = false,
  });

  AcademicYear copyWith({
    String? id,
    String? schoolId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    bool? isCurrent,
    bool? isArchived,
  }) {
    return AcademicYear(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      isCurrent: isCurrent ?? this.isCurrent,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    startDate,
    endDate,
    description,
    isCurrent,
    isArchived,
  ];
}

/// The calendaring system a school uses to divide an academic year.
/// A school picks whichever fits how it actually runs (three terms, two
/// semesters, four quarters, ...) - nothing is assumed to be terms.
enum AcademicPeriodType { term, semester, quarter, trimester, module, custom }

/// A term/semester/quarter within an academic year. The school decides the
/// system (Term 1-3, Semester 1-2, Quarter 1-4, ...) - nothing is assumed.
///
/// Kept as `AcademicTerm` rather than renamed to `AcademicPeriod` so the
/// repository interface, Isar cache, bloc events, and existing callers
/// (e.g. lib/features/teacher/data/services/academic_calendar_service_impl.dart)
/// don't need to move; `periodType` is what lets this same class represent
/// any of the calendaring systems above.
class AcademicTerm extends Equatable {
  final String id;
  final String schoolId;
  final String academicYearId;
  final String name;
  final int order;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCurrent;
  final AcademicPeriodType periodType;
  final bool isArchived;

  /// True once this term's calendar has been confirmed via the
  /// `confirmAcademicCalendar` Cloud Function callable (billing/
  /// subscription_cycles generation keys off this, at the term level, not
  /// the year level - each term gets its own renewal cycle). Clients cannot
  /// set this directly; firestore.rules blocks it and the callable
  /// re-validates and writes it server-side. Defaults to false so existing
  /// and newly-drafted terms are never silently treated as confirmed.
  final bool isConfirmed;

  const AcademicTerm({
    required this.id,
    required this.schoolId,
    required this.academicYearId,
    required this.name,
    this.order = 0,
    required this.startDate,
    required this.endDate,
    this.isCurrent = false,
    this.periodType = AcademicPeriodType.term,
    this.isArchived = false,
    this.isConfirmed = false,
  });

  AcademicTerm copyWith({
    String? id,
    String? schoolId,
    String? academicYearId,
    String? name,
    int? order,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    AcademicPeriodType? periodType,
    bool? isArchived,
    bool? isConfirmed,
  }) {
    return AcademicTerm(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      academicYearId: academicYearId ?? this.academicYearId,
      name: name ?? this.name,
      order: order ?? this.order,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      periodType: periodType ?? this.periodType,
      isArchived: isArchived ?? this.isArchived,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    academicYearId,
    name,
    order,
    startDate,
    endDate,
    isCurrent,
    periodType,
    isArchived,
    isConfirmed,
  ];
}

/// A class/grade (P1, S1, Baby Class, Year 8, Grade 12, Level 300, ...).
/// Belongs to an EducationalLevel; nothing about naming is assumed.
class SchoolClass extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String code;
  final String levelId;

  /// Display order within [levelId]. Zero is retained for legacy documents.
  final int order;
  final int capacity;
  final String description;
  final bool isActive;

  const SchoolClass({
    required this.id,
    required this.schoolId,
    required this.name,
    this.code = '',
    this.levelId = '',
    this.order = 0,
    this.capacity = 0,
    this.description = '',
    this.isActive = true,
  });

  SchoolClass copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? code,
    String? levelId,
    int? order,
    int? capacity,
    String? description,
    bool? isActive,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      code: code ?? this.code,
      levelId: levelId ?? this.levelId,
      order: order ?? this.order,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    code,
    levelId,
    order,
    capacity,
    description,
    isActive,
  ];
}

/// A stream/section within a class (East, West, A, B, Blue, ...). Named
/// ClassStream, not Stream, to avoid colliding with dart:async's Stream.
class ClassStream extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String code;
  final String classId;
  final int capacity;
  final bool isActive;

  const ClassStream({
    required this.id,
    required this.schoolId,
    required this.name,
    this.code = '',
    required this.classId,
    this.capacity = 0,
    this.isActive = true,
  });

  ClassStream copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? code,
    String? classId,
    int? capacity,
    bool? isActive,
  }) {
    return ClassStream(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      code: code ?? this.code,
      classId: classId ?? this.classId,
      capacity: capacity ?? this.capacity,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    code,
    classId,
    capacity,
    isActive,
  ];
}

/// A subject, assignable to any set of levels/classes. No subject list is
/// hardcoded anywhere else in the app.
class Subject extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String code;
  final String departmentId;
  final String color;
  final String description;

  /// School-configured category, retained with [isElective] for compatibility
  /// with consumers that still use the older boolean.
  final String subjectType;
  final bool isElective;
  final bool isPractical;
  final int creditUnits;
  final bool isActive;
  final List<String> assignedLevelIds;
  final List<String> assignedClassIds;

  const Subject({
    required this.id,
    required this.schoolId,
    required this.name,
    this.code = '',
    this.departmentId = '',
    this.color = '',
    this.description = '',
    this.subjectType = 'Core',
    this.isElective = false,
    this.isPractical = false,
    this.creditUnits = 0,
    this.isActive = true,
    this.assignedLevelIds = const [],
    this.assignedClassIds = const [],
  });

  Subject copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? code,
    String? departmentId,
    String? color,
    String? description,
    String? subjectType,
    bool? isElective,
    bool? isPractical,
    int? creditUnits,
    bool? isActive,
    List<String>? assignedLevelIds,
    List<String>? assignedClassIds,
  }) {
    return Subject(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      code: code ?? this.code,
      departmentId: departmentId ?? this.departmentId,
      color: color ?? this.color,
      description: description ?? this.description,
      subjectType: subjectType ?? this.subjectType,
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
    schoolId,
    name,
    code,
    departmentId,
    color,
    description,
    subjectType,
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
  final String schoolId;
  final String name;
  final String code;
  final String description;
  final String headOfDepartmentStaffId;
  final int displayOrder;
  final bool isActive;

  const Department({
    required this.id,
    required this.schoolId,
    required this.name,
    this.code = '',
    this.description = '',
    this.headOfDepartmentStaffId = '',
    this.displayOrder = 0,
    this.isActive = true,
  });

  Department copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? code,
    String? description,
    String? headOfDepartmentStaffId,
    int? displayOrder,
    bool? isActive,
  }) {
    return Department(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      headOfDepartmentStaffId:
          headOfDepartmentStaffId ?? this.headOfDepartmentStaffId,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    code,
    description,
    headOfDepartmentStaffId,
    displayOrder,
    isActive,
  ];
}

/// A school-owned role definition.  It describes a responsibility, not a
/// person: people receive one or more `StaffRoleAssignment` rows elsewhere.
/// It deliberately remains distinct from the fixed, permission-bearing
/// `UserRole` enum; category and label never grant access on their own.
/// [permissions] is the tenant-configurable permission set this role grants
/// through `EffectiveAccessResolver`/`PermissionEvaluator` — every id in it
/// must exist in `Permission.all`; unknown ids are simply never checked for
/// by any `can()` call, so they grant nothing even if written directly.
class StaffDesignation extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String code;
  final String category;
  final String description;
  final int displayOrder;
  final bool isActive;
  final String scopeType;
  final String roleNature;
  final bool requiresScope;
  final bool allowMultipleStaff;
  final bool allowConcurrentAssignments;
  final bool allowTemporaryAssignments;
  final bool isSystemPreset;
  final bool isArchived;
  final String iconName;
  final String colorHex;
  final Set<String> permissions;

  const StaffDesignation({
    required this.id,
    required this.schoolId,
    required this.name,
    this.code = '',
    this.category = '',
    this.description = '',
    this.displayOrder = 0,
    this.isActive = true,
    this.scopeType = 'wholeSchool',
    this.roleNature = 'Standard',
    this.requiresScope = false,
    this.allowMultipleStaff = true,
    this.allowConcurrentAssignments = true,
    this.allowTemporaryAssignments = true,
    this.isSystemPreset = false,
    this.isArchived = false,
    this.iconName = 'badge_outlined',
    this.colorHex = '#6366F1',
    this.permissions = const {},
  });

  StaffDesignation copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? code,
    String? category,
    String? description,
    int? displayOrder,
    bool? isActive,
    String? scopeType,
    String? roleNature,
    bool? requiresScope,
    bool? allowMultipleStaff,
    bool? allowConcurrentAssignments,
    bool? allowTemporaryAssignments,
    bool? isSystemPreset,
    bool? isArchived,
    String? iconName,
    String? colorHex,
    Set<String>? permissions,
  }) {
    return StaffDesignation(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      code: code ?? this.code,
      category: category ?? this.category,
      description: description ?? this.description,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      scopeType: scopeType ?? this.scopeType,
      roleNature: roleNature ?? this.roleNature,
      requiresScope: requiresScope ?? this.requiresScope,
      allowMultipleStaff: allowMultipleStaff ?? this.allowMultipleStaff,
      allowConcurrentAssignments:
          allowConcurrentAssignments ?? this.allowConcurrentAssignments,
      allowTemporaryAssignments:
          allowTemporaryAssignments ?? this.allowTemporaryAssignments,
      isSystemPreset: isSystemPreset ?? this.isSystemPreset,
      isArchived: isArchived ?? this.isArchived,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    code,
    category,
    description,
    displayOrder,
    isActive,
    scopeType,
    roleNature,
    requiresScope,
    allowMultipleStaff,
    allowConcurrentAssignments,
    allowTemporaryAssignments,
    isSystemPreset,
    isArchived,
    iconName,
    colorHex,
    permissions,
  ];
}

/// Alias so new code can read naturally as `RoleDefinition` — this IS the
/// role definition entity; there is deliberately no separate type.
typedef RoleDefinition = StaffDesignation;
