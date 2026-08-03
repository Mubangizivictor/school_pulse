import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/school_model.dart';
import '../models/subscription_plan_model.dart';
import '../models/audit_log_model.dart';

abstract class SuperAdminRemoteDataSource {
  Future<List<SchoolModel>> getAllSchools();
  Stream<List<SchoolModel>> watchSchools();
  Future<void> createSchool(SchoolModel school, String adminEmail, String adminPassword);
  Future<void> updateSchool(SchoolModel school);
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans();
  Future<void> logAction(AuditLogModel log);
  Future<List<AuditLogModel>> getAuditLogs({String? schoolId});
  Future<Map<String, dynamic>> getPlatformStats();
}

class SuperAdminRemoteDataSourceImpl implements SuperAdminRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  SuperAdminRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  @override
  Future<List<AuditLogModel>> getAuditLogs({String? schoolId}) async {
    Query query = firestore.collection('super_admin_audit_logs').orderBy('timestamp', descending: true);
    
    if (schoolId != null) {
      query = query.where('schoolId', isEqualTo: schoolId);
    }

    final snapshot = await query.limit(100).get();
    return snapshot.docs.map((doc) => AuditLogModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<SchoolModel>> getAllSchools() async {
    final snapshot = await firestore.collection('schools').get();
    return snapshot.docs.map((doc) => SchoolModel.fromJson(doc.data())).toList();
  }

  @override
  Stream<List<SchoolModel>> watchSchools() {
    return firestore.collection('schools').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SchoolModel.fromJson(doc.data())).toList();
    });
  }

  @override
  Future<void> createSchool(SchoolModel school, String adminEmail, String adminPassword) async {
    // schools/{id} is the sole institution tenant source of truth as of
    // Phase 1 (classification/divisions/displayLabel live on this doc). The
    // legacy tenants/{tenantId} doc is deprecated in place - no new writes
    // go there; existing docs are left untouched, not migrated.
    await firestore.collection('schools').doc(school.id).set(school.toJson());

    // Note: Creating the Admin user usually happens via a Cloud Function
    // to avoid logging out the Super Admin from the current app session.
    // For this implementation, we assume a Cloud Function will handle
    // the actual Firebase Auth user creation and assigning the 'schoolAdmin' role
    // when a new 'school_admin_invitation' document is created.

    await firestore.collection('school_admin_invitations').add({
      'email': adminEmail,
      'schoolId': school.id,
      'tenantId': school.tenantId,
      'tempPassword': adminPassword,
      'role': 'schoolAdmin',
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  @override
  Future<void> updateSchool(SchoolModel school) async {
    await firestore.collection('schools').doc(school.id).update(school.toJson());
  }

  @override
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans() async {
    final snapshot = await firestore.collection('subscription_plans').get();
    return snapshot.docs.map((doc) => SubscriptionPlanModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> logAction(AuditLogModel log) async {
    await firestore.collection('super_admin_audit_logs').add(log.toJson());
  }

  @override
  Future<Map<String, dynamic>> getPlatformStats() async {
    final schools = await firestore.collection('schools').get();
    
    // In a real app, these would be aggregated or retrieved from a summary document
    // For now, we calculate them from the schools collection
    int totalStudents = 0;
    int totalStaff = 0;
    
    // This is a bit expensive for a real production app without aggregation
    for (var doc in schools.docs) {
      final schoolData = doc.data();
      totalStudents += (schoolData['studentCount'] ?? 0) as int;
      totalStaff += (schoolData['staffCount'] ?? 0) as int;
    }

    return {
      'totalSchools': schools.size,
      'activeSchools': schools.docs.where((d) => d.data()['status'] == 'active').length,
      'totalStudents': totalStudents,
      'totalStaff': totalStaff,
    };
  }
}
