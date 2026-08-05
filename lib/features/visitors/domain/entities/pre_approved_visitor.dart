import 'package:equatable/equatable.dart';

class PreApprovedVisitor extends Equatable {
  final String id;
  final String schoolId;
  final String fullName;
  final String phone;
  final String purpose;
  final DateTime expectedDate;
  final String host;
  final bool isUsed;

  const PreApprovedVisitor({
    required this.id,
    required this.schoolId,
    required this.fullName,
    required this.phone,
    required this.purpose,
    required this.expectedDate,
    required this.host,
    this.isUsed = false,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    fullName,
    phone,
    purpose,
    expectedDate,
    host,
    isUsed,
  ];
}
