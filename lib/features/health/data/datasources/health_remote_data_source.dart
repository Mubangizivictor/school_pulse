import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/clinic_visit_model.dart';
import '../models/emergency_incident_model.dart';
import '../models/medical_inventory_model.dart';
import '../models/medical_supply_request_model.dart';
import '../models/student_health_profile_model.dart';

abstract class HealthRemoteDataSource {
  Future<StudentHealthProfileModel> getStudentHealthProfile(
    String studentId,
    String schoolId,
  );
  Future<void> updateStudentHealthProfile(
    StudentHealthProfileModel profile,
    String schoolId,
  );
  Future<List<StudentHealthProfileModel>> getAllHealthProfiles(String schoolId);

  Future<List<ClinicVisitModel>> getClinicVisits({
    required String schoolId,
    String? studentId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> recordClinicVisit(ClinicVisitModel visit);

  /// Pushes [visit] only if no document with its id exists yet - used by
  /// the offline sync sweep, where the initial [recordClinicVisit] attempt
  /// may have already partially or fully succeeded before the app lost
  /// connection or was killed. Guards against re-sending parent/teacher
  /// alerts for a visit that was already recorded.
  Future<void> pushClinicVisitIfAbsent(ClinicVisitModel visit);

  /// Dispenses [quantity] of [itemId] against [visitId] for [studentId]
  /// through the server-authoritative `dispenseMedicalItem` callable, which
  /// decrements stock atomically, refuses to go negative, verifies the visit
  /// belongs to the learner and both records are in the caller's school,
  /// writes a stock-movement row, and appends a health-audit event. The
  /// client never touches `medical_inventory` for a dispense.
  Future<void> dispenseMedicalItem({
    required String itemId,
    required String visitId,
    required String studentId,
    required int quantity,
  });

  Future<List<EmergencyIncidentModel>> getEmergencyIncidents({
    required String schoolId,
    String? studentId,
  });
  Future<void> recordEmergencyIncident(EmergencyIncidentModel incident);

  Future<List<MedicalInventoryItemModel>> getMedicalInventory(String schoolId);
  Future<void> updateInventoryItem(MedicalInventoryItemModel item);

  Future<List<MedicalSupplyRequestModel>> getMedicalSupplyRequests(
    String schoolId,
  );
  Future<void> createSupplyRequest(MedicalSupplyRequestModel request);
  Future<void> updateSupplyRequestStatus(
    String requestId,
    String schoolId,
    String status, {
    String? reviewNotes,
    String? rejectionReason,
  });
}

class HealthRemoteDataSourceImpl implements HealthRemoteDataSource {
  final FirebaseFirestore firestore;

  /// Clinic mutations (`createClinicVisit`, `dispenseMedicalItem`) are
  /// deployed to the default region, which is what `FirebaseFunctions.instance`
  /// targets - the same endpoint on web and every mobile platform.
  final FirebaseFunctions functions;

  HealthRemoteDataSourceImpl({
    required this.firestore,
    FirebaseFunctions? functions,
  }) : functions = functions ?? FirebaseFunctions.instance;

  String _requireSchoolId(String? schoolId) {
    final value = schoolId?.trim() ?? '';
    if (value.isEmpty) {
      throw StateError(
        'This account is not assigned to a school. Contact the school administrator.',
      );
    }
    return value;
  }

  String _profileDocumentId(String schoolId, String studentId) =>
      base64Url.encode(utf8.encode('$schoolId:$studentId')).replaceAll('=', '');

  Future<Set<String>> _healthRecipients(
    String schoolId,
    String studentId, {
    bool includeTeacher = false,
    bool includeLeadership = false,
  }) async {
    final recipients = <String>{};
    final student = await firestore.collection('students').doc(studentId).get();
    final className =
        student.data()?['classId'] ?? student.data()?['className'];
    final users = await firestore
        .collection('users')
        .where('schoolId', isEqualTo: schoolId)
        .get();
    for (final user in users.docs) {
      final data = user.data();
      final role = data['role'] as String? ?? '';
      final roles = <String>{
        role,
        ...List<String>.from(data['roles'] as List? ?? const []),
      };
      final studentIds = List<String>.from(
        data['studentIds'] as List? ?? const [],
      );
      if (role == 'parent' && studentIds.contains(studentId)) {
        recipients.add(user.id);
      }
      if (includeTeacher &&
          roles.contains('classTeacher') &&
          data['assignedClass'] == className) {
        recipients.add(user.id);
      }
      if (includeLeadership &&
          roles.intersection({
            'schoolAdmin',
            'headTeacher',
            'deputyHead',
            'director',
          }).isNotEmpty) {
        recipients.add(user.id);
      }
    }

    // A guardian may have an access code before their first app login has
    // created users/parent_CODE. Addressing the deterministic parent UID
    // keeps the alert waiting for them when they do sign in.
    final codes = await firestore
        .collection('parent_access_codes')
        .where('schoolId', isEqualTo: schoolId)
        .get();
    for (final code in codes.docs) {
      final studentIds = List<String>.from(
        code.data()['studentIds'] as List? ?? const [],
      );
      if (studentIds.contains(studentId)) {
        final parentCode = code.data()['parentCode'] ?? code.data()['code'];
        if (parentCode is String && parentCode.isNotEmpty) {
          recipients.add('parent_$parentCode');
        }
      }
    }
    return recipients;
  }

  @override
  Future<StudentHealthProfileModel> getStudentHealthProfile(
    String studentId,
    String schoolId,
  ) async {
    final tenant = _requireSchoolId(schoolId);
    final doc = await firestore
        .collection('health_profiles')
        .doc(_profileDocumentId(tenant, studentId))
        .get();
    if (doc.exists) {
      return StudentHealthProfileModel.fromJson({
        ...doc.data()!,
        'studentId': studentId,
        'schoolId': tenant,
      });
    }
    return StudentHealthProfileModel(
      studentId: studentId,
      schoolId: tenant,
      bloodGroup: 'Unknown',
      emergencyContactName: '',
      emergencyContactPhone: '',
    );
  }

  @override
  Future<void> updateStudentHealthProfile(
    StudentHealthProfileModel profile,
    String schoolId,
  ) async {
    final tenant = _requireSchoolId(schoolId);
    await firestore
        .collection('health_profiles')
        .doc(_profileDocumentId(tenant, profile.studentId))
        .set({
          ...profile.toJson(),
          'schoolId': tenant,
        }, SetOptions(merge: true));
  }

  @override
  Future<List<StudentHealthProfileModel>> getAllHealthProfiles(
    String schoolId,
  ) async {
    final tenant = _requireSchoolId(schoolId);
    final snapshot = await firestore
        .collection('health_profiles')
        .where('schoolId', isEqualTo: tenant)
        .get();
    return snapshot.docs
        .map(
          (doc) => StudentHealthProfileModel.fromJson({
            ...doc.data(),
            'schoolId': tenant,
          }),
        )
        .toList();
  }

  @override
  Future<List<ClinicVisitModel>> getClinicVisits({
    required String schoolId,
    String? studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final tenant = _requireSchoolId(schoolId);
    Query<Map<String, dynamic>> query = firestore
        .collection('clinic_visits')
        .where('schoolId', isEqualTo: tenant);
    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }
    final snapshot = await query.get();
    final visits =
        snapshot.docs
            .map(
              (doc) => ClinicVisitModel.fromJson({...doc.data(), 'id': doc.id}),
            )
            .where((visit) {
              if (startDate != null && visit.dateTime.isBefore(startDate)) {
                return false;
              }
              if (endDate != null && visit.dateTime.isAfter(endDate)) {
                return false;
              }
              return true;
            })
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return visits;
  }

  /// Sends the visit to `createClinicVisit` (server stamps `recordedBy`,
  /// `status`, `completedAt`; idempotent on the visit id; writes a
  /// health-audit row) and returns the id the server used. The client never
  /// writes `clinic_visits` directly - firestore.rules make create
  /// callable-only.
  Future<String> _callCreateClinicVisit(
    ClinicVisitModel visit,
    String tenant,
  ) async {
    final payload = {...visit.toJson(), 'schoolId': tenant};
    // toJson() emits Firestore Timestamps for dateTime; the callable takes
    // JSON, so hand it an ISO-8601 string instead.
    payload['dateTime'] = visit.dateTime.toUtc().toIso8601String();
    final res = await functions
        .httpsCallable('createClinicVisit')
        .call<Map<String, dynamic>>({'visit': payload});
    final id = (res.data['id'] as String?)?.trim();
    if (id == null || id.isEmpty) {
      throw StateError('The clinic visit could not be recorded.');
    }
    return id;
  }

  Future<void> _writeVisitAlerts(
    String tenant,
    ClinicVisitModel visit,
    String recordId,
  ) async {
    // The visit record itself is written by the callable. Alerts carry no
    // clinical content ("an update is available in the authorised portal"),
    // so they stay a client-side batch, addressed only to the learner's
    // guardians - never teachers.
    final recipients = await _healthRecipients(tenant, visit.studentId);
    if (recipients.isEmpty) return;
    final batch = firestore.batch();
    for (final recipient in recipients) {
      final alert = firestore.collection('alerts').doc();
      batch.set(alert, {
        'userId': recipient,
        'senderId': visit.recordedBy,
        'schoolId': tenant,
        'studentId': visit.studentId,
        'title': 'School clinic visit',
        'body': 'A school clinic update is available in the authorised portal.',
        'type': 'clinic_visit',
        'recordId': recordId,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
    await batch.commit();
  }

  @override
  Future<void> recordClinicVisit(ClinicVisitModel visit) async {
    final tenant = _requireSchoolId(visit.schoolId);
    final id = await _callCreateClinicVisit(visit, tenant);
    await _writeVisitAlerts(tenant, visit, id);
  }

  @override
  Future<void> pushClinicVisitIfAbsent(ClinicVisitModel visit) async {
    final tenant = _requireSchoolId(visit.schoolId);
    // createClinicVisit is idempotent on the visit id, so the offline sweep
    // can safely re-send without a client-side existence check. Alerts are
    // only written if the guardian set is non-empty and are keyed on the
    // visit id, so a duplicate sweep just overwrites identical alert docs.
    final id = await _callCreateClinicVisit(visit, tenant);
    await _writeVisitAlerts(tenant, visit, id);
  }

  @override
  Future<void> dispenseMedicalItem({
    required String itemId,
    required String visitId,
    required String studentId,
    required int quantity,
  }) async {
    await functions.httpsCallable('dispenseMedicalItem').call<dynamic>({
      'itemId': itemId,
      'visitId': visitId,
      'studentId': studentId,
      'quantity': quantity,
    });
  }

  @override
  Future<List<EmergencyIncidentModel>> getEmergencyIncidents({
    required String schoolId,
    String? studentId,
  }) async {
    final tenant = _requireSchoolId(schoolId);
    Query<Map<String, dynamic>> query = firestore
        .collection('emergency_incidents')
        .where('schoolId', isEqualTo: tenant);
    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }
    final snapshot = await query.get();
    final incidents =
        snapshot.docs
            .map(
              (doc) => EmergencyIncidentModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }),
            )
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return incidents;
  }

  @override
  Future<void> recordEmergencyIncident(EmergencyIncidentModel incident) async {
    final tenant = _requireSchoolId(incident.schoolId);
    final collection = firestore.collection('emergency_incidents');
    final doc = incident.id.isEmpty
        ? collection.doc()
        : collection.doc(incident.id);
    final recipients = await _healthRecipients(
      tenant,
      incident.studentId,
      includeLeadership: true,
    );
    await _writeRecordAndAlerts(
      record: doc,
      recordData: {
        ...incident.toJson(),
        'id': doc.id,
        'schoolId': tenant,
        'parentNotified':
            incident.parentNotified ||
            recipients.any((recipient) => recipient.startsWith('parent_')),
      },
      recipients: recipients,
      schoolId: tenant,
      studentId: incident.studentId,
      senderId: incident.recordedBy,
      title: 'Emergency health incident',
      body: 'An urgent school clinic update requires authorised review.',
      type: 'emergency_incident',
      recordId: doc.id,
    );
  }

  @override
  Future<List<MedicalInventoryItemModel>> getMedicalInventory(
    String schoolId,
  ) async {
    final tenant = _requireSchoolId(schoolId);
    final snapshot = await firestore
        .collection('medical_inventory')
        .where('schoolId', isEqualTo: tenant)
        .get();
    final items =
        snapshot.docs
            .map(
              (doc) => MedicalInventoryItemModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }),
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  @override
  Future<void> updateInventoryItem(MedicalInventoryItemModel item) async {
    final tenant = _requireSchoolId(item.schoolId);
    final collection = firestore.collection('medical_inventory');
    final doc = item.id.isEmpty ? collection.doc() : collection.doc(item.id);
    await doc.set({
      ...item.toJson(),
      'id': doc.id,
      'schoolId': tenant,
    }, SetOptions(merge: true));
  }

  @override
  Future<List<MedicalSupplyRequestModel>> getMedicalSupplyRequests(
    String schoolId,
  ) async {
    final tenant = _requireSchoolId(schoolId);
    final snapshot = await firestore
        .collection('medical_supply_requests')
        .where('schoolId', isEqualTo: tenant)
        .get();
    final requests =
        snapshot.docs
            .map(
              (doc) => MedicalSupplyRequestModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }),
            )
            .toList()
          ..sort((a, b) => b.requestDate.compareTo(a.requestDate));
    return requests;
  }

