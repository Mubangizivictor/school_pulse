import 'package:equatable/equatable.dart';
import '../../domain/entities/boarding_entities.dart';

abstract class MatronEvent extends Equatable {
  const MatronEvent();

  @override
  List<Object?> get props => [];
}

class MatronDashboardRequested extends MatronEvent {
  final String? schoolId;
  final String? gender;
  const MatronDashboardRequested({this.schoolId, this.gender});

  @override
  List<Object?> get props => [schoolId, gender];
}

// Dormitory Management
class DormitoriesRequested extends MatronEvent {
  final String? gender;
  const DormitoriesRequested({this.gender});

  @override
  List<Object?> get props => [gender];
}

class UnallocatedStudentsRequested extends MatronEvent {
  final String? gender;
  const UnallocatedStudentsRequested({this.gender});

  @override
  List<Object?> get props => [gender];
}

class AllocateStudentRequested extends MatronEvent {
  final String studentId;
  final String dormitoryId;
  final String? bedNumber;

  const AllocateStudentRequested({
    required this.studentId,
    required this.dormitoryId,
    this.bedNumber,
  });

  @override
  List<Object?> get props => [studentId, dormitoryId, bedNumber];
}

class DormitoryStudentsRequested extends MatronEvent {
  final String dormitoryId;
  const DormitoryStudentsRequested(this.dormitoryId);

  @override
  List<Object?> get props => [dormitoryId];
}

// Attendance
class SubmitAttendanceRequested extends MatronEvent {
  final String dormitoryId;
  final String type;
  final Map<String, String> attendance;

  const SubmitAttendanceRequested({
    required this.dormitoryId,
    required this.type,
    required this.attendance,
  });

  @override
  List<Object?> get props => [dormitoryId, type, attendance];
}

// Welfare
class WelfareRecordsRequested extends MatronEvent {
  final String? schoolId;
  final String? studentId;
  final String? gender;
  const WelfareRecordsRequested({this.schoolId, this.studentId, this.gender});

  @override
  List<Object?> get props => [schoolId, studentId, gender];
}

class AddWelfareRecordRequested extends MatronEvent {
  final WelfareRecord record;
  const AddWelfareRecordRequested(this.record);

  @override
  List<Object?> get props => [record];
}

// Discipline
class DisciplineCasesRequested extends MatronEvent {
  final String? studentId;
  final String? gender;
  const DisciplineCasesRequested({this.studentId, this.gender});

  @override
  List<Object?> get props => [studentId, gender];
}

class AddDisciplineCaseRequested extends MatronEvent {
  final DisciplineCase disciplineCase;
  const AddDisciplineCaseRequested(this.disciplineCase);

  @override
  List<Object?> get props => [disciplineCase];
}

// Hygiene
class HygieneChecksRequested extends MatronEvent {
  final String? dormitoryId;
  final String? gender;
  const HygieneChecksRequested({this.dormitoryId, this.gender});

  @override
  List<Object?> get props => [dormitoryId, gender];
}

class AddHygieneCheckRequested extends MatronEvent {
  final HygieneCheck check;
  const AddHygieneCheckRequested(this.check);

  @override
  List<Object?> get props => [check];
}

// Leave
class StudentsOnLeaveRequested extends MatronEvent {
  final String? gender;
  const StudentsOnLeaveRequested({this.gender});

  @override
  List<Object?> get props => [gender];
}
