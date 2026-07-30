import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/report_template.dart';
import '../entities/subject_result.dart';
import '../services/report_pdf_generator.dart';
import '../../../student/domain/entities/student.dart';

class GenerateReportCardParams {
  final Student student;
  final List<SubjectResult> results;
  final ReportTemplate template;
  final String schoolName;
  final String term;
  final String year;
  final String? schoolLogoUrl;

  GenerateReportCardParams({
    required this.student,
    required this.results,
    required this.template,
    required this.schoolName,
    required this.term,
    required this.year,
    this.schoolLogoUrl,
  });
}

class GenerateReportCard implements UseCase<Uint8List, GenerateReportCardParams> {
  @override
  Future<Either<Failure, Uint8List>> call(GenerateReportCardParams params) async {
    try {
      final pdfData = await ReportPdfGenerator.generateReportCard(
        student: params.student,
        results: params.results,
        template: params.template,
        schoolName: params.schoolName,
        schoolId: params.student.schoolId,
        term: params.term,
        year: params.year,
        schoolLogoUrl: params.schoolLogoUrl,
      );
      return Right(pdfData);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
