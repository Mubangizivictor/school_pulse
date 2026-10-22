import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/homework.dart';
import '../repositories/teacher_repository.dart';

class GetHomework {
  final TeacherRepository repository;
  GetHomework(this.repository);
  Future<Either<Failure, List<Homework>>> call(
    String schoolId,
    String teacherId,
  ) async => await repository.getHomework(schoolId, teacherId);
}

class CreateHomework {
  final TeacherRepository repository;
  CreateHomework(this.repository);
  Future<Either<Failure, void>> call(Homework homework) async =>
      await repository.createHomework(homework);
}

class UpdateHomework {
  final TeacherRepository repository;
  UpdateHomework(this.repository);
  Future<Either<Failure, void>> call(Homework homework) async =>
      await repository.updateHomework(homework);
}

class DeleteHomework {
  final TeacherRepository repository;
  DeleteHomework(this.repository);
  Future<Either<Failure, void>> call(
    String homeworkId, {
    required String schoolId,
  }) async => await repository.deleteHomework(homeworkId, schoolId: schoolId);
}
