import 'package:flutter/material.dart';
import 'package:school_pulse/core/permissions/permission.dart';

enum ReportSensitivity { normal, sensitive, restricted }

enum ReportFormat { pdf, excel, csv }

enum ReportScope { institution, campus, division, department, classRoom }

enum ReportJobStatus { queued, processing, ready, failed, expired, cancelled }

class ReportDefinition {
  const ReportDefinition({
    required this.reportKey,
    required this.moduleKey,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    this.requiredPermission = Permission.reportsView,
    this.minimumScope = ReportScope.institution,
    this.filters = const ['Date range'],
    this.columns = const [],
    this.supportedFormats = const [
      ReportFormat.pdf,
      ReportFormat.excel,
      ReportFormat.csv,
    ],
    this.sensitivity = ReportSensitivity.normal,
    this.supportsGrouping = false,
    this.supportsAggregation = true,
    this.supportsScheduling = false,
    this.supportsComparison = false,
    this.supportsSnapshot = false,
    this.supportsLiveView = true,
    this.requiresOnline = true,
    this.version = 1,
  });

  final String reportKey,
      moduleKey,
      title,
      description,
      category,
      requiredPermission;
  final IconData icon;
  final ReportScope minimumScope;
  final List<String> filters, columns;
  final List<ReportFormat> supportedFormats;
  final ReportSensitivity sensitivity;
  final bool supportsGrouping,
      supportsAggregation,
      supportsScheduling,
      supportsComparison,
      supportsSnapshot,
      supportsLiveView,
      requiresOnline;
  final int version;
}

/// Contract implemented by source modules. The Reports Center only orchestrates
/// access, filters, output and audit; it never reproduces source calculations.
abstract class InstitutionReportProvider {
  ReportDefinition get definition;
  Future<void> validateFilters(Map<String, dynamic> filters);
  Future<ReportResult> executeReport(Map<String, dynamic> filters);
  Future<Map<String, Object?>> getSummary(Map<String, dynamic> filters);
  Future<ReportResult?> getSnapshot(String snapshotId);
}

class ReportResult {
  const ReportResult({
    required this.headers,
    required this.rows,
    this.summary = const {},
    this.isSnapshot = false,
    required this.generatedAt,
    this.dataVersion,
  });
  final List<String> headers;
  final List<List<Object?>> rows;
  final Map<String, Object?> summary;
  final bool isSnapshot;
  final DateTime generatedAt;
  final String? dataVersion;
}

