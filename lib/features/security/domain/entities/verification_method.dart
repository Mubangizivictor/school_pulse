/// The verification methods a gate can require, per the admin-configurable
/// security spec. Stored on Gate.requiredVerificationMethods as raw string
/// values (`.id`) so they round-trip through Firestore/Isar without an enum
/// codec.
enum VerificationMethod {
  qrStudentId('qr_student_id', 'QR Student ID'),
  digitalId('digital_id', 'Student Digital ID'),
  fingerprint('fingerprint', 'Fingerprint'),
  manualSearch('manual_search', 'Manual Search'),
  parentCode('parent_code', 'Parent Code Verification'),
  visitorPass('visitor_pass', 'Visitor Pass'),
  staffId('staff_id', 'Staff ID');

  final String id;
  final String label;
  const VerificationMethod(this.id, this.label);

  static VerificationMethod? fromId(String id) {
    for (final method in VerificationMethod.values) {
      if (method.id == id) return method;
    }
    return null;
  }
}

/// The gate types an admin can choose from when creating a gate. Stored as
/// the raw label string on Gate.type - kept as a plain list (not an enum)
/// since admins may want custom gate names later; this just seeds sensible
/// defaults in the picker.
const List<String> kGateTypes = [
  'Main Entrance',
  'Student Gate',
  'Staff Gate',
  'Boarding Gate',
  'Visitor Gate',
  'Transport Gate',
  'Emergency Gate',
  'Sports Gate',
];
