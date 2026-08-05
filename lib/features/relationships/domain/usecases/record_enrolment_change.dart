import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import '../repositories/relationship_repository.dart';

class RecordEnrolmentChange
    implements UseCase<void, RecordEnrolmentChangeParams> {
  final RelationshipRepository repository;

  RecordEnrolmentChange(this.repository);

  @override
  Future<Either<Failure, void>> call(RecordEnrolmentChangeParams params) {
    return repository.recordEnrolmentChange(
      schoolId: params.schoolId,
      studentId: params.studentId,
      classId: params.classId,
      streamId: params.streamId,
      academicYearId: params.academicYearId,
      recordedBy: params.recordedBy,
      reason: params.reason,
    );
  }
}

class RecordEnrolmentChangeParams extends Equatable {
  final String schoolId;
  final String studentId;
  final String classId;
  final String? streamId;
  final String academicYearId;
  final String recordedBy;
  final String? reason;

  const RecordEnrolmentChangeParams({
    required this.schoolId,
    required this.studentId,
    required this.classId,
    this.streamId,
    required this.academicYearId,
    required this.recordedBy,
    this.reason,
  });

  @override
  List<Object?> get props => [
    schoolId,
    studentId,
    classId,
    streamId,
    academicYearId,
    recordedBy,
    reason,
  ];
}
