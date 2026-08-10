import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school.dart';

/// Single source of truth for the currently active institution tenant.
/// Loaded once after authentication and consumed by routing and feature
/// blocs - individual modules must not build their own tenant context.
class InstitutionContext extends Equatable {
  final String institutionId;
  final String displayLabel;
  final InstitutionClassification classification;
  final List<InstitutionDivision> divisions;
  final SchoolStatus status;
  final List<String> enabledFeatures;
  final DateTime loadedAt;
  final bool isOfflineCached;

  /// Subscription access is tenant-level state. It lives here so every role
  /// sees the same activation/renewal gate instead of each feature inventing
  /// its own billing check.
  final DateTime? subscriptionExpiry;
  final String subscriptionStatus;
  final bool hasEverActivated;

  const InstitutionContext({
    required this.institutionId,
    required this.displayLabel,
    required this.classification,
    required this.divisions,
    required this.status,
    required this.enabledFeatures,
    required this.loadedAt,
    this.isOfflineCached = false,
    this.subscriptionExpiry,
    this.subscriptionStatus = 'active',
    this.hasEverActivated = true,
  });

  factory InstitutionContext.fromSchool(
    School school, {
    bool isOfflineCached = false,
  }) {
    final metadata = school.metadata;
    final hasExplicitActivationFlag = metadata.containsKey('hasEverActivated');
    final source = metadata['source']?.toString() ?? '';

    return InstitutionContext(
      institutionId: school.id,
      displayLabel: school.displayLabel ?? school.name,
      classification: school.classification,
      divisions: school.divisions,
      status: school.status,
      enabledFeatures: school.enabledFeatures,
      loadedAt: DateTime.now(),
      isOfflineCached: isOfflineCached,
      subscriptionExpiry: school.subscriptionExpiry,
      subscriptionStatus:
          metadata['subscriptionStatus']?.toString() ??
          (school.status == SchoolStatus.trial ? 'awaiting_payment' : 'active'),
      // Older non-public tenants pre-date manual billing and must not become
      // locked merely because they have no new metadata field. Public-site
      // tenants are treated as unpaid until the manual lifecycle writes the
      // explicit activation flag.
      hasEverActivated: hasExplicitActivationFlag
          ? metadata['hasEverActivated'] == true
          : source != 'public_website_application',
    );
  }

  bool get isSuspended =>
      status == SchoolStatus.suspended || status == SchoolStatus.archived;

  bool get requiresMfa => enabledFeatures.contains('mfa_required');

  bool get isPaymentUnderReview => subscriptionStatus == 'payment_review';

  /// First subscription payment: the school has been accepted/provisioned,
  /// but no paid subscription has ever been verified. The dashboard must be
  /// completely inaccessible until the SaaS Owner approves the payment.
  bool get isInitialPaymentRequired {
    if (hasEverActivated) return false;
    return subscriptionStatus == 'awaiting_payment' ||
        subscriptionStatus == 'payment_review' ||
        subscriptionStatus == 'payment_due' ||
        subscriptionStatus == 'rejected' ||
        status == SchoolStatus.trial;
  }

  /// Renewal: after at least one successful activation the dashboard may stay
  /// visible, but all interaction is blocked once the paid period has ended
  /// (or while a renewal proof is waiting for verification).
  bool get isRenewalLocked {
    if (!hasEverActivated || isSuspended) return false;
    final expired = subscriptionExpiry != null &&
        !subscriptionExpiry!.isAfter(DateTime.now());
    return expired ||
        subscriptionStatus == 'payment_due' ||
        subscriptionStatus == 'payment_review';
  }

  @override
  List<Object?> get props => [
    institutionId,
    displayLabel,
    classification,
    divisions,
    status,
    enabledFeatures,
    loadedAt,
    isOfflineCached,
    subscriptionExpiry,
    subscriptionStatus,
    hasEverActivated,
  ];
}
