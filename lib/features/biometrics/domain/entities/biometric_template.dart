/// Plain (non-Isar) version of the fingerprint template cache record - see
/// biometric_template_isar.dart (mobile-only now) for the persisted shape.
class BiometricTemplate {
  String personId;
  String schoolId;
  String personType; // 'student' or 'staff'
  String encryptedTemplate;
  DateTime updatedAt;
  bool isSynced;

  BiometricTemplate({
    required this.personId,
    required this.schoolId,
    required this.personType,
    required this.encryptedTemplate,
    required this.updatedAt,
    required this.isSynced,
  });
}
