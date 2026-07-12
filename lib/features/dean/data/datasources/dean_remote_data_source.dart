import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/dean_stats.dart';

abstract class DeanRemoteDataSource {
  Future<DeanStats> getDeanStats();
}

class DeanRemoteDataSourceImpl implements DeanRemoteDataSource {
  final FirebaseFirestore firestore;

  DeanRemoteDataSourceImpl({required this.firestore});

  @override
  Future<DeanStats> getDeanStats() async {
    // In a real app, these would be calculated or fetched from a summary doc
    final studentsQuery = await firestore.collection('students').count().get();
    final teachersQuery = await firestore.collection('users').where('role', isEqualTo: 'classTeacher').count().get();
    
    // For average performance and syllabus coverage, we might have a 'school_stats' collection
    final statsDoc = await firestore.collection('school_stats').doc('academic').get();
    
    if (statsDoc.exists) {
      final data = statsDoc.data()!;
      return DeanStats(
        totalStudents: studentsQuery.count ?? 0,
        totalTeachers: teachersQuery.count ?? 0,
        averagePerformance: (data['averagePerformance'] ?? 0.0).toDouble(),
        syllabusCoverage: (data['syllabusCoverage'] ?? 0.0).toDouble(),
      );
    }

    return DeanStats(
      totalStudents: studentsQuery.count ?? 0,
      totalTeachers: teachersQuery.count ?? 0,
      averagePerformance: 0.0,
      syllabusCoverage: 0.0,
    );
  }
}
