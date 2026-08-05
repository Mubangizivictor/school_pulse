import '../../domain/entities/school.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/audit_log.dart';
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
    );
    await remoteDataSource.updateSchool(model);
  }

  @override
  Future<void> suspendSchool(String schoolId, String reason) async {
    final schools = await remoteDataSource.getAllSchools();
    final school = schools.firstWhere((s) => s.id == schoolId);
    await remoteDataSource.updateSchool(
      SchoolModel(
        id: school.id,
        name: school.name,
        tenantId: school.tenantId,
        address: school.address,
        contactEmail: school.contactEmail,
        contactPhone: school.contactPhone,
        status: SchoolStatus.suspended,
        subscriptionPlanId: school.subscriptionPlanId,
        createdAt: school.createdAt,
        subscriptionExpiry: school.subscriptionExpiry,
        enabledFeatures: school.enabledFeatures,
        metadata: {...school.metadata, 'suspensionReason': reason},
      ),
    );
  }

  @override
  Future<void> activateSchool(String schoolId) async {
    final schools = await remoteDataSource.getAllSchools();
    final school = schools.firstWhere((s) => s.id == schoolId);
    await remoteDataSource.updateSchool(
      SchoolModel(
        id: school.id,
        name: school.name,
        tenantId: school.tenantId,
        address: school.address,
        contactEmail: school.contactEmail,
        contactPhone: school.contactPhone,
        status: SchoolStatus.active,
        subscriptionPlanId: school.subscriptionPlanId,
        createdAt: school.createdAt,
        subscriptionExpiry: school.subscriptionExpiry,
        enabledFeatures: school.enabledFeatures,
        metadata: school.metadata,
      ),
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
    final schools = await remoteDataSource.getAllSchools();
    final school = schools.firstWhere((s) => s.id == schoolId);
    await remoteDataSource.updateSchool(
      SchoolModel(
        id: school.id,
        name: school.name,
        tenantId: school.tenantId,
        address: school.address,
        contactEmail: school.contactEmail,
        contactPhone: school.contactPhone,
        status: school.status,
        subscriptionPlanId: planId,
        createdAt: school.createdAt,
        subscriptionExpiry: expiry,
        enabledFeatures: school.enabledFeatures,
        metadata: school.metadata,
      ),
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
}
