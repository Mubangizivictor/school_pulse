import 'package:equatable/equatable.dart';

class VisitorBlacklist extends Equatable {
  final String id;
  final String schoolId;
  final String visitorId;
  final String fullName;
  final String phone;
  final String reason;
  final DateTime dateAdded;
  final String addedBy;

  const VisitorBlacklist({
    required this.id,
    required this.schoolId,
    required this.visitorId,
    required this.fullName,
    required this.phone,
    required this.reason,
    required this.dateAdded,
    required this.addedBy,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    visitorId,
    fullName,
    phone,
    reason,
    dateAdded,
    addedBy,
  ];
}
