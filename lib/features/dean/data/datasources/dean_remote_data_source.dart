import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/structure/domain/services/structure_configuration_service.dart';
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
  Future<void> approveAssessmentMarks({
    required String schoolId,
    required String assessmentId,
  });
  Future<void> rejectAssessmentMarks({
    required String schoolId,
    required String assessmentId,
    required String reason,
  });
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
  Future<List<AssessmentModeration>> getAssessmentsOverview({
    required String schoolId,
  });
  Future<void> createAssessment({
    required String schoolId,
    String? campusId,
    required String title,
    required String subjectId,
    required String classId,
    required String type,
    required double maximumMark,
  });
  Future<Map<String, dynamic>> getStudentAcademicProfile(String studentId);
  Future<void> sendAcademicAnnouncement({
    required String title,
    required String message,
    required List<String> targetRoles,
    List<String>? targetIds,
  });
}

class DeanRemoteDataSourceImpl implements DeanRemoteDataSource {
  DeanRemoteDataSourceImpl({
    required this.firestore,
    required this.structureConfigurationService,
  });

  final FirebaseFirestore firestore;
  final StructureConfigurationService structureConfigurationService;

  CollectionReference<Map<String, dynamic>> _assessments(String schoolId) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('subject_assessments');

  CollectionReference<Map<String, dynamic>> _marks(String schoolId) =>
      firestore.collection('schools').doc(schoolId).collection('student_marks');

  static const _visibleStatuses = [
    'submitted',
    'approved',
    'published',
    'locked',
    'returned',
  ];

