import 'data_operation_models.dart';

/// Contract implemented by a source module.  The Data Management Center only
/// orchestrates jobs; it never writes source records itself.
abstract interface class DataImportProvider {
  ImportTemplate get template;
  Future<void> validateAndImport({
    required String importJobId,
    required String institutionId,
    required String correlationId,
  });
}

abstract interface class DataExportProvider {
  String get moduleKey;
  Future<String> buildExport({
    required String exportJobId,
    required String institutionId,
    required Map<String, dynamic> filters,
  });
}

abstract interface class DataQualityProvider {
  String get moduleKey;
  Future<List<Map<String, dynamic>>> scan(String institutionId);
}
