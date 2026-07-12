import 'package:cloud_firestore/cloud_firestore.dart';
import '../../presentation/bloc/teacher_state.dart';
import '../../domain/usecases/get_attendance_history.dart';
import '../../domain/entities/teacher_dashboard_stats.dart';

abstract class TeacherRemoteDataSource {
  Future<List<TeacherStudent>> getStudentsByClass(String className);
  Future<void> submitAttendance({
    required String className,
    required DateTime date,
    required Map<String, String> attendance,
  });
  Future<List<AttendanceHistoryRecord>> getAttendanceHistory(String teacherId);
  Future<TeacherDashboardStats> getTeacherDashboardStats(String teacherId);
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
    
    // We store attendance in a subcollection or a dedicated top-level collection
    // Let's use a top-level collection 'attendance' for better scalability
    final batch = firestore.batch();
    
    attendance.forEach((studentId, status) {
      final docRef = firestore.collection('attendance').doc('${studentId}_$dateStr');
      batch.set(docRef, {
        'studentId': studentId,
        'className': className,
        'date': Timestamp.fromDate(date),
        'status': status,
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
        classProgress: (data['classProgress'] as List? ?? []).map((cp) => ClassProgress(
          title: cp['title'] ?? '',
          progress: (cp['progress'] ?? 0.0).toDouble(),
          subtitle: cp['subtitle'] ?? '',
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
      classProgress: [],
    );
  }
}
