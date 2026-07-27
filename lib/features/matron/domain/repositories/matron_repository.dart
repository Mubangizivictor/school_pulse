import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../presentation/bloc/matron_state.dart';

abstract class MatronRepository {
  Future<Either<Failure, MatronLoaded>> getDashboardData();
  Future<Either<Failure, List<Student>>> getUnallocatedStudents();
  Future<Either<Failure, void>> allocateStudent(String studentId, String dormitoryId);
  Future<Either<Failure, List<Student>>> getDormitoryStudents(String dormitoryId);
  Future<Either<Failure, void>> submitNightAttendance(String dormitoryId, Map<String, bool> attendance);
}

class Student {
  final String id;
  final String name;
  final String? bedNumber;

  const Student({required this.id, required this.name, this.bedNumber});
}
