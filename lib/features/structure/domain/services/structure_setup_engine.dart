import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import '../entities/assessment_grading_entities.dart';
import '../entities/attendance_config_entities.dart';
import '../entities/campus_entities.dart';
import '../entities/communication_config_entities.dart';
import '../entities/curriculum_assignment.dart';
import '../entities/feature_toggles.dart';
import '../entities/fee_category_entities.dart';
import '../entities/hostel_entities.dart';
import '../entities/institution_profile.dart';
import '../entities/structure_entities.dart';
import '../entities/structure_setup_preferences.dart';
import '../entities/teaching_assignment.dart';
import '../entities/timetable.dart';
import '../entities/timetable_config.dart';
import '../entities/transport_structure_entities.dart';
import 'timetable_conflict_resolver.dart';

enum StructureSetupStepId {
  institution,
  academicYear,
  academicTerms,
  levels,
  departments,
  classes,
  streams,
  subjects,
  curriculum,
  assessmentAndGrading,
  learningSpaces,
  schoolDay,
  staffRoles,
  staffAccounts,
  academicAssignments,
  classTimetables,
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

  /// The wizard sets this once the tenant-scoped extended sources have loaded.
  /// Older callers/tests can leave it false and keep the definition-only flow.
  final bool extendedDataLoaded;
  final List<CurriculumAssignment> curriculumAssignments;
  final List<UserEntity> staff;
  final List<TeachingAssignment> teachingAssignments;
  final List<Timetable> classTimetables;
  final List<TimetableLesson> timetableLessons;

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
    this.extendedDataLoaded = false,
    this.curriculumAssignments = const [],
    this.staff = const [],
    this.teachingAssignments = const [],
    this.classTimetables = const [],
    this.timetableLessons = const [],
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
    if (issues.isNotEmpty) return StructureStepState.needsAttention;
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

  List<StructureSetupStepResult> get requiredSteps => steps
      .where((step) => step.applicable && step.required)
      .toList(growable: false);

  StructureSetupStepResult? get nextStep {
    for (final step in steps) {
      if (!step.applicable || step.id == StructureSetupStepId.review) continue;
      if (step.prerequisitesComplete && !step.isSatisfied) return step;
    }
    final review = steps.where(
      (step) => step.id == StructureSetupStepId.review,
    );
    return review.isEmpty ? null : review.first;
  }

  bool get isReady =>
      requiredSteps.every((step) => step.isSatisfied) &&
      !issues.any((issue) => issue.severity == StructureIssueSeverity.critical);

  double get progress {
    final required = requiredSteps
        .where((step) => step.id != StructureSetupStepId.review)
        .toList(growable: false);
    if (required.isEmpty) return 1;
    return required.where((step) => step.isSatisfied).length / required.length;
  }
}

class StructureSetupEngine {
  final TimetableConflictResolver timetableConflictResolver;

  const StructureSetupEngine({
    this.timetableConflictResolver = const TimetableConflictResolver(),
  });

