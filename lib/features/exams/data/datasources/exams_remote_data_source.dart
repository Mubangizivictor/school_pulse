import 'package:cloud_firestore/cloud_firestore.dart';
import '../../presentation/bloc/exams_state.dart';

abstract class ExamsRemoteDataSource {
  Future<List<ExamSchedule>> getUpcomingExams();
  Future<Map<String, dynamic>> getExamsStats();
}

class ExamsRemoteDataSourceImpl implements ExamsRemoteDataSource {
  final FirebaseFirestore firestore;

  ExamsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ExamSchedule>> getUpcomingExams() async {
    final snapshot = await firestore
        .collection('exams')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('timestamp')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ExamSchedule(
        subject: data['subject'] ?? '',
        className: data['className'] ?? '',
        date: data['date'] ?? '',
        session: data['session'] ?? '',
      );
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> getExamsStats() async {
    final doc = await firestore.collection('stats').doc('exams_summary').get();
    return doc.data() ?? {};
  }
}
