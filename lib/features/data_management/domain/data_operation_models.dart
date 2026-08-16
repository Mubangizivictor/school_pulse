import 'package:cloud_firestore/cloud_firestore.dart';

enum DataOperationStatus {
  uploaded,
  parsing,
  validating,
  needsMapping,
  needsReview,
  ready,
  importing,
  partiallyCompleted,
  completed,
  failed,
  cancelled,
  rolledBack,
  queued,
  processing,
  expired,
}

enum DataOperationKind { import, export, migration, quality, restore }

class DataOperation {
  const DataOperation({
    required this.id,
    required this.kind,
    required this.moduleKey,
    required this.status,
    required this.createdAt,
    this.total = 0,
    this.processed = 0,
    this.failed = 0,
    this.duplicates = 0,
    this.fileReference,
    this.failureReason,
    this.correlationId,
  });

  final String id;
  final DataOperationKind kind;
  final String moduleKey;
  final DataOperationStatus status;
  final DateTime createdAt;
  final int total;
  final int processed;
  final int failed;
  final int duplicates;
  final String? fileReference;
  final String? failureReason;
  final String? correlationId;

  factory DataOperation.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
    DataOperationKind kind,
  ) {
    final data = document.data();
    final created = data['createdAt'];
    return DataOperation(
      id: document.id,
      kind: kind,
      moduleKey:
          data['moduleKey'] as String? ??
          data['migrationKey'] as String? ??
          'data',
      status: _status(data['status'] as String?),
      createdAt: created is Timestamp
          ? created.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      total:
          (data['totalRows'] ??
                  data['totalRecords'] ??
                  data['recordsScanned'] ??
                  0)
              as int,
      processed:
          (data['processedRows'] ??
                  data['processedRecords'] ??
                  data['migrated'] ??
                  0)
              as int,
      failed: (data['failedRows'] ?? data['failed'] ?? 0) as int,
      duplicates: (data['duplicateRows'] ?? 0) as int,
      fileReference: data['fileReference'] as String?,
      failureReason: data['failureReason'] as String?,
      correlationId: data['correlationId'] as String?,
    );
  }

  static DataOperationStatus _status(String? value) {
    return DataOperationStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => DataOperationStatus.queued,
    );
  }
}

class ImportTemplate {
  const ImportTemplate({
    required this.moduleKey,
    required this.label,
    required this.templateVersion,
    required this.requiredColumns,
    required this.optionalColumns,
    required this.duplicateKeys,
  });

  final String moduleKey;
  final String label;
  final String templateVersion;
  final List<String> requiredColumns;
  final List<String> optionalColumns;
  final List<String> duplicateKeys;
}

const supportedImportTemplates = <ImportTemplate>[
  ImportTemplate(
    moduleKey: 'students',
    label: 'Students',
    templateVersion: 'students-v1',
    requiredColumns: [
      'admissionNumber',
      'firstName',
      'lastName',
      'academicUnit',
    ],
    optionalColumns: ['dateOfBirth', 'gender', 'guardianPhone', 'email'],
    duplicateKeys: ['admissionNumber', 'studentCode', 'name + dateOfBirth'],
  ),
  ImportTemplate(
    moduleKey: 'staff',
    label: 'Staff',
    templateVersion: 'staff-v1',
    requiredColumns: ['staffCode', 'firstName', 'lastName'],
    optionalColumns: ['email', 'phone', 'department'],
    duplicateKeys: ['staffCode', 'email', 'phone'],
  ),
  ImportTemplate(
    moduleKey: 'parents',
    label: 'Parents & guardians',
    templateVersion: 'parents-v1',
    requiredColumns: ['firstName', 'lastName'],
    optionalColumns: ['phone', 'email', 'parentCode'],
    duplicateKeys: ['parentCode', 'email', 'phone'],
  ),
  ImportTemplate(
    moduleKey: 'structure',
    label: 'Academic structure',
    templateVersion: 'structure-v1',
    requiredColumns: ['name', 'type'],
    optionalColumns: ['code', 'parentCode', 'campus'],
    duplicateKeys: ['code', 'normalizedName + parentPath'],
  ),
];
