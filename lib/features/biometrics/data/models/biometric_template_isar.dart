import 'package:isar/isar.dart';

part 'biometric_template_isar.g.dart';

@collection
class BiometricTemplateIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String personId;

  late String schoolId;
  late String personType; // 'student' or 'staff'
  late String encryptedTemplate;
  late DateTime updatedAt;
  late bool isSynced;

  BiometricTemplateIsar();
}
