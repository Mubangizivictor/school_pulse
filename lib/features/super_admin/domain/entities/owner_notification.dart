import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'owner_notification_taxonomy.dart';

/// Durable platform notification surfaced to the SaaS Owner.
/// Supports school applications, manual payments and platform alerts.
class OwnerNotification extends Equatable {
  const OwnerNotification({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.body,
    required this.paymentId,
    required this.applicationId,
    required this.schoolId,
    required this.schoolName,
    required this.amountUgx,
    required this.method,
    required this.createdAt,
    required this.category,
    required this.severity,
    this.reference = '',
    this.resolvedAt,
    this.openedAt,
    this.platformHealthDegraded = false,
    this.pushStatus,
    this.emailStatus,
    this.inAppStatus,
  });

  final String id;
  final String type;
  final String status;
  final String title;
  final String body;
  final String paymentId;
  final String applicationId;
  final String schoolId;
  final String schoolName;
  final int amountUgx;
  final String method;
  final DateTime createdAt;

  /// Owner grouping — drives the tonal icon and the filter chips.
  final OwnerNotificationCategory category;

  /// Severity/status chip. Always shown on the detail screen; only shown on
  /// a tile for [OwnerNotificationSeverity.showsOnTile].
  final OwnerNotificationSeverity severity;

  /// A short, already-masked reference for the detail card (e.g.
  /// `MOMO •••• 4821`). Never a full PAN / raw payment reference.
  final String reference;

  final DateTime? resolvedAt;

  /// When the owner first opened this notification's detail — drives the
  /// "Opened by you · 1:33 PM" audit strip. Server-stamped.
  final DateTime? openedAt;

  /// True only when a `platform` notification represents a degraded / outage
  /// state (red pulse). A healthy / operational platform notification is
  /// false (green pulse).
  final bool platformHealthDegraded;

  final String? pushStatus;
  final String? emailStatus;
  final String? inAppStatus;

  bool get isUnread => status == 'unread';
  bool get isRead => status == 'read';
  bool get isResolved => status == 'resolved' || resolvedAt != null;
  bool get isPayment =>
      category == OwnerNotificationCategory.billing ||
      paymentId.isNotEmpty ||
      type.contains('payment');
  bool get isApplication =>
      category == OwnerNotificationCategory.schools ||
      applicationId.isNotEmpty ||
      type.contains('application');

  /// Tri-state display label derived from [status]/[resolvedAt].
  String get displayStatus {
    if (isResolved) return 'RESOLVED';
    if (isUnread) return 'NEW';
    return 'READ';
  }