  ModerationStatus _moderationStatusFor(String status) {
    switch (status) {
      case 'approved':
      case 'published':
      case 'locked':
        return ModerationStatus.approved;
      case 'returned':
        return ModerationStatus.rejected;
      default:
        return ModerationStatus.pending;
    }
  }

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
        teacherName: "Mr. Ssemanda",
        weeklyLessonsCount: 22,
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
      TeacherWorkload(
        teacherId: "t2",
        teacherName: "Ms. Nakato",
        weeklyLessonsCount: 20,
        lessonsDelivered: 20,
        lessonsMissed: 0,
        assessmentsCreated: 4,
        marksPending: 0,
        assignedSubjects: const [
          AssignedSubject(
            subjectId: "s2",
            subjectName: "English",
            classId: "c3",
            className: "S3B",
            weeklyLessons: 20,
          ),
        ],
      ),
      TeacherWorkload(
        teacherId: "t3",
        teacherName: "Mr. Ogwang",
        weeklyLessonsCount: 25,
        lessonsDelivered: 15,
        lessonsMissed: 5,
        assessmentsCreated: 3,
        marksPending: 12,
        assignedSubjects: const [
          AssignedSubject(
            subjectId: "s3",
            subjectName: "Physics",
            classId: "c4",
            className: "S4A",
            weeklyLessons: 25,
          ),
        ],
      ),
      TeacherWorkload(
        teacherId: "t4",
        teacherName: "Ms. Achieng",
        weeklyLessonsCount: 18,
        lessonsDelivered: 16,
        lessonsMissed: 1,
        assessmentsCreated: 6,
        marksPending: 8,
        assignedSubjects: const [
          AssignedSubject(
            subjectId: "s4",
            subjectName: "Biology",
            classId: "c5",
            className: "S2B",
            weeklyLessons: 18,
          ),
        ],
      ),
      TeacherWorkload(
        teacherId: "t5",
        teacherName: "Mr. Kato",
        weeklyLessonsCount: 15,
        lessonsDelivered: 12,
        lessonsMissed: 1,
        assessmentsCreated: 2,
        marksPending: 3,
        assignedSubjects: const [
          AssignedSubject(
            subjectId: "s5",
            subjectName: "History",
            classId: "c6",
            className: "S1A",
            weeklyLessons: 15,
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
  Future<void> approveAssessmentMarks({
    required String schoolId,
    required String assessmentId,
  }) async {
    await _setAssessmentMarksStatus(
      schoolId: schoolId,
      assessmentId: assessmentId,
      assessmentStatus: 'approved',
      markStatus: 'approved',
    );
  }

  @override
  Future<void> rejectAssessmentMarks({
    required String schoolId,
    required String assessmentId,
    required String reason,
  }) async {
    await _setAssessmentMarksStatus(
      schoolId: schoolId,
      assessmentId: assessmentId,
      assessmentStatus: 'returned',
      markStatus: 'returned',
      rejectionReason: reason,
    );
  }

  /// Moves an assessment's moderation status and every one of its marks in
  /// lockstep. The class teacher's report engine reads `student_marks` by
  /// `markStatus` alone (it has no notion of `subject_assessments`), while
  /// the QA screens read `subject_assessments.status` - so a decision here
  /// that only touched one collection would leave the other showing stale
  /// information.
  Future<void> _setAssessmentMarksStatus({
    required String schoolId,
    required String assessmentId,
    required String assessmentStatus,
    required String markStatus,
    String? rejectionReason,
  }) async {
    final assessmentRef = _assessments(schoolId).doc(assessmentId);
    final marksSnapshot = await _marks(
      schoolId,
    ).where('assessmentId', isEqualTo: assessmentId).get();

    // A batch caps at 500 writes; one per mark document plus the assessment
    // itself is comfortably within that for a single assessment's cohort,
    // but chunk defensively rather than assume a class size ceiling.
    const chunkSize = 400;
    final markDocs = marksSnapshot.docs;

    for (var offset = 0; offset < markDocs.length; offset += chunkSize) {
      final batch = firestore.batch();
      if (offset == 0) {
        batch.update(assessmentRef, {
          'status': assessmentStatus,
          if (rejectionReason != null) 'rejectionReason': rejectionReason,
        });
      }
      for (final doc in markDocs.skip(offset).take(chunkSize)) {
        batch.update(doc.reference, {
          'markStatus': markStatus,
          if (rejectionReason != null) 'returnReason': rejectionReason,
        });
      }
      await batch.commit();
    }

    if (markDocs.isEmpty) {
      // No marks yet is still a valid moderation decision on the assessment
      // itself (e.g. rejecting before any submissions exist).
      await assessmentRef.update({
        'status': assessmentStatus,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
      });
    }
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
        'overallReadiness': 0.72,
        'mockExamsCompleted': 3,
        'mockExamsPlanned': 4,
        'candidatesRegistered': 240,
        'readinessCategories': [
          {'category': 'Candidate Records', 'readiness': 0.85},
          {'category': 'Subject Achievement', 'readiness': 0.68},
          {'category': 'Activities of Integration', 'readiness': 0.60},
          {'category': 'Project Work', 'readiness': 0.70},
          {'category': 'CA Marks Completion', 'readiness': 0.75},
          {'category': 'Exam Readiness', 'readiness': 0.80},
        ],
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
        'overallReadiness': 0.78,
        'classesReady': 10,
        'classesTotal': 16,
        'marksCompletePct': 0.78,
        'teacherRemarksPct': 0.65,
        'classTeacherRemarksPct': 0.72,
        'moderationCompletePct': 0.60,
        'dosReviewStatus': 'Pending',
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
  Future<List<AssessmentModeration>> getAssessmentsOverview({
    required String schoolId,
  }) async {
    final year = await structureConfigurationService.getCurrentAcademicYear(
      schoolId,
    );
    final term = await structureConfigurationService.getCurrentAcademicPeriod(
      schoolId,
    );
    if (year == null) return [];

    Query<Map<String, dynamic>> query = _assessments(schoolId)
        .where('academicYearId', isEqualTo: year.id)
        .where('status', whereIn: _visibleStatuses);
    if (term != null) {
      query = query.where('termId', isEqualTo: term.id);
    }

    final snapshot = await query.get();
    final results = <AssessmentModeration>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final subjectId = data['subjectId'] as String? ?? '';
      final classId = data['classId'] as String? ?? '';
      final assessmentId = doc.id;

      final marksSnapshot = await _marks(
        schoolId,
      ).where('assessmentId', isEqualTo: assessmentId).get();
      final scores = marksSnapshot.docs
          .map((m) => (m.data()['score'] as num?)?.toDouble())
          .whereType<double>()
          .toList();
      final submissionCount = scores.length;
      final averageScore = scores.isEmpty
          ? 0.0
          : scores.reduce((a, b) => a + b) / scores.length;

      final subjectName = await _lookupName(
        collection: 'subjects',
        id: subjectId,
      );
      final className = await _lookupName(collection: 'classes', id: classId);
      final teacherStaffId = data['staffId'] as String? ?? '';
      final teacherName = teacherStaffId.isEmpty
          ? ''
          : await _lookupUserName(teacherStaffId);

      results.add(
        AssessmentModeration(
          id: assessmentId,
          assessmentId: assessmentId,
          title: data['title'] as String? ?? '',
          className: className,
          subjectName: subjectName,
          teacherName: teacherName,
          submissionCount: submissionCount,
          totalStudents: submissionCount,
          averageScore: averageScore,
          status: _moderationStatusFor(data['status'] as String? ?? ''),
          rejectionReason: data['rejectionReason'] as String?,
          createdAt:
              (data['assessmentDate'] as Timestamp?)?.toDate() ??
              DateTime.now(),
          subjectId: subjectId,
          classId: classId,
          teacherStaffId: teacherStaffId,
          academicYearId: data['academicYearId'] as String? ?? '',
          termId: data['termId'] as String? ?? '',
        ),
      );
    }

    return results;
  }

  Future<String> _lookupName({
    required String collection,
    required String id,
  }) async {
    if (id.isEmpty) return '';
    final doc = await firestore.collection(collection).doc(id).get();
    if (!doc.exists) return '';
    final data = doc.data();
    return (data?['name'] as String?) ?? '';
  }

  Future<String> _lookupUserName(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) return '';
    final data = doc.data();
    return (data?['name'] as String?) ?? '';
  }

  @override
  Future<void> createAssessment({
    required String schoolId,
    String? campusId,
    required String title,
    required String subjectId,
    required String classId,
    required String type,
    required double maximumMark,
  }) async {
    final year = await structureConfigurationService.getCurrentAcademicYear(
      schoolId,
    );
    final term = await structureConfigurationService.getCurrentAcademicPeriod(
      schoolId,
    );

    final componentId = _assessments(schoolId).doc().id;
    await _assessments(schoolId).add({
      'campusId': campusId,
      'academicYearId': year?.id ?? '',
      'termId': term?.id ?? '',
      'subjectId': subjectId,
      'classId': classId,
      'assessmentTypeId': type.toLowerCase().replaceAll(' ', '_'),
      'assessmentTypeName': type,
      'title': title,
      'maximumMark': maximumMark,
      'status': 'draft',
      'requiresApproval': true,
      'components': [
        {
          'id': componentId,
          'name': title,
          'maximumMark': maximumMark,
          'weight': 100.0,
          'isRequired': true,
          'entryStatus': 'draft',
        },
      ],
    });
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
