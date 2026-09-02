import '../../domain/entities/school.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/entities/school_application.dart';
import '../../domain/repositories/super_admin_repository.dart';
import '../datasources/super_admin_remote_datasource.dart';
import '../models/school_model.dart';
import '../models/audit_log_model.dart';

class SuperAdminRepositoryImpl implements SuperAdminRepository {
  final SuperAdminRemoteDataSource remoteDataSource;

  SuperAdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<School>> getAllSchools() async {
    return await remoteDataSource.getAllSchools();
  }

  @override
  Stream<List<School>> watchSchools() {
    return remoteDataSource.watchSchools();
  }

  @override
  Future<void> createSchool(
    School school,
    String adminEmail,
    String adminPassword,
  ) async {
    final model = SchoolModel(
      id: school.id,
      name: school.name,
      tenantId: school.tenantId,
      address: school.address,
      contactEmail: school.contactEmail,
      contactPhone: school.contactPhone,
      status: school.status,
      subscriptionPlanId: school.subscriptionPlanId,
      createdAt: school.createdAt,
      subscriptionExpiry: school.subscriptionExpiry,
      enabledFeatures: school.enabledFeatures,
      metadata: school.metadata,
      classification: school.classification,
      classificationOther: school.classificationOther,
      divisions: school.divisions,
      displayLabel: school.displayLabel,
    );
    await remoteDataSource.createSchool(model, adminEmail, adminPassword);
  }

  @override
  Future<void> updateSchool(School school) async {
    final model = SchoolModel(
      id: school.id,
      name: school.name,
      tenantId: school.tenantId,
      address: school.address,
      contactEmail: school.contactEmail,
      contactPhone: school.contactPhone,
      status: school.status,
      subscriptionPlanId: school.subscriptionPlanId,
      createdAt: school.createdAt,
      subscriptionExpiry: school.subscriptionExpiry,
      enabledFeatures: school.enabledFeatures,
      metadata: school.metadata,
      classification: school.classification,
      classificationOther: school.classificationOther,
      divisions: school.divisions,
      displayLabel: school.displayLabel,
    );
    await remoteDataSource.updateSchool(model);
  }

  @override
  Future<List<SchoolApplication>> getSchoolApplications() async {
    return remoteDataSource.getSchoolApplications();
  }

  @override
  Future<String> approveSchoolApplication(String applicationId) {
    return remoteDataSource.approveSchoolApplication(applicationId);
  }

  @override
  Future<void> rejectSchoolApplication(String applicationId, String reason) {
    return remoteDataSource.rejectSchoolApplication(applicationId, reason);
  }

  @override
  Future<void> suspendSchool(String schoolId, String reason) async {
    await remoteDataSource.setSchoolLifecycleStatus(
      schoolId: schoolId,
      status: 'suspended',
      reason: reason,
    );
  }

  @override
  Future<void> archiveSchool(String schoolId, String reason) async {
    await remoteDataSource.setSchoolLifecycleStatus(
      schoolId: schoolId,
      status: 'archived',
      reason: reason,
    );
  }

  @override
  Future<void> activateSchool(String schoolId) async {
    await remoteDataSource.setSchoolLifecycleStatus(
      schoolId: schoolId,
      status: 'active',
    );
  }

  @override
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    return await remoteDataSource.getSubscriptionPlans();
  }

  @override
  Future<void> updateSchoolSubscription(
    String schoolId,
    String planId,
    DateTime expiry,
  ) async {
    await remoteDataSource.updateSchoolSubscriptionPlan(
      schoolId: schoolId,
      planId: planId,
      expiry: expiry,
    );
  }

  @override
  Future<Map<String, dynamic>> getPlatformStats() async {
    return await remoteDataSource.getPlatformStats();
  }

  @override
  Future<List<AuditLog>> getAuditLogs({String? schoolId}) async {
    return await remoteDataSource.getAuditLogs(schoolId: schoolId);
  }

  @override
  Future<void> logAction(AuditLog log) async {
    final model = AuditLogModel(
      id: log.id,
      ownerId: log.ownerId,
      action: log.action,
      schoolId: log.schoolId,
      affectedUserId: log.affectedUserId,
      timestamp: log.timestamp,
      device: log.device,
      reason: log.reason,
      metadata: log.metadata,
    );
    await remoteDataSource.logAction(model);
  }

  @override
  Future<SupportModeSession> enterSupportMode({
    required String schoolId,
    required String reason,
  }) {
    return remoteDataSource.enterSupportMode(
      schoolId: schoolId,
      reason: reason,
    );
  }

  @override
  Future<void> exitSupportMode({required String ownerId, String? schoolId}) {
    return remoteDataSource.exitSupportMode(
      ownerId: ownerId,
      schoolId: schoolId,
    );
  }
}
