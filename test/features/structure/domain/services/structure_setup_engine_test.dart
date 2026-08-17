import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/entities/assessment_grading_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/attendance_config_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/feature_toggles.dart';
import 'package:school_pulse/features/structure/domain/entities/institution_profile.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_setup_preferences.dart';
import 'package:school_pulse/features/structure/domain/entities/timetable_config.dart';
import 'package:school_pulse/features/structure/domain/services/structure_dependency_graph_validator.dart';
import 'package:school_pulse/features/structure/domain/services/structure_setup_engine.dart';

void main() {
  const engine = StructureSetupEngine();

  group('StructureSetupEngine realistic dummy school', () {
    test('primary school can complete without departments, streams, rooms, houses, boarding or transport', () {
      final resolution = engine.resolve(_healthyContext());

      expect(resolution.isReady, isTrue);
      expect(
        resolution.steps
            .firstWhere((step) => step.id == StructureSetupStepId.departments)
            .state,
        StructureStepState.notApplicable,
      );
      expect(
        resolution.steps
            .firstWhere((step) => step.id == StructureSetupStepId.streams)
            .state,
        StructureStepState.notApplicable,
      );
    });

    test('secondary stream capacity cannot exceed parent class capacity', () {
      final base = _healthyContext(
        preferences: const StructureSetupPreferences(
          departments: StructureUseChoice.disabled,
          streams: StructureUseChoice.enabled,
          rooms: StructureUseChoice.disabled,
          houses: StructureUseChoice.disabled,
          clubs: StructureUseChoice.disabled,
          boarding: StructureUseChoice.disabled,
          transport: StructureUseChoice.disabled,
        ),
      );
      final resolution = engine.resolve(
        _copyContext(
          base,
          classes: const [
            SchoolClass(
              id: 's1',
              name: 'Senior 1',
              code: 'S1',
              levelId: 'primary',
              capacity: 100,
            ),
          ],
          streams: const [
            ClassStream(id: 'blue', name: 'Blue', classId: 's1', capacity: 50),
            ClassStream(id: 'red', name: 'Red', classId: 's1', capacity: 50),
            ClassStream(id: 'green', name: 'Green', classId: 's1', capacity: 20),
          ],
        ),
      );

      expect(resolution.isReady, isFalse);
      expect(
        resolution.issues.any(
          (issue) =>
              issue.stepId == StructureSetupStepId.streams &&
              issue.message.contains('exceeding class capacity 100'),
        ),
        isTrue,
      );
    });

    test('exactly matching stream capacity is valid', () {
      final base = _healthyContext(
        preferences: const StructureSetupPreferences(
          departments: StructureUseChoice.disabled,
          streams: StructureUseChoice.enabled,
          rooms: StructureUseChoice.disabled,
          houses: StructureUseChoice.disabled,
          clubs: StructureUseChoice.disabled,
          boarding: StructureUseChoice.disabled,
          transport: StructureUseChoice.disabled,
        ),
      );
      final resolution = engine.resolve(
        _copyContext(
          base,
          classes: const [
            SchoolClass(
              id: 'p5',
              name: 'Primary 5',
              code: 'P5',
              levelId: 'primary',
              capacity: 80,
            ),
          ],
          streams: const [
            ClassStream(id: 'blue', name: 'Blue', classId: 'p5', capacity: 40),
            ClassStream(id: 'red', name: 'Red', classId: 'p5', capacity: 40),
          ],
        ),
      );

      expect(
        resolution.issues.where((issue) => issue.stepId == StructureSetupStepId.streams),
        isEmpty,
      );
    });

    test('overlapping terms are rejected', () {
      final context = _healthyContext();
      final resolution = engine.resolve(
        _copyContext(
          context,
          academicTerms: [
            AcademicTerm(
              id: 'term1',
              academicYearId: '2026',
              name: 'Term 1',
              order: 1,
              startDate: DateTime(2026, 2, 2),
              endDate: DateTime(2026, 5, 1),
              isCurrent: true,
            ),
            AcademicTerm(
              id: 'term2',
              academicYearId: '2026',
              name: 'Term 2',
              order: 2,
              startDate: DateTime(2026, 4, 20),
              endDate: DateTime(2026, 8, 7),
            ),
          ],
        ),
      );

      expect(resolution.isReady, isFalse);
      expect(
        resolution.issues.any(
          (issue) => issue.stepId == StructureSetupStepId.academicTerms && issue.message.contains('overlaps'),
        ),
        isTrue,
      );
    });

    test('broken completed data is surfaced as Needs Attention', () {
      final context = _healthyContext();
      final resolution = engine.resolve(
        _copyContext(
          context,
          subjects: const [
            Subject(
              id: 'math',
              name: 'Mathematics',
              code: 'MATH',
              departmentId: 'missing-department',
              assignedLevelIds: ['primary'],
              assignedClassIds: ['p5'],
            ),
          ],
        ),
      );

      expect(resolution.isReady, isFalse);
      expect(
        resolution.issues.any(
          (issue) => issue.stepId == StructureSetupStepId.subjects && issue.message.contains('missing or inactive department'),
        ),
        isTrue,
      );
    });

    test('dependency graph is acyclic and prerequisites only point backward', () {
      final resolution = engine.resolve(_healthyContext());
      const validator = StructureDependencyGraphValidator();

      expect(validator.validate(resolution.steps), isEmpty);
    });
  });
}