  StructureSetupResolution resolve(StructureSetupContext context) {
    final issuesByStep = <StructureSetupStepId, List<StructureSetupIssue>>{};

    void issue(
      StructureSetupStepId stepId,
      String message, {
      StructureIssueSeverity severity = StructureIssueSeverity.critical,
    }) {
      issuesByStep
          .putIfAbsent(stepId, () => <StructureSetupIssue>[])
          .add(
            StructureSetupIssue(
              stepId: stepId,
              message: message,
              severity: severity,
            ),
          );
    }

    final institutionComplete = _institutionComplete(
      context.institutionProfile,
    );
    if (!institutionComplete) {
      issue(
        StructureSetupStepId.institution,
        'Complete the school name, type, country, timezone and currency.',
      );
    }

    final currentYears = context.academicYears
        .where((year) => year.isCurrent && !year.isArchived)
        .toList(growable: false);
    final currentYear = currentYears.length == 1 ? currentYears.first : null;
    var academicYearComplete = currentYear != null;
    if (currentYears.isEmpty) {
      issue(
        StructureSetupStepId.academicYear,
        'Set one academic year as current.',
      );
    } else if (currentYears.length > 1) {
      academicYearComplete = false;
      issue(
        StructureSetupStepId.academicYear,
        'Only one academic year can be current.',
      );
    } else if (!currentYear!.startDate.isBefore(currentYear.endDate)) {
      academicYearComplete = false;
      issue(
        StructureSetupStepId.academicYear,
        'Academic year end date must be after its start date.',
      );
    }

    final termsForCurrentYear = currentYear == null
        ? <AcademicTerm>[]
        : context.academicTerms
              .where((term) => term.academicYearId == currentYear.id)
              .toList(growable: false);
    final termsComplete =
        currentYear != null &&
        termsForCurrentYear.isNotEmpty &&
        _termsAreValid(termsForCurrentYear, currentYear, issue);
    if (currentYear != null && termsForCurrentYear.isEmpty) {
      issue(
        StructureSetupStepId.academicTerms,
        'Add at least one term, semester or academic period.',
      );
    }

    final currentTerm = termsForCurrentYear
        .where((term) => term.isCurrent)
        .firstOrNull;

    final activeLevels = context.levels
        .where((level) => level.isActive)
        .toList();
    var levelsComplete = activeLevels.isNotEmpty;
    if (activeLevels.isEmpty) {
      issue(
        StructureSetupStepId.levels,
        'Add at least one active educational level.',
      );
    }
    levelsComplete =
        levelsComplete &&
        _uniqueCodes(
          activeLevels.map((level) => level.code),
          StructureSetupStepId.levels,
          issue,
          label: 'level',
          allowEmpty: true,
        );

    final departmentsDecided =
        context.preferences.departments != StructureUseChoice.undecided;
    final departmentsApplicable =
        context.preferences.departments != StructureUseChoice.disabled;
    final activeDepartments = context.departments
        .where((department) => department.isActive)
        .toList();
    var departmentsComplete = !departmentsApplicable;
    if (!departmentsDecided) {
      departmentsComplete = false;
      issue(
        StructureSetupStepId.departments,
        'Choose whether this school uses academic departments.',
      );
    } else if (departmentsApplicable) {
      departmentsComplete = activeDepartments.isNotEmpty;
      if (!departmentsComplete) {
        issue(
          StructureSetupStepId.departments,
          'Add at least one department or choose No.',
        );
      }
    }

    final activeLevelIds = activeLevels.map((item) => item.id).toSet();
    final activeClasses = context.classes
        .where((schoolClass) => schoolClass.isActive)
        .toList();
    var classesComplete = activeClasses.isNotEmpty;
    if (!classesComplete) {
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
        issue(
          StructureSetupStepId.classes,
          '${schoolClass.name} has an invalid negative capacity.',
        );
      }
    }

    final streamsDecided =
        context.preferences.streams != StructureUseChoice.undecided;
    final streamsApplicable =
        context.preferences.streams != StructureUseChoice.disabled;
    final activeStreams = context.streams
        .where((stream) => stream.isActive)
        .toList();
    var streamsComplete = !streamsApplicable;
    if (!streamsDecided) {
      streamsComplete = false;
      issue(
        StructureSetupStepId.streams,
        'Choose whether this school uses streams or sections.',
      );
    } else if (streamsApplicable) {
      streamsComplete = activeStreams.isNotEmpty;
      if (!streamsComplete) {
        issue(
          StructureSetupStepId.streams,
          'Add streams/sections or choose No.',
        );
      }
      final classesById = {
        for (final schoolClass in activeClasses) schoolClass.id: schoolClass,
      };
      final allocatedByClass = <String, int>{};
      final namesByClass = <String, Set<String>>{};
      final codesByClass = <String, Set<String>>{};
      for (final stream in activeStreams) {
        final parent = classesById[stream.classId];
        if (parent == null) {
          streamsComplete = false;
          issue(
            StructureSetupStepId.streams,
            '${stream.name} belongs to a missing or inactive class.',
          );
          continue;
        }
        if (stream.capacity <= 0) {
          streamsComplete = false;
          issue(
            StructureSetupStepId.streams,
            '${stream.name} must have a capacity greater than zero.',
          );
        }
        allocatedByClass[stream.classId] =
            (allocatedByClass[stream.classId] ?? 0) + stream.capacity;
        final nameKey = stream.name.trim().toLowerCase();
        if (!namesByClass
            .putIfAbsent(stream.classId, () => <String>{})
            .add(nameKey)) {
          streamsComplete = false;
          issue(
            StructureSetupStepId.streams,
            '${parent.name} contains duplicate stream name "${stream.name}".',
          );
        }
        final codeKey = stream.code.trim().toLowerCase();
        if (codeKey.isNotEmpty &&
            !codesByClass
                .putIfAbsent(stream.classId, () => <String>{})
                .add(codeKey)) {
          streamsComplete = false;
          issue(
            StructureSetupStepId.streams,
            '${parent.name} contains duplicate stream code "${stream.code}".',
          );
        }
      }
      for (final entry in allocatedByClass.entries) {
        final parent = classesById[entry.key];
        if (parent == null) continue;
        if (parent.capacity <= 0) {
          streamsComplete = false;
          issue(
            StructureSetupStepId.streams,
            '${parent.name} needs a positive class capacity before streams are used.',
          );
        } else if (entry.value > parent.capacity) {
          streamsComplete = false;
          issue(
            StructureSetupStepId.streams,
            '${parent.name} stream capacity is ${entry.value}, exceeding class capacity ${parent.capacity}.',
          );
        }
      }
    }

