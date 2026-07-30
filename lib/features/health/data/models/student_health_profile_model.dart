import '../../domain/entities/student_health_profile.dart';

class StudentHealthProfileModel extends StudentHealthProfile {
  const StudentHealthProfileModel({
    required super.studentId,
    required super.schoolId,
    required super.bloodGroup,
    super.rhesusFactor,
    super.height,
    super.weight,
    super.bmi,
    super.allergies,
    super.chronicIllnesses,
    super.disabilities,
    super.specialMedicalNeeds,
    super.medicalNotes,
    super.currentMedications,
    required super.emergencyContactName,
    required super.emergencyContactPhone,
    super.familyDoctorName,
    super.familyDoctorPhone,
    super.hospitalPreference,
    super.insuranceInformation,
    super.vaccinationHistory,
    super.medicalRestrictions,
    super.dietaryRestrictions,
    super.physicalActivityRestrictions,
  });

  factory StudentHealthProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentHealthProfileModel(
      studentId: json['studentId'] as String,
      schoolId: json['schoolId'] as String? ?? '',
      bloodGroup: json['bloodGroup'] as String,
      rhesusFactor: json['rhesusFactor'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      allergies: List<String>.from(json['allergies'] ?? []),
      chronicIllnesses: List<String>.from(json['chronicIllnesses'] ?? []),
      disabilities: List<String>.from(json['disabilities'] ?? []),
      specialMedicalNeeds: json['specialMedicalNeeds'] as String?,
      medicalNotes: json['medicalNotes'] as String?,
      currentMedications: List<String>.from(json['currentMedications'] ?? []),
      emergencyContactName: json['emergencyContactName'] as String,
      emergencyContactPhone: json['emergencyContactPhone'] as String,
      familyDoctorName: json['familyDoctorName'] as String?,
      familyDoctorPhone: json['familyDoctorPhone'] as String?,
      hospitalPreference: json['hospitalPreference'] as String?,
      insuranceInformation: json['insuranceInformation'] as String?,
      vaccinationHistory:
          (json['vaccinationHistory'] as List?)
              ?.map(
                (e) =>
                    VaccinationRecordModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      medicalRestrictions: List<String>.from(json['medicalRestrictions'] ?? []),
      dietaryRestrictions: List<String>.from(json['dietaryRestrictions'] ?? []),
      physicalActivityRestrictions: List<String>.from(
        json['physicalActivityRestrictions'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'schoolId': schoolId,
      'bloodGroup': bloodGroup,
      'rhesusFactor': rhesusFactor,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'allergies': allergies,
      'chronicIllnesses': chronicIllnesses,
      'disabilities': disabilities,
      'specialMedicalNeeds': specialMedicalNeeds,
      'medicalNotes': medicalNotes,
      'currentMedications': currentMedications,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'familyDoctorName': familyDoctorName,
      'familyDoctorPhone': familyDoctorPhone,
      'hospitalPreference': hospitalPreference,
      'insuranceInformation': insuranceInformation,
      'vaccinationHistory': vaccinationHistory
          .map(
            (record) => record is VaccinationRecordModel
                ? record.toJson()
                : {
                    'id': record.id,
                    'vaccineName': record.vaccineName,
                    'dateAdministered': record.dateAdministered
                        .toIso8601String(),
                    'nextDueDate': record.nextDueDate?.toIso8601String(),
                    'healthProvider': record.healthProvider,
                    'certificateUrl': record.certificateUrl,
                  },
          )
          .toList(),
      'medicalRestrictions': medicalRestrictions,
      'dietaryRestrictions': dietaryRestrictions,
      'physicalActivityRestrictions': physicalActivityRestrictions,
    };
  }
}

class VaccinationRecordModel extends VaccinationRecord {
  const VaccinationRecordModel({
    required super.id,
    required super.vaccineName,
    required super.dateAdministered,
    super.nextDueDate,
    super.healthProvider,
    super.certificateUrl,
  });

  factory VaccinationRecordModel.fromJson(Map<String, dynamic> json) {
    return VaccinationRecordModel(
      id: json['id'] as String,
      vaccineName: json['vaccineName'] as String,
      dateAdministered: DateTime.parse(json['dateAdministered'] as String),
      nextDueDate: json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'] as String)
          : null,
      healthProvider: json['healthProvider'] as String?,
      certificateUrl: json['certificateUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vaccineName': vaccineName,
      'dateAdministered': dateAdministered.toIso8601String(),
      'nextDueDate': nextDueDate?.toIso8601String(),
      'healthProvider': healthProvider,
      'certificateUrl': certificateUrl,
    };
  }
}
