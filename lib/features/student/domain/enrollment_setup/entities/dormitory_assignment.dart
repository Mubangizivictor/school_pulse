import 'package:equatable/equatable.dart';

/// Assigns one boarding student to a specific bed in a hostel room.
/// Firestore collection: `dormitory_assignments/{id}`. Before writing a
/// new one, callers must check for an existing assignment matching
/// [hostelId]+[roomId]+[bed] exactly and refuse to overwrite it - see
/// [EnrollmentSetupRepository.assignDormitory].
class DormitoryAssignment extends Equatable {
  final String id;
  final String studentId;
  final String schoolId;
  final String hostelId;
  final String roomId;
  final String bed;
  final DateTime assignedAt;
  final String assignedBy;

  const DormitoryAssignment({
    required this.id,
    required this.studentId,
    required this.schoolId,
    required this.hostelId,
    required this.roomId,
    required this.bed,
    required this.assignedAt,
    required this.assignedBy,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    schoolId,
    hostelId,
    roomId,
    bed,
    assignedAt,
    assignedBy,
  ];
}
