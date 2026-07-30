import 'package:equatable/equatable.dart';

enum SchoolStatus { active, suspended, trial, archived }

class School extends Equatable {
  final String id;
  final String name;
  final String tenantId;
  final String address;
  final String contactEmail;
  final String contactPhone;
  final SchoolStatus status;
  final String subscriptionPlanId;
  final DateTime createdAt;
  final DateTime subscriptionExpiry;
  final List<String> enabledFeatures;
  final Map<String, dynamic> metadata;

  const School({
    required this.id,
    required this.name,
    required this.tenantId,
    required this.address,
    required this.contactEmail,
    required this.contactPhone,
    this.status = SchoolStatus.trial,
    required this.subscriptionPlanId,
    required this.createdAt,
    required this.subscriptionExpiry,
    this.enabledFeatures = const [],
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        name,
        tenantId,
        address,
        contactEmail,
        contactPhone,
        status,
        subscriptionPlanId,
        createdAt,
        subscriptionExpiry,
        enabledFeatures,
        metadata,
      ];

  School copyWith({
    String? name,
    String? address,
    String? contactEmail,
    String? contactPhone,
    SchoolStatus? status,
    String? subscriptionPlanId,
    DateTime? subscriptionExpiry,
    List<String>? enabledFeatures,
    Map<String, dynamic>? metadata,
  }) {
    return School(
      id: id,
      name: name ?? this.name,
      tenantId: tenantId,
      address: address ?? this.address,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      status: status ?? this.status,
      subscriptionPlanId: subscriptionPlanId ?? this.subscriptionPlanId,
      createdAt: createdAt,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      enabledFeatures: enabledFeatures ?? this.enabledFeatures,
      metadata: metadata ?? this.metadata,
    );
  }
}
