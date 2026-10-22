/// Owner-only notification taxonomy.
///
/// Deliberately standalone: it shares nothing with the School Admin /
/// Teacher / Parent / Student / DOS / Bursar / Gatekeeper notification
/// enums, categories or filters. These values only ever describe a document
/// in the owner feed (`super_admin_notifications`).
library;

/// The owner-facing grouping a notification belongs to. Drives the tonal
/// icon square, the optional severity chip and the filter chips on the
/// Owner Notifications screen.
enum OwnerNotificationCategory {
  /// Manual / subscription payment awaiting the owner's review. Amber cash.
  billing,

  /// Platform health / incident. Red pulse only when degraded; green pulse
  /// when operational.
  platform,

  /// School onboarding / application / custom-domain request. Blue school.
  schools,

  /// Security-center event for the owner. Green shield.
  security,

  /// Digest / system information. Muted-grey report.
  digest;

  /// Wire token used by the feed document (`category` field) and by the
  /// preference callable's per-category toggles.
  String get wire {
    switch (this) {
      case OwnerNotificationCategory.billing:
        return 'billing';
      case OwnerNotificationCategory.platform:
        return 'platform';
      case OwnerNotificationCategory.schools:
        return 'schools';
      case OwnerNotificationCategory.security:
        return 'security';
      case OwnerNotificationCategory.digest:
        return 'digest';
    }
  }

  static OwnerNotificationCategory fromWire(String? value) {
    switch (value) {
      case 'billing':
      case 'payment':
      case 'payments':
        return OwnerNotificationCategory.billing;
      case 'platform':
      case 'platform_health':
      case 'incident':
        return OwnerNotificationCategory.platform;
      case 'schools':
      case 'school':
      case 'application':
      case 'onboarding':
      case 'domain':
        return OwnerNotificationCategory.schools;
      case 'security':
        return OwnerNotificationCategory.security;
      case 'digest':
      case 'system':
      case 'information':
        return OwnerNotificationCategory.digest;
      default:
        return OwnerNotificationCategory.digest;
    }
  }
}

/// The severity/status chip shown on a tile (only for critical / requires
/// review) and always on the detail screen.
enum OwnerNotificationSeverity {
  /// `REQUIRES REVIEW` - an owner decision is pending (e.g. a manual payment).
  requiresReview,

  /// `CRITICAL` - a degraded platform / security event.
  critical,

  /// `INFORMATION` - nothing to do; digests and confirmations.
  information,

  /// `RESOLVED` - the underlying item has been dealt with.
  resolved;

  String get label {
    switch (this) {
      case OwnerNotificationSeverity.requiresReview:
        return 'REQUIRES REVIEW';
      case OwnerNotificationSeverity.critical:
        return 'CRITICAL';
      case OwnerNotificationSeverity.information:
        return 'INFORMATION';
      case OwnerNotificationSeverity.resolved:
        return 'RESOLVED';
    }
  }

  /// A tile only shows a chip for the two attention-grabbing severities.
  bool get showsOnTile =>
      this == OwnerNotificationSeverity.requiresReview ||
      this == OwnerNotificationSeverity.critical;

  static OwnerNotificationSeverity fromWire(String? value) {
    switch (value) {
      case 'requires_review':
      case 'requiresReview':
      case 'action_required':
        return OwnerNotificationSeverity.requiresReview;
      case 'critical':
      case 'severe':
        return OwnerNotificationSeverity.critical;
      case 'resolved':
      case 'done':
        return OwnerNotificationSeverity.resolved;
      case 'information':
      case 'info':
        return OwnerNotificationSeverity.information;
      default:
        return OwnerNotificationSeverity.information;
    }
  }
}

/// The compact horizontal filter chips on the Owner Notifications screen.
enum OwnerNotificationFilter {
  all,
  critical,
  billing,
  platform,
  schools,
  security;

  String get label {
    switch (this) {
      case OwnerNotificationFilter.all:
        return 'All';
      case OwnerNotificationFilter.critical:
        return 'Critical';
      case OwnerNotificationFilter.billing:
        return 'Billing';
      case OwnerNotificationFilter.platform:
        return 'Platform';
      case OwnerNotificationFilter.schools:
        return 'Schools';
      case OwnerNotificationFilter.security:
        return 'Security';
    }
  }
}
