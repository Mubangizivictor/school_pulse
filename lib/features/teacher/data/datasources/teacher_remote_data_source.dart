import 'package:cloud_firestore/cloud_firestore.dart';
import '../../presentation/bloc/teacher_state.dart';
import '../../domain/usecases/get_attendance_history.dart';
import '../../domain/entities/teacher_dashboard_stats.dart';
import '../../domain/entities/homework.dart';
import '../../domain/entities/report_comment.dart';
import '../../domain/entities/competency_rating.dart';

abstract class TeacherRemoteDataSource {
  Future<List<TeacherStudent>> getStudentsByClass(String className);
  Future<void> submitAttendance({
    required String className,
    required DateTime date,
    required Map<String, String> attendance,
  });
  Future<void> submitMarks({
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
  Future<List<Homework>> getHomework(String teacherId);
  Future<void> createHomework(Homework homework);
  Future<void> updateHomework(Homework homework);
  Future<void> deleteHomework(String homeworkId);

  // Report Comments
  Future<List<ReportComment>> getReportComments({
    required String className,
    required String term,
    required String year,
  });
  Future<void> saveReportComment(ReportComment comment);

  // Competency Ratings
  Future<List<CompetencyRating>> getCompetencyRatings({
    required String className,
    required String term,
    required String year,
    required String competency,
  });
  Future<void> saveCompetencyRating(CompetencyRating rating);

  Future<void> generateReports({
    required String className,
    required String term,
    required String year,
    required List<String> studentIds,
    required List<String> enabledSections,
  });
}

/// UCE-style aggregate grade for a percentage score.
String gradeForScore(double score) {
  if (score >= 85) return 'D1';
  if (score >= 75) return 'D2';
  if (score >= 65) return 'C3';
  if (score >= 60) return 'C4';
  if (score >= 55) return 'C5';
  if (score >= 50) return 'C6';
  if (score >= 45) return 'P7';
  if (score >= 40) return 'P8';
  return 'F9';
}

class TeacherRemoteDataSourceImpl implements TeacherRemoteDataSource {
  final FirebaseFirestore firestore;

  TeacherRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<TeacherStudent>> getStudentsByClass(String className) async {
    final snapshot = await firestore
        .collection('students')
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
    required String className,
    required DateTime date,
    required Map<String, String> attendance,
  }) async {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    // 'attendance_records' is the collection the parent app reads, so the
    // register a teacher submits here is what parents see. One doc per
    // student per day keeps re-submissions idempotent.
    final batch = firestore.batch();

    attendance.forEach((studentId, status) {
      final docRef = firestore
          .collection('attendance_records')
          .doc('${studentId}_$dateStr');
      batch.set(docRef, {
        'studentId': studentId,
        'className': className,
        'date': Timestamp.fromDate(date),
        'status': status,
        'note': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    // Per-class daily summary that the attendance history screen lists.
    final presentCount =
        attendance.values.where((s) => s == 'present').length;
    final logRef =
        firestore.collection('attendance_logs').doc('${className}_$dateStr');
    batch.set(logRef, {
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
    final batch = firestore.batch();
    final slug = [subject, term, year, assessment]
        .join('_')
        .replaceAll(RegExp(r'\s+'), '-');

    marks.forEach((studentId, score) {
      final docRef = firestore
          .collection('academic_records')
          .doc('${studentId}_$slug');
      batch.set(docRef, {
        'studentId': studentId,
        'className': className,
        'subject': subject,
        'score': score,
        'grade': gradeForScore(score),
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

  @override
  Future<List<AttendanceHistoryRecord>> getAttendanceHistory(String teacherId) async {
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
  Future<TeacherDashboardStats> getTeacherDashboardStats(String teacherId) async {
    // In a real app, this would be fetched from a teacher-specific stats doc
    // For now, let's provide some realistic default data or fetch from school_stats
    final statsDoc = await firestore.collection('school_stats').doc('teacher_$teacherId').get();
    
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
        classProgress: (data['classProgress'] as List? ?? []).map((cp) => ClassProgress(
          title: cp['title'] ?? '',
          progress: (cp['progress'] ?? 0.0).toDouble(),
          subtitle: cp['subtitle'] ?? '',
          className: cp['className'] ?? '',
        )).toList(),
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
  Future<List<Homework>> getHomework(String teacherId) async {
    final snapshot = await firestore
        .collection('homework')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('dueDate', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Homework(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        className: data['className'] ?? '',
        subject: data['subject'] ?? '',
        dueDate: (data['dueDate'] as Timestamp).toDate(),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        teacherId: data['teacherId'] ?? '',
        attachments: (data['attachments'] as List?)?.map((e) => e as String).toList(),
      );
    }).toList();
  }

  @override
  Future<void> createHomework(Homework homework) async {
    await firestore.collection('homework').add({
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
    await firestore.collection('homework').doc(homework.id).update({
      'title': homework.title,
      'description': homework.description,
      'className': homework.className,
      'subject': homework.subject,
      'dueDate': Timestamp.fromDate(homework.dueDate),
      'attachments': homework.attachments ?? [],
    });
  }

  @override
  Future<void> deleteHomework(String homeworkId) async {
    await firestore.collection('homework').doc(homeworkId).delete();
  }

  @override
  Future<List<ReportComment>> getReportComments({
    required String className,
    required String term,
    required String year,
  }) async {
    final snapshot = await firestore
        .collection('report_comments')
        .where('className', isEqualTo: className)
        .where('term', isEqualTo: term)
        .where('year', isEqualTo: year)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ReportComment(
        id: doc.id,
        studentId: data['studentId'] ?? '',
        className: data['className'] ?? '',
        term: data['term'] ?? '',
        year: data['year'] ?? '',
        comment: data['comment'] ?? '',
        recommendations: (data['recommendations'] as List?)?.map((e) => e as String).toList() ?? [],
        teacherId: data['teacherId'] ?? '',
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      );
    }).toList();
  }

  @override
  Future<void> saveReportComment(ReportComment comment) async {
    final docId = '${comment.studentId}_${comment.term}_${comment.year}';
    await firestore.collection('report_comments').doc(docId).set({
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
    required String className,
    required String term,
    required String year,
    required String competency,
  }) async {
    final snapshot = await firestore
        .collection('competency_ratings')
        .where('className', isEqualTo: className)
        .where('term', isEqualTo: term)
        .where('year', isEqualTo: year)
        .where('competency', isEqualTo: competency)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return CompetencyRating(
        id: doc.id,
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
    final docId = '${rating.studentId}_${rating.term}_${rating.year}_${rating.competency.replaceAll(' ', '_')}';
    await firestore.collection('competency_ratings').doc(docId).set({
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
      final docId = '${studentId}_${term}_${year}';
      final docRef = firestore.collection('report_cards').doc(docId);

      batch.set(docRef, {
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
