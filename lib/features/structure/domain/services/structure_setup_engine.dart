import '../entities/assessment_grading_entities.dart';
import '../entities/attendance_config_entities.dart';
import '../entities/campus_entities.dart';
import '../entities/communication_config_entities.dart';
import '../entities/feature_toggles.dart';
import '../entities/fee_category_entities.dart';
import '../entities/hostel_entities.dart';
import '../entities/institution_profile.dart';
import '../entities/structure_entities.dart';
import '../entities/structure_setup_preferences.dart';
import '../entities/timetable_config.dart';
import '../entities/transport_structure_entities.dart';

enum StructureSetupStepId {
  institution,
  academicYear,
  academicTerms,
  levels,
  departments,
  classes,
  streams,
  subjects,
  assessmentAndGrading,
  learningSpaces,
  schoolDay,
  staffRoles,
  houses,
  clubs,
  boarding,
  transport,
  attendance,
  financeFoundation,
  communication,
  review,
}

enum StructureStepState {
  blocked,
  available,
  complete,
  needsAttention,
  notApplicable,
}

enum StructureIssueSeverity { warning, critical }

class StructureSetupIssue {
  final StructureSetupStepId stepId;
  final String message;
  final StructureIssueSeverity severity;

  const StructureSetupIssue({
    required this.stepId,
    required this.message,
    this.severity = StructureIssueSeverity.critical,
  });
}

class StructureSetupContext {
  final InstitutionProfile institutionProfile;
  final StructureSetupPreferences preferences;
  final FeatureToggles featureToggles;
  final List<AcademicYear> academicYears;
  final List<AcademicTerm> academicTerms;
  final List<EducationalLevel> levels;
  final List<Department> departments;
  final List<SchoolClass> classes;
  final List<ClassStream> streams;
  final List<Subject> subjects;
  final List<AssessmentTypeDef> assessmentTypes;
  final List<GradingSystemDef> gradingSystems;
  final List<GradeBand> gradeBands;
  final List<Facility> facilities;
  final TimetableConfig timetableConfig;
  final List<StaffDesignation> designations;
  final List<StaffRole> staffRoles;
  final List<House> houses;
  final List<Club> clubs;
  final List<Hostel> hostels;
  final List<HostelRoom> hostelRooms;
  final List<TransportRoute> transportRoutes;
  final List<TransportStop> transportStops;
  final List<TransportVehicle> transportVehicles;
  final List<AttendanceTypeDef> attendanceTypes;
  final List<FeeCategory> feeCategories;
  final List<AnnouncementCategoryDef> announcementCategories;
  final List<NotificationCategoryDef> notificationCategories;
  final List<MessageTemplateDef> messageTemplates;

  const StructureSetupContext({
    required this.institutionProfile,
    required this.preferences,
    required this.featureToggles,
    required this.academicYears,
    required this.academicTerms,
    required this.levels,
    required this.departments,
    required this.classes,
    required this.streams,
    required this.subjects,
    required this.assessmentTypes,
    required this.gradingSystems,
    required this.gradeBands,
    required this.facilities,
    required this.timetableConfig,
    required this.designations,
    required this.staffRoles,
    required this.houses,
    required this.clubs,
    required this.hostels,
    required this.hostelRooms,
    required this.transportRoutes,
    required this.transportStops,
    required this.transportVehicles,
    required this.attendanceTypes,
    required this.feeCategories,
    required this.announcementCategories,
    required this.notificationCategories,
    required this.messageTemplates,
  });
}

class StructureSetupStepResult {
  final StructureSetupStepId id;
  final String section;
  final String title;
  final String description;
  final String route;
  final bool required;
  final bool applicable;
  final bool complete;
  final bool prerequisitesComplete;
  final List<StructureSetupStepId> prerequisites;
  final List<StructureSetupIssue> issues;

  const StructureSetupStepResult({
    required this.id,
    required this.section,
    required this.title,
    required this.description,
    required this.route,
    required this.required,
    required this.applicable,
    required this.complete,
    required this.prerequisitesComplete,
    required this.prerequisites,
    required this.issues,
  });