    final activeSubjects = context.subjects
        .where((subject) => subject.isActive)
        .toList();
    var subjectsComplete = activeSubjects.isNotEmpty;
    if (!subjectsComplete) {
      issue(StructureSetupStepId.subjects, 'Add at least one active subject.');
    }
    final departmentIds = activeDepartments.map((item) => item.id).toSet();
    final classIds = activeClasses.map((item) => item.id).toSet();
    for (final subject in activeSubjects) {
      if (subject.departmentId.isNotEmpty &&
          !departmentIds.contains(subject.departmentId)) {
        subjectsComplete = false;
        issue(
          StructureSetupStepId.subjects,
          '${subject.name} references a missing or inactive department.',
        );
      }
      if (subject.assignedLevelIds.any((id) => !activeLevelIds.contains(id))) {
        subjectsComplete = false;
        issue(
          StructureSetupStepId.subjects,
          '${subject.name} contains an invalid level assignment.',
        );
      }
      if (subject.assignedClassIds.any((id) => !classIds.contains(id))) {
        subjectsComplete = false;
        issue(
          StructureSetupStepId.subjects,
          '${subject.name} contains an invalid class assignment.',
        );
      }
    }

    var curriculumComplete = true;
    if (context.extendedDataLoaded) {
      curriculumComplete = _curriculumIsValid(
        context,
        currentYear,
        activeClasses,
        activeStreams,
        issue,
      );
    }

    final activeAssessmentTypes = context.assessmentTypes
        .where((type) => type.isActive)
        .toList();
    final activeGradingSystems = context.gradingSystems
        .where((system) => system.isActive)
        .toList();
    var gradingComplete =
        activeAssessmentTypes.isNotEmpty && activeGradingSystems.isNotEmpty;
    if (activeAssessmentTypes.isEmpty) {
      issue(
        StructureSetupStepId.assessmentAndGrading,
        'Add at least one active assessment type.',
      );
    }
    if (activeGradingSystems.isEmpty) {
      issue(
        StructureSetupStepId.assessmentAndGrading,
        'Add at least one active grading system.',
      );
    }
    for (final system in activeGradingSystems) {
      final bands =
          context.gradeBands
              .where((band) => band.gradingSystemId == system.id)
              .toList()
            ..sort((a, b) => a.minScore.compareTo(b.minScore));
      if (bands.isEmpty) {
        gradingComplete = false;
        issue(
          StructureSetupStepId.assessmentAndGrading,
          '${system.name} has no grade bands.',
        );
        continue;
      }
      for (var i = 0; i < bands.length; i++) {
        final band = bands[i];
        if (band.minScore > band.maxScore) {
          gradingComplete = false;
          issue(
            StructureSetupStepId.assessmentAndGrading,
            '${system.name}: ${band.grade} has an invalid score range.',
          );
        }
        if (i > 0 && band.minScore <= bands[i - 1].maxScore) {
          gradingComplete = false;
          issue(
            StructureSetupStepId.assessmentAndGrading,
            '${system.name} contains overlapping grade bands.',
          );
          break;
        }
      }
    }

    final roomsDecided =
        context.preferences.rooms != StructureUseChoice.undecided;
    final roomsApplicable =
        context.preferences.rooms != StructureUseChoice.disabled;
    final activeFacilities = context.facilities
        .where((facility) => facility.isActive)
        .toList();
    var roomsComplete = !roomsApplicable;
    if (!roomsDecided) {
      roomsComplete = false;
      issue(
        StructureSetupStepId.learningSpaces,
        'Choose whether this school manages rooms and learning spaces.',
      );
    } else if (roomsApplicable) {
      roomsComplete = activeFacilities.isNotEmpty;
      if (!roomsComplete) {
        issue(
          StructureSetupStepId.learningSpaces,
          'Add a learning space or choose No.',
        );
      }
    }

    final schoolDayComplete = _schoolDayIsValid(context.timetableConfig, issue);

    final activeRoles = context.designations
        .where((role) => role.isActive)
        .toList();
    final staffRolesComplete = activeRoles.isNotEmpty;
    if (!staffRolesComplete) {
      issue(
        StructureSetupStepId.staffRoles,
        'Define at least one active staff responsibility/role.',
      );
    }

    var staffAccountsComplete = true;
    var academicAssignmentsComplete = true;
    var classTimetablesComplete = true;
    if (context.extendedDataLoaded) {
      staffAccountsComplete = context.staff.any((item) => item.isActive);
      if (!staffAccountsComplete) {
        issue(
          StructureSetupStepId.staffAccounts,
          'Create at least one active staff account for this school.',
        );
      }
      academicAssignmentsComplete = _academicAssignmentsAreValid(
        context,
        currentYear,
        issue,
      );
      classTimetablesComplete = _classTimetablesAreValid(
        context,
        currentYear,
        currentTerm,
        activeClasses,
        activeStreams,
        issue,
      );
    }

