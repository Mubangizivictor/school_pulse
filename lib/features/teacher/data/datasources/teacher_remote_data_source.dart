import 'package:cloud_firestore/cloud_firestore.dart';
import '../../presentation/bloc/teacher_state.dart';
import '../../domain/usecases/get_attendance_history.dart';
import '../../domain/entities/teacher_dashboard_stats.dart';
import '../../domain/entities/homework.dart';
import '../../domain/entities/report_comment.dart';
import '../../domain/entities/competency_rating.dart';
import 'package:school_pulse/features/structure/domain/entities/assessment_grading_entities.dart';
import 'package:school_pulse/features/structure/domain/services/grade_resolver.dart';

abstract class TeacherRemoteDataSource {
  Future<List<TeacherStudent>> getStudentsByClass(
    String schoolId,
    String className,
  );
  Future<void> submitAttendance({
    required String schoolId,
    required String className,
    required DateTime date,
    required Map<String, String> attendance,
  });
  Future<void> submitMarks({
    required String schoolId,
    required String className,
    required String subject,
    required String assessment,
    required String term,
    required String year,
    required Map<String, double> marks,
  });
  Future<List<AttendanceHistoryRecord>> getAttendanceHistory(String teacherId);
  Future<TeacherDashboardStats> getTeacherDashboardStats(String teacherId);

  // Homework
  Future<List<Homework>> getHomework(String schoolId, String teacherId);
  Future<void> createHomework(Homework homework);
  Future<void> updateHomework(Homework homework);
  Future<void> deleteHomework(String homeworkId, {required String schoolId});

  // Report Comments
  Future<List<ReportComment>> getReportComments({
    required String schoolId,
    required String className,
    required String term,
    required String year,
  });
  Future<void> saveReportComment(ReportComment comment);

  // Competency Ratings
  Future<List<CompetencyRating>> getCompetencyRatings({
    required String schoolId,
    required String className,
    required String term,
    required String year,
    required String competency,
  });
  Future<void> saveCompetencyRating(CompetencyRating rating);

  Future<void> generateReports({
    required String schoolId,
    required String className,
    required String term,
    required String year,
    required List<String> studentIds,
    required List<String> enabledSections,
  });
}

class TeacherRemoteDataSourceImpl implements TeacherRemoteDataSource {
  final FirebaseFirestore firestore;

  TeacherRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<TeacherStudent>> getStudentsByClass(
    String schoolId,
    String className,
  ) async {
    final snapshot = await firestore
        .collection('students')
        .where('schoolId', isEqualTo: schoolId)
        .where('className', isEqualTo: className)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return TeacherStudent(
        id: doc.id,
        name: data['name'] ?? '',
        studentId: data['studentId'] ?? '',
        className: data['className'] ?? '',
      );
    }).toList();
  }

  @override
  Future<void> submitAttendance({
    required String schoolId,
    required String className,
    required DateTime date,
    required Map<String, String> attendance,
  }) async {
    final dateStr =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    // 'attendance_records' is the collection the parent app reads, so the
    // register a teacher submits here is what parents see. One doc per
    // student per day keeps re-submissions idempotent.
    final batch = firestore.batch();

    attendance.forEach((studentId, status) {
      final docRef = firestore
          .collection('attendance_records')
          .doc('${studentId}_$dateStr');
      batch.set(docRef, {
        'schoolId': schoolId,
        'studentId': studentId,
        'className': className,
        'date': Timestamp.fromDate(date),
        'status': status,
        'note': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    // Per-class daily summary that the attendance history screen lists.
    final presentCount = attendance.values.where((s) => s == 'present').length;
    final logRef = firestore
        .collection('attendance_logs')
        .doc('${className}_$dateStr');
    batch.set(logRef, {
      'schoolId': schoolId,
      'className': className,
      'date': Timestamp.fromDate(date),
      'presentCount': presentCount,
      'totalCount': attendance.length,
      'status': 'Submitted',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  @override
  Future<void> submitMarks({
    required String schoolId,
    required String className,
    required String subject,
    required String assessment,
    required String term,
    required String year,
    required Map<String, double> marks,
  }) async {
    // One doc per student/subject/term/year/assessment so a teacher can
    // correct marks by re-submitting. Written to 'academic_records', the
    // collection the parent academics and report card screens read.
    final system = await _resolveDefaultGradingSystem(schoolId);
    final bands = system == null
        ? const <GradeBand>[]
        : await _gradeBands(schoolId, system.id);
    const resolver = GradeResolver();

    final batch = firestore.batch();
    final slug = [
      subject,
      term,
      year,
      assessment,
    ].join('_').replaceAll(RegExp(r'\s+'), '-');

    marks.forEach((studentId, score) {
      // Resolution is intentionally left null (never a fabricated grade)
      // when the school has no grading system configured - that state
      // should be visibly "not graded", not silently mis-rendered under a
      // fallback scale the school never chose. See
      // Structure > Academics > Grading Systems.
      final resolution = system == null
          ? null
          : resolver.resolveScore(score: score, system: system, ranges: bands);

      final docRef = firestore
          .collection('academic_records')
          .doc('${studentId}_$slug');
      batch.set(docRef, {
        'studentId': studentId,
        'className': className,
        'subject': subject,
        'score': score,
        'grade': resolution?.gradeCode,
        'gradeLabel': resolution?.gradeLabel,
        'gradeColorHex': resolution == null
            ? null
            : bands
                  .where((b) => b.grade == resolution.gradeCode)
                  .map((b) => b.colorHex)
                  .firstOrNull,
        'isPassing': resolution?.isPassing,
        'gradingSystemId': system?.id,
        'gradingSystemVersion': system?.version,
        'term': term,
        'year': year,
        'assessment': assessment,
        'teacherRemark': '',
        'trend': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    await batch.commit();
  }

  /// The school's single active default grading system, if one is
  /// configured. Whole-school scoped for now - the wizard does not yet
  /// carry an educational-level/class context down to this call, so a
  /// level-scoped default cannot be resolved here.
  Future<GradingSystemDef?> _resolveDefaultGradingSystem(
    String schoolId,
  ) async {
    final snapshot = await firestore
        .collection('structure_grading_systems')
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true)
        .where('isDefault', isEqualTo: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    return GradingSystemDef(
      id: snapshot.docs.first.id,
      schoolId: data['schoolId'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      isDefault: data['isDefault'] ?? false,
      isActive: data['isActive'] ?? true,
      description: data['description'] ?? '',
      scaleType: data['scaleType'] ?? 'Range Based',
      gradeFormat: data['gradeFormat'] ?? 'Letter',
      decimalPlaces: data['decimalPlaces'] ?? 2,
      passingScore: (data['passingScore'] as num?)?.toDouble(),
      passingGradeCode: data['passingGradeCode'],
      allowIncomplete: data['allowIncomplete'] ?? false,
      appliesTo: data['appliesTo'] ?? 'school',
      levelIds: List<String>.from(data['levelIds'] ?? const []),
      classIds: List<String>.from(data['classIds'] ?? const []),
      academicYearIds: List<String>.from(data['academicYearIds'] ?? const []),
      version: data['version'] ?? 1,
    );
  }

  Future<List<GradeBand>> _gradeBands(
    String schoolId,
    String gradingSystemId,
  ) async {
    final snapshot = await firestore
        .collection('grade_bands')
        .where('schoolId', isEqualTo: schoolId)
        .where('gradingSystemId', isEqualTo: gradingSystemId)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return GradeBand(
        id: doc.id,
        schoolId: data['schoolId'] ?? '',
        gradingSystemId: data['gradingSystemId'] ?? '',
        grade: data['grade'] ?? '',
        minScore: (data['minScore'] as num?)?.toDouble() ?? 0,
        maxScore: (data['maxScore'] as num?)?.toDouble() ?? 0,
        remarks: data['remarks'] ?? '',
        order: data['order'] ?? 0,
        label: data['label'] ?? '',
        gradePoint: (data['gradePoint'] as num?)?.toDouble(),
        isPassing: data['isPassing'] ?? true,
        colorHex: data['colorHex'] ?? '',
        hasNumericBoundary: data['hasNumericBoundary'] ?? true,
      );
    }).toList();
  }

  @override
  Future<List<AttendanceHistoryRecord>> getAttendanceHistory(
    String teacherId,
  ) async {
    // In a real app, we might filter by teacherId if classes are assigned to teachers
    // For now, let's just fetch recent attendance records from the 'attendance_logs' collection
    // which should summarize daily attendance per class.

    final snapshot = await firestore
        .collection('attendance_logs')
        .orderBy('date', descending: true)
        .limit(20)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AttendanceHistoryRecord(
        className: data['className'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        presentCount: data['presentCount'] ?? 0,
        totalCount: data['totalCount'] ?? 0,
        status: data['status'] ?? 'Submitted',
      );
    }).toList();
  }

  @override
  Future<TeacherDashboardStats> getTeacherDashboardStats(
    String teacherId,
  ) async {
    // In a real app, this would be fetched from a teacher-specific stats doc
    // For now, let's provide some realistic default data or fetch from school_stats
    final statsDoc = await firestore
        .collection('school_stats')
        .doc('teacher_$teacherId')
        .get();

    if (statsDoc.exists) {
      final data = statsDoc.data()!;
      return TeacherDashboardStats(
        studentsToday: data['studentsToday'] ?? 0,
        totalStudents: data['totalStudents'] ?? 0,
        submissionsDue: data['submissionsDue'] ?? 0,
        classesToday: data['classesToday'] ?? 0,
        activeNotifications: data['activeNotifications'] ?? 0,
        attendanceTaken: data['attendanceTaken'] ?? 0,
        marksEntered: data['marksEntered'] ?? 0,
        reportsGenerated: data['reportsGenerated'] ?? 0,
        classProgress: (data['classProgress'] as List? ?? [])
            .map(
              (cp) => ClassProgress(
                title: cp['title'] ?? '',
                progress: (cp['progress'] ?? 0.0).toDouble(),
                subtitle: cp['subtitle'] ?? '',
                className: cp['className'] ?? '',
              ),
            )
            .toList(),
      );
    }

    // Default mock-like data but from "real" source
    return const TeacherDashboardStats(
      studentsToday: 0,
      totalStudents: 0,
      submissionsDue: 0,
      classesToday: 0,
      activeNotifications: 0,
      attendanceTaken: 0,
      marksEntered: 0,
      reportsGenerated: 0,
      classProgress: [],
    );
  }

  @override
  Future<List<Homework>> getHomework(String schoolId, String teacherId) async {
    final snapshot = await firestore
        .collection('homework')
        .where('schoolId', isEqualTo: schoolId)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('dueDate', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Homework(
        id: doc.id,
        schoolId: data['schoolId'] ?? '',
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        className: data['className'] ?? '',
        subject: data['subject'] ?? '',
        dueDate: (data['dueDate'] as Timestamp).toDate(),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        teacherId: data['teacherId'] ?? '',
        attachments: (data['attachments'] as List?)
            ?.map((e) => e as String)
            .toList(),
      );
    }).toList();
  }

  @override
  Future<void> createHomework(Homework homework) async {
    await firestore.collection('homework').add({
      'schoolId': homework.schoolId,
      'title': homework.title,
      'description': homework.description,
      'className': homework.className,
      'subject': homework.subject,
      'dueDate': Timestamp.fromDate(homework.dueDate),
      'createdAt': FieldValue.serverTimestamp(),
      'teacherId': homework.teacherId,
      'attachments': homework.attachments ?? [],
    });
  }

  @override
  Future<void> updateHomework(Homework homework) async {
    final docRef = firestore.collection('homework').doc(homework.id);
    final doc = await docRef.get();
    if (!doc.exists || doc.data()?['schoolId'] != homework.schoolId) {
      throw Exception('Homework not found for this school.');
    }
    await docRef.update({
      'title': homework.title,
      'description': homework.description,
      'className': homework.className,
      'subject': homework.subject,
      'dueDate': Timestamp.fromDate(homework.dueDate),
      'attachments': homework.attachments ?? [],
    });
  }

  @override
  Future<void> deleteHomework(
    String homeworkId, {
    required String schoolId,
  }) async {
    final docRef = firestore.collection('homework').doc(homeworkId);
    final doc = await docRef.get();
    if (!doc.exists || doc.data()?['schoolId'] != schoolId) {
      throw Exception('Homework not found for this school.');
    }
    await docRef.delete();
  }

  @override
  Future<List<ReportComment>> getReportComments({
    required String schoolId,
    required String className,
    required String term,
    required String year,
  }) async {
    final snapshot = await firestore
        .collection('report_comments')
        .where('schoolId', isEqualTo: schoolId)
        .where('className', isEqualTo: className)
        .where('term', isEqualTo: term)
        .where('year', isEqualTo: year)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ReportComment(
        id: doc.id,
        schoolId: data['schoolId'] ?? '',
        studentId: data['studentId'] ?? '',
        className: data['className'] ?? '',
        term: data['term'] ?? '',
        year: data['year'] ?? '',
        comment: data['comment'] ?? '',
        recommendations:
            (data['recommendations'] as List?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        teacherId: data['teacherId'] ?? '',
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      );
    }).toList();
  }

  @override
  Future<void> saveReportComment(ReportComment comment) async {
    final docId = '${comment.studentId}_${comment.term}_${comment.year}';
    await firestore.collection('report_comments').doc(docId).set({
      'schoolId': comment.schoolId,
      'studentId': comment.studentId,
      'className': comment.className,
      'term': comment.term,
      'year': comment.year,
      'comment': comment.comment,
      'recommendations': comment.recommendations,
      'teacherId': comment.teacherId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<List<CompetencyRating>> getCompetencyRatings({
    required String schoolId,
    required String className,
    required String term,
    required String year,
    required String competency,
  }) async {
    final snapshot = await firestore
        .collection('competency_ratings')
        .where('schoolId', isEqualTo: schoolId)
        .where('className', isEqualTo: className)
        .where('term', isEqualTo: term)
        .where('year', isEqualTo: year)
        .where('competency', isEqualTo: competency)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return CompetencyRating(
        id: doc.id,
        schoolId: data['schoolId'] ?? '',
        studentId: data['studentId'] ?? '',
        className: data['className'] ?? '',
        term: data['term'] ?? '',
        year: data['year'] ?? '',
        competency: data['competency'] ?? '',
        level: data['level'] ?? 1,
        teacherId: data['teacherId'] ?? '',
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      );
    }).toList();
  }

  @override
  Future<void> saveCompetencyRating(CompetencyRating rating) async {
    final docId =
        '${rating.studentId}_${rating.term}_${rating.year}_${rating.competency.replaceAll(' ', '_')}';
    await firestore.collection('competency_ratings').doc(docId).set({
      'schoolId': rating.schoolId,
      'studentId': rating.studentId,
      'className': rating.className,
      'term': rating.term,
      'year': rating.year,
      'competency': rating.competency,
      'level': rating.level,
      'teacherId': rating.teacherId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> generateReports({
    required String schoolId,
    required String className,
    required String term,
    required String year,
    required List<String> studentIds,
    required List<String> enabledSections,
  }) async {
    final batch = firestore.batch();

    for (final studentId in studentIds) {
      // In a real app, this might trigger a Cloud Function or
      // create a 'report_card' doc that the PDF generator listens to.
      // For now, we'll create the shell record that makes it visible to parents/deans.
      final docId = '${schoolId}_${studentId}_${term}_$year';
      final docRef = firestore.collection('report_cards').doc(docId);

      batch.set(docRef, {
        'schoolId': schoolId,
        'studentId': studentId,
        'className': className,
        'term': term,
        'year': year,
        'status': 'pending',
        'enabledSections': enabledSections,
        'generatedAt': FieldValue.serverTimestamp(),
        'isLockedForFees': false,
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }
}