  StructureStepState get state {
    if (!applicable) return StructureStepState.notApplicable;
    if (!prerequisitesComplete) return StructureStepState.blocked;
    if (complete && issues.isEmpty) return StructureStepState.complete;
    if (complete && issues.isNotEmpty) return StructureStepState.needsAttention;
    return StructureStepState.available;
  }

  bool get isSatisfied => !applicable || (complete && issues.isEmpty);
}

class StructureSetupResolution {
  final List<StructureSetupStepResult> steps;
  final List<StructureSetupIssue> issues;

  const StructureSetupResolution({required this.steps, required this.issues});

  List<StructureSetupStepResult> get applicableSteps =>
      steps.where((step) => step.applicable).toList(growable: false);

  List<StructureSetupStepResult> get requiredSteps =>
      steps.where((step) => step.applicable && step.required).toList(growable: false);

  StructureSetupStepResult? get nextStep {
    for (final step in steps) {
      if (!step.applicable || step.id == StructureSetupStepId.review) continue;
      if (step.prerequisitesComplete && !step.isSatisfied) return step;
    }
    final review = steps.where((step) => step.id == StructureSetupStepId.review);
    return review.isEmpty ? null : review.first;
  }

  bool get isReady =>
      requiredSteps.every((step) => step.isSatisfied) &&
      !issues.any((issue) => issue.severity == StructureIssueSeverity.critical);

  double get progress {
    final required = requiredSteps.where((step) => step.id != StructureSetupStepId.review).toList();
    if (required.isEmpty) return 1;
    final done = required.where((step) => step.isSatisfied).length;
    return done / required.length;
  }
}

class StructureSetupEngine {
  const StructureSetupEngine();

