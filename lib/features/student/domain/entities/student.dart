import 'package:equatable/equatable.dart';
import 'student_enums.dart';

class Student extends Equatable {
  final String id; // Internal System ID (UUID)
  final String schoolId;
  final String name;
  final String? photoUrl;
  final String studentCode; // Human-Friendly Code (e.g., SMAC260001)
  final String admissionNumber; // Legacy or sequential number
  final String? qrReference; // Secure reference token for QR codes
  final DateTime dateOfBirth;
  final Gender gender;
  final String classId;
  final String? streamId;
  final String academicYearId;
  final String? previousSchool;
  final StudentStatus status;

  // Detailed Information
  final MedicalInfo? medicalInfo;
  final List<EmergencyContact> emergencyContacts;
  final List<String> parentIds; // IDs of related parents/guardians
  final Map<String, String> documents; // documentType -> url

  // Hierarchical Assignment
  final String? campusId;
  final EducationLevel level;

  // Boarding dorm leadership (Room Leader / Dorm Prefect), set by the
  // Matron/Patron boarding modules - null if the student holds no role.
  final String? dormLeadershipRole;
  final String? dormLeadershipDormId;
  final String? dormLeadershipDormName;

  // Day/boarding classification, set during the Enrollment Setup Wizard's
  // Admission step. Null for students enrolled before this field existed
  // or where it was never captured.
  final StudentBoardingType? boardingType;

  const Student({
    required this.id,
    required this.schoolId,
    required this.name,
    this.photoUrl,
    required this.studentCode,
    required this.admissionNumber,
    this.qrReference,
    required this.dateOfBirth,
    required this.gender,
    required this.classId,
    this.streamId,
    required this.academicYearId,
    this.previousSchool,
    required this.status,
    this.medicalInfo,
    this.emergencyContacts = const [],
    this.parentIds = const [],
    this.documents = const {},
    this.campusId,
    required this.level,
    this.dormLeadershipRole,
    this.dormLeadershipDormId,
    this.dormLeadershipDormName,
    this.boardingType,
  });

  factory Student.empty([String id = '']) {
    return Student(
      id: id,
      schoolId: '',
      name: '',
      studentCode: '',
      admissionNumber: '',
      dateOfBirth: DateTime(2000),
      gender: Gender.male,
      classId: '',
      academicYearId: '',
      status: StudentStatus.active,
      level: EducationLevel.primary,
    );
  }

  String get studentId => id;
  String get className =>
      classId; // Temporary alias until class objects are used everywhere

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    photoUrl,
    studentCode,
    admissionNumber,
    qrReference,
    dateOfBirth,
    gender,
    classId,
    streamId,
    academicYearId,
    previousSchool,
    status,
    medicalInfo,
    emergencyContacts,
    parentIds,
    documents,
    campusId,
    level,
    dormLeadershipRole,
    dormLeadershipDormId,
    dormLeadershipDormName,
    boardingType,
  ];

  Student copyWith({
    String? name,
    String? photoUrl,
    String? classId,
    String? streamId,
    String? academicYearId,
    StudentStatus? status,
    MedicalInfo? medicalInfo,
    List<EmergencyContact>? emergencyContacts,
    List<String>? parentIds,
    Map<String, String>? documents,
    String? campusId,
    StudentBoardingType? boardingType,
  }) {
    return Student(
      id: id,
      schoolId: schoolId,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      studentCode: studentCode,
      admissionNumber: admissionNumber,
      qrReference: qrReference,
      dateOfBirth: dateOfBirth,
      gender: gender,
      classId: classId ?? this.classId,
      streamId: streamId ?? this.streamId,
      academicYearId: academicYearId ?? this.academicYearId,
      previousSchool: previousSchool,
      status: status ?? this.status,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      parentIds: parentIds ?? this.parentIds,
      documents: documents ?? this.documents,
      campusId: campusId ?? this.campusId,
      level: level,
      dormLeadershipRole: dormLeadershipRole,
      dormLeadershipDormId: dormLeadershipDormId,
      dormLeadershipDormName: dormLeadershipDormName,
      boardingType: boardingType ?? this.boardingType,
    );
  }
}

class MedicalInfo extends Equatable {
  final String? bloodGroup;
  final List<String> allergies;
  final List<String> chronicConditions;
  final String? medications;
  final String? disabilities;

  const MedicalInfo({
    this.bloodGroup,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.medications,
    this.disabilities,
  });

  @override
  List<Object?> get props => [
    bloodGroup,
    allergies,
    chronicConditions,
    medications,
    disabilities,
  ];
}

class EmergencyContact extends Equatable {
  final String name;
  final String relationship;
  final String phoneNumber;
  final String? email;

  /// Optional users/{uid} if this contact also happens to hold a login
  /// (e.g. they're already a parent on another child). Not required - most
  /// emergency contacts have no account at all, per design.
  final String? linkedUserId;

  const EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.email,
    this.linkedUserId,
  });

  @override
  List<Object?> get props => [
    name,
    relationship,
    phoneNumber,
    email,
    linkedUserId,
  ];
}
