import 'package:equatable/equatable.dart';

/// Simple connection states surfaced in the UI - deliberately not
/// Google/OAuth terminology, per the "translate errors" requirement.
enum SheetsConnectionStatus { connected, needsAttention, disconnected }

SheetsConnectionStatus _connectionStatusFrom(String? raw) {
  switch (raw) {
    case 'connected':
      return SheetsConnectionStatus.connected;
    case 'needs_attention':
      return SheetsConnectionStatus.needsAttention;
    default:
      return SheetsConnectionStatus.disconnected;
  }
}

class SheetsIntegration extends Equatable {
  final bool linked;
  final String spreadsheetId;
  final String spreadsheetName;
  final String worksheetName;
  final bool autoSync;
  final String syncFrequency;
  final DateTime? lastSyncAt;
  final String lastSyncStatus;
  final String connectedAccountEmail;
  final SheetsConnectionStatus connectionStatus;
  final String connectedBy;
  final DateTime? connectedAt;

  const SheetsIntegration({
    this.linked = false,
    this.spreadsheetId = '',
    this.spreadsheetName = '',
    this.worksheetName = '',
    this.autoSync = true,
    this.syncFrequency = 'Every marking',
    this.lastSyncAt,
    this.lastSyncStatus = '',
    this.connectedAccountEmail = '',
    this.connectionStatus = SheetsConnectionStatus.disconnected,
    this.connectedBy = '',
    this.connectedAt,
  });

  factory SheetsIntegration.fromMap(Map<String, dynamic> map) {
    DateTime? toDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return (value as dynamic).toDate() as DateTime;
      } catch (_) {
        return null;
      }
    }

    return SheetsIntegration(
      linked: map['linked'] == true,
      spreadsheetId: (map['spreadsheetId'] as String?) ?? '',
      spreadsheetName: (map['spreadsheetName'] as String?) ?? '',
      worksheetName: (map['worksheetName'] as String?) ?? '',
      autoSync: map['autoSync'] != false,
      syncFrequency: (map['syncFrequency'] as String?) ?? 'Every marking',
      lastSyncAt: toDate(map['lastSyncAt']),
      lastSyncStatus: (map['lastSyncStatus'] as String?) ?? '',
      connectedAccountEmail: (map['connectedAccountEmail'] as String?) ?? '',
      connectionStatus: _connectionStatusFrom(
        map['connectionStatus'] as String?,
      ),
      connectedBy: (map['connectedBy'] as String?) ?? '',
      connectedAt: toDate(map['connectedAt']),
    );
  }

  SheetsIntegration copyWith({
    bool? linked,
    String? spreadsheetId,
    String? spreadsheetName,
    String? worksheetName,
    bool? autoSync,
    String? syncFrequency,
    DateTime? lastSyncAt,
    String? lastSyncStatus,
    String? connectedAccountEmail,
    SheetsConnectionStatus? connectionStatus,
    String? connectedBy,
    DateTime? connectedAt,
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
      connectedAccountEmail:
          connectedAccountEmail ?? this.connectedAccountEmail,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      connectedBy: connectedBy ?? this.connectedBy,
      connectedAt: connectedAt ?? this.connectedAt,
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
    connectedAccountEmail,
    connectionStatus,
    connectedBy,
    connectedAt,
  ];
}

class ResyncResult extends Equatable {
  final int recordsScanned;
  final int recordsExported;
  final int recordsSkippedAlreadyExported;

  const ResyncResult({
    required this.recordsScanned,
    required this.recordsExported,
    required this.recordsSkippedAlreadyExported,
  });

  @override
  List<Object?> get props => [
    recordsScanned,
    recordsExported,
    recordsSkippedAlreadyExported,
  ];
}

class SessionExportResult extends Equatable {
  final int recordCount;
  final int alreadyExportedCount;

  const SessionExportResult({
    required this.recordCount,
    required this.alreadyExportedCount,
  });

  @override
  List<Object?> get props => [recordCount, alreadyExportedCount];
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
  List<Object?> get props => [
    id,
    startedAt,
    success,
    recordCount,
    errorMessage,
  ];
}
