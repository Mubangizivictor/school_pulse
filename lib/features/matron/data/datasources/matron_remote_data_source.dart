import 'package:cloud_firestore/cloud_firestore.dart';
import '../../presentation/bloc/matron_state.dart';

abstract class MatronRemoteDataSource {
  Future<List<DormitoryStatus>> getDormitoriesStatus();
  Future<Map<String, int>> getAttendanceStats();
}

class MatronRemoteDataSourceImpl implements MatronRemoteDataSource {
  final FirebaseFirestore firestore;

  MatronRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<DormitoryStatus>> getDormitoriesStatus() async {
    final snapshot = await firestore.collection('dormitories').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final capacity = data['capacity'] ?? 0;
      final currentOccupants = data['currentOccupants'] ?? 0;
      
      String status = 'Normal';
      if (currentOccupants >= capacity) {
        status = currentOccupants > capacity ? 'Over Capacity' : 'Full';
      }

      return DormitoryStatus(
        name: data['name'] ?? '',
        capacity: capacity,
        currentOccupants: currentOccupants,
        status: status,
      );
    }).toList();
  }

  @override
  Future<Map<String, int>> getAttendanceStats() async {
    final doc = await firestore.collection('stats').doc('attendance_summary').get();
    final data = doc.data() ?? {};
    return {
      'totalStudents': data['totalStudents'] ?? 0,
      'studentsPresent': data['studentsPresent'] ?? 0,
      'studentsOnLeave': data['studentsOnLeave'] ?? 0,
    };
  }
}
