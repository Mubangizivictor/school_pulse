import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/assessment_mark.dart';
import '../repositories/assessment_repository.dart';

class SaveMarksParams extends Equatable {
  final String schoolId;
  final List<AssessmentMark> marks;

  const SaveMarksParams({required this.schoolId, required this.marks});

  @override
  List<Object?> get props => [schoolId, marks];
}

class SaveMarks implements UseCase<void, SaveMarksParams> {
  final AssessmentRepository repository;

  SaveMarks(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveMarksParams params) async {
    return await repository.saveMarks(params.schoolId, params.marks);
  }
}