StructureSetupContext _healthyContext({
  StructureSetupPreferences? preferences,
}) {
  return StructureSetupContext(
    institutionProfile: const InstitutionProfile(
      name: 'School Pulse Structure E2E Test School',
      shortName: 'SPTEST',
      schoolType: 'Combined Primary & Secondary',
      schoolCategory: 'Day',
      country: 'Uganda',
      district: 'Wakiso',
      city: 'Wakiso',
      phone: '0700000000',
      email: 'structure-test@example.invalid',
      timeZone: 'Africa/Kampala',
      currency: 'UGX',
      language: 'English',
      dateFormat: 'dd/MM/yyyy',
      timeFormat: '24h',
    ),
    preferences: preferences ??
        const StructureSetupPreferences(
          departments: StructureUseChoice.disabled,
          streams: StructureUseChoice.disabled,
          rooms: StructureUseChoice.disabled,
          houses: StructureUseChoice.disabled,
          clubs: StructureUseChoice.disabled,
          boarding: StructureUseChoice.disabled,
          transport: StructureUseChoice.disabled,
        ),
    featureToggles: const FeatureToggles(
      transport: false,
      hostel: false,
      boarding: false,
      communication: false,
    ),
    academicYears: [
      AcademicYear(
        id: '2026',
        name: '2026',
        startDate: DateTime(2026, 1, 20),
        endDate: DateTime(2026, 12, 10),
        isCurrent: true,
      ),
    ],
    academicTerms: [
      AcademicTerm(
        id: 'term1',
        academicYearId: '2026',
        name: 'Term 1',
        order: 1,
        startDate: DateTime(2026, 2, 2),
        endDate: DateTime(2026, 5, 1),
        isCurrent: true,
      ),
      AcademicTerm(
        id: 'term2',
        academicYearId: '2026',
        name: 'Term 2',
        order: 2,
        startDate: DateTime(2026, 5, 25),
        endDate: DateTime(2026, 8, 7),
      ),
      AcademicTerm(
        id: 'term3',
        academicYearId: '2026',
        name: 'Term 3',
        order: 3,
        startDate: DateTime(2026, 9, 7),
        endDate: DateTime(2026, 12, 4),
      ),
    ],
    levels: const [
      EducationalLevel(id: 'primary', name: 'Primary', code: 'PRI', order: 1),
    ],
    departments: const [],
    classes: const [
      SchoolClass(
        id: 'p5',
        name: 'Primary 5',
        code: 'P5',
        levelId: 'primary',
        capacity: 80,
      ),
    ],
    streams: const [],
    subjects: const [
      Subject(
        id: 'math',
        name: 'Mathematics',
        code: 'MATH',
        assignedLevelIds: ['primary'],
        assignedClassIds: ['p5'],
      ),
    ],
    assessmentTypes: const [
      AssessmentTypeDef(id: 'exam', name: 'End of Term Exam', weightPercentage: 100),
    ],
    gradingSystems: const [
      GradingSystemDef(
        id: 'primary-percentage',
        name: 'Primary Internal Percentage Scale',
        type: 'percentage',
        isDefault: true,
      ),
    ],
    gradeBands: const [
      GradeBand(
        id: 'a',
        gradingSystemId: 'primary-percentage',
        grade: 'A',
        minScore: 80,
        maxScore: 100,
        order: 1,
      ),
      GradeBand(
        id: 'b',
        gradingSystemId: 'primary-percentage',
        grade: 'B',
        minScore: 60,
        maxScore: 79.99,
        order: 2,
      ),
      GradeBand(
        id: 'c',
        gradingSystemId: 'primary-percentage',
        grade: 'C',
        minScore: 0,
        maxScore: 59.99,
        order: 3,
      ),
    ],
    facilities: const [],
    timetableConfig: const TimetableConfig(
      teachingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      periodsPerDay: 3,
      schoolStartTime: '08:00',
      schoolEndTime: '12:00',
      slots: [
        TimetableSlot(name: 'Period 1', startTime: '08:00', endTime: '08:45'),
        TimetableSlot(name: 'Break', startTime: '08:45', endTime: '09:05', type: 'break'),
        TimetableSlot(name: 'Period 2', startTime: '09:05', endTime: '09:50'),
        TimetableSlot(name: 'Period 3', startTime: '09:50', endTime: '10:35'),
      ],
    ),
    designations: const [
      StaffDesignation(id: 'teacher', name: 'Teacher'),
    ],
    staffRoles: const [
      StaffRole(id: 'subject-teacher', name: 'Subject Teacher', designationId: 'teacher'),
    ],
    houses: const [],
    clubs: const [],
    hostels: const [],
    hostelRooms: const [],
    transportRoutes: const [],
    transportStops: const [],
    transportVehicles: const [],
    attendanceTypes: const [
      AttendanceTypeDef(id: 'present', name: 'Present'),
    ],
    feeCategories: const [],
    announcementCategories: const [],
    notificationCategories: const [],
    messageTemplates: const [],
  );
}

