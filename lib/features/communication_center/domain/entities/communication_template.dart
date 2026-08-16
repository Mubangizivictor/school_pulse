import 'package:equatable/equatable.dart';
import 'communication_campaign.dart';

/// A reusable message body (fee reminder, school closure, etc). Wording is
/// always institution-authored; nothing here is hardcoded.
class CommunicationTemplate extends Equatable {
  final String templateId;
  final String schoolId;
  final String name;
  final CommunicationType communicationType;
  final String shortSummary;
  final String body;
  final List<String> placeholders;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CommunicationTemplate({
    required this.templateId,
    required this.schoolId,
    required this.name,
    this.communicationType = CommunicationType.custom,
    this.shortSummary = '',
    required this.body,
    this.placeholders = const [],
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    templateId,
    schoolId,
    name,
    communicationType,
    shortSummary,
    body,
    placeholders,
    createdAt,
    updatedAt,
  ];
}
