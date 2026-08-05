import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/teacher_repository.dart';

class SubmitMarks implements UseCase<void, MarksParams> {
  final TeacherRepository repository;

  SubmitMarks(this.repository);

  @override
  Future<Either<Failure, void>> call(MarksParams params) async {
    return await repository.submitMarks(
      className: params.className,
      subject: params.subject,
      assessment: params.assessment,
      term: params.term,
      year: params.year,
      marks: params.marks,
    );
  }
}

class MarksParams extends Equatable {
  final String className;
  final String subject;
  final String assessment;
  final String term;
  final String year;

  /// studentId -> score (0-100)
  final Map<String, double> marks;

  const MarksParams({
    required this.className,
    required this.subject,
    required this.assessment,
    required this.term,
    required this.year,
    required this.marks,
  });

  @override
  List<Object?> get props => [
    className,
    subject,
    assessment,
    term,
    year,
    marks,
  ];
}
