import 'package:equatable/equatable.dart';

/// A single code that grants a parent access to one or more students
/// (siblings). Doc ID in Firestore IS the code, so a parent can be looked
/// up by exact match before they've signed in.
class ParentAccessCode extends Equatable {
  final String id; // Internal System ID (UUID)
  final String parentCode; // Human-Friendly Code (e.g., SMAC583920)
  final String schoolId;
  final List<String> studentIds;
  final List<String> studentNames;
  final String? parentName;
  final String? phoneNumber; // Added for verification
  final String? pin; // Temporary or permanent PIN
  final bool mustChangePin;

  final bool isActive;
  final String? deactivationReason;

  /// Alias for parentCode for backward compatibility in UI
  String get code => parentCode;

  const ParentAccessCode({
    required this.id,
    required this.parentCode,
    required this.schoolId,
    required this.studentIds,
    required this.studentNames,
    this.parentName,
    this.phoneNumber,
    this.pin,
    this.mustChangePin = true,
    this.isActive = true,
    this.deactivationReason,
  });

  @override
  List<Object?> get props => [
        id,
        parentCode,
        schoolId,
        studentIds,
        studentNames,
        parentName,
        phoneNumber,
        pin,
        mustChangePin,
        isActive,
        deactivationReason,
      ];
}
