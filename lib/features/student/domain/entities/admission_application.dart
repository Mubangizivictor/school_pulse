import 'package:equatable/equatable.dart';
import 'student_enums.dart';

class AdmissionApplication extends Equatable {
  final String id;
  final String schoolId;
  final String studentName;
  final DateTime dateOfBirth;
  final Gender gender;
  final String targetClassId;
  final String? targetStreamId;
  final String academicYearId;
  final String? previousSchool;
  final String applicantParentName;
  final String applicantParentPhone;
  final AdmissionStatus status;
  final DateTime appliedAt;
  final String? reviewerId;
  final String? reviewComments;
  final Map<String, String> attachedDocuments; // type -> url

  const AdmissionApplication({
    required this.id,
    required this.schoolId,
    required this.studentName,
    required this.dateOfBirth,
    required this.gender,
    required this.targetClassId,
    this.targetStreamId,
    required this.academicYearId,
    this.previousSchool,
    required this.applicantParentName,
    required this.applicantParentPhone,
    required this.status,
    required this.appliedAt,
    this.reviewerId,
    this.reviewComments,
    this.attachedDocuments = const {},
  });

  @override
  List<Object?> get props => [
        id,
        schoolId,
        studentName,
        dateOfBirth,
        gender,
        targetClassId,
        targetStreamId,
        academicYearId,
        previousSchool,
        applicantParentName,
        applicantParentPhone,
        status,
        appliedAt,
        reviewerId,
        reviewComments,
        attachedDocuments,
      ];

  AdmissionApplication copyWith({
    AdmissionStatus? status,
    String? reviewerId,
    String? reviewComments,
  }) {
    return AdmissionApplication(
      id: id,
      schoolId: schoolId,
      studentName: studentName,
      dateOfBirth: dateOfBirth,
      gender: gender,
      targetClassId: targetClassId,
      targetStreamId: targetStreamId,
      academicYearId: academicYearId,
      previousSchool: previousSchool,
      applicantParentName: applicantParentName,
      applicantParentPhone: applicantParentPhone,
      status: status ?? this.status,
      appliedAt: appliedAt,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewComments: reviewComments ?? this.reviewComments,
      attachedDocuments: attachedDocuments,
    );
  }
}
