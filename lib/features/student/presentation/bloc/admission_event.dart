import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import '../../domain/entities/admission_application.dart';

abstract class AdmissionEvent extends Equatable {
  const AdmissionEvent();

  @override
  List<Object?> get props => [];
}

class LoadApplicationsRequested extends AdmissionEvent {
  final String schoolId;

  const LoadApplicationsRequested(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class SubmitApplicationRequested extends AdmissionEvent {
  final AdmissionApplication application;

  const SubmitApplicationRequested(this.application);

  @override
  List<Object?> get props => [application];
}

class ReviewApplicationRequested extends AdmissionEvent {
  final String applicationId;
  final String reviewerId;
  final bool approve;
  final String? comments;

  const ReviewApplicationRequested({
    required this.applicationId,
    required this.reviewerId,
    required this.approve,
    this.comments,
  });

  @override
  List<Object?> get props => [applicationId, reviewerId, approve, comments];
}

// `operatorUser` is the signed-in staff member attempting the enroll action
// - the bloc checks Permission.admissionEnroll against them before calling
// AdmissionService, rather than trusting the caller.
class EnrollStudentRequested extends AdmissionEvent {
  final UserEntity operatorUser;
  final String applicationId;
  final String schoolId;
  final String schoolCode;
  final String academicYear;
  final String academicYearId;
  final String? term;
  final String? feeStructureId;
  final double? totalBilled;

  const EnrollStudentRequested({
    required this.operatorUser,
    required this.applicationId,
    required this.schoolId,
    required this.schoolCode,
    required this.academicYear,
    required this.academicYearId,
    this.term,
    this.feeStructureId,
    this.totalBilled,
  });

  @override
  List<Object?> get props => [
        operatorUser,
        applicationId,
        schoolId,
        schoolCode,
        academicYear,
        academicYearId,
        term,
        feeStructureId,
        totalBilled,
      ];
}
