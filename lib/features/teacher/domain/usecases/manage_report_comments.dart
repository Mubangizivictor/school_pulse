import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/report_comment.dart';
import '../repositories/teacher_repository.dart';

class GetReportComments {
  final TeacherRepository repository;
  GetReportComments(this.repository);

  Future<Either<Failure, List<ReportComment>>> call({
    required String schoolId,
    required String className,
    required String term,
    required String year,
  }) async {
    return await repository.getReportComments(
      schoolId: schoolId,
      className: className,
      term: term,
      year: year,
    );
  }
}

class SaveReportComment {
  final TeacherRepository repository;
  SaveReportComment(this.repository);

  Future<Either<Failure, void>> call(ReportComment comment) async {
    return await repository.saveReportComment(comment);
  }
}
