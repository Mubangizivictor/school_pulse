import 'package:equatable/equatable.dart';

class StudentHealthProfile extends Equatable {
  final String studentId;
  final String schoolId;
  final String bloodGroup;
  final String? rhesusFactor;
  final double? height;
  final double? weight;
  final double? bmi;
  final List<String> allergies;
  final List<String> chronicIllnesses;
  final List<String> disabilities;
  final String? specialMedicalNeeds;
  final String? medicalNotes;
  final List<String> currentMedications;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String? familyDoctorName;
  final String? familyDoctorPhone;
  final String? hospitalPreference;
  final String? insuranceInformation;
  final List<VaccinationRecord> vaccinationHistory;
  final List<String> medicalRestrictions;
  final List<String> dietaryRestrictions;
  final List<String> physicalActivityRestrictions;

  const StudentHealthProfile({
    required this.studentId,
    required this.schoolId,
    required this.bloodGroup,
    this.rhesusFactor,
    this.height,
    this.weight,
    this.bmi,
    this.allergies = const [],
    this.chronicIllnesses = const [],
    this.disabilities = const [],
    this.specialMedicalNeeds,
    this.medicalNotes,
    this.currentMedications = const [],
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    this.familyDoctorName,
    this.familyDoctorPhone,
    this.hospitalPreference,
    this.insuranceInformation,
    this.vaccinationHistory = const [],
    this.medicalRestrictions = const [],
    this.dietaryRestrictions = const [],
    this.physicalActivityRestrictions = const [],
  });

  StudentHealthProfile copyWith({
    String? bloodGroup,
    String? rhesusFactor,
    double? height,
    double? weight,
    double? bmi,
    List<String>? allergies,
    List<String>? chronicIllnesses,
    List<String>? disabilities,
    String? specialMedicalNeeds,
    String? medicalNotes,
    List<String>? currentMedications,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? familyDoctorName,
    String? familyDoctorPhone,
    String? hospitalPreference,
    String? insuranceInformation,
    List<VaccinationRecord>? vaccinationHistory,
    List<String>? medicalRestrictions,
    List<String>? dietaryRestrictions,
    List<String>? physicalActivityRestrictions,
  }) {
    return StudentHealthProfile(
      studentId: studentId,
      schoolId: schoolId,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      rhesusFactor: rhesusFactor ?? this.rhesusFactor,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      allergies: allergies ?? this.allergies,
      chronicIllnesses: chronicIllnesses ?? this.chronicIllnesses,
      disabilities: disabilities ?? this.disabilities,
      specialMedicalNeeds: specialMedicalNeeds ?? this.specialMedicalNeeds,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      currentMedications: currentMedications ?? this.currentMedications,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      familyDoctorName: familyDoctorName ?? this.familyDoctorName,
      familyDoctorPhone: familyDoctorPhone ?? this.familyDoctorPhone,
      hospitalPreference: hospitalPreference ?? this.hospitalPreference,
      insuranceInformation: insuranceInformation ?? this.insuranceInformation,
      vaccinationHistory: vaccinationHistory ?? this.vaccinationHistory,
      medicalRestrictions: medicalRestrictions ?? this.medicalRestrictions,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      physicalActivityRestrictions:
          physicalActivityRestrictions ?? this.physicalActivityRestrictions,
    );
  }

  @override
  List<Object?> get props => [
    studentId,
    schoolId,
    bloodGroup,
    rhesusFactor,
    height,
    weight,
    bmi,
    allergies,
    chronicIllnesses,
    disabilities,
    specialMedicalNeeds,
    medicalNotes,
    currentMedications,
    emergencyContactName,
    emergencyContactPhone,
    familyDoctorName,
    familyDoctorPhone,
    hospitalPreference,
    insuranceInformation,
    vaccinationHistory,
    medicalRestrictions,
    dietaryRestrictions,
    physicalActivityRestrictions,
  ];
}

class VaccinationRecord extends Equatable {
  final String id;
  final String vaccineName;
  final DateTime dateAdministered;
  final DateTime? nextDueDate;
  final String? healthProvider;
  final String? certificateUrl;

  const VaccinationRecord({
    required this.id,
    required this.vaccineName,
    required this.dateAdministered,
    this.nextDueDate,
    this.healthProvider,
    this.certificateUrl,
  });

  @override
  List<Object?> get props => [
    id,
    vaccineName,
    dateAdministered,
    nextDueDate,
    healthProvider,
    certificateUrl,
  ];
}
