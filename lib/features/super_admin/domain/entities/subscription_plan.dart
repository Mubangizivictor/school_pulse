import 'package:equatable/equatable.dart';

enum BillingCycle { monthly, termly, yearly }

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final BillingCycle billingCycle;
  final int termLengthDays;
  final bool customPricing;
  final int maxStudents;
  final int maxStaff;
  final double storageLimitGb;
  final List<String> includedFeatures;
  final bool isDefault;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.billingCycle,
    this.termLengthDays = 120,
    this.customPricing = false,
    required this.maxStudents,
    required this.maxStaff,
    required this.storageLimitGb,
    required this.includedFeatures,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    billingCycle,
    termLengthDays,
    customPricing,
    maxStudents,
    maxStaff,
    storageLimitGb,
    includedFeatures,
    isDefault,
  ];
}
