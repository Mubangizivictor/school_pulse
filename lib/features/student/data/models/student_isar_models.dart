import 'dart:convert';
import 'package:isar/isar.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/student_enums.dart';

part 'student_isar_models.g.dart';

/// Offline-first cache of the full Student profile, distinct from
/// student_identity's StudentCacheIsar (which only holds the thin
/// QR/NFC-lookup projection). This one backs offline search and profile
/// viewing for the Student Information module itself.
@collection
class StudentProfileIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String studentId;

  @Index()
  late String schoolId;

  @Index(caseSensitive: false)
  late String name;

  String? photoUrl;

  @Index()
  late String studentCode;

  @Index()
  late String admissionNumber;

  String? qrReference;
  late DateTime dateOfBirth;
  late String gender;

  @Index()
  late String classId;

  String? streamId;
  late String academicYearId;
  String? previousSchool;

  @Index()
  late String status;

  String? campusId;
  late String level;

  // Nested structures have no first-class Isar representation here, so
  // they're kept as JSON strings, matching the flatten-on-write approach
  // gate_ops uses for its own non-scalar entity fields.
  String? medicalInfoJson;
  late String emergencyContactsJson;
  late List<String> parentIds;
  late String documentsJson;

  String? dormLeadershipRole;
  String? dormLeadershipDormId;
  String? dormLeadershipDormName;

  StudentProfileIsar();

  factory StudentProfileIsar.fromEntity(Student entity) {
    return StudentProfileIsar()
      ..studentId = entity.id
      ..schoolId = entity.schoolId
      ..name = entity.name
      ..photoUrl = entity.photoUrl
      ..studentCode = entity.studentCode
      ..admissionNumber = entity.admissionNumber
      ..qrReference = entity.qrReference
      ..dateOfBirth = entity.dateOfBirth
      ..gender = entity.gender.name
      ..classId = entity.classId
      ..streamId = entity.streamId
      ..academicYearId = entity.academicYearId
      ..previousSchool = entity.previousSchool
      ..status = entity.status.name
      ..campusId = entity.campusId
      ..level = entity.level.name
      ..medicalInfoJson = entity.medicalInfo == null
          ? null
          : jsonEncode({
              'bloodGroup': entity.medicalInfo!.bloodGroup,
              'allergies': entity.medicalInfo!.allergies,
              'chronicConditions': entity.medicalInfo!.chronicConditions,
              'medications': entity.medicalInfo!.medications,
              'disabilities': entity.medicalInfo!.disabilities,
            })
      ..emergencyContactsJson = jsonEncode(
        entity.emergencyContacts
            .map(
              (c) => {
                'name': c.name,
                'relationship': c.relationship,
                'phoneNumber': c.phoneNumber,
                'email': c.email,
                'linkedUserId': c.linkedUserId,
              },
            )
            .toList(),
      )
      ..parentIds = entity.parentIds
      ..documentsJson = jsonEncode(entity.documents)
      ..dormLeadershipRole = entity.dormLeadershipRole
      ..dormLeadershipDormId = entity.dormLeadershipDormId
      ..dormLeadershipDormName = entity.dormLeadershipDormName;
  }

  Student toEntity() {
    final rawMedical = medicalInfoJson;
    final medicalMap = rawMedical == null
        ? null
        : jsonDecode(rawMedical) as Map<String, dynamic>;
    final contactsList = jsonDecode(emergencyContactsJson) as List;
    final documentsMap = jsonDecode(documentsJson) as Map<String, dynamic>;

    return Student(
      id: studentId,
      schoolId: schoolId,
      name: name,
      photoUrl: photoUrl,
      studentCode: studentCode,
      admissionNumber: admissionNumber,
      qrReference: qrReference,
      dateOfBirth: dateOfBirth,
      gender: Gender.values.firstWhere(
        (v) => v.name == gender,
        orElse: () => Gender.other,
      ),
      classId: classId,
      streamId: streamId,
      academicYearId: academicYearId,
      previousSchool: previousSchool,
      status: StudentStatus.values.firstWhere(
        (v) => v.name == status,
        orElse: () => StudentStatus.active,
      ),
      medicalInfo: medicalMap == null
          ? null
          : MedicalInfo(
              bloodGroup: medicalMap['bloodGroup'] as String?,
              allergies: List<String>.from(medicalMap['allergies'] ?? []),
              chronicConditions: List<String>.from(
                medicalMap['chronicConditions'] ?? [],
              ),
              medications: medicalMap['medications'] as String?,
              disabilities: medicalMap['disabilities'] as String?,
            ),
      emergencyContacts: contactsList
          .cast<Map<String, dynamic>>()
          .map(
            (c) => EmergencyContact(
              name: c['name'] ?? '',
              relationship: c['relationship'] ?? '',
              phoneNumber: c['phoneNumber'] ?? '',
              email: c['email'] as String?,
              linkedUserId: c['linkedUserId'] as String?,
            ),
          )
          .toList(),
      parentIds: parentIds,
      documents: documentsMap.map((k, v) => MapEntry(k, v as String)),
      campusId: campusId,
      level: EducationLevel.values.firstWhere(
        (v) => v.name == level,
        orElse: () => EducationLevel.primary,
      ),
      dormLeadershipRole: dormLeadershipRole,
      dormLeadershipDormId: dormLeadershipDormId,
      dormLeadershipDormName: dormLeadershipDormName,
    );
  }
}
