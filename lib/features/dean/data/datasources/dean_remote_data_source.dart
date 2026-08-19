import '../models/dean_stats_model.dart';
import '../../domain/entities/academic_dashboard_stats.dart';
import '../../domain/entities/teacher_workload.dart';
import '../../domain/entities/lesson_tracking.dart';
import '../../domain/entities/homework_record.dart';
import '../../domain/entities/academic_intervention.dart';
import '../../domain/entities/class_observation.dart';
import '../../domain/entities/curriculum.dart';
import '../../domain/entities/assessment_moderation.dart';
import '../../domain/entities/report_card_approval.dart';
import '../../domain/entities/today_operations.dart';
import '../../domain/entities/examination_schedule.dart';

abstract class DeanRemoteDataSource {
  Future<DeanStatsModel> getDeanDashboardStats();
  Future<List<TeacherWorkload>> getTeacherWorkloads();
  Future<TeacherWorkload> getTeacherWorkloadDetail(String teacherId);
  Future<List<LessonRecord>> getLessonRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? teacherId,
    String? classId,
    LessonStatus? status,
  });
  Future<List<HomeworkRecord>> getHomeworkRecords({
    String? classId,
    String? teacherId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<AcademicIntervention>> getInterventions();
  Future<void> createIntervention(AcademicIntervention intervention);
  Future<void> updateInterventionStatus(
    String id,
    InterventionStatus status,
    String outcomes,
  );
  Future<List<ClassObservation>> getClassObservations();
  Future<void> recordObservation(ClassObservation observation);
  Future<List<Subject>> getSubjects();
  Future<void> updateSubjectAllocation(
    String subjectId,
    List<String> teacherIds,
  );
  Future<List<Curriculum>> getCurricula();
  Future<void> updateCurriculum(Curriculum curriculum);
  Future<void> approveAssessmentMarks(String assessmentId);
  Future<void> rejectAssessmentMarks(String assessmentId, String reason);
  Future<List<AssessmentModeration>> getPendingModerationAssessments();
  Future<void> approveReportCards(List<String> reportCardIds);
  Future<void> rejectReportCards(List<String> reportCardIds, String reason);
  Future<List<ReportCardApproval>> getPendingReportApprovals();
  Future<Map<String, dynamic>> getPerformanceAnalytics({
    required String type,
    String? id,
    String? academicYear,
    String? term,
  });
  Future<Map<String, dynamic>> getMasterTimetable();
  Future<List> getExaminationSchedules();
  Future<TodaysOperations> getTodaysOperations();
  Future<(List<LessonRecord>, Map<String, bool>)> getMissedLessons();
  Future<List<AssessmentModeration>> getAssessmentsOverview();
  Future<Map<String, dynamic>> getStudentAcademicProfile(String studentId);
  Future<void> sendAcademicAnnouncement({
    required String title,
    required String message,
    required List<String> targetRoles,
    List<String>? targetIds,
  });
}

class DeanRemoteDataSourceImpl implements DeanRemoteDataSource {
  @override
  Future<DeanStatsModel> getDeanDashboardStats() async {
    return DeanStatsModel(
      totalStudents: 1250,
      totalTeachers: 85,
      totalClasses: 40,
      totalSubjects: 15,
      currentAcademicYear: "2024",
      currentTerm: "Term 3",
      activeTimetables: 40,
      lessonsConductedToday: 180,
      lessonsMissedToday: 5,
      assessmentsPending: 12,
      marksPendingEntry: 45,
      reportCardsPendingApproval: 150,
      reportCardsPublished: 0,
      overallSchoolAverage: 72.4,
      topPerformingClasses: const [
        ClassPerformance(classId: "c1", className: "P.7 Blue", average: 88.5),
        ClassPerformance(
          classId: "c2",
          className: "S.4 Science",
          average: 82.1,
        ),
      ],
      bottomPerformingClasses: const [
        ClassPerformance(classId: "c3", className: "P.5 Red", average: 54.2),
      ],
      subjectRankings: const [
        SubjectPerformance(
          subjectId: "s1",
          subjectName: "Mathematics",
          average: 65.5,
        ),
        SubjectPerformance(
          subjectId: "s2",
          subjectName: "English",
          average: 78.2,
        ),
      ],
      attendanceTrend: 2.5,
      homeworkCompletionRate: 85.0,
      teacherLessonCompletionRate: 94.2,
      activeAlerts: [
        AcademicAlert(
          id: "a1",
          title: "Low Lesson Completion",
          message: "Mathematics department is below 80% coverage.",
          severity: AlertSeverity.high,
          timestamp: DateTime.now(),
        ),
        AcademicAlert(
          id: "a2",
          title: "Marks Entry Overdue",
          message: "S.4 Science Mid-Term marks are 3 days overdue.",
          severity: AlertSeverity.critical,
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        AcademicAlert(
          id: "a3",
          title: "Substitute Needed",
          message: "P.6 English lesson at 11:00am has no assigned teacher.",
          severity: AlertSeverity.medium,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        AcademicAlert(
          id: "a4",
          title: "Syllabus Coverage Dip",
          message: "History coverage dropped slightly this week.",
          severity: AlertSeverity.low,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );
  }

  @override
  Future<List<TeacherWorkload>> getTeacherWorkloads() async {
    return [
      TeacherWorkload(
        teacherId: "t1",
        teacherName: "John Doe",
        weeklyLessonsCount: 20,
        lessonsDelivered: 18,
        lessonsMissed: 2,
        assessmentsCreated: 5,
        marksPending: 45,
        assignedSubjects: const [
          AssignedSubject(
            subjectId: "s1",
            subjectName: "Mathematics",
            classId: "c1",
            className: "P.7 Blue",
            weeklyLessons: 10,
          ),
          AssignedSubject(
            subjectId: "s1",
            subjectName: "Mathematics",
            classId: "c2",
            className: "P.7 Red",
            weeklyLessons: 10,
          ),
        ],
      ),
    ];
  }

  @override
  Future<TeacherWorkload> getTeacherWorkloadDetail(String teacherId) async {
    return TeacherWorkload(
      teacherId: teacherId,
      teacherName: "John Doe",
      weeklyLessonsCount: 22,
      lessonsDelivered: 18,
      lessonsMissed: 1,
      assessmentsCreated: 4,
      marksPending: 24,
      assignedSubjects: const [],
    );
  }

  @override
  Future<List<LessonRecord>> getLessonRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? teacherId,
    String? classId,
    LessonStatus? status,
  }) async {
    return [
      LessonRecord(
        id: "l1",
        subjectId: "s1",
        subjectName: "Mathematics",
        classId: "c1",
        className: "Year 10A",
        teacherId: "t1",
        teacherName: "John Doe",
        scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: LessonStatus.completed,
        topicCovered: "Algebraic Equations",
      ),
    ];
  }

  @override
  Future<List<HomeworkRecord>> getHomeworkRecords({
    String? classId,
    String? teacherId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return [
      HomeworkRecord(
        id: "h1",
        title: "Algebra Worksheet",
        subjectId: "s1",
        subjectName: "Mathematics",
        classId: "c1",
        className: "P.7 Blue",
        teacherId: "t1",
        teacherName: "John Doe",
        assignedDate: DateTime.now().subtract(const Duration(days: 1)),
        dueDate: DateTime.now().add(const Duration(days: 2)),
        totalStudents: 30,
        submittedCount: 25,
        feedbackStatus: "Pending Feedback",
      ),
    ];
  }

  @override
  Future<List<AcademicIntervention>> getInterventions() async {
    return [
      AcademicIntervention(
        id: "i1",
        studentId: "st1",
        studentName: "Namono Grace",
        reason: "Declining Mathematics scores",
        type: InterventionType.remedial,
        status: InterventionStatus.inProgress,
        startDate: DateTime.now().subtract(const Duration(days: 14)),
        assignedTo: const ["t1"],
        outcomes: "Improving in latest tests",
      ),
    ];
  }

  @override
  Future<void> createIntervention(AcademicIntervention intervention) async {}

  @override
  Future<void> updateInterventionStatus(
    String id,
    InterventionStatus status,
    String outcomes,
  ) async {}

  @override
  Future<List<ClassObservation>> getClassObservations() async {
    return [
      ClassObservation(
        id: "o1",
        teacherId: "t1",
        teacherName: "John Doe",
        observerId: "d1",
        classId: "c1",
        className: "Year 10A",
        subjectId: "s1",
        subjectName: "Mathematics",
        date: DateTime.now().subtract(const Duration(days: 2)),
        strengths: "Clear communication",
        areasForImprovement: "Pacing of the lesson",
        recommendations: "Limit group work to 15 mins",
      ),
    ];
  }

  @override
  Future<void> recordObservation(ClassObservation observation) async {}

  @override
  Future<List<Subject>> getSubjects() async {
    return [
      Subject(
        id: "s1",
        name: "Mathematics",
        code: "MTH101",
        department: "Science",
        currentCoverage: 75.0,
        objectives: const [
          LearningObjective(
            id: "o1",
            description: "Understand linear equations",
            isCore: true,
          ),
          LearningObjective(
            id: "o2",
            description: "Solve quadratic equations",
            isCore: true,
          ),
          LearningObjective(
            id: "o3",
            description: "Introduction to Calculus",
            isCore: false,
          ),
        ],
        topics: [
          Topic(
            id: "t1",
            title: "Algebra I",
            estimatedLessons: 10,
            subTopics: const [
              SubTopic(id: "st1", title: "Linear Equations", isCompleted: true),
              SubTopic(id: "st2", title: "Inequalities", isCompleted: true),
              SubTopic(id: "st3", title: "Functions", isCompleted: false),
            ],
          ),
          Topic(
            id: "t2",
            title: "Geometry",
            estimatedLessons: 8,
            subTopics: const [
              SubTopic(id: "st4", title: "Triangles", isCompleted: false),
              SubTopic(id: "st5", title: "Circles", isCompleted: false),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  Future<void> updateSubjectAllocation(
    String subjectId,
    List<String> teacherIds,
  ) async {}

  @override
  Future<void> updateCurriculum(Curriculum curriculum) async {}

  @override
  Future<List<Curriculum>> getCurricula() async {
    final subjects = await getSubjects();
    return [
      Curriculum(
        id: "c1",
        schoolId: "s1",
        name: "National Primary Curriculum",
        description: "The standard curriculum for primary schools in Uganda.",
        applicableLevels: const [
          "P.1",
          "P.2",
          "P.3",
          "P.4",
          "P.5",
          "P.6",
          "P.7",
        ],
        subjects: subjects,
        calendarConfig: const AcademicCalendarConfig(
          termsPerYear: 3,
          termNames: ["Term 1", "Term 2", "Term 3"],
          defaultWeighting: [
            AssessmentWeighting(type: "Continuous Assessment", weight: 30),
            AssessmentWeighting(type: "End of Term Exam", weight: 70),
          ],
        ),
      ),
    ];
  }

  @override
  Future<void> approveAssessmentMarks(String assessmentId) async {}

  @override
  Future<void> rejectAssessmentMarks(
    String assessmentId,
    String reason,
  ) async {}

  @override
  Future<List<AssessmentModeration>> getPendingModerationAssessments() async {
    return [
      AssessmentModeration(
        id: "am1",
        assessmentId: "as1",
        title: "Mid-Term Algebra Test",
        className: "Year 10A",
        subjectName: "Mathematics",
        teacherName: "John Doe",
        submissionCount: 28,
        totalStudents: 30,
        averageScore: 72.5,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AssessmentModeration(
        id: "am2",
        assessmentId: "as2",
        title: "Weekly Physics Quiz",
        className: "S.4 Science",
        subjectName: "Physics",
        teacherName: "Jane Smith",
        submissionCount: 45,
        totalStudents: 45,
        averageScore: 68.2,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  @override
  Future<void> approveReportCards(List<String> reportCardIds) async {}

  @override
  Future<void> rejectReportCards(
    List<String> reportCardIds,
    String reason,
  ) async {}

  @override
  Future<List<ReportCardApproval>> getPendingReportApprovals() async {
    return [
      const ReportCardApproval(
        id: "rc1",
        studentId: "st1",
        studentName: "Namono Grace",
        className: "P.7 Blue",
        averageScore: 88.5,
        term: "Term 3",
        year: "2024",
      ),
      const ReportCardApproval(
        id: "rc2",
        studentId: "st2",
        studentName: "Musa Kevin",
        className: "P.7 Blue",
        averageScore: 72.1,
        term: "Term 3",
        year: "2024",
      ),
    ];
  }

  @override
  Future<Map<String, dynamic>> getPerformanceAnalytics({
    required String type,
    String? id,
    String? academicYear,
    String? term,
  }) async {
    return {
      'gradeDistribution': {
        'D1': 15,
        'D2': 25,
        'C3': 45,
        'C4': 60,
        'C5': 30,
        'C6': 20,
        'P7': 10,
        'P8': 5,
        'F9': 2,
      },
      'subjectPassRates': [
        {'subject': 'Mathematics', 'rate': 0.88},
      ],
      'topStudents': [
        {'name': 'Namono Grace', 'class': 'P.7 Blue', 'score': 0.92},
      ],
      'unebReadiness': {
        'overallReadiness': 0.78,
        'mockExamsCompleted': 3,
        'mockExamsPlanned': 4,
        'candidatesRegistered': 240,
        'subjectBreakdown': [
          {
            'subject': 'Mathematics',
            'readiness': 0.82,
            'passRateProjection': 0.75,
          },
          {'subject': 'English', 'readiness': 0.88, 'passRateProjection': 0.81},
          {'subject': 'Science', 'readiness': 0.70, 'passRateProjection': 0.66},
          {
            'subject': 'Social Studies',
            'readiness': 0.74,
            'passRateProjection': 0.69,
          },
        ],
      },
      'reportsReadiness': {
        'overallReadiness': 0.62,
        'reportCardsPublished': 0,
        'reportCardsPendingApproval': 150,
        'marksFullyEntered': 0.71,
        'classBreakdown': [
          {'className': 'P.7 Blue', 'readiness': 0.90},
          {'className': 'P.7 Red', 'readiness': 0.65},
          {'className': 'S.4 Science', 'readiness': 0.55},
          {'className': 'S.4 Arts', 'readiness': 0.40},
        ],
      },
    };
  }

  @override
  Future<Map<String, dynamic>> getMasterTimetable() async => {};

  @override
  Future<List<ExaminationSchedule>> getExaminationSchedules() async {
    return [
      ExaminationSchedule(
        id: "ex1",
        examName: "Mid-Term Examination",
        subjectId: "s1",
        subjectName: "Mathematics",
        className: "S.4 Science",
        date: DateTime.now().add(const Duration(days: 2)),
        startTime: "08:00",
        durationLabel: "2h 30m",
        venue: "Main Hall",
        status: ExaminationStatus.scheduled,
      ),
      ExaminationSchedule(
        id: "ex2",
        examName: "Mid-Term Examination",
        subjectId: "s2",
        subjectName: "English",
        className: "S.4 Science",
        date: DateTime.now().add(const Duration(days: 2)),
        startTime: "11:00",
        durationLabel: "2h",
        venue: "Main Hall",
        status: ExaminationStatus.scheduled,
      ),
      ExaminationSchedule(
        id: "ex3",
        examName: "End of Term Exam",
        subjectId: "s3",
        subjectName: "Physics",
        className: "S.4 Science",
        date: DateTime.now().subtract(const Duration(days: 1)),
        startTime: "09:00",
        durationLabel: "3h",
        venue: "Lab Block",
        status: ExaminationStatus.marksPending,
      ),
      ExaminationSchedule(
        id: "ex4",
        examName: "Continuous Assessment Test",
        subjectId: "s1",
        subjectName: "Mathematics",
        className: "P.7 Blue",
        date: DateTime.now().subtract(const Duration(days: 5)),
        startTime: "10:00",
        durationLabel: "1h 30m",
        venue: "P.7 Blue Classroom",
        status: ExaminationStatus.published,
      ),
      ExaminationSchedule(
        id: "ex5",
        examName: "Mock UNEB Exam",
        subjectId: "s4",
        subjectName: "Biology",
        className: "S.4 Science",
        date: DateTime.now(),
        startTime: "13:00",
        durationLabel: "2h",
        venue: "Science Block",
        status: ExaminationStatus.inProgress,
      ),
      ExaminationSchedule(
        id: "ex6",
        examName: "End of Term Exam",
        subjectId: "s5",
        subjectName: "History",
        className: "S.3 Arts",
        date: DateTime.now().add(const Duration(days: 7)),
        startTime: "08:30",
        durationLabel: "2h",
        venue: "Room 12",
        status: ExaminationStatus.scheduled,
      ),
    ];
  }

  @override
  Future<TodaysOperations> getTodaysOperations() async {
    return const TodaysOperations(
      lessonsScheduled: 210,
      lessonsCompleted: 168,
      lessonsInProgress: 12,
      lessonsMissed: 5,
      assessmentsToday: 8,
      awaitingConfirmation: 3,
      teacherAbsences: 4,
      substituteLessons: 3,
      examinationsToday: 1,
      meetingsToday: 2,
    );
  }

  @override
  Future<(List<LessonRecord>, Map<String, bool>)> getMissedLessons() async {
    final lessons = [
      LessonRecord(
        id: "ml1",
        subjectId: "s2",
        subjectName: "English",
        classId: "c4",
        className: "P.6 Green",
        teacherId: "t2",
        teacherName: "Jane Smith",
        scheduledAt: DateTime.now().subtract(const Duration(hours: 3)),
        status: LessonStatus.missed,
        remarks: "Teacher on sick leave, no substitute assigned",
      ),
      LessonRecord(
        id: "ml2",
        subjectId: "s3",
        subjectName: "Physics",
        classId: "c2",
        className: "S.4 Science",
        teacherId: "t3",
        teacherName: "Robert Okello",
        scheduledAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        status: LessonStatus.missed,
        remarks: "Lab unavailable due to maintenance",
      ),
      LessonRecord(
        id: "ml3",
        subjectId: "s1",
        subjectName: "Mathematics",
        classId: "c1",
        className: "P.7 Blue",
        teacherId: "t1",
        teacherName: "John Doe",
        scheduledAt: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
        status: LessonStatus.missed,
        remarks: "Resolved: makeup lesson held Saturday",
      ),
    ];
    final resolvedById = {"ml1": false, "ml2": false, "ml3": true};
    return (lessons, resolvedById);
  }

  @override
  Future<List<AssessmentModeration>> getAssessmentsOverview() async {
    return [
      AssessmentModeration(
        id: "ao1",
        assessmentId: "as1",
        title: "Mid-Term Algebra Test",
        className: "Year 10A",
        subjectName: "Mathematics",
        teacherName: "John Doe",
        submissionCount: 28,
        totalStudents: 30,
        averageScore: 72.5,
        status: ModerationStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AssessmentModeration(
        id: "ao2",
        assessmentId: "as2",
        title: "Weekly Physics Quiz",
        className: "S.4 Science",
        subjectName: "Physics",
        teacherName: "Jane Smith",
        submissionCount: 45,
        totalStudents: 45,
        averageScore: 68.2,
        status: ModerationStatus.approved,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      AssessmentModeration(
        id: "ao3",
        assessmentId: "as3",
        title: "English Comprehension CAT",
        className: "P.6 Green",
        subjectName: "English",
        teacherName: "Robert Okello",
        submissionCount: 30,
        totalStudents: 32,
        averageScore: 61.0,
        status: ModerationStatus.rejected,
        rejectionReason: "Marks entry incomplete for 2 students",
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  @override
  Future<Map<String, dynamic>> getStudentAcademicProfile(
    String studentId,
  ) async {
    return {
      'studentId': studentId,
      'studentName': 'Namono Grace',
      'className': 'P.7 Blue',
      'admissionNumber': 'SP-2024-0142',
      'attendanceRate': 0.94,
      'overallAverage': 84.2,
      'term1Marks': {
        'Mathematics': 78.0,
        'English': 82.0,
        'Science': 75.0,
        'Social Studies': 88.0,
      },
      'term2Marks': {
        'Mathematics': 85.0,
        'English': 86.0,
        'Science': 80.0,
        'Social Studies': 90.0,
      },
      'subjectTeachers': [
        {'subject': 'Mathematics', 'teacher': 'John Doe'},
        {'subject': 'English', 'teacher': 'Jane Smith'},
        {'subject': 'Science', 'teacher': 'Robert Okello'},
        {'subject': 'Social Studies', 'teacher': 'Mary Namutebi'},
      ],
      'interventions': [
        {'reason': 'Declining Mathematics scores', 'status': 'inProgress'},
      ],
      'remarks':
          'Consistent improvement across Term 2; recommend continued remedial support in Science.',
    };
  }

  @override
  Future<void> sendAcademicAnnouncement({
    required String title,
    required String message,
    required List<String> targetRoles,
    List<String>? targetIds,
  }) async {}
}
