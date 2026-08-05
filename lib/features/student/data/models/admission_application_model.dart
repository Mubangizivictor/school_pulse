import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/admission_application.dart';
import '../../domain/entities/student_enums.dart';

class AdmissionApplicationModel extends AdmissionApplication {
  const AdmissionApplicationModel({
    required super.id,
    required super.schoolId,
    required super.studentName,
    required super.dateOfBirth,
    required super.gender,
    required super.targetClassId,
    super.targetStreamId,
    required super.academicYearId,
    super.previousSchool,
    required super.applicantParentName,
    required super.applicantParentPhone,
    required super.status,
    required super.appliedAt,
    super.reviewerId,
    super.reviewComments,
    super.attachedDocuments,
  });

  factory AdmissionApplicationModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return AdmissionApplicationModel(
      id: id,
      schoolId: map['schoolId'] ?? '',
      studentName: map['studentName'] ?? '',
      dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
      gender: Gender.values.firstWhere((e) => e.name == map['gender']),
      targetClassId: map['targetClassId'] ?? '',
      targetStreamId: map['targetStreamId'],
      academicYearId: map['academicYearId'] ?? '',
      previousSchool: map['previousSchool'],
      applicantParentName: map['applicantParentName'] ?? '',
      applicantParentPhone: map['applicantParentPhone'] ?? '',
      status: AdmissionStatus.values.firstWhere((e) => e.name == map['status']),
      appliedAt: (map['appliedAt'] as Timestamp).toDate(),
      reviewerId: map['reviewerId'],
      reviewComments: map['reviewComments'],
      attachedDocuments: Map<String, String>.from(
        map['attachedDocuments'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'studentName': studentName,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender.name,
      'targetClassId': targetClassId,
      'targetStreamId': targetStreamId,
      'academicYearId': academicYearId,
      'previousSchool': previousSchool,
      'applicantParentName': applicantParentName,
      'applicantParentPhone': applicantParentPhone,
      'status': status.name,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'reviewerId': reviewerId,
      'reviewComments': reviewComments,
      'attachedDocuments': attachedDocuments,
    };
  }
}
