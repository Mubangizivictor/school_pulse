import 'package:equatable/equatable.dart';

/// What a Nurse is allowed to see for one student - never the full
/// `Student`/`StudentHealthProfile` records. Clinical fields are null
/// when the operator only holds `health.student.basic.read` (identity
/// only), populated when they also hold `health.student.clinical.read`.
class NurseStudentView extends Equatable {
  final String studentId;
  final String name;
  final String? photoUrl;
  final int? age;
  final String classId;

  final bool hasClinicalAccess;
  final List<String>? allergies;
  final List<String>? currentMedications;
  final List<String>? chronicIllnesses;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final int? recentClinicVisitCount;

  const NurseStudentView({
    required this.studentId,
    required this.name,
    required this.photoUrl,
    required this.age,
    required this.classId,
    required this.hasClinicalAccess,
    this.allergies,
    this.currentMedications,
    this.chronicIllnesses,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.recentClinicVisitCount,
  });

  @override
  List<Object?> get props => [
    studentId,
    name,
    photoUrl,
    age,
    classId,
    hasClinicalAccess,
    allergies,
    currentMedications,
    chronicIllnesses,
    emergencyContactName,
    emergencyContactPhone,
    recentClinicVisitCount,
  ];
}
