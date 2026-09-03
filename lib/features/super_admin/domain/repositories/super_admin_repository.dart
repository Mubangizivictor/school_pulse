import 'package:equatable/equatable.dart';

import '../entities/school.dart';
import '../entities/subscription_plan.dart';
import '../entities/audit_log.dart';
import '../entities/school_application.dart';
import 'package:school_pulse/features/billing/domain/entities/subscription_cycle.dart';

abstract class SuperAdminRepository {
  // School Management
  Future<List<School>> getAllSchools();
  Stream<List<School>> watchSchools();
  Future<void> createSchool(
    School school,
    String adminEmail,
    String adminPassword,
  );
  Future<void> updateSchool(School school);
  Future<void> suspendSchool(String schoolId, String reason);
  Future<void> activateSchool(String schoolId);
  Future<void> archiveSchool(String schoolId, String reason);

  // Public website onboarding / owner review
  Future<List<SchoolApplication>> getSchoolApplications();
  Future<String> approveSchoolApplication(String applicationId);
  Future<void> rejectSchoolApplication(String applicationId, String reason);

  // Subscription Management
  Future<List<SubscriptionPlan>> getSubscriptionPlans();
  Future<void> updateSchoolSubscription(
    String schoolId,
    String planId,
    DateTime expiry,
  );

  // Analytics
  Future<Map<String, dynamic>> getPlatformStats();

  // Audit Logs
  Future<List<AuditLog>> getAuditLogs({String? schoolId});
  Future<void> logAction(AuditLog log);

  // Owner Support Mode
  Future<SupportModeSession> enterSupportMode({
    required String schoolId,
    required String reason,
  });
  Future<void> exitSupportMode({required String ownerId, String? schoolId});

  /// School-scoped admin users (role == schoolAdmin) for the School Admins
  /// panel on School Details. Queries the flat `users` collection - there is
  /// no dedicated school-admins subcollection.
  Future<List<SchoolAdminSummary>> getSchoolAdmins(String schoolId);

  // Term-based billing (Phase 2B, read-only)

  /// All `subscription_cycles` docs for one school, oldest term first. Used
  /// by the School Details "Term cycle history" section.
  Future<List<SubscriptionCycle>> getSubscriptionCyclesForSchool(
    String schoolId,
  );

  /// Cross-school "upcoming renewals" feed for the Billing home screen -
  /// non-terminal cycles only, capped at 50, oldest term first. See
  /// SubscriptionCycleRemoteDataSource for why 50.
  Future<List<SubscriptionCycle>> getAllUpcomingSubscriptionCycles();
}

/// Compact projection of a school admin user for the Super Admin console.
/// Deliberately excludes anything beyond what School Details needs to show -
/// this is not a general user profile.
class SchoolAdminSummary extends Equatable {
  final String uid;
  final String name;
  final String email;
  final bool isPrimary;
  final bool mfaEnabled;
  final DateTime? lastSignInAt;

  const SchoolAdminSummary({
    required this.uid,
    required this.name,
    required this.email,
    this.isPrimary = false,
    this.mfaEnabled = false,
    this.lastSignInAt,
  });

  @override
  List<Object?> get props => [
    uid,
    name,
    email,
    isPrimary,
    mfaEnabled,
    lastSignInAt,
  ];
}

class SupportModeSession {
  final String token;
  final String adminUid;
  final String adminName;
  final String schoolName;
  final DateTime expiresAt;

  const SupportModeSession({
    required this.token,
    required this.adminUid,
    required this.adminName,
    required this.schoolName,
    required this.expiresAt,
  });
}
