import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/school_model.dart';
import '../models/subscription_plan_model.dart';
import '../models/audit_log_model.dart';
import '../models/school_application_model.dart';
import '../../domain/repositories/super_admin_repository.dart'
    show SupportModeSession;

abstract class SuperAdminRemoteDataSource {
  Future<List<SchoolModel>> getAllSchools();
  Stream<List<SchoolModel>> watchSchools();
  Future<void> createSchool(
    SchoolModel school,
    String adminEmail,
    String adminPassword,
  );
  Future<void> updateSchool(SchoolModel school);
  Future<List<SchoolApplicationModel>> getSchoolApplications();
  Future<String> approveSchoolApplication(String applicationId);
  Future<void> rejectSchoolApplication(String applicationId, String reason);
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans();
  Future<void> logAction(AuditLogModel log);
  Future<List<AuditLogModel>> getAuditLogs({String? schoolId});
  Future<Map<String, dynamic>> getPlatformStats();

  /// Calls the `enterSupportMode` Cloud Function, which verifies the caller
  /// is the platform owner, audits the request, and mints a short-lived
  /// custom token for that school's admin account.
  Future<SupportModeSession> enterSupportMode({
    required String schoolId,
    required String reason,
  });

  /// Calls `exitSupportMode` while still signed in as the impersonated
  /// admin, tearing down the server-side session doc and logging the exit.
  Future<void> exitSupportMode({required String ownerId, String? schoolId});
}

