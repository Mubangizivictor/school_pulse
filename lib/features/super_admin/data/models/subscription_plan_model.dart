import '../../domain/entities/subscription_plan.dart';

class SubscriptionPlanModel extends SubscriptionPlan {
  const SubscriptionPlanModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.billingCycle,
    super.termLengthDays,
    super.trialDays,
    super.customPricing,
    required super.maxStudents,
    required super.maxStaff,
    required super.storageLimitGb,
    super.smsLimitPerMonth,
    required super.includedFeatures,
    super.includedModules,
    super.isDefault,
    super.isPublic,
    super.isActive,
    super.isArchived,
    super.isPopular,
    super.displayOrder,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.toString().split('.').last == json['billingCycle'],
        orElse: () => BillingCycle.termly,
      ),
      termLengthDays: (json['termLengthDays'] ?? 120) as int,
      trialDays: (json['trialDays'] ?? 0) as int,
      customPricing: json['customPricing'] == true,
      maxStudents: json['maxStudents'] ?? 0,
      maxStaff: json['maxStaff'] ?? 0,
      storageLimitGb: (json['storageLimitGb'] ?? 0).toDouble(),
      smsLimitPerMonth: (json['smsLimitPerMonth'] ?? 0) as int,
      includedFeatures: List<String>.from(json['includedFeatures'] ?? []),
      includedModules: List<String>.from(json['includedModules'] ?? []),
      isDefault: json['isDefault'] ?? false,
      isPublic: json['isPublic'] ?? true,
      isActive: json['isActive'] ?? true,
      isArchived: json['isArchived'] == true,
      isPopular: json['isPopular'] ?? false,
      displayOrder: (json['displayOrder'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'billingCycle': billingCycle.toString().split('.').last,
      'termLengthDays': termLengthDays,
      'trialDays': trialDays,
      'customPricing': customPricing,
      'maxStudents': maxStudents,
      'maxStaff': maxStaff,
      'storageLimitGb': storageLimitGb,
      'smsLimitPerMonth': smsLimitPerMonth,
      'includedFeatures': includedFeatures,
      'includedModules': includedModules,
      'isDefault': isDefault,
      'isPublic': isPublic,
      'isActive': isActive,
      'isArchived': isArchived,
      'isPopular': isPopular,
      'displayOrder': displayOrder,
    };
  }
}
