import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:school_pulse/features/super_admin/data/models/audit_log_model.dart';
import 'package:school_pulse/features/super_admin/domain/entities/audit_log.dart';

import '../domain/platform_health_models.dart';

const kPlatformHealthIncidentActions = [
  'PLATFORM_HEALTH_INCIDENT_ACKNOWLEDGED',
  'PLATFORM_HEALTH_INCIDENT_RESOLVED',
];

/// Follows InstitutionHealthRepository's shape: a live Firestore stream of
/// the cached aggregate for the Home card/screen, plus callables for the
/// on-demand refresh and incident acknowledgement actions.
class PlatformHealthRepository {
  PlatformHealthRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  DocumentReference<Map<String, dynamic>> get _current =>
      _firestore.collection('platform_health').doc('current');

  /// Null when no aggregation has ever run yet - callers must render a
  /// neutral "checking..." state, never a false-positive healthy default.
  Stream<PlatformHealthSummary?> watchCurrent() => _current.snapshots().map(
    (snap) => snap.exists && snap.data() != null
        ? PlatformHealthSummary.fromMap(snap.data()!)
        : null,
  );

  Future<PlatformHealthSummary> refresh() async {
    final result = await _functions
        .httpsCallable('checkPlatformHealth')
        .call<Map<String, dynamic>>();
    return PlatformHealthSummary.fromMap(
      Map<String, dynamic>.from(result.data as Map),
    );
  }

  Future<void> acknowledgeIncident(String component, {String? note}) async {
    await _functions
        .httpsCallable('acknowledgePlatformHealthIncident')
        .call<Map<String, dynamic>>({
          'component': component,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        });
  }

  /// Compact incident timeline: super_admin_audit_logs entries for
  /// acknowledged/resolved Platform Health incidents only - never every
  /// automatic poll, since checkPlatformHealth deliberately writes no
  /// audit log for a routine refresh.
  Stream<List<AuditLog>> watchIncidentHistory({int limit = 20}) => _firestore
      .collection('super_admin_audit_logs')
      .where('action', whereIn: kPlatformHealthIncidentActions)
      .orderBy('timestamp', descending: true)
      .limit(limit)
      .snapshots()
      .map(
        (snap) => [
          for (final doc in snap.docs)
            AuditLogModel.fromJson({...doc.data(), 'id': doc.id}),
        ],
      );
}