    final housesDecided =
        context.preferences.houses != StructureUseChoice.undecided;
    final housesApplicable =
        context.preferences.houses != StructureUseChoice.disabled;
    var housesComplete = !housesApplicable;
    if (!housesDecided) {
      housesComplete = false;
      issue(
        StructureSetupStepId.houses,
        'Choose whether this school uses houses.',
      );
    } else if (housesApplicable) {
      housesComplete = context.houses.any((house) => house.isActive);
      if (!housesComplete) {
        issue(StructureSetupStepId.houses, 'Add a house or choose No.');
      }
    }

    final clubsDecided =
        context.preferences.clubs != StructureUseChoice.undecided;
    final clubsApplicable =
        context.preferences.clubs != StructureUseChoice.disabled;
    var clubsComplete = !clubsApplicable;
    if (!clubsDecided) {
      clubsComplete = false;
      issue(
        StructureSetupStepId.clubs,
        'Choose whether this school uses clubs and societies.',
      );
    } else if (clubsApplicable) {
      clubsComplete = context.clubs.any((club) => club.isActive);
      if (!clubsComplete) {
        issue(StructureSetupStepId.clubs, 'Add a club or choose No.');
      }
    }

    final boardingDecided =
        context.preferences.boarding != StructureUseChoice.undecided;
    final boardingApplicable =
        context.preferences.boarding == StructureUseChoice.enabled;
    var boardingComplete = !boardingApplicable;
    if (!boardingDecided) {
      boardingComplete = false;
      issue(
        StructureSetupStepId.boarding,
        'Choose whether this school provides boarding.',
      );
    } else if (boardingApplicable) {
      boardingComplete = context.hostels.any((hostel) => hostel.isActive);
      if (!boardingComplete) {
        issue(
          StructureSetupStepId.boarding,
          'Add an active hostel/dormitory or choose No.',
        );
      }
    }

    final transportDecided =
        context.preferences.transport != StructureUseChoice.undecided;
    final transportApplicable =
        context.preferences.transport == StructureUseChoice.enabled;
    var transportComplete = !transportApplicable;
    if (!transportDecided) {
      transportComplete = false;
      issue(
        StructureSetupStepId.transport,
        'Choose whether this school operates transport.',
      );
    } else if (transportApplicable) {
      transportComplete =
          context.transportRoutes.any((route) => route.isActive) &&
          context.transportVehicles.any((vehicle) => vehicle.isActive);
      if (!transportComplete) {
        issue(
          StructureSetupStepId.transport,
          'Add at least one active route and vehicle or choose No.',
        );
      }
    }

    final attendanceComplete = context.attendanceTypes.any(
      (type) => type.isActive,
    );
    if (!attendanceComplete) {
      issue(
        StructureSetupStepId.attendance,
        'Enable at least one attendance type.',
      );
    }

    final financeComplete = context.feeCategories.any(
      (category) => category.isActive,
    );
    if (!financeComplete) {
      issue(
        StructureSetupStepId.financeFoundation,
        'No structural fee categories are configured yet.',
        severity: StructureIssueSeverity.warning,
      );
    }