/// The one catalog used by navigation, search, schedules, and exports.
/// Source modules remain responsible for data calculation and execution.
class ReportRegistry {
  static const definitions = <ReportDefinition>[
    ReportDefinition(
      reportKey: 'students.directory',
      moduleKey: 'students',
      title: 'Student Directory',
      description: 'Enrolled students and their current status.',
      category: 'Students',
      icon: Icons.people_outline,
      filters: ['Campus', 'Division', 'Class', 'Status'],
      columns: ['Student', 'Admission no.', 'Class', 'Status'],
      supportsScheduling: true,
    ),
    ReportDefinition(
      reportKey: 'students.admissions',
      moduleKey: 'students',
      title: 'Admissions',
      description: 'Applications and admissions decisions.',
      category: 'Students',
      icon: Icons.how_to_reg_outlined,
      filters: ['Date range', 'Status', 'Campus'],
      columns: ['Applicant', 'Applied', 'Status'],
    ),
    ReportDefinition(
      reportKey: 'attendance.daily',
      moduleKey: 'attendance',
      title: 'Daily Attendance',
      description: 'Attendance supplied by the Attendance service.',
      category: 'Attendance',
      icon: Icons.fact_check_outlined,
      filters: ['Date range', 'Campus', 'Division', 'Class'],
      columns: ['Date', 'Class', 'Present', 'Absent', 'Rate'],
      supportsScheduling: true,
      supportsComparison: true,
    ),
    ReportDefinition(
      reportKey: 'attendance.absentees',
      moduleKey: 'attendance',
      title: 'Absentees',
      description: 'Students absent in the selected period.',
      category: 'Attendance',
      icon: Icons.person_off_outlined,
      minimumScope: ReportScope.classRoom,
      filters: ['Date range', 'Class', 'Attendance status'],
      columns: ['Student', 'Class', 'Date', 'Status'],
    ),
    ReportDefinition(
      reportKey: 'academics.marks_completion',
      moduleKey: 'assessments',
      title: 'Marks Completion',
      description: 'Assessment-entry progress from the Academic service.',
      category: 'Academics',
      icon: Icons.assignment_turned_in_outlined,
      filters: ['Academic year', 'Academic period', 'Division', 'Subject'],
      columns: ['Subject', 'Class', 'Completed', 'Pending'],
      supportsComparison: true,
    ),
    ReportDefinition(
      reportKey: 'academics.performance',
      moduleKey: 'assessments',
      title: 'Class Performance',
      description: 'Source-defined class performance summary.',
      category: 'Academics',
      icon: Icons.insights_outlined,
      filters: ['Academic year', 'Academic period', 'Class', 'Subject'],
      columns: ['Class', 'Average', 'Pass rate'],
      supportsGrouping: true,
      supportsComparison: true,
    ),
    ReportDefinition(
      reportKey: 'report_cards.published',
      moduleKey: 'reports',
      title: 'Published Reports',
      description: 'Published report cards and release status.',
      category: 'Report Cards',
      icon: Icons.description_outlined,
      filters: ['Academic year', 'Academic period', 'Class', 'Report state'],
      columns: ['Student', 'Class', 'Published at', 'Status'],
      supportsSnapshot: true,
    ),
    ReportDefinition(
      reportKey: 'finance.collections',
      moduleKey: 'finance',
      title: 'Collections',
      description: 'Validated collections summary supplied by Finance.',
      category: 'Finance',
      icon: Icons.account_balance_wallet_outlined,
      filters: ['Date range', 'Campus', 'Payment status'],
      columns: ['Date', 'Method', 'Amount'],
      sensitivity: ReportSensitivity.sensitive,
      supportsScheduling: true,
      supportsComparison: true,
    ),
    ReportDefinition(
      reportKey: 'finance.outstanding',
      moduleKey: 'finance',
      title: 'Outstanding Fees',
      description: 'Validated balances supplied by Finance.',
      category: 'Finance',
      icon: Icons.receipt_long_outlined,
      filters: ['Campus', 'Division', 'Class', 'Payment status'],
      columns: ['Student', 'Class', 'Balance'],
      sensitivity: ReportSensitivity.sensitive,
      supportsScheduling: true,
    ),
    ReportDefinition(
      reportKey: 'staff.directory',
      moduleKey: 'staff',
      title: 'Staff Directory',
      description: 'Staff, roles, and employment status.',
      category: 'Staff',
      icon: Icons.badge_outlined,
      filters: ['Department', 'Campus', 'Employment status'],
      columns: ['Staff member', 'Department', 'Role', 'Status'],
    ),
    ReportDefinition(
      reportKey: 'library.overdue',
      moduleKey: 'library',
      title: 'Overdue Books',
      description: 'Current overdue loans from Library.',
      category: 'Library',
      icon: Icons.local_library_outlined,
      filters: ['Date range', 'Status'],
      columns: ['Borrower', 'Book', 'Due date', 'Days overdue'],
    ),
    ReportDefinition(
      reportKey: 'health.aggregate',
      moduleKey: 'health',
      title: 'Aggregate Health Statistics',
      description: 'Privacy-safe aggregate clinic statistics.',
      category: 'Health',
      icon: Icons.monitor_heart_outlined,
      filters: ['Date range', 'Campus'],
      columns: ['Period', 'Visits', 'Alerts'],
      sensitivity: ReportSensitivity.sensitive,
      supportsScheduling: true,
    ),
    ReportDefinition(
      reportKey: 'security.visitors',
      moduleKey: 'security',
      title: 'Visitor Log',
      description: 'Visitor and gate activity.',
      category: 'Security',
      icon: Icons.security_outlined,
      filters: ['Date range', 'Status'],
      columns: ['Visitor', 'Purpose', 'Check-in', 'Check-out'],
      sensitivity: ReportSensitivity.sensitive,
    ),
    ReportDefinition(
      reportKey: 'system.exports',
      moduleKey: 'structure',
      title: 'Data Exports',
      description: 'Auditable history of generated report exports.',
      category: 'System',
      icon: Icons.history_outlined,
      filters: ['Date range', 'Status', 'Format'],
      columns: ['Report', 'Requested by', 'Format', 'Status'],
      sensitivity: ReportSensitivity.restricted,
    ),
  ];

