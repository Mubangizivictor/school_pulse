import '../entities/school.dart';
import '../entities/subscription_plan.dart';
import '../entities/audit_log.dart';
import '../entities/school_application.dart';

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
}