class SuperAdminRemoteDataSourceImpl implements SuperAdminRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  SuperAdminRemoteDataSourceImpl({required this.firestore, required this.auth});

  // public_functions/ (codebase "publicwebsite") - getSchoolApplicationsForOwner,
  // approveSchoolApplication, rejectSchoolApplication.
  FirebaseFunctions get _ownerFunctions =>
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  // functions/ (codebase "default") - enterSupportMode/exitSupportMode live
  // here, not on the publicwebsite codebase above, so they need the
  // default-region instance or they resolve to a callable that doesn't
  // exist in europe-west1 (surfaces as FirebaseFunctionsException
  // code: not-found).
  FirebaseFunctions get _defaultCodebaseFunctions => FirebaseFunctions.instance;

  @override
  Future<List<AuditLogModel>> getAuditLogs({String? schoolId}) async {
    Query query = firestore
        .collection('super_admin_audit_logs')
        .orderBy('timestamp', descending: true);

    if (schoolId != null) {
      query = query.where('schoolId', isEqualTo: schoolId);
    }

    final snapshot = await query.limit(100).get();
    return snapshot.docs
        .map(
          (doc) => AuditLogModel.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  // NOTE: `getAllSchools`/`watchSchools` are unbounded reads used both by
  // the Schools list AND by dashboard aggregates (total/active school
  // counts, revenue rollups - see super_admin_repository_impl.dart). A
  // `.limit()` here would silently under-count those aggregates once the
  // platform passes the cap, which is worse than an unbounded read at
  // today's low school volume. Real pagination needs a separate paginated
  // query for the list view distinct from whatever computes the counts -
  // out of scope for this pass; flagging here rather than adding a limit
  // that would quietly corrupt dashboard numbers.
  @override
  Future<List<SchoolModel>> getAllSchools() async {
    final snapshot = await firestore.collection('schools').get();
    return snapshot.docs
        .map((doc) => SchoolModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Stream<List<SchoolModel>> watchSchools() {
    return firestore.collection('schools').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SchoolModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  @override
  Future<void> createSchool(
    SchoolModel school,
    String adminEmail,
    String adminPassword,
  ) async {
    // Tenant creation, slug reservation, membership provisioning, and audit
    // logging must be one Admin-SDK transaction. In particular, never write
    // an invitation containing a password from this client path.
    final slug = school.slug.isNotEmpty
        ? school.slug
        : school.tenantId.toLowerCase();
    try {
      await _ownerFunctions.httpsCallable('createSchoolPortal').call({
        'schoolName': school.name,
        'slug': slug,
        'adminEmail': adminEmail,
        'planId': school.subscriptionPlanId,
        'branding': {
          ...school.branding,
          'address': school.address,
          'phone': school.contactPhone,
          'email': school.contactEmail,
        },
      });
    } on FirebaseFunctionsException catch (e) {
      throw StateError(e.message ?? 'Unable to create the school portal.');
    }
  }

  @override
  Future<void> updateSchool(SchoolModel school) async {
    await firestore
        .collection('schools')
        .doc(school.id)
        .update(school.toJson());
  }

  @override
  Future<List<SchoolApplicationModel>> getSchoolApplications() async {
    try {
      final callable = _ownerFunctions.httpsCallable(
        'getSchoolApplicationsForOwner',
      );
      final result = await callable.call<Map<String, dynamic>>();
      final raw = result.data['applications'];
      if (raw is! List) return const [];

      return raw.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        final id = (map['id'] ?? map['authUid'] ?? '').toString();
        return SchoolApplicationModel.fromFirestore(id, map);
      }).toList();
    } on FirebaseFunctionsException catch (e) {
      throw StateError(
        e.message ?? 'Unable to load school registration applications.',
      );
    }
  }

  @override
  Future<String> approveSchoolApplication(String applicationId) async {
    try {
      final callable = _ownerFunctions.httpsCallable(
        'approveSchoolApplication',
      );
      final result = await callable.call<Map<String, dynamic>>({
        'applicationId': applicationId,
      });
      final schoolId = result.data['schoolId']?.toString();
      if (schoolId == null || schoolId.isEmpty) {
        throw StateError('Approval completed without a school ID.');
      }
      return schoolId;
    } on FirebaseFunctionsException catch (e) {
      throw StateError(
        e.message ?? 'Unable to approve this school application.',
      );
    }
  }

  @override
  Future<void> rejectSchoolApplication(
    String applicationId,
    String reason,
  ) async {
    try {
      final callable = _ownerFunctions.httpsCallable('rejectSchoolApplication');
      await callable.call<Map<String, dynamic>>({
        'applicationId': applicationId,
        'reason': reason,
      });
    } on FirebaseFunctionsException catch (e) {
      throw StateError(
        e.message ?? 'Unable to reject this school application.',
      );
    }
  }

  @override
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans() async {
    final snapshot = await firestore.collection('subscription_plans').get();
    return snapshot.docs
        .map((doc) => SubscriptionPlanModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> logAction(AuditLogModel log) async {
    await firestore.collection('super_admin_audit_logs').add(log.toJson());
  }

  @override
  Future<Map<String, dynamic>> getPlatformStats() async {
    final schools = await firestore.collection('schools').get();
    final applications = await getSchoolApplications();

    int totalStudents = 0;
    int totalStaff = 0;
    for (final doc in schools.docs) {
      final schoolData = doc.data();
      final metadata = schoolData['metadata'] is Map
          ? Map<String, dynamic>.from(schoolData['metadata'] as Map)
          : const <String, dynamic>{};
      totalStudents +=
          ((schoolData['studentCount'] ?? metadata['studentCount'] ?? 0) as num)
              .toInt();
      totalStaff +=
          ((schoolData['staffCount'] ?? metadata['staffCount'] ?? 0) as num)
              .toInt();
    }

    return {
      'totalSchools': schools.size,
      'activeSchools': schools.docs
          .where((d) => d.data()['status'] == 'active')
          .length,
      'totalStudents': totalStudents,
      'totalStaff': totalStaff,
      'pendingApplications': applications
          .where((application) => application.status.name == 'pendingReview')
          .length,
    };
  }

  @override
  Future<SupportModeSession> enterSupportMode({
    required String schoolId,
    required String reason,
  }) async {
    final callable = _defaultCodebaseFunctions.httpsCallable(
      'enterSupportMode',
    );
    final result = await callable.call<Map<String, dynamic>>({
      'schoolId': schoolId,
      'reason': reason,
    });
    final data = result.data;
    return SupportModeSession(
      token: data['token'] as String,
      adminUid: data['adminUid'] as String,
      adminName: data['adminName'] as String? ?? 'School Admin',
      schoolName: data['schoolName'] as String? ?? '',
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        (data['expiresAt'] as num).toInt(),
      ),
    );
  }

  @override
  Future<void> exitSupportMode({
    required String ownerId,
    String? schoolId,
  }) async {
    final callable = _defaultCodebaseFunctions.httpsCallable('exitSupportMode');
    await callable.call<Map<String, dynamic>>({
      'ownerId': ownerId,
      if (schoolId != null) 'schoolId': schoolId,
    });
  }
}