  factory OwnerNotification.fromJson(Map<String, dynamic> json) {
    DateTime date(Object? value) {
      if (value is Timestamp) return value.toDate();
      return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
    }

    DateTime? nullableDate(Object? value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      return DateTime.tryParse(value.toString());
    }

    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : const <String, dynamic>{};
    final delivery = json['delivery'] is Map
        ? Map<String, dynamic>.from(json['delivery'] as Map)
        : const <String, dynamic>{};
    final push = delivery['push'] is Map
        ? Map<String, dynamic>.from(delivery['push'] as Map)
        : const <String, dynamic>{};
    final email = delivery['email'] is Map
        ? Map<String, dynamic>.from(delivery['email'] as Map)
        : const <String, dynamic>{};
    final inApp = delivery['inApp'] is Map
        ? Map<String, dynamic>.from(delivery['inApp'] as Map)
        : const <String, dynamic>{};

    /// Maps a raw delivery status (which may carry a technical error code
    /// alongside 'sent'/'failed') to a friendly owner-facing value. Raw
    /// messaging/SMTP diagnostics are never shown in the UI.
    String? friendlyStatus(Map<String, dynamic> channel) {
      final raw = channel['status']?.toString();
      if (raw == null || raw.isEmpty) return null;
      if (raw == 'sent' || raw == 'delivered') return 'delivered';
      if (raw == 'failed') return 'delivery issue';
      return raw;
    }

    final type = json['type']?.toString() ?? 'platform_event';
    final paymentId =
        (json['paymentId'] ?? data['paymentId'])?.toString() ?? '';
    final applicationId =
        (json['applicationId'] ?? data['applicationId'])?.toString() ?? '';
    final schoolName =
        (json['schoolName'] ?? data['schoolName'])?.toString() ??
        'School Pulse';
    final amountRaw = json['amountUgx'] ?? data['amountUgx'] ?? data['amount'];
    final amount = amountRaw is num
        ? amountRaw.round()
        : int.tryParse(amountRaw?.toString() ?? '') ?? 0;

    final status = json['status']?.toString() ?? 'unread';
    final resolvedAt = nullableDate(json['resolvedAt']);

    // --- Category: explicit `category` wins; else derive from shape ------
    OwnerNotificationCategory category;
    if (json['category'] != null) {
      category = OwnerNotificationCategory.fromWire(json['category'].toString());
    } else if (paymentId.isNotEmpty) {
      // Explicit foreign keys are stronger signals than the free-text type,
      // whose default value ('platform_event') would otherwise mis-bucket.
      category = OwnerNotificationCategory.billing;
    } else if (applicationId.isNotEmpty) {
      category = OwnerNotificationCategory.schools;
    } else if (type.contains('payment') || type.contains('billing')) {
      category = OwnerNotificationCategory.billing;
    } else if (type.contains('incident') ||
        type.contains('health') ||
        type == 'platform_health' ||
        type.contains('platform_health')) {
      category = OwnerNotificationCategory.platform;
    } else if (type.contains('application') ||
        type.contains('domain') ||
        type.contains('school') ||
        type.contains('onboarding')) {
      category = OwnerNotificationCategory.schools;
    } else if (type.contains('security') || type.contains('sign_in')) {
      category = OwnerNotificationCategory.security;
    } else if (type.contains('digest')) {
      category = OwnerNotificationCategory.digest;
    } else {
      category = OwnerNotificationCategory.digest;
    }

    final degraded = (json['platformHealthDegraded'] ??
                data['platformHealthDegraded'] ??
                (json['healthState']?.toString() == 'degraded') ??
                false) ==
            true ||
        json['healthState']?.toString() == 'degraded' ||
        json['healthState']?.toString() == 'outage';

    // --- Severity: explicit `severity` wins; else derive ----------------
    OwnerNotificationSeverity severity;
    if (json['severity'] != null) {
      severity =
          OwnerNotificationSeverity.fromWire(json['severity'].toString());
    } else if (status == 'resolved' || resolvedAt != null) {
      severity = OwnerNotificationSeverity.resolved;
    } else if (category == OwnerNotificationCategory.billing &&
        (paymentId.isNotEmpty || type.contains('pending'))) {
      severity = OwnerNotificationSeverity.requiresReview;
    } else if (category == OwnerNotificationCategory.platform && degraded) {
      severity = OwnerNotificationSeverity.critical;
    } else if (category == OwnerNotificationCategory.security &&
        type.contains('alert')) {
      severity = OwnerNotificationSeverity.critical;
    } else if (category == OwnerNotificationCategory.schools &&
        !type.contains('approved') &&
        !type.contains('rejected') &&
        !type.contains('resolved') &&
        (applicationId.isNotEmpty ||
            type.contains('request') ||
            type.contains('pending') ||
            type.contains('new_application'))) {
      severity = OwnerNotificationSeverity.requiresReview;
    } else {
      severity = OwnerNotificationSeverity.information;
    }

    String defaultTitle() {
      switch (category) {
        case OwnerNotificationCategory.billing:
          return 'Payment awaiting review';
        case OwnerNotificationCategory.platform:
          return degraded
              ? 'Platform health needs attention'
              : 'Platform health update';
        case OwnerNotificationCategory.schools:
          return 'New school request';
        case OwnerNotificationCategory.security:
          return 'Security alert';
        case OwnerNotificationCategory.digest:
          return 'Owner digest ready';
      }
    }

    return OwnerNotification(
      id: json['id']?.toString() ?? '',
      type: type,
      status: status,
      title: json['title']?.toString() ?? defaultTitle(),
      body: json['body']?.toString() ?? '',
      paymentId: paymentId,
      applicationId: applicationId,
      schoolId: (json['schoolId'] ?? data['schoolId'])?.toString() ?? '',
      schoolName: schoolName,
      amountUgx: amount,
      method: (json['method'] ?? data['method'])?.toString() ?? '',
      createdAt: date(json['createdAt']),
      category: category,
      severity: severity,
      reference:
          (json['reference'] ?? data['reference'] ?? data['maskedReference'])
              ?.toString() ??
          '',
      resolvedAt: resolvedAt,
      openedAt: nullableDate(json['openedAt']),
      platformHealthDegraded: degraded,
      pushStatus: friendlyStatus(push),
      emailStatus: friendlyStatus(email),
      inAppStatus: friendlyStatus(inApp),
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    status,
    title,
    body,
    paymentId,
    applicationId,
    schoolId,
    schoolName,
    amountUgx,
    method,
    createdAt,
    category,
    severity,
    reference,
    resolvedAt,
    openedAt,
    platformHealthDegraded,
    pushStatus,
    emailStatus,
    inAppStatus,
  ];
}
