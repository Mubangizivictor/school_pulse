import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/student_repository.dart';

class DocumentService {
  final StudentRepository repository;

  DocumentService(this.repository);

  Future<Either<Failure, String>> uploadDocument({
    required String studentId,
    required String documentType, // 'birth_certificate', 'previous_report', etc.
    required dynamic file,
  }) {
    return repository.uploadStudentDocument(studentId, documentType, file);
  }

  Future<Either<Failure, void>> removeDocument({
    required String studentId,
    required String documentType,
  }) {
    return repository.deleteStudentDocument(studentId, documentType);
  }
}
