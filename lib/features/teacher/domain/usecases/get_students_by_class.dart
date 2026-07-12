import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../presentation/bloc/teacher_state.dart';
import '../repositories/teacher_repository.dart';

class GetStudentsByClass implements UseCase<List<TeacherStudent>, String> {
  final TeacherRepository repository;

  GetStudentsByClass(this.repository);

  @override
  Future<Either<Failure, List<TeacherStudent>>> call(String params) async {
    return await repository.getStudentsByClass(params);
  }
}
