import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../student/domain/entities/student.dart';

class GetStudentsForAssessmentParams {
  final String classId;
  final String? streamId;

  GetStudentsForAssessmentParams({required this.classId, this.streamId});
}

class GetStudentsForAssessment
    implements UseCase<List<Student>, GetStudentsForAssessmentParams> {
  // We need to fetch students assigned to a specific class/stream
  // This likely interacts with the Student module
  final dynamic
  studentRepository; // Replace with actual StudentRepository when available

  GetStudentsForAssessment(this.studentRepository);

  @override
  Future<Either<Failure, List<Student>>> call(
    GetStudentsForAssessmentParams params,
  ) async {
    // Implementation would call studentRepository.getStudentsByClass
    return Left(
      ServerFailure("Not implemented: Needs StudentRepository integration"),
    );
  }
}
