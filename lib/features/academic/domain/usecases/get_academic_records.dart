import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/academic_record.dart';
import '../repositories/academic_repository.dart';

class GetAcademicRecords implements UseCase<List<AcademicRecord>, GetAcademicRecordsParams> {
  final AcademicRepository repository;

  GetAcademicRecords(this.repository);

  @override
  Future<Either<Failure, List<AcademicRecord>>> call(GetAcademicRecordsParams params) async {
    return await repository.getAcademicRecords(
      params.studentId,
      term: params.term,
      year: params.year,
    );
  }
}

class GetAcademicRecordsParams extends Equatable {
  final String studentId;
  final String? term;
  final String? year;

  const GetAcademicRecordsParams({
    required this.studentId,
    this.term,
    this.year,
  });

  @override
  List<Object?> get props => [studentId, term, year];
}
