enum RelationshipType {
  parent,
  guardian,
  sponsor,
  foster,
  relative,
  caregiver,
  institutionAppointed,
  custom,
}

/// Locking/history model: once `active`, a relationship is never edited or
/// hard-deleted. Reallocation supersedes it with a new doc (see
/// ReallocateRelationship) rather than mutating the old one in place, so
/// the chain of who held access to a student when stays fully auditable.
enum RelationshipStatus {
  active,
  superseded,
  revoked,
}

enum EnrolmentStatus { active, ended }