  static ReportDefinition? byKey(String key) {
    for (final definition in definitions) {
      if (definition.reportKey == key) return definition;
    }
    return null;
  }
}

class ReportAccessDecision {
  const ReportAccessDecision({
    required this.canView,
    this.canExport = false,
    this.canPrint = false,
    this.canSchedule = false,
    this.requiresMfa = false,
    this.reason,
  });
  final bool canView, canExport, canPrint, canSchedule, requiresMfa;
  final String? reason;
}

class ReportAccessResolver {
  const ReportAccessResolver();
  ReportAccessDecision resolve({
    required ReportDefinition report,
    required Set<String> enabledModules,
    required Set<String> permissions,
    required bool mfaEnabled,
  }) {
    if (!enabledModules.contains(report.moduleKey)) {
      return const ReportAccessDecision(
        canView: false,
        reason: 'This institution has not enabled the source module.',
      );
    }
    if (!permissions.contains(Permission.reportsView) &&
        !permissions.contains(report.requiredPermission)) {
      return const ReportAccessDecision(
        canView: false,
        reason: 'You do not have permission to view reports.',
      );
    }
    final sensitive = report.sensitivity != ReportSensitivity.normal;
    if (sensitive && !permissions.contains(Permission.reportsViewSensitive)) {
      return const ReportAccessDecision(
        canView: false,
        reason: 'This is a sensitive report.',
      );
    }
    return ReportAccessDecision(
      canView: true,
      canExport: permissions.contains(Permission.reportsExport),
      canPrint: permissions.contains(Permission.reportsPrint),
      canSchedule:
          report.supportsScheduling &&
          permissions.contains(Permission.reportsSchedule),
      requiresMfa: sensitive && !mfaEnabled,
    );
  }
}

class SavedReport {
  const SavedReport({
    required this.id,
    required this.reportKey,
    required this.name,
    required this.ownerUserId,
    required this.filters,
    required this.createdAt,
  });
  final String id, reportKey, name, ownerUserId;
  final Map<String, dynamic> filters;
  final DateTime createdAt;
  Map<String, dynamic> toJson() => {
    'reportKey': reportKey,
    'name': name,
    'ownerUserId': ownerUserId,
    'filters': filters,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };
}

class ReportExportJob {
  const ReportExportJob({
    required this.id,
    required this.reportKey,
    required this.ownerUserId,
    required this.format,
    required this.status,
    required this.filters,
    required this.createdAt,
  });
  final String id, reportKey, ownerUserId;
  final ReportFormat format;
  final ReportJobStatus status;
  final Map<String, dynamic> filters;
  final DateTime createdAt;
  Map<String, dynamic> toJson() => {
    'reportKey': reportKey,
    'ownerUserId': ownerUserId,
    'format': format.name,
    'status': status.name,
    'filters': filters,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };
}

String reportCsv({
  required List<String> headers,
  required List<List<Object?>> rows,
}) => const ListToCsvConverter().convert([headers, ...rows]);

class ListToCsvConverter {
  const ListToCsvConverter();
  String convert(List<List<Object?>> values) =>
      values.map((row) => row.map(_escape).join(',')).join('\r\n');
  String _escape(Object? value) {
    final raw = value?.toString() ?? '';
    return raw.contains(RegExp('[,"\n\r]'))
        ? '"${raw.replaceAll('"', '""')}"'
        : raw;
  }
}
