import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// A single device/session record for a SaaS owner account, backed by
/// `super_admin_settings/{ownerId}/sessions/{deviceId}`. Nested under the
/// existing owner-settings doc (rather than a new top-level collection) to
/// follow the same `super_admin_settings/{ownerId}` ownership convention
/// already used for notification/security preferences on this doc.
class OwnerSession extends Equatable {
  final String deviceId;
  final String platform;
  final String deviceName;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;
  final bool trusted;

  const OwnerSession({
    required this.deviceId,
    required this.platform,
    required this.deviceName,
    required this.createdAt,
    required this.lastActiveAt,
    required this.trusted,
  });

  factory OwnerSession.fromMap(String deviceId, Map<String, dynamic> map) {
    DateTime? toDate(dynamic value) =>
        value is Timestamp ? value.toDate() : null;
    return OwnerSession(
      deviceId: deviceId,
      platform: map['platform'] as String? ?? 'Unknown',
      deviceName: map['deviceName'] as String? ?? 'Unknown device',
      createdAt: toDate(map['createdAt']),
      lastActiveAt: toDate(map['lastActiveAt']),
      trusted: map['trusted'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
    deviceId,
    platform,
    deviceName,
    createdAt,
    lastActiveAt,
    trusted,
  ];
}
