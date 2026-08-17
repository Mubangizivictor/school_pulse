import '../entities/structure_entities.dart';

/// Pure business-rule validation used before Structure writes.
///
/// Keeping these checks outside widgets makes the critical invariants easy to
/// test and reusable by future repository/server enforcement.
class StructureIntegrityValidator {
  const StructureIntegrityValidator();

  String? validateLevel(
    EducationalLevel candidate,
    List<EducationalLevel> levels,
  ) {
    if (candidate.name.trim().isEmpty) return 'Enter a level name.';
    if (levels.any(
      (level) => level.id != candidate.id &&
          level.isActive &&
          candidate.isActive &&
          level.name.trim().toLowerCase() == candidate.name.trim().toLowerCase(),
    )) {
      return 'An active level with this name already exists.';
    }
    final code = candidate.code.trim().toLowerCase();
    if (code.isNotEmpty &&
        levels.any(
          (level) => level.id != candidate.id &&
              level.isActive &&
              candidate.isActive &&
              level.code.trim().toLowerCase() == code,
        )) {
      return 'This level code is already in use.';
    }
    return null;
  }

  String? validateAcademicYear(
    AcademicYear candidate,
    List<AcademicYear> years,
  ) {
    if (candidate.name.trim().isEmpty) return 'Enter an academic year name.';
    if (!candidate.startDate.isBefore(candidate.endDate)) {
      return 'Academic year end date must be after the start date.';
    }
    if (years.any(
      (year) => year.id != candidate.id &&
          year.name.trim().toLowerCase() == candidate.name.trim().toLowerCase(),
    )) {
      return 'An academic year with this name already exists.';
    }
    return null;
  }

  String? validateAcademicTerm(
    AcademicTerm candidate,
    List<AcademicYear> years,
    List<AcademicTerm> terms,
  ) {
    final matchingYears = years.where((year) => year.id == candidate.academicYearId);
    if (matchingYears.isEmpty) return 'Select a valid academic year.';
    final year = matchingYears.first;
    if (!candidate.startDate.isBefore(candidate.endDate)) {
      return 'Term end date must be after the start date.';
    }
    if (candidate.startDate.isBefore(year.startDate) ||
        candidate.endDate.isAfter(year.endDate)) {
      return '${candidate.name} must fall inside ${year.name}.';
    }
    if (terms.any((other) {
      if (other.id == candidate.id ||
          other.academicYearId != candidate.academicYearId) {
        return false;
      }
      return !candidate.endDate.isBefore(other.startDate) &&
          !candidate.startDate.isAfter(other.endDate);
    })) {
      return 'This academic period overlaps another period in ${year.name}.';
    }
    if (terms.any(
      (other) => other.id != candidate.id &&
          other.academicYearId == candidate.academicYearId &&
          other.name.trim().toLowerCase() == candidate.name.trim().toLowerCase(),
    )) {
      return 'A period with this name already exists in ${year.name}.';
    }
    return null;
  }

  String? validateClass(
    SchoolClass candidate, {
    required List<EducationalLevel> levels,
    required List<SchoolClass> classes,
    required List<ClassStream> streams,
  }) {
    if (candidate.name.trim().isEmpty) return 'Enter a class name.';
    if (!levels.any((level) => level.id == candidate.levelId && level.isActive)) {
      return 'Select an active educational level.';
    }
    if (candidate.capacity < 0) return 'Class capacity cannot be negative.';
    if (classes.any(
      (item) => item.id != candidate.id &&
          item.isActive &&
          candidate.isActive &&
          item.levelId == candidate.levelId &&
          item.name.trim().toLowerCase() == candidate.name.trim().toLowerCase(),
    )) {
      return 'This class already exists under the selected level.';
    }
    final code = candidate.code.trim().toLowerCase();
    if (code.isNotEmpty &&
        classes.any(
          (item) => item.id != candidate.id &&
              item.isActive &&
              candidate.isActive &&
              item.code.trim().toLowerCase() == code,
        )) {
      return 'This class code is already in use.';
    }

    final allocated = streams
        .where((stream) => stream.classId == candidate.id && stream.isActive)
        .fold<int>(0, (sum, stream) => sum + stream.capacity);
    if (allocated > 0 && candidate.capacity <= 0) {
      return 'This class already has $allocated stream places. Set a class capacity of at least $allocated.';
    }
    if (candidate.capacity > 0 && allocated > candidate.capacity) {
      return 'Class capacity cannot be reduced to ${candidate.capacity}; active streams already allocate $allocated places.';
    }
    return null;
  }

