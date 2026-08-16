import 'package:flutter/material.dart';
import '../../presentation/bloc/structure_state.dart';

/// The single source of truth for Structure Setup.  Completion is derived
/// from tenant-scoped source data, never from a screen visit or a stored flag.
enum SetupStepStatus {
  locked,
  available,
  inProgress,
  completed,
  needsAttention,
  optional,
  notApplicable,
}

class StructureSetupStep {
  const StructureSetupStep({
    required this.id,
    required this.title,
    required this.route,
    required this.complete,
    this.description = '',
    this.hardPrerequisiteIds = const [],
    this.recommendedPrerequisiteIds = const [],
    this.required = true,
    this.applicable,
  });

  final String id, title, route, description;
  final bool Function(StructureState) complete;
  final bool Function(StructureState)? applicable;
  final List<String> hardPrerequisiteIds, recommendedPrerequisiteIds;
  final bool required;
}

class StructureSetupSection {
  const StructureSetupSection({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.steps,
  });
  final String id, title, description;
  final IconData icon;
  final List<StructureSetupStep> steps;
}

class ResolvedSetupStep {
  const ResolvedSetupStep(this.definition, this.status, this.blockedBy);
  final StructureSetupStep definition;
  final SetupStepStatus status;
  final List<String> blockedBy;
  bool get isComplete =>
      status == SetupStepStatus.completed ||
      status == SetupStepStatus.notApplicable;
}

class StructureHealth {
  const StructureHealth(this.sections, this.steps);
  final List<StructureSetupSection> sections;
  final Map<String, ResolvedSetupStep> steps;
  Iterable<ResolvedSetupStep> get applicableRequired => steps.values.where(
    (s) => s.definition.required && s.status != SetupStepStatus.notApplicable,
  );
  int get totalApplicableRequired => applicableRequired.length;
  int get completedRequired => applicableRequired
      .where((s) => s.status == SetupStepStatus.completed)
      .length;
  int get needsAttention => steps.values
      .where((s) => s.status == SetupStepStatus.needsAttention)
      .length;
  int get optional => steps.values
      .where(
        (s) =>
            !s.definition.required && s.status != SetupStepStatus.notApplicable,
      )
      .length;
  int get locked =>
      steps.values.where((s) => s.status == SetupStepStatus.locked).length;
  int get notApplicable => steps.values
      .where((s) => s.status == SetupStepStatus.notApplicable)
      .length;
  int get remaining => totalApplicableRequired - completedRequired;
  double get ratio => totalApplicableRequired == 0
      ? 1
      : completedRequired / totalApplicableRequired;
  int get percentage => (ratio * 100).round();
  ResolvedSetupStep? get next => steps.values
      .where(
        (s) =>
            s.definition.required &&
            (s.status == SetupStepStatus.available ||
                s.status == SetupStepStatus.inProgress ||
                s.status == SetupStepStatus.needsAttention),
      )
      .cast<ResolvedSetupStep?>()
      .firstOrNull;
}

class StructureHealthResolver {
  StructureHealth resolve(StructureState state) {
    final sections = registry;
    final all = sections.expand((s) => s.steps).toList();
    final map = <String, ResolvedSetupStep>{};
    for (final step in all) {
      final applicable = step.applicable?.call(state) ?? true;
      if (!applicable) {
        map[step.id] = ResolvedSetupStep(
          step,
          SetupStepStatus.notApplicable,
          const [],
        );
        continue;
      }
      final blocked = step.hardPrerequisiteIds
          .where((id) => map[id]?.isComplete != true)
          .toList();
      final complete = step.complete(state);
      final invalid = _invalid(step.id, state);
      final status = !step.required && !complete
          ? SetupStepStatus.optional
          : invalid
          ? SetupStepStatus.needsAttention
          : complete
          ? SetupStepStatus.completed
          : blocked.isNotEmpty
          ? SetupStepStatus.locked
          : _hasStarted(step.id, state)
          ? SetupStepStatus.inProgress
          : SetupStepStatus.available;
      map[step.id] = ResolvedSetupStep(step, status, blocked);
    }
    return StructureHealth(sections, map);
  }

