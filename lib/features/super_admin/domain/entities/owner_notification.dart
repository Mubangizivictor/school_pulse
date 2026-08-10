import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// A platform-level notification surfaced to the SaaS owner, currently
/// emitted only when a school submits a manual subscription payment for
/// verification. Written server-side to `super_admin_notifications` by the
/// payment Cloud Functions; the owner console only ever reads this
/// collection (see [OwnerNotification.fromJson]).
class OwnerNotification extends Equatable {
  const OwnerNotification({
    required this.id,
    required this.type,
    required this.status,
    required this.paymentId,
    required this.schoolId,
    required this.schoolName,
    required this.amountUgx,
    required this.method,
    required this.createdAt,
    this.resolvedAt,
  });

  final String id;
  final String type;

  /// 'unread' or 'resolved'.
  final String status;
  final String paymentId;
  final String schoolId;
  final String schoolName;
  final int amountUgx;

  /// 'mtn' or 'bank'.
  final String method;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  bool get isUnread => status == 'unread';

  factory OwnerNotification.fromJson(Map<String, dynamic> json) {
    // Read directly from Firestore (see OwnerNotificationService), so
    // createdAt/resolvedAt arrive as Timestamp objects rather than ISO
    // strings - unlike ManualSubscriptionPayment, which comes through a
    // Cloud Function's JSON response.
    DateTime date(Object? value) {
      if (value is Timestamp) return value.toDate();
      return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
    }

    DateTime? nullableDate(Object? value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      return DateTime.tryParse(value.toString());
    }

    return OwnerNotification(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'manual_payment_submitted',
      status: json['status']?.toString() ?? 'unread',
      paymentId: json['paymentId']?.toString() ?? '',
      schoolId: json['schoolId']?.toString() ?? '',
      schoolName: json['schoolName']?.toString() ?? 'Unknown school',
      amountUgx: (json['amountUgx'] as num?)?.round() ?? 0,
      method: json['method']?.toString() ?? 'mtn',
      createdAt: date(json['createdAt']),
      resolvedAt: nullableDate(json['resolvedAt']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    status,
    paymentId,
    schoolId,
    schoolName,
    amountUgx,
    method,
    createdAt,
    resolvedAt,
  ];
}
