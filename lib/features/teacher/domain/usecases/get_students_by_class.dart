import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../presentation/bloc/teacher_state.dart';
import '../repositories/teacher_repository.dart';

class GetStudentsByClassParams {
  final String schoolId;
  final String className;

  GetStudentsByClassParams({required this.schoolId, required this.className});
}

class GetStudentsByClass
    implements UseCase<List<TeacherStudent>, GetStudentsByClassParams> {
  final TeacherRepository repository;

  GetStudentsByClass(this.repository);

  @override
  Future<Either<Failure, List<TeacherStudent>>> call(
    GetStudentsByClassParams params,
  ) async {
    return await repository.getStudentsByClass(
      params.schoolId,
      params.className,
    );
  }
}
