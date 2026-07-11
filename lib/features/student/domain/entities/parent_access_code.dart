import 'package:equatable/equatable.dart';

/// A single code that grants a parent access to one or more students
/// (siblings). Doc ID in Firestore IS the code, so a parent can be looked
/// up by exact match before they've signed in.
class ParentAccessCode extends Equatable {
  final String code;
  final List<String> studentIds;
  final List<String> studentNames;
  final String? parentName;

  final bool isActive;

  const ParentAccessCode({
    required this.code,
    required this.studentIds,
    required this.studentNames,
    this.parentName,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [code, studentIds, studentNames, parentName, isActive];
}
