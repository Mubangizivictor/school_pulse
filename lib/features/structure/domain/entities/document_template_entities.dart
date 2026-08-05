import 'package:equatable/equatable.dart';

/// A named document-template registry entry (Student ID Card, Report Card,
/// Certificate, Gate Pass, ...). This is a catalog entry, not a WYSIWYG
/// layout designer - actually rendering each document type stays with the
/// module that produces it (e.g. Exams already has its own richer
/// ReportTemplate for report-card layout).
class DocumentTemplateDef extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String templateType;
  final String description;
  final bool isActive;

  const DocumentTemplateDef({
    required this.id,
    required this.schoolId,
    required this.name,
    this.templateType = '',
    this.description = '',
    this.isActive = true,
  });

  DocumentTemplateDef copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? templateType,
    String? description,
    bool? isActive,
  }) {
    return DocumentTemplateDef(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      templateType: templateType ?? this.templateType,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    templateType,
    description,
    isActive,
  ];
}
