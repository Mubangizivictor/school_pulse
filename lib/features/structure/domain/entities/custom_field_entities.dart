import 'package:equatable/equatable.dart';

/// An admin-defined custom field on a record type (Student, Staff, ...).
/// This defines the field itself; storing/reading each record's actual
/// custom-field values is left to whichever module owns that record.
class CustomFieldDef extends Equatable {
  final String id;
  final String appliesTo;
  final String fieldName;
  final String fieldType;
  final List<String> options;
  final bool isRequired;
  final bool isActive;

  const CustomFieldDef({
    required this.id,
    required this.appliesTo,
    required this.fieldName,
    this.fieldType = 'text',
    this.options = const [],
    this.isRequired = false,
    this.isActive = true,
  });

  CustomFieldDef copyWith({
    String? id,
    String? appliesTo,
    String? fieldName,
    String? fieldType,
    List<String>? options,
    bool? isRequired,
    bool? isActive,
  }) {
    return CustomFieldDef(
      id: id ?? this.id,
      appliesTo: appliesTo ?? this.appliesTo,
      fieldName: fieldName ?? this.fieldName,
      fieldType: fieldType ?? this.fieldType,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props =>
      [id, appliesTo, fieldName, fieldType, options, isRequired, isActive];
}
