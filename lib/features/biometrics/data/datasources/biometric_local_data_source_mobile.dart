import 'package:isar/isar.dart';
import '../../domain/entities/biometric_template.dart';
import '../models/biometric_template_isar.dart';
import 'biometric_local_data_source.dart';

BiometricLocalDataSource create({dynamic isar, dynamic remote}) =>
    BiometricLocalDataSourceImpl(isar as Isar);

BiometricTemplate _toPlain(BiometricTemplateIsar t) => BiometricTemplate(
  personId: t.personId,
  schoolId: t.schoolId,
  personType: t.personType,
  encryptedTemplate: t.encryptedTemplate,
  updatedAt: t.updatedAt,
  isSynced: t.isSynced,
);

BiometricTemplateIsar _toIsar(BiometricTemplate t) => BiometricTemplateIsar()
  ..personId = t.personId
  ..schoolId = t.schoolId
  ..personType = t.personType
  ..encryptedTemplate = t.encryptedTemplate
  ..updatedAt = t.updatedAt
  ..isSynced = t.isSynced;

class BiometricLocalDataSourceImpl implements BiometricLocalDataSource {
  final Isar isar;

  BiometricLocalDataSourceImpl(this.isar);

  @override
  Future<void> saveTemplate(BiometricTemplate template) async {
    await isar.writeTxn(() async {
      await isar.biometricTemplateIsars.put(_toIsar(template));
    });
  }

  @override
  Future<BiometricTemplate?> getTemplate(String personId) async {
    final found = await isar.biometricTemplateIsars
        .filter()
        .personIdEqualTo(personId)
        .findFirst();
    return found == null ? null : _toPlain(found);
  }

  @override
  Future<List<BiometricTemplate>> getPendingSyncTemplates() async {
    final found = await isar.biometricTemplateIsars
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
    return found.map(_toPlain).toList();
  }

  @override
  Future<void> markTemplateAsSynced(String personId) async {
    await isar.writeTxn(() async {
      final template = await isar.biometricTemplateIsars
          .filter()
          .personIdEqualTo(personId)
          .findFirst();
      if (template != null) {
        template.isSynced = true;
        await isar.biometricTemplateIsars.put(template);
      }
    });
  }

  @override
  Future<void> clearAllTemplates() async {
    await isar.writeTxn(() async {
      await isar.biometricTemplateIsars.clear();
    });
  }
}
