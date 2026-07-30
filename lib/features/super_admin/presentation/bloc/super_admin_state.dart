import 'package:equatable/equatable.dart';
import '../../domain/entities/school.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/audit_log.dart';

enum SuperAdminStatus { initial, loading, success, failure }

class SuperAdminState extends Equatable {
  final SuperAdminStatus status;
  final List<School> schools;
  final List<SubscriptionPlan> plans;
  final List<Invoice> invoices;
  final List<Transaction> transactions;
  final List<AuditLog> auditLogs;
  final Map<String, dynamic> stats;
  final String? errorMessage;
  final String? supportModeSchoolId;

  const SuperAdminState({
    this.status = SuperAdminStatus.initial,
    this.schools = const [],
    this.plans = const [],
    this.invoices = const [],
    this.transactions = const [],
    this.auditLogs = const [],
    this.stats = const {},
    this.errorMessage,
    this.supportModeSchoolId,
  });

  @override
  List<Object?> get props => [
        status,
        schools,
        plans,
        invoices,
        transactions,
        auditLogs,
        stats,
        errorMessage,
        supportModeSchoolId,
      ];

  SuperAdminState copyWith({
    SuperAdminStatus? status,
    List<School>? schools,
    List<SubscriptionPlan>? plans,
    List<Invoice>? invoices,
    List<Transaction>? transactions,
    List<AuditLog>? auditLogs,
    Map<String, dynamic>? stats,
    String? errorMessage,
    String? supportModeSchoolId,
  }) {
    return SuperAdminState(
      status: status ?? this.status,
      schools: schools ?? this.schools,
      plans: plans ?? this.plans,
      invoices: invoices ?? this.invoices,
      transactions: transactions ?? this.transactions,
      auditLogs: auditLogs ?? this.auditLogs,
      stats: stats ?? this.stats,
      errorMessage: errorMessage,
      supportModeSchoolId: supportModeSchoolId ?? this.supportModeSchoolId,
    );
  }
}
