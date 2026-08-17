import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/structure/domain/entities/assessment_grading_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/attendance_config_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/curriculum_assignment.dart';
import 'package:school_pulse/features/structure/domain/entities/feature_toggles.dart';
import 'package:school_pulse/features/structure/domain/entities/institution_profile.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_setup_preferences.dart';
import 'package:school_pulse/features/structure/domain/entities/teaching_assignment.dart';
import 'package:school_pulse/features/structure/domain/entities/timetable.dart';
import 'package:school_pulse/features/structure/domain/entities/timetable_config.dart';
import 'package:school_pulse/features/structure/domain/services/structure_setup_engine.dart';

void main() {
  const engine = StructureSetupEngine();

  test(
    'runtime-ready school passes curriculum, staff, assignment and timetable chain',
    () {
      final resolution = engine.resolve(_runtimeContext());

      expect(resolution.isReady, isTrue);
      for (final id in const [
        StructureSetupStepId.curriculum,
        StructureSetupStepId.staffAccounts,
        StructureSetupStepId.academicAssignments,
        StructureSetupStepId.classTimetables,
      ]) {
        expect(
          resolution.steps.firstWhere((step) => step.id == id).isSatisfied,
          isTrue,
          reason: '$id should be satisfied',
        );
      }
    },
  );

  test('missing teacher assignment blocks timetable dependency chain', () {
    final resolution = engine.resolve(
      _runtimeContext(teachingAssignments: const []),
    );

    expect(resolution.isReady, isFalse);
    expect(
      resolution.issues.any(
        (issue) =>
            issue.stepId == StructureSetupStepId.academicAssignments &&
            issue.message.contains('no active Subject Teacher assignment'),
      ),
      isTrue,
    );
    expect(
      resolution.steps
          .firstWhere((step) => step.id == StructureSetupStepId.classTimetables)
          .prerequisitesComplete,
      isFalse,
    );
  });

  test('published timetable without lessons is not accepted as complete', () {
    final resolution = engine.resolve(
      _runtimeContext(timetableLessons: const []),
    );

    expect(resolution.isReady, isFalse);
    expect(
      resolution.issues.any(
        (issue) =>
            issue.stepId == StructureSetupStepId.classTimetables &&
            issue.message.contains('contains no lessons'),
      ),
      isTrue,
    );
  });
}

StructureSetupContext _runtimeContext({
  List<TeachingAssignment>? teachingAssignments,
  List<TimetableLesson>? timetableLessons,
}) {
  final year = AcademicYear(
    id: '2026',
    schoolId: 'school-a',
    name: '2026',
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 12, 31),
    isCurrent: true,
  );
  final term = AcademicTerm(
    id: 'term-1',
    schoolId: 'school-a',
    academicYearId: '2026',
    name: 'Term 1',
    order: 1,
    startDate: DateTime(2026, 2, 1),
    endDate: DateTime(2026, 5, 1),
    isCurrent: true,
  );

  return StructureSetupContext(
    institutionProfile: const InstitutionProfile(
      name: 'Runtime School',
      schoolType: 'Secondary',
      country: 'Uganda',
      timeZone: 'Africa/Kampala',
      currency: 'UGX',
    ),
    preferences: const StructureSetupPreferences(
      departments: StructureUseChoice.disabled,
      streams: StructureUseChoice.disabled,
      rooms: StructureUseChoice.disabled,
      houses: StructureUseChoice.disabled,
      clubs: StructureUseChoice.disabled,
      boarding: StructureUseChoice.disabled,
      transport: StructureUseChoice.disabled,
    ),
    featureToggles: const FeatureToggles(),
    academicYears: [year],
    academicTerms: [term],
    levels: const [
      EducationalLevel(
        id: 'secondary',
        schoolId: 'school-a',
        name: 'Secondary',
        code: 'SEC',
      ),
    ],
    departments: const [],
    classes: const [
      SchoolClass(
        id: 's1',
        schoolId: 'school-a',
        name: 'Senior 1',
        code: 'S1',
        levelId: 'secondary',
        capacity: 50,
      ),
    ],
    streams: const [],
    subjects: const [
      Subject(
        id: 'math',
        schoolId: 'school-a',
        name: 'Mathematics',
        code: 'MATH',
        assignedLevelIds: ['secondary'],
        assignedClassIds: ['s1'],
      ),
    ],
    assessmentTypes: const [
      AssessmentTypeDef(
        id: 'exam',
        schoolId: 'school-a',
        name: 'Exam',
        weightPercentage: 100,
      ),
    ],
    gradingSystems: const [
      GradingSystemDef(
        id: 'default',
        schoolId: 'school-a',
        name: 'Default',
        type: 'percentage',
        isDefault: true,
      ),
    ],
    gradeBands: const [
      GradeBand(
        id: 'all',
        schoolId: 'school-a',
        gradingSystemId: 'default',
        grade: 'P',
        minScore: 0,
        maxScore: 100,
      ),
    ],
    facilities: const [],
    timetableConfig: const TimetableConfig(
      teachingDays: ['Monday'],
      periodsPerDay: 1,
      schoolStartTime: '08:00',
      schoolEndTime: '09:00',
      slots: [
        TimetableSlot(name: 'Period 1', startTime: '08:00', endTime: '09:00'),
      ],
    ),
    designations: const [
      StaffDesignation(id: 'teacher', schoolId: 'school-a', name: 'Teacher'),
    ],
    houses: const [],
    clubs: const [],
    hostels: const [],
    hostelRooms: const [],
    transportRoutes: const [],
    transportStops: const [],
    transportVehicles: const [],
    attendanceTypes: const [
      AttendanceTypeDef(id: 'present', schoolId: 'school-a', name: 'Present'),
    ],
    feeCategories: const [],
    announcementCategories: const [],
    notificationCategories: const [],
    messageTemplates: const [],
    extendedDataLoaded: true,
    curriculumAssignments: const [
      CurriculumAssignment(
        id: 's1-math',
        schoolId: 'school-a',
        academicYearId: '2026',
        levelId: 'secondary',
        classId: 's1',
        subjectId: 'math',
      ),
    ],
    staff: const [
      UserEntity(
        id: 'teacher-a',
        name: 'Teacher A',
        email: 'teacher@example.invalid',
        schoolId: 'school-a',
        roles: [UserRole.subjectTeacher],
      ),
    ],
    teachingAssignments:
        teachingAssignments ??
        const [
          TeachingAssignment(
            id: 'teach-math',
            schoolId: 'school-a',
            staffId: 'teacher-a',
            academicYearId: '2026',
            responsibilityType: TeachingResponsibilityType.subjectTeacher,
            classId: 's1',
            subjectId: 'math',
          ),
        ],
    classTimetables: [
      Timetable(
        id: 'table-s1',
        schoolId: 'school-a',
        academicYearId: '2026',
        termId: 'term-1',
        classId: 's1',
        name: 'S1 Term 1',
        status: TimetableStatus.active,
        createdAt: DateTime(2026, 1, 1),
      ),
    ],
    timetableLessons:
        timetableLessons ??
        [
          TimetableLesson(
            id: 'lesson-1',
            schoolId: 'school-a',
            timetableId: 'table-s1',
            academicYearId: '2026',
            termId: 'term-1',
            classId: 's1',
            subjectId: 'math',
            teacherId: 'teacher-a',
            occurrences: const [
              TimetableLessonOccurrence(day: 'Monday', slotId: 'p1'),
            ],
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
  );
}
