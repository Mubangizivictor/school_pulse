import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/student_enrolment.dart';
import '../../domain/entities/relationship_enums.dart';

class StudentEnrolmentModel extends StudentEnrolment {
  const StudentEnrolmentModel({
    required super.id,
    required super.schoolId,
    required super.studentId,
    required super.classId,
    super.streamId,
    required super.academicYearId,
    super.status,
    required super.startDate,
    super.endDate,
    super.reason,
    required super.recordedBy,
    required super.createdAt,
  });

  factory StudentEnrolmentModel.fromMap(String id, Map<String, dynamic> map) {
    return StudentEnrolmentModel(
      id: id,
      schoolId: map['schoolId'] ?? '',
      studentId: map['studentId'] ?? '',
      classId: map['classId'] ?? '',
      streamId: map['streamId'],
      academicYearId: map['academicYearId'] ?? '',
      status: EnrolmentStatus.values.firstWhere(
        (v) => v.name == (map['status'] ?? '').toString(),
        orElse: () => EnrolmentStatus.active,
      ),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      reason: map['reason'],
      recordedBy: map['recordedBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'studentId': studentId,
      'classId': classId,
      'streamId': streamId,
      'academicYearId': academicYearId,
      'status': status.name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'reason': reason,
      'recordedBy': recordedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
