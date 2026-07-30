import 'package:equatable/equatable.dart';

/// A named document-template registry entry (Student ID Card, Report Card,
/// Certificate, Gate Pass, ...). This is a catalog entry, not a WYSIWYG
/// layout designer - actually rendering each document type stays with the
/// module that produces it (e.g. Exams already has its own richer
/// ReportTemplate for report-card layout).
class DocumentTemplateDef extends Equatable {
  final String id;
  final String name;
  final String templateType;
  final String description;
  final bool isActive;

  const DocumentTemplateDef({
    required this.id,
    required this.name,
    this.templateType = '',
    this.description = '',
    this.isActive = true,
  });

  DocumentTemplateDef copyWith({
    String? id,
    String? name,
    String? templateType,
    String? description,
    bool? isActive,
  }) {
    return DocumentTemplateDef(
      id: id ?? this.id,
      name: name ?? this.name,
      templateType: templateType ?? this.templateType,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, templateType, description, isActive];
}