  StructureSetupResolution resolve(StructureSetupContext context) {
    final issuesByStep = <StructureSetupStepId, List<StructureSetupIssue>>{};

    void issue(
      StructureSetupStepId stepId,
      String message, {
      StructureIssueSeverity severity = StructureIssueSeverity.critical,
    }) {
      issuesByStep.putIfAbsent(stepId, () => []).add(
            StructureSetupIssue(stepId: stepId, message: message, severity: severity),
          );
    }

    final institutionComplete = _institutionComplete(context.institutionProfile);
    if (!institutionComplete) {
      issue(
        StructureSetupStepId.institution,
        'Complete the school name, type, country, timezone and currency.',
      );
    }

    final currentYears = context.academicYears
        .where((year) => year.isCurrent && !year.isArchived)
        .toList(growable: false);
    final academicYearComplete = currentYears.length == 1 &&
        currentYears.first.startDate.isBefore(currentYears.first.endDate);
    if (currentYears.isEmpty) {
      issue(StructureSetupStepId.academicYear, 'Set one academic year as current.');
    } else if (currentYears.length > 1) {
      issue(StructureSetupStepId.academicYear, 'Only one academic year can be current.');
    } else if (!currentYears.first.startDate.isBefore(currentYears.first.endDate)) {
      issue(StructureSetupStepId.academicYear, 'Academic year end date must be after its start date.');
    }

    final currentYear = currentYears.length == 1 ? currentYears.first : null;
    final termsForCurrentYear = currentYear == null
        ? <AcademicTerm>[]
        : context.academicTerms
            .where((term) => term.academicYearId == currentYear.id)
            .toList(growable: false);
    final termsComplete = currentYear != null &&
        termsForCurrentYear.isNotEmpty &&
        _termsAreValid(termsForCurrentYear, currentYear, issue);

    final activeLevels = context.levels.where((level) => level.isActive).toList();
    final levelsComplete = activeLevels.isNotEmpty &&
        _uniqueNonEmptyCodes(
          activeLevels.map((level) => level.code),
          StructureSetupStepId.levels,
          issue,
          label: 'level',
          allowEmpty: true,
        );
    if (activeLevels.isEmpty) {
      issue(StructureSetupStepId.levels, 'Add at least one active educational level.');
    }

    final departmentsApplicable =
        context.preferences.departments != StructureUseChoice.disabled;
    final departmentsDecided =
        context.preferences.departments != StructureUseChoice.undecided;
    final activeDepartments = context.departments.where((d) => d.isActive).toList();
    var departmentsComplete = !departmentsApplicable;
    if (!departmentsDecided) {
      issue(
        StructureSetupStepId.departments,
        'Choose whether this school uses academic departments.',
      );
      departmentsComplete = false;
    } else if (departmentsApplicable) {
      departmentsComplete = activeDepartments.isNotEmpty;
      if (activeDepartments.isEmpty) {
        issue(StructureSetupStepId.departments, 'Add at least one department or mark departments as not used.');
      }
    }

    final activeLevelIds = activeLevels.map((e) => e.id).toSet();
    final activeClasses = context.classes.where((schoolClass) => schoolClass.isActive).toList();
    var classesComplete = activeClasses.isNotEmpty;
    if (activeClasses.isEmpty) {
      issue(StructureSetupStepId.classes, 'Add at least one active class.');
    }
    for (final schoolClass in activeClasses) {
      if (!activeLevelIds.contains(schoolClass.levelId)) {
        classesComplete = false;
        issue(
          StructureSetupStepId.classes,
          '${schoolClass.name} is linked to a missing or inactive educational level.',
        );
      }
      if (schoolClass.capacity < 0) {
        classesComplete = false;
        issue(StructureSetupStepId.classes, '${schoolClass.name} has an invalid negative capacity.');
      }
    }

    final streamsApplicable = context.preferences.streams != StructureUseChoice.disabled;
    final streamsDecided = context.preferences.streams != StructureUseChoice.undecided;
    final activeStreams = context.streams.where((stream) => stream.isActive).toList();
    var streamsComplete = !streamsApplicable;
    if (!streamsDecided) {
      streamsComplete = false;
      issue(StructureSetupStepId.streams, 'Choose whether this school uses streams or sections.');
    } else if (streamsApplicable) {
      streamsComplete = activeStreams.isNotEmpty;
      if (activeStreams.isEmpty) {
        issue(StructureSetupStepId.streams, 'Add streams/sections or mark them as not used.');
      }
      final classesById = {for (final schoolClass in activeClasses) schoolClass.id: schoolClass};
      final allocatedByClass = <String, int>{};
      final namesByClass = <String, Set<String>>{};
      final codesByClass = <String, Set<String>>{};
      for (final stream in activeStreams) {
        final parent = classesById[stream.classId];
        if (parent == null) {
          streamsComplete = false;
          issue(StructureSetupStepId.streams, '${stream.name} belongs to a missing or inactive class.');
          continue;
        }
        if (stream.capacity < 0) {
          streamsComplete = false;
          issue(StructureSetupStepId.streams, '${stream.name} has an invalid negative capacity.');
        }
        allocatedByClass[stream.classId] =
            (allocatedByClass[stream.classId] ?? 0) + stream.capacity;
        final normalizedName = stream.name.trim().toLowerCase();
        if (!(namesByClass.putIfAbsent(stream.classId, () => <String>{})).add(normalizedName)) {
          streamsComplete = false;
          issue(StructureSetupStepId.streams, '${parent.name} contains duplicate stream name "${stream.name}".');
        }
        final normalizedCode = stream.code.trim().toLowerCase();
        if (normalizedCode.isNotEmpty &&
            !(codesByClass.putIfAbsent(stream.classId, () => <String>{})).add(normalizedCode)) {
          streamsComplete = false;
          issue(StructureSetupStepId.streams, '${parent.name} contains duplicate stream code "${stream.code}".');
        }
      }
      for (final entry in allocatedByClass.entries) {
        final parent = classesById[entry.key];
        if (parent != null && parent.capacity > 0 && entry.value > parent.capacity) {
          streamsComplete = false;
          issue(
            StructureSetupStepId.streams,
            '${parent.name} stream capacity is ${entry.value}, exceeding class capacity ${parent.capacity}.',
          );
        }
      }
    }

    final activeSubjects = context.subjects.where((subject) => subject.isActive).toList();
    var subjectsComplete = activeSubjects.isNotEmpty;
    if (activeSubjects.isEmpty) {
      issue(StructureSetupStepId.subjects, 'Add at least one active subject.');
    }
    final departmentIds = activeDepartments.map((e) => e.id).toSet();
    final classIds = activeClasses.map((e) => e.id).toSet();
    for (final subject in activeSubjects) {
      if (subject.departmentId.isNotEmpty && !departmentIds.contains(subject.departmentId)) {
        subjectsComplete = false;
        issue(StructureSetupStepId.subjects, '${subject.name} references a missing or inactive department.');
      }
      if (subject.assignedLevelIds.any((id) => !activeLevelIds.contains(id))) {
        subjectsComplete = false;
        issue(StructureSetupStepId.subjects, '${subject.name} contains an invalid level assignment.');
      }
      if (subject.assignedClassIds.any((id) => !classIds.contains(id))) {
        subjectsComplete = false;
        issue(StructureSetupStepId.subjects, '${subject.name} contains an invalid class assignment.');
      }
    }

    final activeAssessmentTypes = context.assessmentTypes.where((type) => type.isActive).toList();
    final activeGradingSystems = context.gradingSystems.where((system) => system.isActive).toList();
    var gradingComplete = activeAssessmentTypes.isNotEmpty && activeGradingSystems.isNotEmpty;
    if (activeAssessmentTypes.isEmpty) {
      issue(StructureSetupStepId.assessmentAndGrading, 'Add at least one active assessment type.');
    }
    if (activeGradingSystems.isEmpty) {
      issue(StructureSetupStepId.assessmentAndGrading, 'Add at least one active grading system.');
    }
    for (final system in activeGradingSystems) {
      final bands = context.gradeBands
          .where((band) => band.gradingSystemId == system.id)
          .toList()
        ..sort((a, b) => a.minScore.compareTo(b.minScore));
      if (bands.isEmpty) {
        gradingComplete = false;
        issue(StructureSetupStepId.assessmentAndGrading, '${system.name} has no grade bands.');
        continue;
      }
      for (var i = 0; i < bands.length; i++) {
        final band = bands[i];
        if (band.minScore > band.maxScore) {
          gradingComplete = false;
          issue(StructureSetupStepId.assessmentAndGrading, '${system.name}: ${band.grade} has an invalid score range.');
        }
        if (i > 0 && band.minScore <= bands[i - 1].maxScore) {
          gradingComplete = false;
          issue(StructureSetupStepId.assessmentAndGrading, '${system.name} contains overlapping grade bands.');
          break;
        }
      }
    }

    final roomsApplicable = context.preferences.rooms != StructureUseChoice.disabled;
    final roomsDecided = context.preferences.rooms != StructureUseChoice.undecided;
    final activeFacilities = context.facilities.where((facility) => facility.isActive).toList();
    var roomsComplete = !roomsApplicable;
    if (!roomsDecided) {
      roomsComplete = false;
      issue(StructureSetupStepId.learningSpaces, 'Choose whether this school manages rooms and learning spaces.');
    } else if (roomsApplicable) {
      roomsComplete = activeFacilities.isNotEmpty;
      if (activeFacilities.isEmpty) {
        issue(StructureSetupStepId.learningSpaces, 'Add a learning space or mark room management as not used.');
      }
    }

    final timetableComplete = _timetableIsValid(context.timetableConfig, issue);

    final activeRoles = context.staffRoles.where((role) => role.isActive).toList();
    final staffRolesComplete = activeRoles.isNotEmpty;
    if (!staffRolesComplete) {
      issue(StructureSetupStepId.staffRoles, 'Define at least one active staff responsibility/role.');
    }

    final housesApplicable = context.preferences.houses != StructureUseChoice.disabled;
    final housesDecided = context.preferences.houses != StructureUseChoice.undecided;
    var housesComplete = !housesApplicable;
    if (!housesDecided) {
      housesComplete = false;
      issue(StructureSetupStepId.houses, 'Choose whether this school uses houses.');
    } else if (housesApplicable) {
      housesComplete = context.houses.any((house) => house.isActive);
      if (!housesComplete) issue(StructureSetupStepId.houses, 'Add a house or mark houses as not used.');
    }

    final clubsApplicable = context.preferences.clubs != StructureUseChoice.disabled;
    final clubsDecided = context.preferences.clubs != StructureUseChoice.undecided;
    var clubsComplete = !clubsApplicable;
    if (!clubsDecided) {
      clubsComplete = false;
      issue(StructureSetupStepId.clubs, 'Choose whether clubs and societies are configured now.');
    } else if (clubsApplicable) {
      clubsComplete = context.clubs.any((club) => club.isActive);
      if (!clubsComplete) issue(StructureSetupStepId.clubs, 'Add a club or mark clubs as not used.');
    }

    final boardingApplicable = context.featureToggles.boarding || context.featureToggles.hostel;
    final boardingComplete = !boardingApplicable || context.hostels.any((hostel) => hostel.isActive);
    if (boardingApplicable && !boardingComplete) {
      issue(StructureSetupStepId.boarding, 'Boarding is enabled, but no active hostel/dormitory structure exists.');
    }

    final transportApplicable = context.featureToggles.transport;
    final transportComplete = !transportApplicable ||
        (context.transportRoutes.any((route) => route.isActive) &&
            context.transportVehicles.any((vehicle) => vehicle.isActive));
    if (transportApplicable && !transportComplete) {
      issue(StructureSetupStepId.transport, 'Transport is enabled; configure at least one route and one vehicle.');
    }

    final attendanceComplete = context.attendanceTypes.any((type) => type.isActive);
    if (!attendanceComplete) {
      issue(StructureSetupStepId.attendance, 'Enable at least one attendance method/type.');
    }

    final financeComplete = context.feeCategories.any((category) => category.isActive);
    if (!financeComplete) {
      issue(
        StructureSetupStepId.financeFoundation,
        'Add at least one active fee category for the finance foundation.',
        severity: StructureIssueSeverity.warning,
      );
    }

    final communicationApplicable = context.featureToggles.communication;
    final communicationComplete = !communicationApplicable ||
        context.announcementCategories.any((category) => category.isActive) ||
        context.notificationCategories.any((category) => category.isActive) ||
        context.messageTemplates.any((template) => template.isActive);
    if (communicationApplicable && !communicationComplete) {
      issue(
        StructureSetupStepId.communication,
        'Communication is enabled; configure at least one category or message template.',
        severity: StructureIssueSeverity.warning,
      );
    }

    final definitions = <_StepDefinition>[
      _StepDefinition(
        id: StructureSetupStepId.institution,
        section: 'Institution',
        title: 'School identity',
        description: 'Confirm the school identity, type, location and regional defaults.',
        route: '/staff/admin/structure/institution',
        complete: institutionComplete,
      ),
      _StepDefinition(
        id: StructureSetupStepId.academicYear,
        section: 'Academic calendar',
        title: 'Academic year',
        description: 'Create the academic year and choose exactly one current year.',
        route: '/staff/admin/structure/academic?section=years',
        complete: academicYearComplete,
        prerequisites: const [StructureSetupStepId.institution],
      ),
      _StepDefinition(
        id: StructureSetupStepId.academicTerms,
        section: 'Academic calendar',
        title: 'Terms / semesters',
        description: 'Define this year’s terms, semesters or custom academic periods.',
        route: '/staff/admin/structure/academic?section=terms',
        complete: termsComplete,
        prerequisites: const [StructureSetupStepId.academicYear],
      ),
      _StepDefinition(
        id: StructureSetupStepId.levels,
        section: 'Academic organisation',
        title: 'Educational levels',
        description: 'Define the educational tiers offered by this school.',
        route: '/staff/admin/structure/academic?section=levels',
        complete: levelsComplete,
        prerequisites: const [StructureSetupStepId.academicTerms],
      ),
      _StepDefinition(
        id: StructureSetupStepId.departments,
        section: 'Academic organisation',
        title: 'Departments',
        description: 'Choose whether departments are used, then define them without requiring an HOD yet.',
        route: '/staff/admin/structure/people?section=departments',
        complete: departmentsComplete,
        applicable: departmentsApplicable || !departmentsDecided,
        prerequisites: const [StructureSetupStepId.levels],
      ),
      _StepDefinition(
        id: StructureSetupStepId.classes,
        section: 'Academic organisation',
        title: 'Classes',
        description: 'Create classes under the levels already configured.',
        route: '/staff/admin/structure/academic?section=classes',
        complete: classesComplete,
        prerequisites: const [StructureSetupStepId.levels, StructureSetupStepId.academicYear],
      ),
      _StepDefinition(
        id: StructureSetupStepId.streams,
        section: 'Academic organisation',
        title: 'Streams / sections',
        description: 'Choose whether streams are used and keep stream capacity inside the parent class capacity.',
        route: '/staff/admin/structure/academic?section=streams',
        complete: streamsComplete,
        applicable: streamsApplicable || !streamsDecided,
        prerequisites: const [StructureSetupStepId.classes],
      ),
      _StepDefinition(
        id: StructureSetupStepId.subjects,
        section: 'Curriculum',
        title: 'Subjects',
        description: 'Define subjects only after the academic organisation they reference is valid.',
        route: '/staff/admin/structure/academic?section=subjects',
        complete: subjectsComplete,
        prerequisites: const [
          StructureSetupStepId.classes,
          StructureSetupStepId.departments,
          StructureSetupStepId.streams,
        ],
      ),
      _StepDefinition(
        id: StructureSetupStepId.assessmentAndGrading,
        section: 'Curriculum',
        title: 'Assessment & grading',
        description: 'Configure assessment types, grading systems and valid grade bands.',
        route: '/staff/admin/structure/assessment',
        complete: gradingComplete,
        prerequisites: const [StructureSetupStepId.subjects],
      ),
      _StepDefinition(
        id: StructureSetupStepId.learningSpaces,
        section: 'Physical structure',
        title: 'Rooms & learning spaces',
        description: 'Optionally manage classrooms, laboratories, halls and other spaces.',
        route: '/staff/admin/structure/campus',
        complete: roomsComplete,
        applicable: roomsApplicable || !roomsDecided,
        prerequisites: const [StructureSetupStepId.assessmentAndGrading],
      ),
      _StepDefinition(
        id: StructureSetupStepId.schoolDay,
        section: 'Scheduling',
        title: 'School day & periods',
        description: 'Define teaching days, periods, breaks, lunch and other slots before assigning teachers.',
        route: '/staff/admin/structure/operations',
        complete: timetableComplete,
        prerequisites: const [
          StructureSetupStepId.classes,
          StructureSetupStepId.subjects,
          StructureSetupStepId.learningSpaces,
        ],
      ),
      _StepDefinition(
        id: StructureSetupStepId.staffRoles,
        section: 'People',
        title: 'Staff roles & responsibilities',
        description: 'Define responsibilities now; assign actual staff only after the structure exists.',
        route: '/staff/admin/structure/people?section=roles',
        complete: staffRolesComplete,
        prerequisites: const [StructureSetupStepId.schoolDay],
      ),
      _StepDefinition(
        id: StructureSetupStepId.houses,
        section: 'Student life',
        title: 'Houses',
        description: 'Choose whether the school uses houses and configure them if needed.',
        route: '/staff/admin/structure/campus',
        complete: housesComplete,
        applicable: housesApplicable || !housesDecided,
        required: false,
        prerequisites: const [StructureSetupStepId.staffRoles],
      ),
      _StepDefinition(
        id: StructureSetupStepId.clubs,
        section: 'Student life',
        title: 'Clubs & societies',
        description: 'Configure clubs now or mark them as not used for initial setup.',
        route: '/staff/admin/structure/campus',
        complete: clubsComplete,
        applicable: clubsApplicable || !clubsDecided,
        required: false,
        prerequisites: const [StructureSetupStepId.staffRoles],
      ),
      _StepDefinition(
        id: StructureSetupStepId.boarding,
        section: 'Student life',
        title: 'Boarding structure',
        description: 'Define hostel/dormitory structure only when boarding is enabled.',
        route: '/staff/admin/structure/campus',
        complete: boardingComplete,
        applicable: boardingApplicable,
        prerequisites: const [StructureSetupStepId.staffRoles],
      ),
      _StepDefinition(
        id: StructureSetupStepId.transport,
        section: 'Operations',
        title: 'Transport structure',
        description: 'Configure routes and vehicles only when school transport is enabled.',
        route: '/staff/admin/structure/campus',
        complete: transportComplete,
        applicable: transportApplicable,
        required: false,
        prerequisites: const [StructureSetupStepId.staffRoles],
      ),
      _StepDefinition(
        id: StructureSetupStepId.attendance,
        section: 'Operations',
        title: 'Attendance methods',
        description: 'Enable the attendance methods the school actually uses.',
        route: '/staff/admin/structure/operations',
        complete: attendanceComplete,
        prerequisites: const [StructureSetupStepId.staffRoles],
      ),
      _StepDefinition(
        id: StructureSetupStepId.financeFoundation,
        section: 'Operations',
        title: 'Finance foundation',
        description: 'Configure the basic fee categories consumed by Finance.',
        route: '/staff/admin/structure/operations',
        complete: financeComplete,
        required: false,
        prerequisites: const [StructureSetupStepId.attendance],
      ),
      _StepDefinition(
        id: StructureSetupStepId.communication,
        section: 'Operations',
        title: 'Communication foundation',
        description: 'Configure communication categories/templates only when communication is enabled.',
        route: '/staff/admin/structure/operations',
        complete: communicationComplete,
        applicable: communicationApplicable,
        required: false,
        prerequisites: const [StructureSetupStepId.attendance],
      ),
      const _StepDefinition(
        id: StructureSetupStepId.review,
        section: 'Review',
        title: 'Structure review',
        description: 'Run a final integrity review. Required issues must be fixed before the structure is ready.',
        route: '',
        complete: false,
        prerequisites: [
          StructureSetupStepId.institution,
          StructureSetupStepId.academicYear,
          StructureSetupStepId.academicTerms,
          StructureSetupStepId.levels,
          StructureSetupStepId.departments,
          StructureSetupStepId.classes,
          StructureSetupStepId.streams,
          StructureSetupStepId.subjects,
          StructureSetupStepId.assessmentAndGrading,
          StructureSetupStepId.learningSpaces,
          StructureSetupStepId.schoolDay,
          StructureSetupStepId.staffRoles,
          StructureSetupStepId.attendance,
        ],
      ),
    ];

    final resolved = <StructureSetupStepResult>[];
    bool prerequisiteSatisfied(StructureSetupStepId id) {
      final existing = resolved.where((step) => step.id == id);
      if (existing.isEmpty) return false;
      return existing.first.isSatisfied;
    }

    for (final definition in definitions) {
      final prerequisitesComplete = definition.prerequisites.every(prerequisiteSatisfied);
      final stepIssues = issuesByStep[definition.id] ?? const <StructureSetupIssue>[];
      final reviewComplete = definition.id == StructureSetupStepId.review
          ? !issuesByStep.values
              .expand((items) => items)
              .any((item) => item.severity == StructureIssueSeverity.critical)
          : definition.complete;
      resolved.add(
        StructureSetupStepResult(
          id: definition.id,
          section: definition.section,
          title: definition.title,
          description: definition.description,
          route: definition.route,
          required: definition.required,
          applicable: definition.applicable,
          complete: reviewComplete,
          prerequisitesComplete: prerequisitesComplete,
          prerequisites: definition.prerequisites,
          issues: stepIssues,
        ),
      );
    }

    return StructureSetupResolution(
      steps: resolved,
      issues: issuesByStep.values.expand((items) => items).toList(growable: false),
    );
  }

