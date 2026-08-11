import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

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
    this.resolvedAt,
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
  final DateTime? resolvedAt;
  final String? pushStatus;
  final String? emailStatus;
  final String? inAppStatus;

  bool get isUnread => status == 'unread';
  bool get isRead => status == 'read';
  bool get isResolved => status == 'resolved' || resolvedAt != null;
  bool get isPayment => paymentId.isNotEmpty || type.contains('payment');
  bool get isApplication =>
      applicationId.isNotEmpty || type.contains('application');

  /// Tri-state display label derived from [status]/[resolvedAt]. Any status
  /// that isn't explicitly 'unread' or 'resolved' (including older documents
  /// with unexpected values) is treated as read rather than resolved, since
  /// "resolved" is a stronger claim that requires explicit evidence.
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

    String defaultTitle() {
      if (paymentId.isNotEmpty || type.contains('payment')) {
        return 'Payment verification required';
      }
      if (applicationId.isNotEmpty || type.contains('application')) {
        return 'New school application';
      }
      return 'School Pulse notification';
    }

    return OwnerNotification(
      id: json['id']?.toString() ?? '',
      type: type,
      status: json['status']?.toString() ?? 'unread',
      title: json['title']?.toString() ?? defaultTitle(),
      body: json['body']?.toString() ?? '',
      paymentId: paymentId,
      applicationId: applicationId,
      schoolId: (json['schoolId'] ?? data['schoolId'])?.toString() ?? '',
      schoolName: schoolName,
      amountUgx: amount,
      method: (json['method'] ?? data['method'])?.toString() ?? '',
      createdAt: date(json['createdAt']),
      resolvedAt: nullableDate(json['resolvedAt']),
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
    resolvedAt,
    pushStatus,
    emailStatus,
    inAppStatus,
  ];
}
