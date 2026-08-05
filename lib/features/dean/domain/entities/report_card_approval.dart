import 'package:equatable/equatable.dart';

class ReportCardApproval extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String className;
  final double averageScore;
  final String term;
  final String year;
  final bool isApproved;
  final String? rejectionReason;

  const ReportCardApproval({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.averageScore,
    required this.term,
    required this.year,
    this.isApproved = false,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    className,
    averageScore,
    term,
    year,
    isApproved,
    rejectionReason,
  ];
}