  bool _institutionComplete(InstitutionProfile profile) {
    return profile.name.trim().isNotEmpty &&
        profile.schoolType.trim().isNotEmpty &&
        profile.country.trim().isNotEmpty &&
        profile.timeZone.trim().isNotEmpty &&
        profile.currency.trim().isNotEmpty;
  }

  bool _termsAreValid(
    List<AcademicTerm> terms,
    AcademicYear year,
    void Function(
      StructureSetupStepId,
      String, {
      StructureIssueSeverity severity,
    }) issue,
  ) {
    var valid = true;
    final sorted = [...terms]..sort((a, b) => a.startDate.compareTo(b.startDate));
    final currentTerms = terms.where((term) => term.isCurrent).toList();
    if (currentTerms.length != 1) {
      valid = false;
      issue(StructureSetupStepId.academicTerms, 'Exactly one term/semester in the current academic year must be current.');
    }
    for (var i = 0; i < sorted.length; i++) {
      final term = sorted[i];
      if (!term.startDate.isBefore(term.endDate)) {
        valid = false;
        issue(StructureSetupStepId.academicTerms, '${term.name} ends before or at its start date.');
      }
      if (term.startDate.isBefore(year.startDate) || term.endDate.isAfter(year.endDate)) {
        valid = false;
        issue(StructureSetupStepId.academicTerms, '${term.name} falls outside ${year.name}.');
      }
      if (i > 0 && !term.startDate.isAfter(sorted[i - 1].endDate)) {
        valid = false;
        issue(StructureSetupStepId.academicTerms, '${term.name} overlaps ${sorted[i - 1].name}.');
      }
    }
    return valid;
  }

