import '../entities/school.dart';
import '../entities/subscription_plan.dart';
import '../entities/audit_log.dart';

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
