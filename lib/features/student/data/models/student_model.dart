import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/student_enums.dart';

class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.schoolId,
    required super.name,
    super.photoUrl,
    required super.studentCode,
    required super.admissionNumber,
    super.qrReference,
    required super.dateOfBirth,
    required super.gender,
    required super.classId,
    super.streamId,
    required super.academicYearId,
    super.previousSchool,
    required super.status,
    super.medicalInfo,
    super.emergencyContacts,
    super.parentIds,
    super.documents,
    super.campusId,
    required super.level,
    super.dormLeadershipRole,
    super.dormLeadershipDormId,
    super.dormLeadershipDormName,
  });

  StudentModel copyWithModelId(String newId) {
    return StudentModel(
      id: newId,
      schoolId: schoolId,
      name: name,
      photoUrl: photoUrl,
      studentCode: studentCode,
      admissionNumber: admissionNumber,
      qrReference: qrReference,
      dateOfBirth: dateOfBirth,
      gender: gender,
      classId: classId,
      streamId: streamId,
      academicYearId: academicYearId,
      previousSchool: previousSchool,
      status: status,
      medicalInfo: medicalInfo,
      emergencyContacts: emergencyContacts,
      parentIds: parentIds,
      documents: documents,
      campusId: campusId,
      level: level,
      dormLeadershipRole: dormLeadershipRole,
      dormLeadershipDormId: dormLeadershipDormId,
      dormLeadershipDormName: dormLeadershipDormName,
    );
  }

  factory StudentModel.fromMap(Map<String, dynamic> map, String id) {
    final rawDateOfBirth = map['dateOfBirth'];
    final dateOfBirth = switch (rawDateOfBirth) {
      Timestamp value => value.toDate(),
      String value => DateTime.tryParse(value) ?? DateTime(2000),
      _ => DateTime(2000),
    };
    final rawGender = (map['gender'] ?? '').toString().toLowerCase();
    final gender = Gender.values.firstWhere(
      (value) => value.name == rawGender,
      orElse: () => Gender.other,
    );
    final status = StudentStatus.values.firstWhere(
      (value) => value.name == (map['status'] ?? '').toString(),
      orElse: () => StudentStatus.active,
    );
    final level = EducationLevel.values.firstWhere(
      (value) => value.name == (map['level'] ?? '').toString(),
      orElse: () => EducationLevel.primary,
    );
    return StudentModel(
      id: id,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      studentCode: map['studentCode'] ?? map['studentId'] ?? '',
      admissionNumber: map['admissionNumber'] ?? map['studentId'] ?? '',
      qrReference: map['qrReference'],
      dateOfBirth: dateOfBirth,
      gender: gender,
      classId: map['classId'] ?? map['className'] ?? '',
      streamId: map['streamId'],
      academicYearId: map['academicYearId'] ?? '',
      previousSchool: map['previousSchool'],
      status: status,
      medicalInfo: map['medicalInfo'] is Map<String, dynamic>
          ? MedicalInfoModel.fromMap(map['medicalInfo'] as Map<String, dynamic>)
          : null,
      emergencyContacts: (map['emergencyContacts'] as List? ?? [])
          .map((e) => EmergencyContactModel.fromMap(e))
          .toList(),
      parentIds: List<String>.from(map['parentIds'] ?? []),
      documents: Map<String, String>.from(map['documents'] ?? {}),
      campusId: map['campusId'],
      level: level,
      dormLeadershipRole: map['dormLeadershipRole'],
      dormLeadershipDormId: map['dormLeadershipDormId'],
      dormLeadershipDormName: map['dormLeadershipDormName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'name': name,
      'photoUrl': photoUrl,
      'studentCode': studentCode,
      'admissionNumber': admissionNumber,
      'qrReference': qrReference,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender.name,
      'classId': classId,
      'streamId': streamId,
      'academicYearId': academicYearId,
      'previousSchool': previousSchool,
      'status': status.name,
      'medicalInfo': medicalInfo != null
          ? (medicalInfo as MedicalInfoModel).toMap()
          : null,
      'emergencyContacts': emergencyContacts
          .map((e) => (e as EmergencyContactModel).toMap())
          .toList(),
      'parentIds': parentIds,
      'documents': documents,
      'campusId': campusId,
      'level': level.name,
      'dormLeadershipRole': dormLeadershipRole,
      'dormLeadershipDormId': dormLeadershipDormId,
      'dormLeadershipDormName': dormLeadershipDormName,
    };
  }
}

class MedicalInfoModel extends MedicalInfo {
  const MedicalInfoModel({
    super.bloodGroup,
    super.allergies,
    super.chronicConditions,
    super.medications,
    super.disabilities,
  });

  factory MedicalInfoModel.fromMap(Map<String, dynamic> map) {
    return MedicalInfoModel(
      bloodGroup: map['bloodGroup'],
      allergies: List<String>.from(map['allergies'] ?? []),
      chronicConditions: List<String>.from(map['chronicConditions'] ?? []),
      medications: map['medications'],
      disabilities: map['disabilities'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'medications': medications,
      'disabilities': disabilities,
    };
  }
}

class EmergencyContactModel extends EmergencyContact {
  const EmergencyContactModel({
    required super.name,
    required super.relationship,
    required super.phoneNumber,
    super.email,
  });

  factory EmergencyContactModel.fromMap(Map<String, dynamic> map) {
    return EmergencyContactModel(
      name: map['name'] ?? '',
      relationship: map['relationship'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relationship': relationship,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
}
