import 'package:equatable/equatable.dart';

class SheetsIntegration extends Equatable {
  final bool linked;
  final String spreadsheetId;
  final String spreadsheetName;
  final String worksheetName;
  final bool autoSync;
  final String syncFrequency;
  final DateTime? lastSyncAt;
  final String lastSyncStatus;

  const SheetsIntegration({
    this.linked = false,
    this.spreadsheetId = '',
    this.spreadsheetName = '',
    this.worksheetName = '',
    this.autoSync = true,
    this.syncFrequency = 'Every marking',
    this.lastSyncAt,
    this.lastSyncStatus = '',
  });

  SheetsIntegration copyWith({
    bool? linked,
    String? spreadsheetId,
    String? spreadsheetName,
    String? worksheetName,
    bool? autoSync,
    String? syncFrequency,
    DateTime? lastSyncAt,
    String? lastSyncStatus,
  }) {
    return SheetsIntegration(
      linked: linked ?? this.linked,
      spreadsheetId: spreadsheetId ?? this.spreadsheetId,
      spreadsheetName: spreadsheetName ?? this.spreadsheetName,
      worksheetName: worksheetName ?? this.worksheetName,
      autoSync: autoSync ?? this.autoSync,
      syncFrequency: syncFrequency ?? this.syncFrequency,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
    );
  }

  @override
  List<Object?> get props => [
    linked,
    spreadsheetId,
    spreadsheetName,
    worksheetName,
    autoSync,
    syncFrequency,
    lastSyncAt,
    lastSyncStatus,
  ];
}

class SheetsSyncLogEntry extends Equatable {
  final String id;
  final DateTime startedAt;
  final bool success;
  final int recordCount;
  final String? errorMessage;

  const SheetsSyncLogEntry({
    required this.id,
    required this.startedAt,
    required this.success,
    required this.recordCount,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [id, startedAt, success, recordCount, errorMessage];
}