StructureSetupContext _copyContext(
  StructureSetupContext source, {
  List<AcademicTerm>? academicTerms,
  List<SchoolClass>? classes,
  List<ClassStream>? streams,
  List<Subject>? subjects,
}) {
  return StructureSetupContext(
    institutionProfile: source.institutionProfile,
    preferences: source.preferences,
    featureToggles: source.featureToggles,
    academicYears: source.academicYears,
    academicTerms: academicTerms ?? source.academicTerms,
    levels: source.levels,
    departments: source.departments,
    classes: classes ?? source.classes,
    streams: streams ?? source.streams,
    subjects: subjects ?? source.subjects,
    assessmentTypes: source.assessmentTypes,
    gradingSystems: source.gradingSystems,
    gradeBands: source.gradeBands,
    facilities: source.facilities,
    timetableConfig: source.timetableConfig,
    designations: source.designations,
    staffRoles: source.staffRoles,
    houses: source.houses,
    clubs: source.clubs,
    hostels: source.hostels,
    hostelRooms: source.hostelRooms,
    transportRoutes: source.transportRoutes,
    transportStops: source.transportStops,
    transportVehicles: source.transportVehicles,
    attendanceTypes: source.attendanceTypes,
    feeCategories: source.feeCategories,
    announcementCategories: source.announcementCategories,
    notificationCategories: source.notificationCategories,
    messageTemplates: source.messageTemplates,
  );
}
