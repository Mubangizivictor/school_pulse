import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the Firestore-side `HealthStatus` union written by
/// functions/platform_health.js. A missing/unrecognized value maps to
/// [unknown], never silently to [operational] - the UI must never claim a
/// service is healthy when the server didn't actually say so.
enum PlatformHealthStatus {
  operational,
  degraded,
  outage,
  unknown,
  notConfigured,
}

PlatformHealthStatus platformHealthStatusFromValue(String? value) =>
    switch (value) {
      'operational' => PlatformHealthStatus.operational,
      'degraded' => PlatformHealthStatus.degraded,
      'outage' => PlatformHealthStatus.outage,
      'not_configured' => PlatformHealthStatus.notConfigured,
      _ => PlatformHealthStatus.unknown,
    };

DateTime? _dateOf(dynamic value) => switch (value) {
  Timestamp timestamp => timestamp.toDate(),
  DateTime date => date,
  _ => null,
};

/// Fixed display order/labels for the 9 monitored components (10th,
/// platformRelease, is intentionally excluded from the on-screen component
/// list per the spec - it only ever reports "not_configured" today and
/// would be pure noise; its data still round-trips through [fromMap] so
/// nothing is silently dropped from the underlying Firestore doc).
const List<(String id, String label)> kPlatformHealthComponentOrder = [
  ('auth', 'Authentication'),
  ('firestore', 'Firestore'),
  ('functions', 'Cloud Functions'),
  ('storage', 'Cloud Storage'),
  ('notifications', 'Notifications'),
  ('scheduledJobs', 'Scheduled jobs'),
  ('schoolOnboarding', 'School onboarding'),
  ('subscriptionProcessing', 'Subscription processing'),
  ('securityMonitoring', 'Security monitoring'),
];

class PlatformHealthComponent {
  const PlatformHealthComponent({
    required this.id,
    required this.status,
    required this.message,
    required this.checkedAt,
  });

  final String id;
  final PlatformHealthStatus status;
  final String message;
  final DateTime? checkedAt;

  factory PlatformHealthComponent.fromMap(
    String id,
    Map<String, dynamic> data,
  ) => PlatformHealthComponent(
    id: id,
    status: platformHealthStatusFromValue(data['status'] as String?),
    message: data['message'] as String? ?? '',
    checkedAt: _dateOf(data['checkedAt']),
  );
}

/// Server-written aggregate read from `platform_health/current`. A missing
/// document (no aggregation has ever run) is represented by the repository
/// returning `null`, not by fabricating an operational-looking default -
/// see PlatformHealthRepository.watchCurrent.
class PlatformHealthSummary {
  const PlatformHealthSummary({
    required this.status,
    required this.summary,
    required this.checkedAt,
    required this.components,
  });

  final PlatformHealthStatus status;
  final String summary;
  final DateTime? checkedAt;
  final List<PlatformHealthComponent> components;

  List<PlatformHealthComponent> get attentionComponents => components
      .where(
        (c) =>
            c.status != PlatformHealthStatus.operational &&
            c.status != PlatformHealthStatus.notConfigured,
      )
      .toList();

  factory PlatformHealthSummary.fromMap(Map<String, dynamic> data) {
    final rawComponents = Map<String, dynamic>.from(
      data['components'] as Map? ?? const {},
    );
    final components = [
      for (final (id, _) in kPlatformHealthComponentOrder)
        if (rawComponents[id] is Map)
          PlatformHealthComponent.fromMap(
            id,
            Map<String, dynamic>.from(rawComponents[id] as Map),
          ),
    ];
    return PlatformHealthSummary(
      status: platformHealthStatusFromValue(data['status'] as String?),
      summary: data['summary'] as String? ?? '',
      checkedAt: _dateOf(data['checkedAt']),
      components: components,
    );
  }
}

String platformHealthComponentLabel(String id) => kPlatformHealthComponentOrder
    .firstWhere((entry) => entry.$1 == id, orElse: () => (id, id))
    .$2;

/// Short, safe, static recommended-next-action strings per component - no
/// network call, no tenant data, just a lookup table.
String? platformHealthRecommendedAction(
  String componentId,
) => switch (componentId) {
  'auth' => 'Check Firebase Authentication status in the console.',
  'firestore' => 'Check Firestore status in the Firebase console.',
  'functions' => 'Check Cloud Functions logs for recent errors.',
  'storage' => 'Verify the default Cloud Storage bucket is configured.',
  'notifications' =>
    'Check Cloud Functions logs for the notification dispatch/escalation jobs.',
  'scheduledJobs' =>
    'Check Cloud Functions logs for the affected scheduled job.',
  'schoolOnboarding' => 'Check failed onboarding jobs.',
  'subscriptionProcessing' =>
    'Check failed payment/subscription processing jobs.',
  'securityMonitoring' =>
    'Review recent high-risk security events across schools.',
  _ => null,
};