  bool _uniqueNonEmptyCodes(
    Iterable<String> values,
    StructureSetupStepId stepId,
    void Function(
      StructureSetupStepId,
      String, {
      StructureIssueSeverity severity,
    }) issue, {
    required String label,
    bool allowEmpty = false,
  }) {
    final seen = <String>{};
    var valid = true;
    for (final value in values) {
      final normalized = value.trim().toLowerCase();
      if (normalized.isEmpty && allowEmpty) continue;
      if (normalized.isEmpty || !seen.add(normalized)) {
        valid = false;
      }
    }
    if (!valid) issue(stepId, 'Active ${label}s must use unique ${allowEmpty ? 'non-empty ' : ''}codes.');
    return valid;
  }

  bool _timetableIsValid(
    TimetableConfig config,
    void Function(
      StructureSetupStepId,
      String, {
      StructureIssueSeverity severity,
    }) issue,
  ) {
    var valid = true;
    if (config.teachingDays.isEmpty) {
      valid = false;
      issue(StructureSetupStepId.schoolDay, 'Select at least one teaching day.');
    }
    final start = _minutes(config.schoolStartTime);
    final end = _minutes(config.schoolEndTime);
    if (start == null || end == null || start >= end) {
      valid = false;
      issue(StructureSetupStepId.schoolDay, 'Set valid school start and end times.');
    }
    if (config.slots.isEmpty) {
      valid = false;
      issue(StructureSetupStepId.schoolDay, 'Add timetable periods and non-teaching slots.');
      return valid;
    }
    final ranged = <({TimetableSlot slot, int start, int end})>[];
    for (final slot in config.slots) {
      final slotStart = _minutes(slot.startTime);
      final slotEnd = _minutes(slot.endTime);
      if (slotStart == null || slotEnd == null || slotStart >= slotEnd) {
        valid = false;
        issue(StructureSetupStepId.schoolDay, '${slot.name} has invalid start/end times.');
        continue;
      }
      if (start != null && end != null && (slotStart < start || slotEnd > end)) {
        valid = false;
        issue(StructureSetupStepId.schoolDay, '${slot.name} falls outside the configured school day.');
      }
      ranged.add((slot: slot, start: slotStart, end: slotEnd));
    }
    ranged.sort((a, b) => a.start.compareTo(b.start));
    for (var i = 1; i < ranged.length; i++) {
      if (ranged[i].start < ranged[i - 1].end) {
        valid = false;
        issue(
          StructureSetupStepId.schoolDay,
          '${ranged[i].slot.name} overlaps ${ranged[i - 1].slot.name}.',
        );
      }
    }
    return valid;
  }

  int? _minutes(String raw) {
    final parts = raw.trim().split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }
    return hour * 60 + minute;
  }
}

class _StepDefinition {
  final StructureSetupStepId id;
  final String section;
  final String title;
  final String description;
  final String route;
  final bool required;
  final bool applicable;
  final bool complete;
  final List<StructureSetupStepId> prerequisites;

  const _StepDefinition({
    required this.id,
    required this.section,
    required this.title,
    required this.description,
    required this.route,
    this.required = true,
    this.applicable = true,
    required this.complete,
    this.prerequisites = const [],
  });
}