  bool _hasStarted(String id, StructureState s) => switch (id) {
    'institution-info' => s.institutionProfile.name.trim().isNotEmpty,
    'academic-years' => s.academicYears.isNotEmpty,
    'levels' => s.levels.isNotEmpty,
    'classes' => s.classes.isNotEmpty,
    'subjects' => s.subjects.isNotEmpty,
    _ => false,
  };

  bool _invalid(String id, StructureState s) => switch (id) {
    'academic-years' =>
      s.academicYears.isNotEmpty &&
          !s.academicYears.any((y) => y.isCurrent && !y.isArchived),
    'classes' => s.classes.any(
      (c) =>
          c.isActive && !s.levels.any((l) => l.id == c.levelId && l.isActive),
    ),
    'streams' => s.streams.any(
      (x) =>
          x.isActive && !s.classes.any((c) => c.id == x.classId && c.isActive),
    ),
    'subjects' => s.subjects.any(
      (x) =>
          x.isActive &&
          x.assignedLevelIds.any(
            (id) => !s.levels.any((l) => l.id == id && l.isActive),
          ),
    ),
    _ => false,
  };

  static bool _activeYear(StructureState s) =>
      s.academicYears.any((y) => y.isCurrent && !y.isArchived);
  static bool _activeLevels(StructureState s) =>
      s.levels.any((x) => x.isActive);
  static bool _activeClasses(StructureState s) =>
      s.classes.any((x) => x.isActive);
  static bool _activeSubjects(StructureState s) => s.subjects.any(
    (x) =>
        x.isActive &&
        (x.assignedLevelIds.isNotEmpty || x.assignedClassIds.isNotEmpty),
  );
  static bool _institution(StructureState s) =>
      s.institutionProfile.name.trim().isNotEmpty &&
      s.institutionProfile.schoolType.trim().isNotEmpty;

