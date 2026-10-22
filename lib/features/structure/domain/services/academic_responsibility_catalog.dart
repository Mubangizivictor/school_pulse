import '../entities/structure_entities.dart';
import '../entities/teaching_assignment.dart';

/// The academic-duty catalogue is deliberately separate from app access
/// roles. A school only sees entries for active, configured designations that
/// match this catalogue, so a future policy/configuration UI can change what
/// is offered without changing the assignment flow.
enum AcademicResponsibilityGroup {
  teaching('Teaching'),
  leadership('Academic leadership'),
  assessmentTimetable('Assessment & timetable');

  const AcademicResponsibilityGroup(this.label);
  final String label;
}

class AcademicResponsibilityDefinition {
  const AcademicResponsibilityDefinition({
    required this.type,
    required this.title,
    required this.group,
    required this.designation,
    required this.needsClass,
    required this.needsSubject,
    required this.needsDepartment,
  });

  final TeachingResponsibilityType type;
  final String title;
  final AcademicResponsibilityGroup group;
  final StaffDesignation designation;
  final bool needsClass;
  final bool needsSubject;
  final bool needsDepartment;

  bool get isInstitutionWide =>
      !needsClass && !needsSubject && !needsDepartment;

  String get scopeHint => needsSubject
      ? 'Class, stream if applicable, and subject'
      : needsDepartment
      ? 'Department'
      : needsClass
      ? 'Class and stream if applicable'
      : 'Institution-wide';
}

/// Resolves only responsibilities which the institution configured as active
/// staff designations. This is intentionally not a final, hard-coded policy.
List<AcademicResponsibilityDefinition> configuredAcademicResponsibilities(
  List<StaffDesignation> designations,
) {
  final result = <AcademicResponsibilityDefinition>[];
  for (final designation in designations.where(
    (item) => item.isActive && !item.isArchived,
  )) {
    final key = '${designation.name}${designation.code}'
        .toLowerCase()
        .replaceAll(RegExp('[^a-z]'), '');
    for (final entry in _catalog.entries) {
      if (entry.value.aliases.any(key.contains)) {
        final meta = entry.value;
        result.add(
          AcademicResponsibilityDefinition(
            type: entry.key,
            title: meta.title,
            group: meta.group,
            designation: designation,
            needsClass: meta.needsClass,
            needsSubject: meta.needsSubject,
            needsDepartment: meta.needsDepartment,
          ),
        );
      }
    }
  }
  result.sort((a, b) => a.title.compareTo(b.title));
  return result;
}

AcademicResponsibilityGroup academicResponsibilityGroup(
  TeachingResponsibilityType type,
) => _catalog[type]!.group;

String academicResponsibilityLabel(TeachingResponsibilityType type) =>
    _catalog[type]!.title;

class _CatalogEntry {
  const _CatalogEntry(
    this.title,
    this.group,
    this.needsClass,
    this.needsSubject,
    this.needsDepartment,
    this.aliases,
  );
  final String title;
  final AcademicResponsibilityGroup group;
  final bool needsClass;
  final bool needsSubject;
  final bool needsDepartment;
  final Set<String> aliases;
}

const _catalog = <TeachingResponsibilityType, _CatalogEntry>{
  TeachingResponsibilityType.subjectTeacher: _CatalogEntry(
    'Subject Teacher',
    AcademicResponsibilityGroup.teaching,
    true,
    true,
    false,
    {'subjectteacher'},
  ),
  TeachingResponsibilityType.classTeacher: _CatalogEntry(
    'Class Teacher',
    AcademicResponsibilityGroup.teaching,
    true,
    false,
    false,
    {'classteacher'},
  ),
  TeachingResponsibilityType.streamTeacher: _CatalogEntry(
    'Stream Teacher',
    AcademicResponsibilityGroup.teaching,
    true,
    false,
    false,
    {'streamteacher'},
  ),
  TeachingResponsibilityType.headOfDepartment: _CatalogEntry(
    'Head of Department',
    AcademicResponsibilityGroup.leadership,
    false,
    false,
    true,
    {'headofdepartment', 'hod'},
  ),
  TeachingResponsibilityType.directorOfStudies: _CatalogEntry(
    'Director of Studies',
    AcademicResponsibilityGroup.leadership,
    false,
    false,
    false,
    {'directorofstudies'},
  ),
  TeachingResponsibilityType.academicCoordinator: _CatalogEntry(
    'Academic Coordinator',
    AcademicResponsibilityGroup.leadership,
    false,
    false,
    false,
    {'academiccoordinator'},
  ),
  TeachingResponsibilityType.examinationsOfficer: _CatalogEntry(
    'Examinations Officer',
    AcademicResponsibilityGroup.assessmentTimetable,
    false,
    false,
    false,
    {'examinationsofficer', 'examsofficer'},
  ),
  TeachingResponsibilityType.timetableCoordinator: _CatalogEntry(
    'Timetable Coordinator',
    AcademicResponsibilityGroup.assessmentTimetable,
    false,
    false,
    false,
    {'timetablecoordinator'},
  ),
  TeachingResponsibilityType.assessmentReportsCoordinator: _CatalogEntry(
    'Assessment & Reports Coordinator',
    AcademicResponsibilityGroup.assessmentTimetable,
    false,
    false,
    false,
    {'assessmentreportscoordinator', 'assessmentandreportscoordinator'},
  ),
};