  String? validateStream(
    ClassStream candidate, {
    required List<SchoolClass> classes,
    required List<ClassStream> streams,
  }) {
    if (candidate.name.trim().isEmpty) return 'Enter a stream name.';
    final parents = classes.where(
      (item) => item.id == candidate.classId && item.isActive,
    );
    if (parents.isEmpty) return 'Select an active parent class.';
    final parent = parents.first;
    if (candidate.capacity <= 0 && candidate.isActive) {
      return 'Enter a stream capacity greater than zero.';
    }
    if (parent.capacity <= 0 && candidate.isActive) {
      return 'Set ${parent.name} capacity before adding active streams.';
    }
    if (streams.any(
      (stream) => stream.id != candidate.id &&
          stream.classId == candidate.classId &&
          stream.isActive &&
          candidate.isActive &&
          stream.name.trim().toLowerCase() == candidate.name.trim().toLowerCase(),
    )) {
      return 'This stream name is already used in ${parent.name}.';
    }
    final code = candidate.code.trim().toLowerCase();
    if (code.isNotEmpty &&
        streams.any(
          (stream) => stream.id != candidate.id &&
              stream.classId == candidate.classId &&
              stream.isActive &&
              candidate.isActive &&
              stream.code.trim().toLowerCase() == code,
        )) {
      return 'This stream code is already used in ${parent.name}.';
    }

    final allocated = streams
        .where((stream) =>
            stream.id != candidate.id &&
            stream.classId == candidate.classId &&
            stream.isActive)
        .fold<int>(0, (sum, stream) => sum + stream.capacity);
    final proposedTotal = allocated + (candidate.isActive ? candidate.capacity : 0);
    if (proposedTotal > parent.capacity) {
      final available = (parent.capacity - allocated).clamp(0, parent.capacity);
      return 'Stream capacity exceeds ${parent.name} capacity. '
          'Class capacity: ${parent.capacity}, already allocated: $allocated, available: $available.';
    }
    return null;
  }

  String? validateSubject(
    Subject candidate, {
    required List<Subject> subjects,
    required List<Department> departments,
  }) {
    if (candidate.name.trim().isEmpty) return 'Enter a subject name.';
    final code = candidate.code.trim().toLowerCase();
    if (code.isNotEmpty &&
        subjects.any(
          (subject) => subject.id != candidate.id &&
              subject.isActive &&
              candidate.isActive &&
              subject.code.trim().toLowerCase() == code,
        )) {
      return 'This subject code is already in use.';
    }
    if (candidate.departmentId.isNotEmpty &&
        !departments.any(
          (department) =>
              department.id == candidate.departmentId && department.isActive,
        )) {
      return 'Select an active department or leave Department empty.';
    }
    return null;
  }

  String? validateDepartment(
    Department candidate,
    List<Department> departments,
  ) {
    if (candidate.name.trim().isEmpty) return 'Enter a department name.';
    if (departments.any(
      (department) => department.id != candidate.id &&
          department.isActive &&
          candidate.isActive &&
          department.name.trim().toLowerCase() == candidate.name.trim().toLowerCase(),
    )) {
      return 'An active department with this name already exists.';
    }
    final code = candidate.code.trim().toLowerCase();
    if (code.isNotEmpty &&
        departments.any(
          (department) => department.id != candidate.id &&
              department.isActive &&
              candidate.isActive &&
              department.code.trim().toLowerCase() == code,
        )) {
      return 'This department code is already in use.';
    }
    return null;
  }

  String? validateDesignation(
    StaffDesignation candidate,
    List<StaffDesignation> designations,
  ) {
    if (candidate.name.trim().isEmpty) return 'Enter a designation name.';
    if (designations.any(
      (designation) => designation.id != candidate.id &&
          designation.isActive &&
          candidate.isActive &&
          designation.name.trim().toLowerCase() == candidate.name.trim().toLowerCase(),
    )) {
      return 'An active designation with this name already exists.';
    }
    return null;
  }

  String? validateRole(
    StaffRole candidate, {
    required List<StaffRole> roles,
    required List<StaffDesignation> designations,
  }) {
    if (candidate.name.trim().isEmpty) return 'Enter a role name.';
    if (roles.any(
      (role) => role.id != candidate.id &&
          role.isActive &&
          candidate.isActive &&
          role.name.trim().toLowerCase() == candidate.name.trim().toLowerCase(),
    )) {
      return 'An active role with this name already exists.';
    }
    if (candidate.designationId.isNotEmpty &&
        !designations.any(
          (designation) =>
              designation.id == candidate.designationId && designation.isActive,
        )) {
      return 'Select an active designation or leave the designation unassigned.';
    }
    return null;
  }
}
