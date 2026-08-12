/// Server-authoritative subscription access state for a school tenant.
///
/// Written by Cloud Functions (payment approval, hourly lifecycle sweep) on
/// the `schools/{schoolId}` document and mirrored into [InstitutionContext].
/// Firestore rules trust this field directly; Flutter must treat it the
/// same way rather than re-deriving access from raw dates wherever possible.
enum AccessMode {
  full,
  readOnly,
  blocked;

  static AccessMode fromRaw(String? raw) {
    switch (raw) {
      case 'readOnly':
        return AccessMode.readOnly;
      case 'blocked':
        return AccessMode.blocked;
      case 'full':
        return AccessMode.full;
      default:
        // No value yet: school predates this field being written server-side.
        // Callers should fall back to date-derived logic, not assume full.
        return AccessMode.full;
    }
  }
}
