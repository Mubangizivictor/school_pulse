/// Pure date-math shared by [SubscriptionAccessResolver] (tenant-side gating)
/// and the SaaS Owner's school list/overview screens (owner-side reporting),
/// so "is this school expired" is computed in exactly one place instead of
/// being re-derived inline on every screen that shows a subscription date.
library;

bool isExpired(DateTime? expiry, {DateTime? now}) {
  if (expiry == null) return false;
  return !expiry.isAfter(now ?? DateTime.now());
}

/// Whole days remaining until [expiry], clamped to zero once expired. Null
/// when there is no expiry to measure against (e.g. pre-activation).
int? daysRemaining(DateTime? expiry, {DateTime? now}) {
  if (expiry == null) return null;
  final effectiveNow = now ?? DateTime.now();
  final diff = expiry.difference(effectiveNow).inDays;
  return diff < 0 ? 0 : diff;
}

bool isExpiringSoon(
  DateTime? expiry, {
  DateTime? now,
  int withinDays = 7,
}) {
  if (expiry == null) return false;
  final effectiveNow = now ?? DateTime.now();
  if (!expiry.isAfter(effectiveNow)) return false;
  return expiry.difference(effectiveNow).inDays <= withinDays;
}
