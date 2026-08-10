import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/student_repository.dart';

enum PromotionMode { automatic, manualApproval }

class PromotionPolicy {
  final PromotionMode mode;
  const PromotionPolicy({this.mode = PromotionMode.manualApproval});
}

class PromotionService {
  final StudentRepository repository;

  PromotionService(this.repository);

  /// A policy gate for end-of-year jobs. Automatic promotion can proceed;
  /// manual schools receive a decision they can route to an approval queue.
  bool requiresApproval(PromotionPolicy policy) =>
      policy.mode == PromotionMode.manualApproval;

  /// Promotes a batch of students to the next class.
  /// This can be called automatically at the end of a year or manually.
  Future<Either<Failure, void>> promoteStudents({
    required String schoolId,
    required List<String> studentIds,
    required String targetClassId,
    String? targetStreamId,
    required String targetAcademicYearId,
    required String recordedBy,
  }) {
    return repository.promoteStudents(
      schoolId: schoolId,
      studentIds: studentIds,
      targetClassId: targetClassId,
      targetStreamId: targetStreamId,
      targetAcademicYearId: targetAcademicYearId,
      recordedBy: recordedBy,
    );
  }
}
