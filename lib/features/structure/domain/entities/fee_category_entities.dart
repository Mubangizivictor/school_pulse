import 'package:equatable/equatable.dart';

/// Structure's own fee category definition - naming/description only, no
/// amounts, per spec ("only define structure, no finance logic"). Finance
/// maintains its own separate, already-wired FeeCategory used by real fee
/// structures; this is not a replacement for it.
class FeeCategory extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String code;
  final String description;
  final bool isMandatory;
  final bool isActive;

  const FeeCategory({
    required this.id,
    required this.schoolId,
    required this.name,
    this.code = '',
    this.description = '',
    this.isMandatory = true,
    this.isActive = true,
  });

  FeeCategory copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? code,
    String? description,
    bool? isMandatory,
    bool? isActive,
  }) {
    return FeeCategory(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      isMandatory: isMandatory ?? this.isMandatory,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    code,
    description,
    isMandatory,
    isActive,
  ];
}