  static final registry = <StructureSetupSection>[
    StructureSetupSection(
      id: 'institution',
      title: 'Institution Setup',
      description: 'Set up your school identity and organisational basics.',
      icon: Icons.account_balance_outlined,
      steps: [
        StructureSetupStep(
          id: 'institution-info',
          title: 'School Information',
          description: 'Name and school type',
          route: '/staff/admin/structure/institution',
          complete: _institution,
        ),
        StructureSetupStep(
          id: 'campuses',
          title: 'Campuses',
          route: '/staff/admin/structure/campus',
          complete: (s) => s.campuses.isNotEmpty,
          hardPrerequisiteIds: const ['institution-info'],
        ),
        StructureSetupStep(
          id: 'institution-settings',
          title: 'School Policies & Preferences',
          route: '/staff/admin/structure/institution',
          complete: (s) =>
              s.institutionProfile.timeZone.isNotEmpty &&
              s.institutionProfile.currency.isNotEmpty,
          hardPrerequisiteIds: const ['institution-info'],
        ),
      ],
    ),
    StructureSetupSection(
      id: 'academics',
      title: 'Academic Structure',
      description: 'Build your academic framework and curriculum.',
      icon: Icons.school_outlined,
      steps: [
        StructureSetupStep(
          id: 'academic-years',
          title: 'Academic Years',
          description: 'Create and select the current school year.',
          route: '/staff/admin/structure/academics/years-terms?mode=years',
          complete: _activeYear,
          hardPrerequisiteIds: const ['institution-info'],
        ),
        StructureSetupStep(
          id: 'levels',
          title: 'Academic Levels / Programs',
          description: 'Define the levels or programs your school offers.',
          route: '/staff/admin/structure/academics/levels',
          complete: _activeLevels,
          hardPrerequisiteIds: const ['institution-info'],
        ),
        StructureSetupStep(
          id: 'terms',
          title: 'Terms / Semesters',
          description:
              'Set the terms, semesters or periods for the current year.',
          route: '/staff/admin/structure/academics/years-terms?mode=terms',
          complete: (s) => s.academicTerms.any(
            (term) =>
                !term.isArchived &&
                s.academicYears.any(
                  (year) => year.id == term.academicYearId && !year.isArchived,
                ),
          ),
          hardPrerequisiteIds: const ['academic-years'],
        ),
        StructureSetupStep(
          id: 'academic-units',
          title: 'Academic Units',
          description: 'Organise faculties, sections or teaching units.',
          route: '/staff/admin/structure/academics/departments',
          complete: (s) => s.departments.any((x) => x.isActive),
          hardPrerequisiteIds: const ['institution-info'],
          required: false,
        ),
        StructureSetupStep(
          id: 'classes',
          title: 'Classes / Cohorts',
          description: 'Create the active classes or cohorts for each level.',
          route: '/staff/admin/structure/academics/classes-streams',
          complete: _activeClasses,
          hardPrerequisiteIds: const ['levels'],
        ),
        StructureSetupStep(
          id: 'streams',
          title: 'Streams / Sections',
          description: 'Add streams only where your classes use them.',
          route: '/staff/admin/structure/academics/classes-streams',
          complete: (s) => s.streams.any((x) => x.isActive),
          hardPrerequisiteIds: const ['classes'],
          required: false,
        ),
        StructureSetupStep(
          id: 'departments',
          title: 'Departments',
          description: 'Set up academic and operational departments.',
          route: '/staff/admin/structure/academics/departments',
          complete: (s) => s.departments.any((x) => x.isActive),
          hardPrerequisiteIds: const ['institution-info'],
          required: false,
        ),
        StructureSetupStep(
          id: 'subjects',
          title: 'Subjects / Courses',
          description: 'Create each teachable subject or course.',
          route: '/staff/admin/structure/academics/subjects',
          complete: _activeSubjects,
          hardPrerequisiteIds: const ['levels', 'classes'],
          recommendedPrerequisiteIds: const ['departments'],
        ),
        StructureSetupStep(
          id: 'subject-class-assignments',
          title: 'Subject–Class Assignments',
          description:
              'Assign subjects or courses to their applicable classes.',
          route: '/staff/admin/structure/academics/subject-class-assignments',
          complete: _activeSubjects,
          hardPrerequisiteIds: const ['subjects', 'classes'],
        ),
        StructureSetupStep(
          id: 'teacher-assignments',
          title: 'Staff / Teacher Assignments',
          description:
              'Assign teachers to their subjects, classes and streams.',
          route: '/staff/admin/staff',
          complete: (_) => false,
          hardPrerequisiteIds: const ['subject-class-assignments'],
          required: false,
        ),
        StructureSetupStep(
          id: 'grading',
          title: 'Grading Systems',
          route: '/staff/admin/structure/academics/grading-systems',
          complete: (s) => s.gradingSystems.isNotEmpty,
          hardPrerequisiteIds: const ['academic-years', 'levels', 'classes'],
        ),
        StructureSetupStep(
          id: 'class-timetables',
          title: 'Class Timetables',
          route: '/staff/admin/structure/timetables',
          complete: (_) => false,
          hardPrerequisiteIds: const [
            'academic-years',
            'levels',
            'classes',
            'subjects',
          ],
          required: false,
        ),
      ],
    ),
    StructureSetupSection(
      id: 'people',
      title: 'People & Roles',
      description: 'Manage staff, students and user roles.',
      icon: Icons.groups_outlined,
      steps: [
        StructureSetupStep(
          id: 'roles',
          title: 'Staff Roles & Responsibilities',
          route: '/staff/admin/structure/people?tab=1',
          complete: (s) =>
              s.designations.any((x) => x.isActive && !x.isArchived),
          hardPrerequisiteIds: const ['institution-info'],
        ),
        StructureSetupStep(
          id: 'staff',
          title: 'Staff Management',
          route: '/staff/admin/staff',
          complete: (_) => false,
          hardPrerequisiteIds: const ['roles'],
          required: false,
        ),
        StructureSetupStep(
          id: 'student-structure',
          title: 'Student Enrollment Configuration',
          route: '/staff/admin/students',
          complete: _activeClasses,
          hardPrerequisiteIds: const ['academic-years', 'classes'],
        ),
      ],
    ),
    StructureSetupSection(
      id: 'operations',
      title: 'Operations',
      description: 'Configure daily operations and school workflows.',
      icon: Icons.settings_outlined,
      steps: [
        StructureSetupStep(
          id: 'attendance',
          title: 'Attendance Configuration',
          route: '/staff/admin/structure/attendance-config',
          complete: (s) =>
              s.attendanceTypes.isNotEmpty || s.attendanceSessions.isNotEmpty,
          hardPrerequisiteIds: const ['institution-info'],
        ),
        StructureSetupStep(
          id: 'operations-timetable',
          title: 'Timetable Configuration',
          route: '/staff/admin/structure/timetable-config',
          complete: (s) => s.timetableConfig.slots.isNotEmpty,
          hardPrerequisiteIds: const [
            'academic-years',
            'levels',
            'classes',
            'subjects',
          ],
        ),
      ],
    ),
    StructureSetupSection(
      id: 'campus-life',
      title: 'Campus Life',
      description: 'Manage houses, clubs, transport, hostel and more.',
      icon: Icons.park_outlined,
      steps: [
        StructureSetupStep(
          id: 'houses',
          title: 'Houses',
          route: '/staff/admin/structure/campus?tab=1',
          complete: (s) => s.houses.isNotEmpty,
          required: false,
        ),
        StructureSetupStep(
          id: 'clubs',
          title: 'Clubs & Societies',
          route: '/staff/admin/structure/campus?tab=2',
          complete: (s) => s.clubs.isNotEmpty,
          required: false,
        ),
        StructureSetupStep(
          id: 'boarding',
          title: 'Boarding / Hostel Structure',
          route: '/staff/admin/structure/operations',
          complete: (s) => s.hostels.isNotEmpty,
          applicable: (s) =>
              s.featureToggles.boarding || s.featureToggles.hostel,
        ),
        StructureSetupStep(
          id: 'transport',
          title: 'Transport Structure',
          route: '/staff/admin/structure/operations',
          complete: (s) => s.transportRoutes.isNotEmpty,
          applicable: (s) => s.featureToggles.transport,
        ),
      ],
    ),
    StructureSetupSection(
      id: 'communication',
      title: 'Communication',
      description: 'Set up communication channels and templates.',
      icon: Icons.forum_outlined,
      steps: [
        StructureSetupStep(
          id: 'communication-defaults',
          title: 'Communication Settings',
          route: '/staff/admin/structure/communication-config',
          complete: (s) =>
              s.announcementCategories.isNotEmpty ||
              s.notificationCategories.isNotEmpty ||
              s.messageTemplates.isNotEmpty,
          applicable: (s) => s.featureToggles.communication,
        ),
      ],
    ),
    StructureSetupSection(
      id: 'finance',
      title: 'Finance Setup',
      description: 'Configure fees, payments and financial settings.',
      icon: Icons.account_balance_wallet_outlined,
      steps: [
        StructureSetupStep(
          id: 'fee-categories',
          title: 'Fee Categories',
          route: '/staff/admin/structure/assessment?tab=0',
          complete: (s) => s.feeCategories.isNotEmpty,
          hardPrerequisiteIds: const ['institution-info'],
        ),
      ],
    ),
    StructureSetupSection(
      id: 'security',
      title: 'System & Security',
      description: 'Security settings, permissions and system preferences.',
      icon: Icons.shield_outlined,
      steps: [
        StructureSetupStep(
          id: 'access-policies',
          title: 'User Access Policies',
          route: '/staff/admin/structure/people?tab=1',
          complete: (s) => s.designations.any((x) => x.permissions.isNotEmpty),
          hardPrerequisiteIds: const ['roles'],
        ),
        StructureSetupStep(
          id: 'system-defaults',
          title: 'System Defaults',
          route: '/staff/admin/structure?section=institution',
          complete: (s) =>
              s.institutionProfile.language.isNotEmpty &&
              s.institutionProfile.timeZone.isNotEmpty,
          hardPrerequisiteIds: const ['institution-info'],
        ),
      ],
    ),
  ];
}

extension on Iterable<ResolvedSetupStep?> {
  ResolvedSetupStep? get firstOrNull => isEmpty ? null : first;
}
