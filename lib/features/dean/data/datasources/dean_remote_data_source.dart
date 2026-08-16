import '../models/dean_stats_model.dart';
import '../../domain/entities/academic_dashboard_stats.dart';
import '../../domain/entities/teacher_workload.dart';
import '../../domain/entities/lesson_tracking.dart';
import '../../domain/entities/homework_record.dart';
import '../../domain/entities/academic_intervention.dart';
import '../../domain/entities/class_observation.dart';
import '../../domain/entities/curriculum.dart';
import '../../domain/entities/assessment_moderation.dart';

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
  Future<Map<String, dynamic>> getPerformanceAnalytics({
    required String type,
    String? id,
    String? academicYear,
    String? term,
  });
  Future<Map<String, dynamic>> getMasterTimetable();
  Future<List> getExaminationSchedules();
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
    };
  }

  @override
  Future<Map<String, dynamic>> getMasterTimetable() async => {};

  @override
  Future<List> getExaminationSchedules() async => [];

  @override
  Future<void> sendAcademicAnnouncement({
    required String title,
    required String message,
    required List<String> targetRoles,
    List<String>? targetIds,
  }) async {}
}
