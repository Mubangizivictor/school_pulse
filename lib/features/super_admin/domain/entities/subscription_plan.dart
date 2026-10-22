import 'package:equatable/equatable.dart';

enum BillingCycle { monthly, termly, yearly }

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final BillingCycle billingCycle;
  final int termLengthDays;
  final int trialDays;
  final bool customPricing;
  final int maxStudents;
  final int maxStaff;
  final double storageLimitGb;
  final int smsLimitPerMonth;
  final List<String> includedFeatures;

  /// Module keys this plan's marketing description includes (subset of
  /// [kPlanModuleKeys]). Stored and validated server-side, but does not
  /// currently drive [School.enabledFeatures] gating - see the plan
  /// management build notes for why that wiring is out of scope.
  final List<String> includedModules;
  final bool isDefault;
  final bool isPublic;
  final bool isActive;

  /// True once archived via archiveSubscriptionPlan. Always implies
  /// [isActive] is false; only archiveSubscriptionPlan/
  /// reactivateSubscriptionPlan may change it.
  final bool isArchived;
  final bool isPopular;
  final int displayOrder;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.billingCycle,
    this.termLengthDays = 120,
    this.trialDays = 0,
    this.customPricing = false,
    required this.maxStudents,
    required this.maxStaff,
    required this.storageLimitGb,
    this.smsLimitPerMonth = 0,
    required this.includedFeatures,
    this.includedModules = const [],
    this.isDefault = false,
    this.isPublic = true,
    this.isActive = true,
    this.isArchived = false,
    this.isPopular = false,
    this.displayOrder = 0,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    billingCycle,
    termLengthDays,
    trialDays,
    customPricing,
    maxStudents,
    maxStaff,
    storageLimitGb,
    smsLimitPerMonth,
    includedFeatures,
    includedModules,
    isDefault,
    isPublic,
    isActive,
    isArchived,
    isPopular,
    displayOrder,
  ];
}

/// The 8 module keys selectable as "included modules" on a plan, a subset of
/// the canonical keys in ModuleRegistry.all.
const List<String> kPlanModuleKeys = [
  'attendance',
  'reports',
  'finance',
  'messaging',
  'health',
  'transport',
  'library',
  'boarding',
];
