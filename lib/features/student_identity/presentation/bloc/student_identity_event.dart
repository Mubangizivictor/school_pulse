import 'package:equatable/equatable.dart';
import '../../../student/domain/entities/student.dart';

abstract class StudentIdentityEvent extends Equatable {
  const StudentIdentityEvent();

  @override
  List<Object?> get props => [];
}

class GenerateStudentIdentityEvent extends StudentIdentityEvent {
  final Student student;
  const GenerateStudentIdentityEvent(this.student);

  @override
  List<Object?> get props => [student];
}

class LoadStudentIdentityEvent extends StudentIdentityEvent {
  final String studentId;
  final String schoolId;
  const LoadStudentIdentityEvent(this.studentId, {required this.schoolId});

  @override
  List<Object?> get props => [studentId, schoolId];
}

class CacheStudentsOfflineEvent extends StudentIdentityEvent {
  final List<Student> students;
  const CacheStudentsOfflineEvent(this.students);

  @override
  List<Object?> get props => [students];
}

class AssignNfcCardEvent extends StudentIdentityEvent {
  final String cardUid;
  final String studentId;
  final String uniqueSystemId;
  final String schoolId;
  const AssignNfcCardEvent({
    required this.cardUid,
    required this.studentId,
    required this.uniqueSystemId,
    required this.schoolId,
  });

  @override
  List<Object?> get props => [cardUid, studentId, uniqueSystemId, schoolId];
}

class ReplaceNfcCardEvent extends StudentIdentityEvent {
  final String oldCardUid;
  final String newCardUid;
  final String studentId;
  final String uniqueSystemId;
  final String schoolId;
  final String reason;
  const ReplaceNfcCardEvent({
    required this.oldCardUid,
    required this.newCardUid,
    required this.studentId,
    required this.uniqueSystemId,
    required this.schoolId,
    required this.reason,
  });

  @override
  List<Object?> get props => [oldCardUid, newCardUid, studentId, uniqueSystemId, schoolId, reason];
}

class RevokeNfcCardEvent extends StudentIdentityEvent {
  final String cardUid;
  final String studentId;
  final String schoolId;
  final String reason;
  const RevokeNfcCardEvent({
    required this.cardUid,
    required this.studentId,
    required this.schoolId,
    required this.reason,
  });

  @override
  List<Object?> get props => [cardUid, studentId, schoolId, reason];
}

class ReactivateNfcCardEvent extends StudentIdentityEvent {
  final String cardUid;
  final String studentId;
  final String schoolId;
  const ReactivateNfcCardEvent({
    required this.cardUid,
    required this.studentId,
    required this.schoolId,
  });

  @override
  List<Object?> get props => [cardUid, studentId, schoolId];
}
