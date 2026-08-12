import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/institution/domain/entities/access_mode.dart';
import 'package:school_pulse/features/institution/domain/entities/institution_context.dart';
import 'package:school_pulse/features/institution/domain/services/subscription_date_math.dart'
    as date_math;

/// What [SubscriptionAccessGate] should render for the current user.
enum AccessGateKind {
  /// Nothing to gate - full read/write access.
  none,

  /// School has never completed its first payment; dashboard fully blocked.
  initialPaymentRequired,

  /// Subscription lapsed; School Admin gets the rich read-only view with a
  /// renewal call-to-action (they're the one who can act on it).
  renewalReadOnly,

  /// Subscription lapsed; every other role gets a simple blocked screen with
  /// no renewal CTA (they can't act on it, just need to know who can).
  renewalBlocked,
}

enum CapacityStatus { withinLimit, nearLimit, atOrOverLimit, unknown }

/// The single place subscription-derived access decisions are computed.
///
/// Wraps [InstitutionContext] (already the tenant's source of truth for
/// subscription state) plus the caller's role, and exposes the small set of
/// booleans/values every screen actually needs instead of each screen
/// re-deriving expiry/access logic from raw dates. Pure, synchronous, no
/// BuildContext dependency - trivially unit-testable.
class SubscriptionAccessResolver {
  const SubscriptionAccessResolver._({
    required this.institution,
    required this.role,
  });

  factory SubscriptionAccessResolver.of(
    InstitutionContext institution, {
    required UserRole role,
  }) {
    return SubscriptionAccessResolver._(institution: institution, role: role);
  }

  final InstitutionContext institution;
  final UserRole role;

  bool get _isSchoolAdmin => role == UserRole.schoolAdmin;

  AccessMode get accessMode => institution.resolvedAccessMode;

  bool get canRead => accessMode != AccessMode.blocked;

  bool get canWrite => accessMode == AccessMode.full;

  /// School Admin must always be able to reach the payment/renewal screen,
  /// even while every other write is locked - otherwise a read-only school
  /// could never pay its way back to full access.
  bool get canManageBilling => _isSchoolAdmin;

  int? get daysRemaining =>
      date_math.daysRemaining(institution.subscriptionExpiry);

  bool get isExpiringSoon =>
      date_math.isExpiringSoon(institution.subscriptionExpiry);

  AccessGateKind get gateKind {
    switch (accessMode) {
      // 'blocked' is only ever written for schools that have never completed
      // a first payment - the lifecycle sweep always uses 'readOnly' for a
      // lapsed renewal, never 'blocked'. See rejectManualPayment/
      // approveManualPayment in payments.js.
      case AccessMode.blocked:
        return AccessGateKind.initialPaymentRequired;
      case AccessMode.readOnly:
        return _isSchoolAdmin
            ? AccessGateKind.renewalReadOnly
            : AccessGateKind.renewalBlocked;
      case AccessMode.full:
        return AccessGateKind.none;
    }
  }
}
