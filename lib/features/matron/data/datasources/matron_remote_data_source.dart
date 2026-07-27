import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/matron_repository.dart';
import '../../presentation/bloc/matron_state.dart';

abstract class MatronRemoteDataSource {
  Future<List<DormitoryStatus>> getDormitoriesStatus();
  Future<Map<String, int>> getAttendanceStats();
  Future<List<Student>> getUnallocatedStudents();
  Future<void> allocateStudent(String studentId, String dormitoryId);
  Future<List<Student>> getDormitoryStudents(String dormitoryId);
  Future<void> submitNightAttendance(String dormitoryId, Map<String, bool> attendance);
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
        id: doc.id,
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

  @override
  Future<List<Student>> getUnallocatedStudents() async {
    final snapshot = await firestore
        .collection('students')
        .where('isBoarder', isEqualTo: true)
        .where('dormitoryId', isNull: true)
        .get();
    
    return snapshot.docs.map((doc) => Student(
      id: doc.id,
      name: doc.data()['name'] ?? 'Unknown Student',
    )).toList();
  }

  @override
  Future<void> allocateStudent(String studentId, String dormitoryId) async {
    await firestore.collection('students').doc(studentId).update({
      'dormitoryId': dormitoryId,
    });
    
    // In a real app, you'd also update the dormitory's currentOccupants count
    // but for simplicity here we'll assume a trigger or batch update happens.
    final dormRef = firestore.collection('dormitories').doc(dormitoryId);
    await firestore.runTransaction((transaction) async {
      final dormDoc = await transaction.get(dormRef);
      final current = dormDoc.data()?['currentOccupants'] ?? 0;
      transaction.update(dormRef, {'currentOccupants': current + 1});
    });
  }

  @override
  Future<List<Student>> getDormitoryStudents(String dormitoryId) async {
    final snapshot = await firestore
        .collection('students')
        .where('dormitoryId', isEqualTo: dormitoryId)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Student(
        id: doc.id,
        name: data['name'] ?? 'Unknown Student',
        bedNumber: data['bedNumber'],
      );
    }).toList();
  }

  @override
  Future<void> submitNightAttendance(String dormitoryId, Map<String, bool> attendance) async {
    final batch = firestore.batch();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    attendance.forEach((studentId, isPresent) {
      final ref = firestore
          .collection('attendance')
          .doc(today)
          .collection('students')
          .doc(studentId);
      
      batch.set(ref, {
        'studentId': studentId,
        'dormitoryId': dormitoryId,
        'isPresent': isPresent,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'night',
      });
    });
    
    await batch.commit();
  }
}
