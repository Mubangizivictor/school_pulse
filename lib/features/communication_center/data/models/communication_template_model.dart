import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_campaign.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_template.dart';

class CommunicationTemplateModel extends CommunicationTemplate {
  const CommunicationTemplateModel({
    required super.templateId,
    required super.schoolId,
    required super.name,
    super.communicationType,
    super.shortSummary,
    required super.body,
    super.placeholders,
    super.createdAt,
    super.updatedAt,
  });

  factory CommunicationTemplateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? const {};
    return CommunicationTemplateModel(
      templateId: doc.id,
      schoolId: data['schoolId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      communicationType: CommunicationTypeX.fromWire(
        data['communicationType'] as String?,
      ),
      shortSummary: data['shortSummary'] as String? ?? '',
      body: data['body'] as String? ?? '',
      placeholders: List<String>.from(data['placeholders'] ?? const []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toDraftPayload() {
    return {
      'name': name,
      'communicationType': communicationType.wireName,
      'shortSummary': shortSummary,
      'body': body,
      'placeholders': placeholders,
    };
  }
}