    final communicationApplicable = context.featureToggles.communication;
    final communicationComplete =
        !communicationApplicable ||
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
        description:
            'Confirm the school identity, type, location and regional defaults.',
        route: '/staff/admin/structure/institution',
        complete: institutionComplete,
      ),
      _StepDefinition(
        id: StructureSetupStepId.academicYear,
        section: 'Academic calendar',
        title: 'Academic year',
        description:
            'Create the academic year and choose exactly one current year.',
        route: '/staff/admin/structure/academic?section=years',
        complete: academicYearComplete,
        prerequisites: const [StructureSetupStepId.institution],
      ),
      _StepDefinition(
        id: StructureSetupStepId.academicTerms,
        section: 'Academic calendar',
        title: 'Terms / semesters',
        description:
            'Define this year’s terms, semesters or custom academic periods.',
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
        description:
            'Choose whether departments are used, then define them without requiring an HOD yet.',
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
        prerequisites: const [StructureSetupStepId.levels],
      ),
      _StepDefinition(
        id: StructureSetupStepId.streams,
        section: 'Academic organisation',
        title: 'Streams / sections',
        description:
            'Choose whether streams are used and keep stream capacity inside the parent class capacity.',
        route: '/staff/admin/structure/academic?section=streams',
        complete: streamsComplete,
        applicable: streamsApplicable || !streamsDecided,
        prerequisites: const [StructureSetupStepId.classes],
      ),
      _StepDefinition(
        id: StructureSetupStepId.subjects,
        section: 'Curriculum',
        title: 'Subjects',
        description:
            'Define the reusable subject catalogue before allocating subjects to classes.',
        route: '/staff/admin/structure/academic?section=subjects',
        complete: subjectsComplete,
        prerequisites: const [
          StructureSetupStepId.classes,
          StructureSetupStepId.departments,
          StructureSetupStepId.streams,
        ],
      ),
    ];

    if (context.extendedDataLoaded) {
      definitions.add(
        _StepDefinition(
          id: StructureSetupStepId.curriculum,
          section: 'Curriculum',
          title: 'Curriculum / subject allocation',
          description:
              'Assign subjects to the classes and streams that study them in the current academic year.',
          route: '/staff/admin/structure/curriculum',
          complete: curriculumComplete,
          prerequisites: const [StructureSetupStepId.subjects],
        ),
      );
    }

    definitions.addAll([
      _StepDefinition(
        id: StructureSetupStepId.assessmentAndGrading,
        section: 'Curriculum',
        title: 'Assessment & grading',
        description:
            'Configure assessment types, grading systems and valid grade bands.',
        route: '/staff/admin/structure/assessment',
        complete: gradingComplete,
        prerequisites: [
          context.extendedDataLoaded
              ? StructureSetupStepId.curriculum
              : StructureSetupStepId.subjects,
        ],
      ),
      _StepDefinition(
        id: StructureSetupStepId.learningSpaces,
        section: 'Physical structure',
        title: 'Rooms & learning spaces',
        description:
            'Optionally manage classrooms, laboratories, halls and other spaces.',
        route: '/staff/admin/structure/campus?section=facilities',
        complete: roomsComplete,
        applicable: roomsApplicable || !roomsDecided,
        prerequisites: const [StructureSetupStepId.assessmentAndGrading],
      ),
      _StepDefinition(
        id: StructureSetupStepId.schoolDay,
        section: 'Scheduling',
        title: 'School day & periods',
        description:
            'Define teaching days, periods, breaks, lunch and other slots before assigning teachers.',
        route: '/staff/admin/structure/operations?section=timetable',
        complete: schoolDayComplete,
        prerequisites: const [StructureSetupStepId.learningSpaces],
      ),
      _StepDefinition(
        id: StructureSetupStepId.staffRoles,
        section: 'People',
        title: 'Staff roles & responsibilities',
        description:
            'Define reusable responsibilities. One staff account may hold several roles.',
        route: '/staff/admin/structure/people?section=roles',
        complete: staffRolesComplete,
        prerequisites: const [StructureSetupStepId.schoolDay],
      ),
    ]);

    if (context.extendedDataLoaded) {
      definitions.addAll([
        _StepDefinition(
          id: StructureSetupStepId.staffAccounts,
          section: 'People',
          title: 'Staff accounts',
          description:
              'Create real staff accounts before assigning academic responsibilities.',
          route: '/staff/admin/users',
          complete: staffAccountsComplete,
          prerequisites: const [StructureSetupStepId.staffRoles],
        ),
        _StepDefinition(
          id: StructureSetupStepId.academicAssignments,
          section: 'People',
          title: 'Academic staff assignments',
          description:
              'Assign Subject Teachers, Class Teachers and HODs using existing staff accounts.',
          route: '/staff/admin/structure/academic-staff-assignments',
          complete: academicAssignmentsComplete,
          prerequisites: const [
            StructureSetupStepId.staffAccounts,
            StructureSetupStepId.curriculum,
          ],
        ),
        _StepDefinition(
          id: StructureSetupStepId.classTimetables,
          section: 'Scheduling',
          title: 'Class / stream timetables',
          description:
              'Build and publish timetables after curriculum and teacher assignments are valid.',
          route: '/staff/admin/structure/class-timetables',
          complete: classTimetablesComplete,
          prerequisites: const [StructureSetupStepId.academicAssignments],
        ),
      ]);
    }

    final campusPrerequisite = context.extendedDataLoaded
        ? StructureSetupStepId.classTimetables
        : StructureSetupStepId.staffRoles;

    definitions.addAll([
      _StepDefinition(
        id: StructureSetupStepId.houses,
        section: 'Student life',
        title: 'Houses',
        description:
            'Choose whether the school uses houses and configure them if needed.',
        route: '/staff/admin/structure/campus?section=houses',
        complete: housesComplete,
        applicable: housesApplicable || !housesDecided,
        required: false,
        prerequisites: [campusPrerequisite],
      ),
      _StepDefinition(
        id: StructureSetupStepId.clubs,
        section: 'Student life',
        title: 'Clubs & societies',
        description: 'Configure clubs now or choose No for initial setup.',
        route: '/staff/admin/structure/campus?section=clubs',
        complete: clubsComplete,
        applicable: clubsApplicable || !clubsDecided,
        required: false,
        prerequisites: [campusPrerequisite],
      ),
      _StepDefinition(
        id: StructureSetupStepId.boarding,
        section: 'Student life',
        title: 'Boarding structure',
        description:
            'Choose whether the school boards learners and define dormitories before assigning welfare staff.',
        route: '/staff/admin/structure/campus?section=hostel',
        complete: boardingComplete,
        applicable: boardingApplicable || !boardingDecided,
        prerequisites: [campusPrerequisite],
      ),
      _StepDefinition(
        id: StructureSetupStepId.transport,
        section: 'Operations',
        title: 'Transport structure',
        description:
            'Choose whether the school operates transport, then define routes and vehicles.',
        route: '/staff/admin/structure/campus?section=transport',
        complete: transportComplete,
        applicable: transportApplicable || !transportDecided,
        required: false,
        prerequisites: [campusPrerequisite],
      ),
      _StepDefinition(
        id: StructureSetupStepId.attendance,
        section: 'Operations',
        title: 'Attendance configuration',
        description:
            'Define the attendance labels and sessions the school actually uses.',
        route: '/staff/admin/structure/operations?section=attendance',
        complete: attendanceComplete,
        prerequisites: [campusPrerequisite],
      ),
      _StepDefinition(
        id: StructureSetupStepId.financeFoundation,
        section: 'Operations',
        title: 'Finance foundation',
        description:
            'Optionally configure structural fee categories consumed by Finance.',
        route: '/staff/admin/structure/operations?section=fees',
        complete: financeComplete,
        required: false,
        prerequisites: const [StructureSetupStepId.attendance],
      ),
      _StepDefinition(
        id: StructureSetupStepId.communication,
        section: 'Operations',
        title: 'Communication foundation',
        description:
            'Configure communication categories/templates only when communication is enabled.',
        route: '/staff/admin/structure/operations?section=communication',
        complete: communicationComplete,
        applicable: communicationApplicable,
        required: false,
        prerequisites: const [StructureSetupStepId.attendance],
      ),
    ]);

    final reviewPrerequisites = definitions
        .where((definition) => definition.required)
        .map((definition) => definition.id)
        .toList(growable: false);
    definitions.add(
      _StepDefinition(
        id: StructureSetupStepId.review,
        section: 'Review',
        title: 'Structure review',
        description:
            'Run a final dependency and integrity review before marking Structure ready.',
        route: '',
        complete: false,
        prerequisites: reviewPrerequisites,
      ),
    );

    final resolved = <StructureSetupStepResult>[];
    bool prerequisiteSatisfied(StructureSetupStepId id) {
      final matches = resolved.where((step) => step.id == id);
      return matches.isNotEmpty && matches.first.isSatisfied;
    }

    for (final definition in definitions) {
      final prerequisitesComplete = definition.prerequisites.every(
        prerequisiteSatisfied,
      );
      final stepIssues =
          issuesByStep[definition.id] ?? const <StructureSetupIssue>[];
      final reviewComplete = definition.id == StructureSetupStepId.review
          ? !issuesByStep.values
                    .expand((items) => items)
                    .any(
                      (item) =>
                          item.severity == StructureIssueSeverity.critical,
                    ) &&
                definition.prerequisites.every(prerequisiteSatisfied)
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
      issues: issuesByStep.values
          .expand((items) => items)
          .toList(growable: false),
    );
  }

  bool _institutionComplete(InstitutionProfile profile) {
    return profile.name.trim().isNotEmpty &&
        profile.schoolType.trim().isNotEmpty &&
        profile.country.trim().isNotEmpty &&
        profile.timeZone.trim().isNotEmpty &&
        profile.currency.trim().isNotEmpty;
  }

  bool _curriculumIsValid(
    StructureSetupContext context,
    AcademicYear? currentYear,
    List<SchoolClass> activeClasses,
    List<ClassStream> activeStreams,
    void Function(
      StructureSetupStepId,
      String, {
      StructureIssueSeverity severity,
    })
    issue,
  ) {
    if (currentYear == null) return false;
    final assignments = context.curriculumAssignments
        .where((item) => item.isActive && item.academicYearId == currentYear.id)
        .toList(growable: false);
    if (assignments.isEmpty) {
      issue(
        StructureSetupStepId.curriculum,
        'Allocate subjects to active classes for ${currentYear.name}.',
      );
      return false;
    }

    var valid = true;
    final activeClassIds = activeClasses.map((item) => item.id).toSet();
    final activeStreamIds = activeStreams.map((item) => item.id).toSet();
    final activeSubjectIds = context.subjects
        .where((item) => item.isActive)
        .map((item) => item.id)
        .toSet();

    for (final assignment in assignments) {
      if (!activeClassIds.contains(assignment.classId) ||
          !activeSubjectIds.contains(assignment.subjectId) ||
          (assignment.streamId.isNotEmpty &&
              !activeStreamIds.contains(assignment.streamId))) {
        valid = false;
        issue(
          StructureSetupStepId.curriculum,
          'A curriculum allocation references a missing or inactive class, stream or subject.',
        );
      }
    }

    for (final schoolClass in activeClasses) {
      final streams = activeStreams
          .where((stream) => stream.classId == schoolClass.id)
          .toList(growable: false);
      if (context.preferences.streams == StructureUseChoice.enabled &&
          streams.isNotEmpty) {
        for (final stream in streams) {
          final covered = assignments.any(
            (item) =>
                item.classId == schoolClass.id &&
                (item.streamId.isEmpty || item.streamId == stream.id),
          );
          if (!covered) {
            valid = false;
            issue(
              StructureSetupStepId.curriculum,
              '${schoolClass.name} ${stream.name} has no subject allocation for ${currentYear.name}.',
            );
          }
        }
      } else if (!assignments.any((item) => item.classId == schoolClass.id)) {
        valid = false;
        issue(
          StructureSetupStepId.curriculum,
          '${schoolClass.name} has no subject allocation for ${currentYear.name}.',
        );
      }
    }
    return valid;
  }

  bool _academicAssignmentsAreValid(
    StructureSetupContext context,
    AcademicYear? currentYear,
    void Function(
      StructureSetupStepId,
      String, {
      StructureIssueSeverity severity,
    })
    issue,
  ) {
    if (currentYear == null) return false;
    final curriculum = context.curriculumAssignments
        .where((item) => item.isActive && item.academicYearId == currentYear.id)
        .toList(growable: false);
    final assignments = context.teachingAssignments
        .where(
          (item) =>
              item.isActive &&
              item.academicYearId == currentYear.id &&
              item.responsibilityType ==
                  TeachingResponsibilityType.subjectTeacher,
        )
        .toList(growable: false);
    final activeStaffIds = context.staff
        .where((item) => item.isActive)
        .map((item) => item.id)
        .toSet();

    var valid = curriculum.isNotEmpty;
    for (final allocation in curriculum) {
      final covered = assignments.any(
        (assignment) =>
            activeStaffIds.contains(assignment.staffId) &&
            assignment.classId == allocation.classId &&
            assignment.subjectId == allocation.subjectId &&
            (allocation.streamId.isEmpty ||
                assignment.streamId.isEmpty ||
                assignment.streamId == allocation.streamId),
      );
      if (!covered) {
        valid = false;
        final subject = context.subjects
            .where((item) => item.id == allocation.subjectId)
            .firstOrNull;
        final schoolClass = context.classes
            .where((item) => item.id == allocation.classId)
            .firstOrNull;
        final stream = context.streams
            .where((item) => item.id == allocation.streamId)
            .firstOrNull;
        issue(
          StructureSetupStepId.academicAssignments,
          '${subject?.name ?? 'Subject'} in ${schoolClass?.name ?? 'class'}${stream == null ? '' : ' ${stream.name}'} has no active Subject Teacher assignment.',
        );
      }
    }
    if (curriculum.isEmpty) {
      issue(
        StructureSetupStepId.academicAssignments,
        'Complete Curriculum / Subject Allocation before assigning teachers.',
      );
    }
    return valid;
  }

  bool _classTimetablesAreValid(
    StructureSetupContext context,
    AcademicYear? currentYear,
    AcademicTerm? currentTerm,
    List<SchoolClass> activeClasses,
    List<ClassStream> activeStreams,
    void Function(
      StructureSetupStepId,
      String, {
      StructureIssueSeverity severity,
    })
    issue,
  ) {
    if (currentYear == null || currentTerm == null) return false;
    final published = context.classTimetables
        .where(
          (item) =>
              item.academicYearId == currentYear.id &&
              item.termId == currentTerm.id &&
              item.status == TimetableStatus.active,
        )
        .toList(growable: false);
    var valid = true;

    for (final schoolClass in activeClasses) {
      final streams = activeStreams
          .where((stream) => stream.classId == schoolClass.id)
          .toList(growable: false);
      if (context.preferences.streams == StructureUseChoice.enabled &&
          streams.isNotEmpty) {
        for (final stream in streams) {
          final table = published
              .where(
                (item) =>
                    item.classId == schoolClass.id &&
                    item.streamId == stream.id,
              )
              .firstOrNull;
          if (table == null) {
            valid = false;
            issue(
              StructureSetupStepId.classTimetables,
              '${schoolClass.name} ${stream.name} has no published timetable for ${currentTerm.name}.',
            );
          } else if (!context.timetableLessons.any(
            (lesson) => lesson.timetableId == table.id,
          )) {
            valid = false;
            issue(
              StructureSetupStepId.classTimetables,
              '${table.name} is published but contains no lessons.',
            );
          }
        }
      } else {
        final table = published
            .where(
              (item) => item.classId == schoolClass.id && item.streamId.isEmpty,
            )
            .firstOrNull;
        if (table == null) {
          valid = false;
          issue(
            StructureSetupStepId.classTimetables,
            '${schoolClass.name} has no published timetable for ${currentTerm.name}.',
          );
        } else if (!context.timetableLessons.any(
          (lesson) => lesson.timetableId == table.id,
        )) {
          valid = false;
          issue(
            StructureSetupStepId.classTimetables,
            '${table.name} is published but contains no lessons.',
          );
        }
      }
    }

    final activeLessons = context.timetableLessons
        .where(
          (lesson) =>
              lesson.academicYearId == currentYear.id &&
              lesson.termId == currentTerm.id,
        )
        .toList(growable: false);
    final seenMessages = <String>{};
    for (final lesson in activeLessons) {
      final conflicts = timetableConflictResolver.findConflicts(
        candidate: lesson,
        otherLessons: activeLessons.where((item) => item.id != lesson.id),
      );
      for (final conflict in conflicts) {
        if (seenMessages.add(conflict.message)) {
          valid = false;
          issue(StructureSetupStepId.classTimetables, conflict.message);
        }
      }
    }
    return valid;
  }

  bool _termsAreValid(
    List<AcademicTerm> terms,
    AcademicYear year,
    void Function(
      StructureSetupStepId,
      String, {
      StructureIssueSeverity severity,
    })
    issue,
  ) {
    var valid = true;
    final sorted = [...terms]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final currentTerms = terms.where((term) => term.isCurrent).toList();
    if (currentTerms.length != 1) {
      valid = false;
      issue(
        StructureSetupStepId.academicTerms,
        'Exactly one term/semester in the current academic year must be current.',
      );
    }
    for (var i = 0; i < sorted.length; i++) {
      final term = sorted[i];
      if (!term.startDate.isBefore(term.endDate)) {
        valid = false;
        issue(
          StructureSetupStepId.academicTerms,
          '${term.name} ends before or at its start date.',
        );
      }
      if (term.startDate.isBefore(year.startDate) ||
          term.endDate.isAfter(year.endDate)) {
        valid = false;
        issue(
          StructureSetupStepId.academicTerms,
          '${term.name} falls outside ${year.name}.',
        );
      }
      if (i > 0 && !term.startDate.isAfter(sorted[i - 1].endDate)) {
        valid = false;
        issue(
          StructureSetupStepId.academicTerms,
          '${term.name} overlaps ${sorted[i - 1].name}.',
        );
      }
    }
    return valid;
  }

  bool _uniqueCodes(
    Iterable<String> values,
    StructureSetupStepId stepId,
    void Function(
      StructureSetupStepId,
      String, {
      StructureIssueSeverity severity,
    })
    issue, {
    required String label,
    bool allowEmpty = false,
  }) {
    final seen = <String>{};
    var valid = true;
    for (final value in values) {
      final normalized = value.trim().toLowerCase();
      if (normalized.isEmpty && allowEmpty) continue;
      if (normalized.isEmpty || !seen.add(normalized)) valid = false;
    }
    if (!valid) {
      issue(
        stepId,
        'Active ${label}s must use unique ${allowEmpty ? 'non-empty ' : ''}codes.',
      );
    }
    return valid;
  }

  bool _schoolDayIsValid(
    TimetableConfig config,
    void Function(
      StructureSetupStepId,
      String, {
      StructureIssueSeverity severity,
    })
    issue,
  ) {
    var valid = true;
    if (config.teachingDays.isEmpty) {
      valid = false;
      issue(
        StructureSetupStepId.schoolDay,
        'Select at least one teaching day.',
      );
    }
    final start = _minutes(config.schoolStartTime);
    final end = _minutes(config.schoolEndTime);
    if (start == null || end == null || start >= end) {
      valid = false;
      issue(
        StructureSetupStepId.schoolDay,
        'Set valid school start and end times.',
      );
    }
    if (config.slots.isEmpty) {
      valid = false;
      issue(
        StructureSetupStepId.schoolDay,
        'Add timetable periods and non-teaching slots.',
      );
      return valid;
    }
    if (!config.slots.any((slot) => slot.type == 'period')) {
      valid = false;
      issue(
        StructureSetupStepId.schoolDay,
        'Add at least one teaching period.',
      );
    }

    final ranged = <({TimetableSlot slot, int start, int end})>[];
    for (final slot in config.slots) {
      final slotStart = _minutes(slot.startTime);
      final slotEnd = _minutes(slot.endTime);
      if (slotStart == null || slotEnd == null || slotStart >= slotEnd) {
        valid = false;
        issue(
          StructureSetupStepId.schoolDay,
          '${slot.name} has invalid start/end times.',
        );
        continue;
      }
      if (start != null &&
          end != null &&
          (slotStart < start || slotEnd > end)) {
        valid = false;
        issue(
          StructureSetupStepId.schoolDay,
          '${slot.name} falls outside the configured school day.',
        );
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
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
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

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
