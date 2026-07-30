import 'package:equatable/equatable.dart';
import '../../domain/entities/school.dart';

abstract class SuperAdminEvent extends Equatable {
  const SuperAdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadSuperAdminDashboard extends SuperAdminEvent {}

class CreateSchoolEvent extends SuperAdminEvent {
  final School school;
  final String adminEmail;
  final String adminPassword;

  const CreateSchoolEvent({
    required this.school,
    required this.adminEmail,
    required this.adminPassword,
  });

  @override
  List<Object?> get props => [school, adminEmail, adminPassword];
}

class UpdateSchoolStatusEvent extends SuperAdminEvent {
  final String schoolId;
  final SchoolStatus status;
  final String? reason;

  const UpdateSchoolStatusEvent({
    required this.schoolId,
    required this.status,
    this.reason,
  });

  @override
  List<Object?> get props => [schoolId, status, reason];
}

class UpdateSubscriptionEvent extends SuperAdminEvent {
  final String schoolId;
  final String planId;
  final DateTime expiry;

  const UpdateSubscriptionEvent({
    required this.schoolId,
    required this.planId,
    required this.expiry,
  });

  @override
  List<Object?> get props => [schoolId, planId, expiry];
}

class LoadAuditLogsEvent extends SuperAdminEvent {
  final String? schoolId;
  const LoadAuditLogsEvent({this.schoolId});

  @override
  List<Object?> get props => [schoolId];
}

class EnterSupportModeEvent extends SuperAdminEvent {
  final String schoolId;
  final String reason;
  const EnterSupportModeEvent({required this.schoolId, required this.reason});

  @override
  List<Object?> get props => [schoolId, reason];
}

class ExitSupportModeEvent extends SuperAdminEvent {}

class ToggleFeatureEvent extends SuperAdminEvent {
  final String schoolId;
  final String feature;
  final bool enabled;

  const ToggleFeatureEvent({
    required this.schoolId,
    required this.feature,
    required this.enabled,
  });

  @override
  List<Object?> get props => [schoolId, feature, enabled];
}

class LoadInvoicesEvent extends SuperAdminEvent {
  final String? schoolId;
  const LoadInvoicesEvent({this.schoolId});

  @override
  List<Object?> get props => [schoolId];
}

class InitiatePaymentEvent extends SuperAdminEvent {
  final String schoolId;
  final double amount;
  final String email;
  final String phoneNumber;
  final String planId;

  const InitiatePaymentEvent({
    required this.schoolId,
    required this.amount,
    required this.email,
    required this.phoneNumber,
    required this.planId,
  });

  @override
  List<Object?> get props => [schoolId, amount, email, phoneNumber, planId];
}
