import 'package:equatable/equatable.dart';

/// What a Bursar is allowed to see for one student - finance only.
/// This service has no dependency capable of reading medical/health data,
/// so there's nothing to leak even by accident.
class BursarStudentView extends Equatable {
  final String studentId;
  final String name;
  final String classId;
  final double totalBilled;
  final double totalPaid;
  final double balance;
  final bool isFullyPaid;

  const BursarStudentView({
    required this.studentId,
    required this.name,
    required this.classId,
    required this.totalBilled,
    required this.totalPaid,
    required this.balance,
    required this.isFullyPaid,
  });

  @override
  List<Object?> get props => [
    studentId,
    name,
    classId,
    totalBilled,
    totalPaid,
    balance,
    isFullyPaid,
  ];
}
