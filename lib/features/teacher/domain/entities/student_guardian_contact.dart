import 'package:equatable/equatable.dart';

/// The parent/guardian contact a teacher may reach for one student, resolved
/// from the same registration-time link the parent portal itself uses -
/// never a hardcoded or guessed value.
class StudentGuardianContact extends Equatable {
  final String name;
  final String phoneNumber;
  final String relationship;

  /// Set once the parent has activated a portal account. Null when they
  /// hold only an access code - messaging has nobody to address yet.
  final String? userId;

  const StudentGuardianContact({
    required this.name,
    required this.phoneNumber,
    this.relationship = '',
    this.userId,
  });

  bool get hasPhone => phoneNumber.trim().isNotEmpty;
  bool get canMessage => userId != null && userId!.isNotEmpty;

  @override
  List<Object?> get props => [name, phoneNumber, relationship, userId];
}
