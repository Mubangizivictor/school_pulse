import '../../domain/entities/subscription_plan.dart';

class SubscriptionPlanModel extends SubscriptionPlan {
  const SubscriptionPlanModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.billingCycle,
    required super.maxStudents,
    required super.maxStaff,
    required super.storageLimitGb,
    required super.includedFeatures,
    super.isDefault,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.toString().split('.').last == json['billingCycle'],
        orElse: () => BillingCycle.yearly,
      ),
      maxStudents: json['maxStudents'] ?? 0,
      maxStaff: json['maxStaff'] ?? 0,
      storageLimitGb: (json['storageLimitGb'] ?? 0).toDouble(),
      includedFeatures: List<String>.from(json['includedFeatures'] ?? []),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'billingCycle': billingCycle.toString().split('.').last,
      'maxStudents': maxStudents,
      'maxStaff': maxStaff,
      'storageLimitGb': storageLimitGb,
      'includedFeatures': includedFeatures,
      'isDefault': isDefault,
    };
  }
}
