import 'package:equatable/equatable.dart';
import '../../domain/entities/school.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/entities/school_application.dart';

enum SuperAdminStatus { initial, loading, success, failure }

class SuperAdminState extends Equatable {
  final SuperAdminStatus status;
  final List<School> schools;
  final List<SchoolApplication> applications;
  final List<SubscriptionPlan> plans;
  final List<AuditLog> auditLogs;
  final Map<String, dynamic> stats;
  final String? errorMessage;
  final String? supportModeSchoolId;
  final String? reviewingApplicationId;
  final String? actionMessage;

  const SuperAdminState({
    this.status = SuperAdminStatus.initial,
    this.schools = const [],
    this.applications = const [],
    this.plans = const [],
    this.auditLogs = const [],
    this.stats = const {},
    this.errorMessage,
    this.supportModeSchoolId,
    this.reviewingApplicationId,
    this.actionMessage,
  });

  @override
  List<Object?> get props => [
    status,
    schools,
    applications,
    plans,
    auditLogs,
    stats,
    errorMessage,
    supportModeSchoolId,
    reviewingApplicationId,
    actionMessage,
  ];

  SuperAdminState copyWith({
    SuperAdminStatus? status,
    List<School>? schools,
    List<SchoolApplication>? applications,
    List<SubscriptionPlan>? plans,
    List<AuditLog>? auditLogs,
    Map<String, dynamic>? stats,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? supportModeSchoolId,
    bool clearSupportModeSchoolId = false,
    String? reviewingApplicationId,
    bool clearReviewingApplicationId = false,
    String? actionMessage,
    bool clearActionMessage = false,
  }) {
    return SuperAdminState(
      status: status ?? this.status,
      schools: schools ?? this.schools,
      applications: applications ?? this.applications,
      plans: plans ?? this.plans,
      auditLogs: auditLogs ?? this.auditLogs,
      stats: stats ?? this.stats,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      supportModeSchoolId: clearSupportModeSchoolId
          ? null
          : (supportModeSchoolId ?? this.supportModeSchoolId),
      reviewingApplicationId: clearReviewingApplicationId
          ? null
          : (reviewingApplicationId ?? this.reviewingApplicationId),
      actionMessage: clearActionMessage
          ? null
          : (actionMessage ?? this.actionMessage),
    );
  }
}
