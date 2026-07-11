import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../mock_data/mock_models.dart';
import '../../presentation/bloc/teacher_state.dart';

abstract class TeacherRepository {
  Future<Either<Failure, List<TeacherStudent>>> getStudentsByClass(String className);
  
  Future<Either<Failure, void>> submitAttendance({
    required String className,
    required DateTime date,
    required Map<String, StudentStatus> attendance,
  });
}
