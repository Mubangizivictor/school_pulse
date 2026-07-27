import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/report_card.dart';
import '../repositories/academic_repository.dart';

class GetReportCards {
  final AcademicRepository repository;
  GetReportCards(this.repository);

  Future<Either<Failure, List<ReportCard>>> call({
    String? studentId,
    String? className,
    String? term,
    String? year,
    ReportCardStatus? status,
  }) async {
    return await repository.getReportCards(
      studentId: studentId,
      className: className,
      term: term,
      year: year,
      status: status,
    );
  }
}

class SignReportCard {
  final AcademicRepository repository;
  SignReportCard(this.repository);

  Future<Either<Failure, void>> call(SignReportParams params) async {
    return await repository.signReportCard(
      reportCardId: params.reportCardId,
      signerId: params.signerId,
      isHeadTeacher: params.isHeadTeacher,
    );
  }
}

class SignReportParams extends Equatable {
  final String reportCardId;
  final String signerId;
  final bool isHeadTeacher;

  const SignReportParams({
    required this.reportCardId,
    required this.signerId,
    required this.isHeadTeacher,
  });

  @override
  List<Object?> get props => [reportCardId, signerId, isHeadTeacher];
}