  @override
  Future<void> createSupplyRequest(MedicalSupplyRequestModel request) async {
    final tenant = _requireSchoolId(request.schoolId);
    final collection = firestore.collection('medical_supply_requests');
    final doc = request.id.isEmpty
        ? collection.doc()
        : collection.doc(request.id);
    final staff = await firestore
        .collection('users')
        .where('schoolId', isEqualTo: tenant)
        .get();
    final recipientRoles = {
      'storeInventory',
      'bursar',
      'schoolAdmin',
      'headTeacher',
    };
    final batch = firestore.batch()
      ..set(doc, {...request.toJson(), 'id': doc.id, 'schoolId': tenant});
    for (final member in staff.docs) {
      final data = member.data();
      final roles = <String>{
        if (data['role'] is String) data['role'] as String,
        ...List<String>.from(data['roles'] as List? ?? const []),
      };
      if (roles.intersection(recipientRoles).isEmpty) continue;
      final alert = firestore.collection('alerts').doc();
      batch.set(alert, {
        'userId': member.id,
        'schoolId': tenant,
        'title': 'Medical supply request',
        'body': '${request.quantity} ${request.unit} of ${request.itemName}',
        'type': 'medical_supply_request',
        'requestId': doc.id,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
    await batch.commit();
  }

  Future<void> _writeRecordAndAlerts({
    required DocumentReference<Map<String, dynamic>> record,
    required Map<String, dynamic> recordData,
    required Set<String> recipients,
    required String schoolId,
    required String studentId,
    required String senderId,
    required String title,
    required String body,
    required String type,
    required String recordId,
  }) async {
    final batch = firestore.batch()..set(record, recordData);
    for (final recipient in recipients) {
      final alert = firestore.collection('alerts').doc();
      batch.set(alert, {
        'userId': recipient,
        'senderId': senderId,
        'schoolId': schoolId,
        'studentId': studentId,
        'title': title,
        'body': body,
        'type': type,
        'recordId': recordId,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
    await batch.commit();
  }

  @override
  Future<void> updateSupplyRequestStatus(
    String requestId,
    String schoolId,
    String status, {
    String? reviewNotes,
    String? rejectionReason,
  }) async {
    final tenant = _requireSchoolId(schoolId);
    final ref = firestore.collection('medical_supply_requests').doc(requestId);
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists || snapshot.data()?['schoolId'] != tenant) {
        throw StateError('Supply request not found for this school.');
      }
      transaction.update(ref, {
        'status': status,
        'bursaReviewNotes': reviewNotes,
        'rejectionReason': rejectionReason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final requestedBy = snapshot.data()?['requestedBy'] as String?;
      if (requestedBy != null && requestedBy.isNotEmpty) {
        final alert = firestore.collection('alerts').doc();
        transaction.set(alert, {
          'userId': requestedBy,
          'schoolId': tenant,
          'title': 'Medical supply request updated',
          'body': 'Your request is now ${status.split('.').last}.',
          'type': 'medical_supply_request',
          'requestId': requestId,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    });
  }
}
